# Api Gameplay

Fetched from the official HappinessMP documentation on 2026-07-12.

## Source pages

- [Game](https://happinessmp.net/docs/scripting/functions/game)
- [Player](https://happinessmp.net/docs/scripting/functions/player)
- [WebUI](https://happinessmp.net/docs/scripting/functions/webui)

---

# Game

On the client side, in addition to the other functions, the so-called [native functions](https://gtamods.com/wiki/Native_function) are also available, i.e. functions that are originally used in the game scripts.

To use them, simply transform the names into the camelCase format. This involves capitalizing the first letter of each word after the initial word and removing underscores, resulting in a more readable and conventional naming style.

List of native functions: [HappinessMP GitHub](https://github.com/HappinessMP/natives), [GTAMods Wiki](https://gtamods.com/wiki/List_of_native_functions_(GTA_IV))

Example:

- Lua
- Squirrel

```lua
Thread.Create(function()
    while true do
        Thread.Pause(0)

        -- This code spawns a SultanRS when the player presses the F1 key.
        if Game.IsGameKeyboardKeyJustPressed(59) then
            local model = Game.GetHashKey("SULTANRS")

            local x, y, z = Game.GetCharCoordinates(Game.GetPlayerChar(Game.GetPlayerId()))
            local heading = Game.GetCharHeading(Game.GetPlayerChar(Game.GetPlayerId()))

            Game.RequestModel(model)

            while not Game.HasModelLoaded(model) do
                Thread.Pause(0)
            end

            local car = Game.CreateCar(model, x, y, z, true)
            Game.SetCarHeading(car, heading)
            Game.SetCarOnGroundProperly(car)

            Game.WarpCharIntoCar(Game.GetPlayerChar(Game.GetPlayerId()), car)

            Game.MarkModelAsNoLongerNeeded(model)
            Game.MarkCarAsNoLongerNeeded(car)
        end
    end
end)
```

```squirrel
Thread.Create(function() {
    while (true) {
        Thread.Pause(0);

        // This code spawns a SultanRS when the player presses the F1 key.
        if (Game.IsGameKeyboardKeyJustPressed(59)) {
            local model = Game.GetHashKey("SULTANRS");

            local pos = Game.GetCharCoordinates(Game.GetPlayerChar(Game.GetPlayerId()));
            local heading = Game.GetCharHeading(Game.GetPlayerChar(Game.GetPlayerId()));

            Game.RequestModel(model);

            while (!Game.HasModelLoaded(model)) {
                Thread.Pause(0);
            }

            local car = Game.CreateCar(model, pos[0], pos[1], pos[2], true);
            Game.SetCarHeading(car, heading);
            Game.SetCarOnGroundProperly(car);

            Game.WarpCharIntoCar(Game.GetPlayerChar(Game.GetPlayerId()), car);

            Game.MarkModelAsNoLongerNeeded(model);
            Game.MarkCarAsNoLongerNeeded(car);
        }
    }
});
```

Source: https://happinessmp.net/docs/scripting/functions/game


---

# Player

## Quick Reference

| Name | Type | Description |
| --- | --- | --- |
| [GetServerID](https://happinessmp.net/docs/scripting/functions/player#getserverid) | Client | Gets serverID from any playerID. |
| [GetIDFromServerID](https://happinessmp.net/docs/scripting/functions/player#getidfromserverid) | Client | Gets playerID from any serverID. |
| [GetRockstarID](https://happinessmp.net/docs/scripting/functions/player#getrockstarid) | Client | Gets rockstarID of local player. |
| [IsConnected](https://happinessmp.net/docs/scripting/functions/player#isconnected) | Server | Returns if player is connected. |
| [SetName](https://happinessmp.net/docs/scripting/functions/player#setname) | Server | Sets name of a player. |
| [GetName](https://happinessmp.net/docs/scripting/functions/player#getname) | Server | Gets name of a player. |
| [GetPing](https://happinessmp.net/docs/scripting/functions/player#getping) | Server | Gets ping of a player. |
| [GetIP](https://happinessmp.net/docs/scripting/functions/player#getip) | Server | Gets ip address of a player. |
| [Kick](https://happinessmp.net/docs/scripting/functions/player#kick) | Server | Kicks a specified player. |
| [SetSession](https://happinessmp.net/docs/scripting/functions/player#setsession) | Server | Sets session of a player. |
| [GetSession](https://happinessmp.net/docs/scripting/functions/player#getsession) | Server | Gets session of a player. |
| [IsSessionActive](https://happinessmp.net/docs/scripting/functions/player#issessionactive) | Server | Returns whether a player is active in their session. |

## Client Functions

### GetServerID

Get serverID from any playerID.

`int serverID = Player.GetServerID(int playerID)`

> **Warning**
>
> This function only works for players who are in the same session as the local player.

Example:

- Lua
- Squirrel

```lua
Events.Subscribe("chatCommand", function(command)
    if command == "/myserverid" then
        local playerID = Game.GetPlayerId()

        Chat.AddMessage("My serverID: " .. Player.GetServerID(playerID))
    end
end)
```

```squirrel
Events.Subscribe("chatCommand", function(command) {
    if (command == "/myserverid") {
        local playerID = Game.GetPlayerId();

        Chat.AddMessage("My serverID: " + Player.GetServerID(playerID));
    }
});
```

### GetIDFromServerID

Get playerID from any serverID.

`int playerID = Player.GetIDFromServerID(int serverID)`

> **Warning**
>
> This function only works for players who are in the same session as the local player.

Example:

- Lua
- Squirrel

```lua
Events.Subscribe("chatCommand", function(command)
    if command == "/testid" then
        local playerID = Game.GetPlayerId()
        local serverID = Player.GetServerID(playerID)
        local playerID2 = Player.GetIDFromServerID(serverID)

        if playerID == playerID2 then
            Chat.AddMessage("GetIDFromServerID works!")
        end
    end
end)
```

```squirrel
Events.Subscribe("chatCommand", function(command) {
    if (command == "/testid") {
        local playerID = Game.GetPlayerId();
        local serverID = Player.GetServerID(playerID);
        local playerID2 = Player.GetIDFromServerID(serverID);

        if (playerID == playerID2) {
            Chat.AddMessage("GetIDFromServerID works!");
        }
    }
});
```

### GetRockstarID

Get rockstarID of local player.

`int rockstarID = Player.GetRockstarID()`

> **Tip**
>
> You can use this ID as a unique identifier to assign data or ban players.

Example:

- Lua
- Squirrel

```lua
Events.Subscribe("chatCommand", function(command)
    if command == "/myrockstarid" then
        Chat.AddMessage("My rockstarID: " .. Player.GetRockstarID())
    end
end)
```

```squirrel
Events.Subscribe("chatCommand", function(command) {
    if (command == "/myrockstarid") {
        Chat.AddMessage("My rockstarID: " + Player.GetRockstarID());
    }
});
```

## Server Functions

### IsConnected

Returns if player is connected.

`bool connected = Player.IsConnected(int serverID)`

### SetName

Sets name of a player.

`Player.SetName(int serverID, string name)`

### GetName

Gets name of a player.

`string name = Player.GetName(int serverID)`

Example:

- Lua
- Squirrel

```lua
Events.Subscribe("testEvent", function()
    local source = Events.GetSource()

    Console.Log(Player.GetName(source) .. " called testEvent!")
end, true)
```

```squirrel
Events.Subscribe("testEvent", function() {
    local source = Events.GetSource();

    Console.Log(Player.GetName(source) + " called testEvent!");
}, true);
```

### GetPing

Gets ping of a player.

`int ping = Player.GetPing(int serverID)`

Example:

- Lua
- Squirrel

```lua
-- in client script:
Events.Subscribe("chatCommand", function(command)
    if command == "/myping" then
        Events.CallRemote("commandMyPing", {})
    end
end)

-- in server script:
Events.Subscribe("commandMyPing", function()
    local source = Events.GetSource()

    Chat.SendMessage(source, "Your ping is: {0000FF}" .. Player.GetPing(source))
end, true)
```

```squirrel
// in client script:
Events.Subscribe("chatCommand", function(command) {
    if (command == "/myping") {
        Events.CallRemote("commandMyPing", []);
    }
});

// in server script:
Events.Subscribe("commandMyPing", function() {
    local source = Events.GetSource();

    Chat.SendMessage(source, "Your ping is: {0000FF}" + Player.GetPing(source));
}, true);
```

### GetIP

Gets ip address of a player.

`string ip = Player.GetIP(int serverID)`

### Kick

Kicks a specified player.

`Player.Kick(int serverID, [optional] string reason)`

> **Note**
>
> If you want to send a chat message to the player before the kick, you have to create a thread and delay the kick by 1 second, otherwise the message will not reach the player.

Example:

- Lua
- Squirrel

```lua
-- in client script:
Events.Subscribe("chatCommand", function(command)
    if command == "/kickme" then
        Events.CallRemote("commandKickMe", {})
    end
end)

-- in server script:
Events.Subscribe("commandKickMe", function()
    Player.Kick(Events.GetSource())
end, true)
```

```squirrel
// in client script:
Events.Subscribe("chatCommand", function(command) {
    if (command == "/kickme") {
        Events.CallRemote("commandKickMe", []);
    }
});

// in server script:
Events.Subscribe("commandKickMe", function() {
    Player.Kick(Events.GetSource());
}, true);
```

### SetSession

Sets session of a player.

`Player.SetSession(int serverID, int sessionID)`

> **Note**
>
> Valid session ids are from 0-65535. 0 is the default session.

> **Warning**
>
> This function only sets which session the player should be in, it does not mean that he is currently in it. Use [IsSessionActive](https://happinessmp.net/docs/scripting/functions/player#issessionactive) to check this.

Example:

- Lua
- Squirrel

```lua
-- in client script:
Events.Subscribe("chatCommand", function(command)
    if command == "/privatesession" then
        Events.CallRemote("commandSession", { true })
    elseif command == "/publicsession" then
        Events.CallRemote("commandSession", { false })
    end
end)

-- in server script:
Events.Subscribe("commandSession", function(private)
    local source = Events.GetSource()

    if private then
        Player.SetSession(source, source)
    else
        Player.SetSession(source, 0)
    end
end, true)
```

```squirrel
// in client script:
Events.Subscribe("chatCommand", function(command) {
    if (command == "/privatesession") {
        Events.CallRemote("commandSession", [ true ]);
    }
    else if (command == "/publicsession") {
        Events.CallRemote("commandSession", [ false ]);
    }
});

// in server script:
Events.Subscribe("commandSession", function(private) {
    local source = Events.GetSource();

    if (private) Player.SetSession(source, source);
    else Player.SetSession(source, 0);
}, true);
```

### GetSession

Gets session of a player.

`int sessionID = Player.GetSession(int serverID)`

> **Warning**
>
> This function only gets which session the player should be in, it does not mean that he is currently in it. Use [IsSessionActive](https://happinessmp.net/docs/scripting/functions/player#issessionactive) to check this.

Example:

- Lua
- Squirrel

```lua
-- in client script:
Events.Subscribe("chatCommand", function(command)
    if command == "/mysession" then
        Events.CallRemote("commandMySession", {})
    end
end)

-- in server script:
Events.Subscribe("commandMySession", function()
    local source = Events.GetSource()

    Chat.SendMessage(source, "My sessionID: " .. Player.GetSession(source))
end, true)
```

```squirrel
// in client script:
Events.Subscribe("chatCommand", function(command) {
    if (command == "/mysession") {
        Events.CallRemote("commandMySession", []);
    }
});

// in server script:
Events.Subscribe("commandMySession", function() {
    local source = Events.GetSource();

    Chat.SendMessage(source, "My sessionID: " + Player.GetSession(source));
}, true);
```

### IsSessionActive

Returns whether a player is active in their session.

`bool active = Player.IsSessionActive(int serverID)`

> **Note**
>
> For example, a player is not active in his session if he is currently switching or lost the connection.

Example:

- Lua
- Squirrel

```lua
-- in client script:
Events.Subscribe("chatCommand", function(command)
    if command == "/privatesession" then
        Events.CallRemote("commandSession", { true })
    elseif command == "/publicsession" then
        Events.CallRemote("commandSession", { false })
    end
end)

-- in server script:
Events.Subscribe("commandSession", function(private)
    local source = Events.GetSource()

    if private then
        Player.SetSession(source, source)
    else
        Player.SetSession(source, 0)
    end

    Thread.Create(function()
        while not Player.IsSessionActive(source) do
            Thread.Pause(50)

            if Player.IsSessionActive(source) then
                Chat.BroadcastMessage(Player.GetName(source) .. " switched the session!")
            end
        end
    end)
end, true)
```

```squirrel
// in client script:
Events.Subscribe("chatCommand", function(command) {
    if (command == "/privatesession") {
        Events.CallRemote("commandSession", [ true ]);
    }
    else if (command == "/publicsession") {
        Events.CallRemote("commandSession", [ false ]);
    }
});

// in server script:
Events.Subscribe("commandSession", function(private) {
    local source = Events.GetSource();

    if (private) Player.SetSession(source, source);
    else Player.SetSession(source, 0);

    Thread.Create(function() {
        while (!Player.IsSessionActive(source)) {
            Thread.Pause(50);

            if (Player.IsSessionActive(source)) {
                Chat.BroadcastMessage(Player.GetName(source) + " switched the session!");
            }
        }
    });
}, true);
```

Source: https://happinessmp.net/docs/scripting/functions/player


---

# WebUI

WebUIs utilize CEF (Chromium Embedded Framework) to render HTML pages directly inside the game. This provides an easy and straightforward way to create modern, beautiful user interfaces using standard web technologies (HTML, CSS, JavaScript).

## Quick Reference

| Name | Type | Description |
| --- | --- | --- |
| [Create](https://happinessmp.net/docs/scripting/functions/webui#create) | Client | Creates a WebUI. |
| [Destroy](https://happinessmp.net/docs/scripting/functions/webui#destroy) | Client | Destroys a WebUI. |
| [CallEvent](https://happinessmp.net/docs/scripting/functions/webui#callevent) | Client | Calls an event on the WebUIs javascript. |
| [SetFocus](https://happinessmp.net/docs/scripting/functions/webui#setfocus) | Client | Sets focus on a WebUI (mouse & keyboard input). |
| [SetRect](https://happinessmp.net/docs/scripting/functions/webui#setrect) | Client | Changes the size of the WebUI sprite. |
| [IsReady](https://happinessmp.net/docs/scripting/functions/webui#isready) | Client | Returns whether the specified WebUI is ready. |

## Client Functions

### Create

Creates a WebUI.

`int webuiID = WebUI.Create(string url, int width, int height, [optional] bool transparent)`

> **Info**
>
> To use a local resource file in the url argument, use "file://[resource]/[file]". Note that the file must be specified in the [meta file](https://happinessmp.net/docs/scripting/resource/#meta-file).

Example:

- Lua
- Squirrel

```lua
Events.Subscribe("chatCommand", function(command)
    if command == "/webui" then
        local testWebUI = WebUI.Create("file://freeroam/webui/index.html", 1920, 1080, true)
    end
end)
```

```squirrel
Events.Subscribe("chatCommand", function(command) {
    if (command == "/webui") {
        local testWebUI = WebUI.Create("file://freeroam/webui/index.html", 1920, 1080, true);
    }
});
```

### Destroy

Destroys a WebUI.

`WebUI.Destroy(int webuiID)`

### CallEvent

Calls an event on the WebUIs javascript.

`WebUI.CallEvent(int webuiID, string name, [optional] list arguments)`

> **Warning**
>
> Events may not be called until the WebUI is [ready](https://happinessmp.net/docs/scripting/functions/webui#isready).

Example:

- Lua
- Squirrel

```lua
-- in client script:
Events.Subscribe("chatCommand", function(command)
    if command == "/webuievent" then
        WebUI.CallEvent(g_webUI, "testEvent", { 3 })
    end
end)

-- in js script:
Events.Subscribe("testEvent", function(testint)
{
    console.log("testEvent was called: " + testint);
});
```

```squirrel
// in client script:
Events.Subscribe("chatCommand", function(command) {
    if (command == "/webuievent") {
        WebUI.CallEvent(g_webUI, "testEvent", [ 3 ]);
    }
});

// in js script:
Events.Subscribe("testEvent", function(testint)
{
    console.log("testEvent was called: " + testint);
});
```

### SetFocus

Sets focus on a WebUI (mouse & keyboard input).

`WebUI.SetFocus(int webuiID, [optional] bool keepGameInput)`

> **Info**
>
> The current implementation only allows you to focus on one WebUI at a time. **Use -1 as webuiID to reset the focus.**

### SetRect

Changes the size and screen placement of the WebUI sprite.

`WebUI.SetRect(int webuiID, int left, int top, int right, int bottom)`

> **Info**
>
> While `Create` defines the internal rendering resolution of the browser, `SetRect` defines where and how large the WebUI is actually drawn on the player's screen using bounding box coordinates.

### IsReady

Returns whether the specified WebUI is ready.

`bool ready = WebUI.IsReady(int webuiID)`

Source: https://happinessmp.net/docs/scripting/functions/webui

