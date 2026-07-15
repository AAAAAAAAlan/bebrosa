---@class VehicleProfile
---@field name string Driver-facing model name used by telemetry.
---@field idleRpm number Approximate idle speed used to convert normalized native revs to RPM.
---@field redlineRpm number Approximate maximum engine speed used for the RPM display.

---@class VehicleProfileOverride
---@field name? string Optional telemetry name replacement.
---@field idleRpm? number Optional model-specific idle RPM.
---@field redlineRpm? number Optional model-specific redline RPM.

---@class VehicleTransmissionState
---@field vehicle number HappinessMP handle of the car currently controlled by this client.
---@field profile VehicleProfile Resolved generic or model-specific display profile.
---@field selectedGear number Manual selection: -1 is reverse, 0 is neutral, and positive values are forward gears.
---@field highGear number Highest native forward gear accepted for this car.
---@field originalHighGear number Native high-gear value restored when manual control ends.
---@field ratios table<number, number> Original native ratio for reverse/standing gear 0 and every forward gear.
---@field ratiosDisconnected boolean Whether ratios currently contain the synthetic clutch value.
---@field clutchPressed boolean Current frame's clutch input state.
---@field previousClutchPressed boolean Previous frame's clutch state, used to detect release.
---@field engineRunning boolean Resource-owned ignition state because no documented getter is available.
---@field stalled boolean Whether the most recent engine stop was caused by drivetrain load.
---@field status string Temporary telemetry status text.
---@field statusUntil number Game timer at which temporary status text expires.
---@field shiftLockedUntil number Game timer before another shift attempt is accepted.
---@field stallCandidateSince number|nil Time at which stationary in-gear load first became stall-worthy.
---@field stallGraceUntil number Grace-period end after clutch release.

--- Immutable resource settings loaded first from config.lua.
---@type table
local config <const> = VehicleSystemConfig

--- Model-hash keyed explicit profile overrides, such as the Sentinel calibration.
---@type table<number, VehicleProfileOverride>
local vehicleOverrides = {}

--- Model-hash keyed resolved profiles; caching avoids classification and allocation every frame.
---@type table<number, VehicleProfile>
local vehicleProfiles = {}

--- Set of non-car or invalid-drivetrain model hashes that must remain on vanilla handling.
---@type table<number, boolean>
local invalidVehicleModels = {}

--- Runtime state for the one car currently driven by the local player.
---@type VehicleTransmissionState|nil
local active = nil

--- Handle of the always-visible CEF telemetry browser.
---@type number|nil
local webui = nil

--- Prevents WebUI events from being sent before CEF has loaded the page.
---@type boolean
local webuiReady = false

--- Game timer of the latest telemetry event, used to enforce the configured update rate.
---@type number
local lastUiUpdate = 0

--- Serialized previous telemetry payload, used to suppress duplicate WebUI updates.
---@type string|nil
local lastUiSnapshot = nil

--- Restricts a numeric value to an inclusive range.
--- Centralizing this keeps gear bounds and normalized telemetry calculations readable.
---@param value number Value to constrain.
---@param minimum number Lowest permitted value.
---@param maximum number Highest permitted value.
---@return number constrainedValue
local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

--- Reports whether a value is a usable finite Lua number.
--- Native drivetrain data is validated with this before it can modify a vehicle.
---@param value any Value returned by a native or supplied by configuration.
---@return boolean isFinite
local function isFiniteNumber(value)
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

--- Checks that a vehicle handle is non-nil and still owned by the game.
--- Handles can become stale after deletion, streaming changes, or resource shutdown.
---@param vehicle number|nil HappinessMP vehicle handle.
---@return boolean exists
local function vehicleExists(vehicle)
    return vehicle ~= nil and Game.DoesVehicleExist(vehicle)
end

--- Sets a temporary status message for the active vehicle.
--- Timed statuses keep input errors visible without permanently replacing READY or STALLED.
---@param text string Text sent to the debug WebUI.
---@param duration number Visibility duration in milliseconds.
local function setStatus(text, duration)
    if active == nil then
        return
    end

    active.status = text
    active.statusUntil = Game.GetGameTimer() + duration
end

--- Resolves the status that should currently be shown by the debug WebUI.
--- Persistent drivetrain state is used after any transient message expires.
---@return string status
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

--- Converts the internal gear number into a driver-facing label.
--- The state machine uses -1 for reverse and 0 for synthetic neutral.
---@param gear number Internal selected gear.
---@return string label
local function gearLabel(gear)
    if gear == -1 then
        return "R"
    elseif gear == 0 then
        return "N"
    end

    return tostring(gear)
end

--- Restores every native ratio captured before manual control began.
--- This prevents the synthetic clutch ratio from leaking into vanilla handling.
---@param state table Active vehicle transmission state.
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

--- Replaces captured ratios with a tiny nonzero value to disconnect engine drive.
--- GTA IV has no documented neutral setter, so this implements clutch and neutral behavior.
---@param state table Active vehicle transmission state.
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

--- Releases the currently managed vehicle and restores its original drivetrain data.
--- It is called on exit, driver changes, unsupported models, and resource shutdown.
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

--- Validates and captures one car before enabling manual transmission control.
--- Returning false leaves unfamiliar or malformed vehicle models on vanilla handling.
---@param vehicle number HappinessMP vehicle handle.
---@param profile table Resolved RPM and display profile for the model.
---@return boolean captured
local function captureVehicle(vehicle, profile)
    -- The native value defines how many forward positions this particular model supports.
    local highGear = Game.GetVehicleHighGear(vehicle)
    local highGearIsValid = isFiniteNumber(highGear)
        and highGear == math.floor(highGear)
        and highGear >= config.transmission.minimumHighGear
        and highGear <= config.transmission.maximumHighGear

    if not highGearIsValid then
        return false
    end

    -- Preserve every native ratio before the synthetic clutch is allowed to replace them.
    ---@type table<number, number>
    local ratios = {}
    for gear = 0, highGear do
        local ratio = Game.GetVehicleGearRatio(vehicle, gear)
        if not isFiniteNumber(ratio) or math.abs(ratio) <= config.transmission.disconnectedRatio then
            return false
        end

        ratios[gear] = ratio
    end

    releaseActiveVehicle()

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

    return true
end

--- Resolves and caches a manual-transmission profile for a GTA IV car model.
--- Explicit model overrides win; otherwise the generic car profile is used.
---@param model number GTA IV model hash.
---@return table|nil profile Nil for bikes, boats, aircraft, trains, or rejected models.
local function resolveCarProfile(model)
    if invalidVehicleModels[model] then
        return nil
    end

    if vehicleProfiles[model] ~= nil then
        return vehicleProfiles[model]
    end

    if not Game.IsThisModelACar(model) then
        invalidVehicleModels[model] = true
        return nil
    end

    local defaults = config.defaultCarProfile
    local override = vehicleOverrides[model] or {}
    local displayName = Game.GetDisplayNameFromVehicleModel(model)

    local profile = {
        name = override.name or displayName or "CAR",
        idleRpm = override.idleRpm or defaults.idleRpm,
        redlineRpm = override.redlineRpm or defaults.redlineRpm
    }

    vehicleProfiles[model] = profile
    return profile
end

--- Finds the local player's current car only when they occupy its driver seat.
--- Restricting work to the local driver avoids modifying AI, passengers, or world vehicles.
---@return number|nil vehicle
---@return table|nil profile
---@return number|nil model
local function getSupportedDrivenVehicle()
    local playerChar = Game.GetPlayerChar(Game.GetPlayerId())
    if not Game.IsCharSittingInAnyCar(playerChar) then
        return nil, nil
    end

    local vehicle = Game.GetCarCharIsUsing(playerChar)
    if not vehicleExists(vehicle) or Game.GetDriverOfCar(vehicle) ~= playerChar then
        return nil, nil
    end

    local model = Game.GetCarModel(vehicle)
    return vehicle, resolveCarProfile(model), model
end

--- Activates, switches, or releases manual control as the local driver changes vehicles.
--- Invalid native gear data is cached by model so failed capture is not retried every frame.
local function updateActiveVehicle()
    local vehicle, profile, model = getSupportedDrivenVehicle()

    if vehicle == nil or profile == nil then
        releaseActiveVehicle()
        return
    end

    if active == nil or active.vehicle ~= vehicle then
        if not captureVehicle(vehicle, profile) then
            releaseActiveVehicle()
            invalidVehicleModels[model] = true
            Console.Log("vehicle-system: leaving model " .. tostring(model) .. " on vanilla handling because its gear data is invalid")
        end
    end
end

--- Attempts to move the selected gearbox position by one step.
--- Clutchless attempts are rejected and produce the configured grind feedback and lockout.
---@param direction number Use 1 to shift up or -1 to shift down.
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

--- Toggles the active car's engine when clutch is held and neutral is selected.
--- Requiring neutral prevents ignition changes from bypassing the stall model.
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

--- Samples clutch, ignition, and sequential shift keys for the current frame.
--- It also starts the post-clutch stall grace period on clutch release.
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

--- Applies synthetic clutch/neutral ratios and reasserts the selected physical gear.
--- Reassertion prevents GTA IV's automatic gearbox from silently choosing another gear.
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

--- Prevents W/S from driving through zero in a direction forbidden by the selected gear.
--- Braking and neutral coasting remain available; only the zero-speed crossover is clamped.
local function enforceSelectedDirection()
    if active == nil then
        return
    end

    local _, forwardSpeed = Game.GetCarSpeedVector(active.vehicle, true)
    local acceleratePressed = Game.IsGameKeyboardKeyPressed(config.keys.accelerate)
    local brakeReversePressed = Game.IsGameKeyboardKeyPressed(config.keys.brakeReverse)
    local lockSpeed = config.transmission.directionLockSpeed
    local disconnected = active.clutchPressed or active.selectedGear == 0
    local forbidden = false

    if disconnected then
        -- Preserve coasting in neutral or with the clutch down, but stop W/S
        -- from creating drive as the vehicle reaches zero.
        forbidden = math.abs(forwardSpeed) <= lockSpeed
            and (acceleratePressed or brakeReversePressed)
    elseif active.selectedGear == -1 then
        -- In reverse, W remains available as a brake while rolling backward.
        forbidden = acceleratePressed and forwardSpeed >= -lockSpeed
    else
        -- In a forward gear, S remains available as a brake while moving ahead.
        forbidden = brakeReversePressed and forwardSpeed <= lockSpeed
    end

    if forbidden then
        Game.SetCarForwardSpeed(active.vehicle, 0.0)
    end
end

--- Stalls a running engine that remains near stationary in gear with the clutch released.
--- The timer and grace period avoid false stalls during a valid clutch-assisted launch.
local function updateStall()
    if active == nil or not active.engineRunning then
        if active ~= nil then
            active.stallCandidateSince = nil
        end
        return
    end

    local now = Game.GetGameTimer()
    local speed = math.abs(Game.GetCarSpeed(active.vehicle))
    local shouldStall = active.selectedGear ~= 0
        and not active.clutchPressed
        and now >= active.stallGraceUntil
        and speed < config.transmission.stallSpeed

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

--- Builds the compact primitive telemetry payload consumed by the WebUI.
--- Primitive return values avoid relying on table serialization across the CEF event bridge.
---@return string vehicleName
---@return string gear
---@return number rpm
---@return string ratio
---@return string clutch
---@return string engine
---@return string status
---@return number signedSpeedKmh
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
    local _, forwardSpeed = Game.GetCarSpeedVector(active.vehicle, true)
    local speedKmh = forwardSpeed * 3.6
    local speed = speedKmh >= 0 and math.floor(speedKmh + 0.5) or math.ceil(speedKmh - 0.5)

    return active.profile.name,
        gearLabel(active.selectedGear),
        rpm,
        ratioText,
        active.clutchPressed and "PRESSED" or "RELEASED",
        engineText,
        currentStatus(),
        speed
end

--- Sends telemetry to CEF at a limited rate and suppresses identical snapshots.
--- This keeps the always-visible widget inexpensive compared with the per-frame physics loop.
---@param force boolean When true, bypass rate and duplicate checks for initial display.
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

--- Creates and positions the transparent, non-focused vehicle debug WebUI.
--- The widget never takes keyboard focus, so transmission controls continue reaching the game.
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

--- Destroys the WebUI and clears readiness/snapshot state.
--- Resetting all local state makes resource restarts create a clean browser instance.
local function destroyWebUI()
    if webui == nil then
        return
    end

    WebUI.Destroy(webui)
    webui = nil
    webuiReady = false
    lastUiSnapshot = nil
end

--- Hashes configured model-name overrides once for constant-time runtime profile lookup.
--- Generic cars do not need entries because resolveCarProfile supplies the default profile.
local function initializeVehicleOverrides()
    for modelName, profile in pairs(config.vehicleOverrides) do
        vehicleOverrides[Game.GetHashKey(modelName)] = profile
    end
end

--- Initializes caches/UI and starts the client-side vehicle management loop.
--- scriptInit runs after the client has joined and all resource scripts are loaded.
Events.Subscribe("scriptInit", function()
    initializeVehicleOverrides()
    createWebUI()

    --- Runs manual transmission physics and telemetry for the local driver every frame.
    --- Only the current driven car is touched, so enabling all car models does not scan the world.
    Thread.Create(function()
        while true do
            updateActiveVehicle()
            updateInput()
            applyTransmission()
            enforceSelectedDirection()
            updateStall()
            updateWebUI(false)
            Thread.Pause(0)
        end
    end)
end)

--- Marks this resource's CEF instance ready and immediately publishes initial telemetry.
---@param webuiId number WebUI handle supplied by HappinessMP.
Events.Subscribe("webUIReady", function(webuiId)
    if webuiId == webui then
        webuiReady = true
        updateWebUI(true)
    end
end)

--- Restores the active drivetrain and removes all resource-owned client objects on shutdown.
---@param resourceName string Name of the resource being stopped.
Events.Subscribe("resourceStop", function(resourceName)
    if resourceName ~= config.resourceName then
        return
    end

    releaseActiveVehicle()
    destroyWebUI()
end)
