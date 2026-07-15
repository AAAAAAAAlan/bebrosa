local config <const> = VehicleSystemConfig

local supportedVehicles = {}
local active = nil

local webui = nil
local webuiReady = false
local lastUiUpdate = 0
local lastUiSnapshot = nil

local debugVehicle = nil
local debugSpawnStarted = false
local debugSpawned = false

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function vehicleExists(vehicle)
    return vehicle ~= nil and Game.DoesVehicleExist(vehicle)
end

local function setStatus(text, duration)
    if active == nil then
        return
    end

    active.status = text
    active.statusUntil = Game.GetGameTimer() + duration
end

local function currentStatus()
    if active == nil then
        return "INACTIVE"
    end

    if active.statusUntil > Game.GetGameTimer() then
        return active.status
    end

    if active.stalled then
        return "STALLED"
    end

    return "READY"
end

local function gearLabel(gear)
    if gear == -1 then
        return "R"
    elseif gear == 0 then
        return "N"
    end

    return tostring(gear)
end

local function restoreRatios(state)
    if not state.ratiosDisconnected or not vehicleExists(state.vehicle) then
        return
    end

    for gear = 0, state.highGear do
        local ratio = state.ratios[gear]
        if ratio ~= nil then
            Game.SetVehicleGearRatio(state.vehicle, gear, ratio)
        end
    end

    state.ratiosDisconnected = false
end

local function disconnectRatios(state)
    if state.ratiosDisconnected or not vehicleExists(state.vehicle) then
        return
    end

    for gear = 0, state.highGear do
        if state.ratios[gear] ~= nil then
            Game.SetVehicleGearRatio(state.vehicle, gear, config.transmission.disconnectedRatio)
        end
    end

    state.ratiosDisconnected = true
end

local function releaseActiveVehicle()
    if active == nil then
        return
    end

    restoreRatios(active)

    if vehicleExists(active.vehicle) then
        Game.SetVehicleHighGear(active.vehicle, active.originalHighGear)
    end

    active = nil
end

local function captureVehicle(vehicle, profile)
    releaseActiveVehicle()

    local highGear = Game.GetVehicleHighGear(vehicle)
    if highGear == nil or highGear < 1 then
        highGear = profile.fallbackHighGear
    end

    local ratios = {}
    for gear = 0, highGear do
        ratios[gear] = Game.GetVehicleGearRatio(vehicle, gear)
    end

    active = {
        vehicle = vehicle,
        profile = profile,
        selectedGear = 0,
        highGear = highGear,
        originalHighGear = highGear,
        ratios = ratios,
        ratiosDisconnected = false,
        clutchPressed = false,
        previousClutchPressed = false,
        engineRunning = false,
        stalled = false,
        status = "READY",
        statusUntil = 0,
        shiftLockedUntil = 0,
        stallCandidateSince = nil,
        stallGraceUntil = 0
    }

    disconnectRatios(active)
    Game.SetVehicleGear(vehicle, 1)
    Game.SetCarEngineOn(vehicle, false, true)
end

local function getSupportedDrivenVehicle()
    local playerChar = Game.GetPlayerChar(Game.GetPlayerId())
    if not Game.IsCharSittingInAnyCar(playerChar) then
        return nil, nil
    end

    local vehicle = Game.GetCarCharIsUsing(playerChar)
    if not vehicleExists(vehicle) or Game.GetDriverOfCar(vehicle) ~= playerChar then
        return nil, nil
    end

    return vehicle, supportedVehicles[Game.GetCarModel(vehicle)]
end

local function updateActiveVehicle()
    local vehicle, profile = getSupportedDrivenVehicle()

    if vehicle == nil or profile == nil then
        releaseActiveVehicle()
        return
    end

    if active == nil or active.vehicle ~= vehicle then
        captureVehicle(vehicle, profile)
    end
end

local function shift(direction)
    local now = Game.GetGameTimer()
    if active == nil or now < active.shiftLockedUntil then
        return
    end

    if not active.clutchPressed then
        active.shiftLockedUntil = now + config.transmission.shiftLockMs
        setStatus("GRIND", config.transmission.grindStatusMs)
        return
    end

    active.selectedGear = clamp(active.selectedGear + direction, -1, active.highGear)
    active.stallCandidateSince = nil
end

local function toggleIgnition()
    if active == nil or not active.clutchPressed then
        return
    end

    if active.selectedGear ~= 0 then
        setStatus("SELECT N", config.transmission.messageStatusMs)
        return
    end

    active.engineRunning = not active.engineRunning
    active.stalled = false
    active.stallCandidateSince = nil

    Game.SetCarEngineOn(active.vehicle, active.engineRunning, true)
    setStatus(active.engineRunning and "ENGINE START" or "ENGINE STOP", config.transmission.messageStatusMs)
end

local function updateInput()
    if active == nil then
        return
    end

    active.previousClutchPressed = active.clutchPressed
    active.clutchPressed = Game.IsGameKeyboardKeyPressed(config.keys.clutch)

    if active.previousClutchPressed and not active.clutchPressed then
        active.stallGraceUntil = Game.GetGameTimer() + config.transmission.stallGraceMs
    end

    if Game.IsGameKeyboardKeyJustPressed(config.keys.ignition) then
        toggleIgnition()
    end

    if Game.IsGameKeyboardKeyJustPressed(config.keys.shiftUp) then
        shift(1)
    elseif Game.IsGameKeyboardKeyJustPressed(config.keys.shiftDown) then
        shift(-1)
    end
end

local function applyTransmission()
    if active == nil then
        return
    end

    local disconnected = active.clutchPressed or active.selectedGear == 0

    if disconnected then
        disconnectRatios(active)

        -- Gear zero is GTA IV's reverse/standing gear, not neutral. Keep the
        -- physical gearbox in first while the tiny ratios disconnect drive.
        Game.SetVehicleGear(active.vehicle, 1)
    else
        restoreRatios(active)
        Game.SetVehicleGear(active.vehicle, active.selectedGear == -1 and 0 or active.selectedGear)
    end

    if not active.engineRunning then
        -- GTA may try to start the engine automatically after entering a car.
        Game.SetCarEngineOn(active.vehicle, false, true)
    end
end

local function updateStall()
    if active == nil or not active.engineRunning then
        if active ~= nil then
            active.stallCandidateSince = nil
        end
        return
    end

    local now = Game.GetGameTimer()
    local speed = math.abs(Game.GetCarSpeed(active.vehicle))
    local revs = Game.GetVehicleEngineRevs(active.vehicle)
    local shouldStall = active.selectedGear ~= 0
        and not active.clutchPressed
        and now >= active.stallGraceUntil
        and speed < config.transmission.stallSpeed
        and revs <= config.transmission.stallRevs

    if not shouldStall then
        active.stallCandidateSince = nil
        return
    end

    if active.stallCandidateSince == nil then
        active.stallCandidateSince = now
        return
    end

    if now - active.stallCandidateSince >= config.transmission.stallDelayMs then
        active.engineRunning = false
        active.stalled = true
        active.stallCandidateSince = nil
        Game.SetCarEngineOn(active.vehicle, false, true)
    end
end

local function telemetry()
    if active == nil then
        return "INACTIVE", "-", 0, "-", "RELEASED", "OFF", "INACTIVE", 0
    end

    local rawRevs = active.engineRunning and Game.GetVehicleEngineRevs(active.vehicle) or 0
    local normalizedRevs = clamp(rawRevs, 0, 1)
    local rpm = active.engineRunning
        and math.floor(active.profile.idleRpm + normalizedRevs * (active.profile.redlineRpm - active.profile.idleRpm) + 0.5)
        or 0

    local ratio = nil
    if active.selectedGear == -1 then
        ratio = active.ratios[0]
    elseif active.selectedGear > 0 then
        ratio = active.ratios[active.selectedGear]
    end

    local ratioText = ratio == nil and "-" or string.format("%.4f", ratio)
    local engineText = active.stalled and "STALLED" or (active.engineRunning and "RUNNING" or "OFF")
    local speed = math.floor(math.abs(Game.GetCarSpeed(active.vehicle)) * 3.6 + 0.5)

    return active.profile.name,
        gearLabel(active.selectedGear),
        rpm,
        ratioText,
        active.clutchPressed and "PRESSED" or "RELEASED",
        engineText,
        currentStatus(),
        speed
end

local function updateWebUI(force)
    if webui == nil then
        return
    end

    if not webuiReady then
        webuiReady = WebUI.IsReady(webui)
        if not webuiReady then
            return
        end
    end

    local now = Game.GetGameTimer()
    if not force and now - lastUiUpdate < config.ui.updateMs then
        return
    end

    lastUiUpdate = now

    local vehicle, gear, rpm, ratio, clutch, engine, status, speed = telemetry()
    local snapshot = table.concat({ vehicle, gear, rpm, ratio, clutch, engine, status, speed }, "|")

    if not force and snapshot == lastUiSnapshot then
        return
    end

    lastUiSnapshot = snapshot
    WebUI.CallEvent(webui, "vehicleSystem:update", {
        vehicle, gear, rpm, ratio, clutch, engine, status, speed
    })
end

local function createWebUI()
    if webui ~= nil then
        return
    end

    webui = WebUI.Create(config.ui.url, config.ui.width, config.ui.height, true)
    WebUI.SetRect(
        webui,
        config.ui.left,
        config.ui.top,
        config.ui.left + config.ui.width,
        config.ui.top + config.ui.height
    )
end

local function destroyWebUI()
    if webui == nil then
        return
    end

    WebUI.Destroy(webui)
    webui = nil
    webuiReady = false
    lastUiSnapshot = nil
end

local function spawnDebugVehicle()
    if debugSpawnStarted or debugSpawned or not config.debugVehicle.enabled then
        return
    end

    debugSpawnStarted = true

    local model = Game.GetHashKey(config.debugVehicle.model)
    if not Game.IsModelInCdimage(model) then
        Console.Log("vehicle-system: invalid debug vehicle model " .. config.debugVehicle.model)
        debugSpawnStarted = false
        return
    end

    Game.RequestModel(model)
    while not Game.HasModelLoaded(model) do
        Game.RequestModel(model)
        Thread.Pause(0)
    end

    local playerChar = Game.GetPlayerChar(Game.GetPlayerId())
    local x, y, z = Game.GetCharCoordinates(playerChar)
    local heading = Game.GetCharHeading(playerChar)
    local radians = math.rad(heading)

    -- GTA headings use local right as this horizontal perpendicular.
    x = x + math.cos(radians) * config.debugVehicle.rightOffset
    y = y - math.sin(radians) * config.debugVehicle.rightOffset

    debugVehicle = Game.CreateCar(model, x, y, z, true)
    Game.SetCarHeading(debugVehicle, heading)
    Game.SetCarOnGroundProperly(debugVehicle)
    Game.SetVehicleDirtLevel(debugVehicle, 0.0)
    Game.WashVehicleTextures(debugVehicle, 255)
    Game.SetCarEngineOn(debugVehicle, false, true)

    Game.MarkModelAsNoLongerNeeded(model)

    debugSpawned = true
    debugSpawnStarted = false
end

local function destroyDebugVehicle()
    if vehicleExists(debugVehicle) then
        Game.DeleteCar(debugVehicle)
    end

    debugVehicle = nil
end

local function initializeSupportedVehicles()
    for modelName, profile in pairs(config.vehicles) do
        supportedVehicles[Game.GetHashKey(modelName)] = profile
    end
end

Events.Subscribe("scriptInit", function()
    initializeSupportedVehicles()
    createWebUI()

    Thread.Create(function()
        while true do
            updateActiveVehicle()
            updateInput()
            applyTransmission()
            updateStall()
            updateWebUI(false)
            Thread.Pause(0)
        end
    end)

    -- playerSpawn is the normal path. This fallback also supports restarting
    -- vehicle-system while the player is already alive.
    Thread.Create(function()
        Thread.Pause(config.debugVehicle.fallbackDelayMs)

        while config.debugVehicle.enabled do
            local playerId = Game.GetPlayerId()
            local playerChar = Game.GetPlayerChar(playerId)

            if Game.IsNetworkPlayerActive(playerId) and not Game.IsCharFatallyInjured(playerChar) then
                break
            end

            Thread.Pause(250)
        end

        spawnDebugVehicle()
    end)
end)

Events.Subscribe("playerSpawn", function()
    Thread.Create(spawnDebugVehicle)
end)

Events.Subscribe("webUIReady", function(webuiId)
    if webuiId == webui then
        webuiReady = true
        updateWebUI(true)
    end
end)

Events.Subscribe("resourceStop", function(resourceName)
    if resourceName ~= config.resourceName then
        return
    end

    releaseActiveVehicle()
    destroyDebugVehicle()
    destroyWebUI()
end)
