# Api Core

Fetched from the official HappinessMP documentation on 2026-07-12.

## Source pages

- [Chat](https://happinessmp.net/docs/scripting/functions/chat)
- [Console](https://happinessmp.net/docs/scripting/functions/console)
- [Events](https://happinessmp.net/docs/scripting/functions/events)
- [Resource](https://happinessmp.net/docs/scripting/functions/resource)
- [Server](https://happinessmp.net/docs/scripting/functions/server)
- [Session](https://happinessmp.net/docs/scripting/functions/session)

---

# Chat

> **Note**
>
> This functions can only be used if the default chat is activated in the server settings.

## Quick Reference

| Name | Type | Description |
| --- | --- | --- |
| [AddMessage](https://happinessmp.net/docs/scripting/functions/chat#addmessage) | Client | Adds a message to the chat. |
| [Clear](https://happinessmp.net/docs/scripting/functions/chat#clear) | Client | Clears all messages. |
| [IsInputActive](https://happinessmp.net/docs/scripting/functions/chat#isinputactive) | Client | Returns whether the chat input is open. |
| [SendMessage](https://happinessmp.net/docs/scripting/functions/chat#sendmessage) | Server | Sends a message to the specified player. |
| [BroadcastMessage](https://happinessmp.net/docs/scripting/functions/chat#broadcastmessage) | Server | Sends a message to all players. |

## Client Functions

### AddMessage

Adds a message to the chat.

`Chat.AddMessage(string message)`

> **Warning**
>
> Remember that this is a client function and the message is therefore only displayed for the client who executed the code.

> **Tip**
>
> You can change the text color of message parts by placing a hex color code in a curly bracket in front of it. See the example below.

Example:

- Lua
- Squirrel

```lua
Events.Subscribe("scriptInit", function()
    Chat.AddMessage("{0000FF}This part is blue. {FFFFFF}And this part is white.")
end)
```

```squirrel
Events.Subscribe("scriptInit", function() {
    Chat.AddMessage("{0000FF}This part is blue. {FFFFFF}And this part is white.");
});
```

### Clear

Clears all messages.

`Chat.Clear()`

### IsInputActive

Returns whether the chat input is open.

`bool inputActive = Chat.IsInputActive()`

## Server Functions

### SendMessage

Sends a message to the specified player.

`Chat.SendMessage(int serverID, string message)`

> **Tip**
>
> You can change the text color of message parts by placing a hex color code in a curly bracket in front of it. See the example below.

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

### BroadcastMessage

Sends a message to all players.

`Chat.BroadcastMessage(string message)`

> **Tip**
>
> You can change the text color of message parts by placing a hex color code in a curly bracket in front of it. See the example below.

Example:

- Lua
- Squirrel

```lua
Events.Subscribe("playerDisconnect", function(id, name, reason)
    Chat.BroadcastMessage("{0000FF}" .. name .. " {FFFFFF}has left the server.")
end)
```

```squirrel
Events.Subscribe("playerDisconnect", function(id, name, reason) {
    Chat.BroadcastMessage("{0000FF}" + name + " {FFFFFF}has left the server.");
});
```

Source: https://happinessmp.net/docs/scripting/functions/chat


---

# Console

## Quick Reference

| Name | Type | Description |
| --- | --- | --- |
| [Log](https://happinessmp.net/docs/scripting/functions/console#log) | Shared | Prints a message to the console and the log file. |

## Shared Functions

### Log

Prints a message to the console and the log file.

`Console.Log(string message)`

Example:

- Lua
- Squirrel

```lua
Events.Subscribe("playerDisconnect", function(id, name, reason)
    Console.Log("Player " .. name .. " has left the server with reason " .. reason .. ".")
end)
```

```squirrel
Events.Subscribe("playerDisconnect", function(id, name, reason) {
    Console.Log("Player " + name + " has left the server with reason " + reason + ".");
});
```

Source: https://happinessmp.net/docs/scripting/functions/console


---

# Events

## Quick Reference

| Name | Type | Description |
| --- | --- | --- |
| [Subscribe](https://happinessmp.net/docs/scripting/functions/events#subscribe) | Shared | Subscribe to an event with a callback function. |
| [Call](https://happinessmp.net/docs/scripting/functions/events#call) | Shared | Calls an event which will trigger all local subscribers. |
| [CallRemote](https://happinessmp.net/docs/scripting/functions/events#callremote) | Shared | Calls an event which will trigger all subscribers on remote side. |
| [Cancel](https://happinessmp.net/docs/scripting/functions/events#cancel) | Shared | Cancel the current executed event. |
| [WasLastCanceled](https://happinessmp.net/docs/scripting/functions/events#waslastcanceled) | Shared | Checks if last completed event was canceled. |
| [BroadcastRemote](https://happinessmp.net/docs/scripting/functions/events#broadcastremote) | Server | Calls an event which will trigger all subscribers on client side for all players. |
| [GetSource](https://happinessmp.net/docs/scripting/functions/events#getsource) | Server | Gets the server ID of the player from which the last event was triggered. |

## Shared Functions

### Subscribe

Subscribe to an event with a callback function.

`Events.Subscribe(string name, function callbackFunc, [optional] bool isRemoteAllowed)`

Example:

- Lua
- Squirrel

```lua
Events.Subscribe("testEvent", function(testint, teststr)
    Console.Log("testEvent triggered: " .. testint .. ", " .. teststr)
end, false)
```

```squirrel
Events.Subscribe("testEvent", function(testint, teststr) {
    Console.Log("testEvent triggered: " + testint + ", " + teststr);
}, false);
```

### Call

Calls an event which will immediately trigger all local subscribers.

`bool success = Events.Call(string name, [optional] list arguments)`

> **Warning**
>
> With this function, you can only call events on the same side.
> **Client -> Client** or **Server -> Server**

> **Info**
>
> The return value will be false if the event was canceled.

Example:

- Lua
- Squirrel

```lua
Events.Call("testEvent", { 2, "meow" })
```

```squirrel
Events.Call("testEvent", [ 2, "meow" ]);
```

### CallRemote

Calls an event which will trigger all subscribers on remote side.

`Events.CallRemote(string name, [server only] int serverID, [optional] list arguments)`

> **Warning**
>
> With this function, you can only call events on the remote side.
> **Client -> Server** or **Server -> Client**

Example:

- Lua
- Squirrel

```lua
-- in client script:
Events.CallRemote("serverEvent", { 1, true })

-- in server script:
Events.CallRemote("clientEvent", playerid, { 1, true })
```

```squirrel
// in client script:
Events.CallRemote("serverEvent", [ 1, true ]);

// in server script:
Events.CallRemote("clientEvent", playerid, [ 1, true ]);
```

### Cancel

Cancel the current executed event.

`Events.Cancel()`

> **Warning**
>
> This function does not stop further event handlers from being called.

> **Note**
>
> The use of this function outside of an event callback has no effect.

### WasLastCanceled

Checks if last completed event was canceled.

`bool canceled = Events.WasLastCanceled()`

## Server Functions

### BroadcastRemote

Calls an event which will trigger all subscribers on client side for all players.

`Events.BroadcastRemote(string name, [optional] list arguments)`

Example:

- Lua
- Squirrel

```lua
Events.BroadcastRemote("clientEvent", { 1, "meow" })
```

```squirrel
Events.BroadcastRemote("clientEvent", [ 1, "meow" ]);
```

### GetSource

Gets the server ID of the player from which the last event was triggered.

`int serverID = Events.GetSource()`

> **Warning**
>
> The function may only be used in server events called from the client side.

Example:

- Lua
- Squirrel

```lua
Events.Subscribe("testEvent", function()
    local source = Events.GetSource()

    Console.Log("testEvent was called from " .. Player.GetName(source))
end, true)
```

```squirrel
Events.Subscribe("testEvent", function() {
    local source = Events.GetSource();

    Console.Log("testEvent was called from " + Player.GetName(source));
}, true);
```

Source: https://happinessmp.net/docs/scripting/functions/events


---

# Resource

## Quick Reference

| Name | Type | Description |
| --- | --- | --- |
| [GetState](https://happinessmp.net/docs/scripting/functions/resource#getstate) | Shared | Returns the state of the specified resource. |
| [GetCurrentName](https://happinessmp.net/docs/scripting/functions/resource#getcurrentname) | Shared | Returns the name of the currently executing resource. |
| [Call](https://happinessmp.net/docs/scripting/functions/resource#call) | Shared | Calls an exported function in the specified resource. |
| [Start](https://happinessmp.net/docs/scripting/functions/resource#start) | Server | Start a resource. |
| [Stop](https://happinessmp.net/docs/scripting/functions/resource#stop) | Server | Stop a resource. |
| [Restart](https://happinessmp.net/docs/scripting/functions/resource#restart) | Server | Restart a resource. |

## Shared Functions

### GetState

Returns the state of the specified resource.

`string state = Resource.GetState(string resource)`

> **Info**
>
> Possible states are:
>
> "unknown"
>
> "started"
>
> "loaded"
>
> "stopped"

### GetCurrentName

Returns the name of the currently executing resource.

`string resource = Resource.GetCurrentName()`

### Call

Calls an exported function in the specified resource.

`Resource.Call(string resource, string function, list arguments)`

Example:

- Lua
- Squirrel

```lua
Resource.Call("myResource", "myFunction", { 8, 16 })
```

```squirrel
Resource.Call("myResource", "myFunction", [ 8, 16 ]);
```

## Server Functions

### Start

Start a resource. The returned Boolean indicates whether the action was successful.

`bool success = Resource.Start(string name)`

### Stop

Stop a resource. The returned Boolean indicates whether the action was successful.

`bool success = Resource.Stop(string name)`

> **Info**
>
> The resource does not stop immediately, but only at the next resource tick.

### Restart

Restart a resource. The returned Boolean indicates whether the action was successful.

`bool success = Resource.Restart(string name)`

> **Info**
>
> The resource does not restart immediately, but only at the next resource tick.

Source: https://happinessmp.net/docs/scripting/functions/resource


---

# Server

## Quick Reference

| Name | Type | Description |
| --- | --- | --- |
| [Stop](https://happinessmp.net/docs/scripting/functions/server#stop) | Server | Stops the server. |
| [Restart](https://happinessmp.net/docs/scripting/functions/server#restart) | Server | Restarts the server. |
| [GetName](https://happinessmp.net/docs/scripting/functions/server#getname) | Server | Returns the server name. |
| [SetName](https://happinessmp.net/docs/scripting/functions/server#setname) | Server | Sets the name of the server. |
| [GetMaxPlayers](https://happinessmp.net/docs/scripting/functions/server#getmaxplayers) | Server | Returns the max players configured. |
| [SetMaxPlayers](https://happinessmp.net/docs/scripting/functions/server#setmaxplayers) | Server | Sets the maximum player slots of the server. |
| [GetVersion](https://happinessmp.net/docs/scripting/functions/server#getversion) | Server | Returns the server version. |

## Server Functions

### Stop

Stops the server and shows all players the specified reason (optional).

`Server.Stop([optional] string reason)`

### Restart

Restarts the server and reconnect all players.

`Server.Restart()`

### GetName

Returns the server name.

`string name = Server.GetName()`

### SetName

Sets the name of the server.

`Server.SetName(string name)`

### GetMaxPlayers

Returns the max players configured.

`int maxPlayers = Server.GetMaxPlayers()`

### SetMaxPlayers

Sets the maximum player slots of the server.

`Server.SetMaxPlayers(int maxPlayers)`

### GetVersion

Returns the server version.

`string version = Server.GetVersion()`

Source: https://happinessmp.net/docs/scripting/functions/server


---

# Session

## Quick Reference

| Name | Type | Description |
| --- | --- | --- |
| [GetSize](https://happinessmp.net/docs/scripting/functions/session#getsize) | Server | Gets the number of players in a session. |
| [GetHostID](https://happinessmp.net/docs/scripting/functions/session#gethostid) | Server | Gets the serverID of a session host. |
| [GetActivePlayers](https://happinessmp.net/docs/scripting/functions/session#getactiveplayers) | Server | Gets the active players of a session. |

## Server Functions

### GetSize

Gets the number of players in a session.

`int size = Session.GetSize(int sessionID)`

> **Warning**
>
> This function also returns players who are assigned to the session but are not yet active.

Example:

- Lua
- Squirrel

```lua
-- in client script:
Events.Subscribe("chatCommand", function(command)
    if command == "/playercount" then
        Events.CallRemote("cmdPlayerCount", {})
    end
end)

-- in server script:
Events.Subscribe("cmdPlayerCount", function()
    local source = Events.GetSource()

    Chat.SendMessage(source, "Current players in your session: " .. Session.GetSize(Player.GetSession(source)))
end, true)
```

```squirrel
// in client script:
Events.Subscribe("chatCommand", function(command) {
    if (command == "/playercount") {
        Events.CallRemote("cmdPlayerCount", []);
    }
});

// in server script:
Events.Subscribe("cmdPlayerCount", function() {
    local source = Events.GetSource();

    Chat.SendMessage(source, "Current players in your session: " + Session.GetSize(Player.GetSession(source)));
}, true);
```

### GetHostID

Gets the serverID of a session host.

`int serverID = Session.GetHostID(int sessionID)`

Example:

- Lua
- Squirrel

```lua
-- in client script:
Events.Subscribe("chatCommand", function(command)
    if command == "/host" then
        Events.CallRemote("cmdHost", {})
    end
end)

-- in server script:
Events.Subscribe("cmdHost", function()
    local source = Events.GetSource()

    Chat.SendMessage(source, "Current host of your session: " .. Session.GetHostID(Player.GetSession(source)))
end, true)
```

```squirrel
// in client script:
Events.Subscribe("chatCommand", function(command) {
    if (command == "/host") {
        Events.CallRemote("cmdHost", []);
    }
});

// in server script:
Events.Subscribe("cmdHost", function() {
    local source = Events.GetSource();

    Chat.SendMessage(source, "Current host of your session: " + Session.GetHostID(Player.GetSession(source)));
}, true);
```

### GetActivePlayers

Gets the active players of a session.

`list activePlayers = Session.GetActivePlayers(int sessionID)`

> **Warning**
>
> This function only returns active players in the session.

Example:

- Lua
- Squirrel

```lua
-- in client script:
Events.Subscribe("chatCommand", function(command)
    if command == "/players" then
        Events.CallRemote("cmdPlayers", {})
    end
end)

-- in server script:
Events.Subscribe("cmdPlayers", function()
    local source = Events.GetSource()

    Chat.SendMessage(source, "Current players in your session:")

    for _, v in pairs(Session.GetActivePlayers(Player.GetSession(source))) do
        Chat.SendMessage(source, "- " .. Player.GetName(v) .. "(" .. v .. ")")
    end
end, true)
```

```squirrel
// in client script:
Events.Subscribe("chatCommand", function(command) {
    if (command == "/players") {
        Events.CallRemote("cmdPlayers", []);
    }
});

// in server script:
Events.Subscribe("cmdPlayers", function() {
    local source = Events.GetSource();
    local players = Session.GetActivePlayers(Player.GetSession(source));

    Chat.SendMessage(source, "Current players in your session:");

    foreach (i in players) {
        Chat.SendMessage(source, "- " + Player.GetName(i) + "(" + i + ")");
    }
}, true);
```

Source: https://happinessmp.net/docs/scripting/functions/session

