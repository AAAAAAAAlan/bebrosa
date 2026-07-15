local DEBUG_UI_URL <const> = "http://127.0.0.1:3000/"
local OPEN_KEY <const> = 23 -- I

local webui = nil

local function closeDebugUI()
    if webui == nil then
        return
    end

    WebUI.SetFocus(-1)
    WebUI.Destroy(webui)
    webui = nil
end

local function openDebugUI()
    if webui ~= nil then
        return
    end

    webui = WebUI.Create(DEBUG_UI_URL, 1920, 1080, true)
    WebUI.SetRect(webui, 0, 0, 1920, 1080)

    -- Give the browser exclusive input so gameplay and camera controls are locked.
    WebUI.SetFocus(webui, false)
end

Events.Subscribe("scriptInit", function()
    Thread.Create(function()
        while true do
            Thread.Pause(0)
            if webui == nil and Game.IsGameKeyboardKeyJustPressed(OPEN_KEY) then
                openDebugUI()
            end
        end
    end)
end)

Events.Subscribe("debugUI:close", function()
    closeDebugUI()
end)

Events.Subscribe("resourceStop", function(resourceName)
    if resourceName == "debug-ui" then
        closeDebugUI()
    end
end)
