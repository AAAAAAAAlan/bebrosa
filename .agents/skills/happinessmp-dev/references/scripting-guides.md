# Scripting Guides

Fetched from the official HappinessMP documentation on 2026-07-12.

## Source pages

- [Addon](https://happinessmp.net/docs/scripting/addon)
- [Events](https://happinessmp.net/docs/scripting/events)
- [Exports](https://happinessmp.net/docs/scripting/exports)
- [Resource](https://happinessmp.net/docs/scripting/resource)
- [WebUI](https://happinessmp.net/docs/scripting/webui)

---

# Addon

An addon is a way to modify or extend the game. For example, vehicles, peds, objects, or weapons can be replaced or added.

## Structure

The structure of an addon is represented by a dedicated folder inside the `addons` directory within the server files. This folder contains the [meta file](https://happinessmp.net/docs/scripting/addon#meta-file) (`meta.xml`) as well as a `stream` folder. The main folder includes the `meta.xml` and definition files such as `.dat` or `.ide`. The `stream` folder is reserved exclusively for streaming files, such as models or textures.

**Server Folder**

```treeview
HappinessMP.Server.exe
addons/
├── my-addon-01/
│	├── stream/
│	│   ├── police2.wft
│	│   └── police2.wtd
│	├── content.dat
│	├── items.ide
│	└── meta.xml
├── my-addon-02/
│	├── stream/
│	├── meta.xml
│	└── ...
resources/
settings.xml
```

## Meta File

The meta file is the configuration file of a addon. It defines which files are loaded and how they should be handled.

**meta.xml**

```xml
<meta>
  <file type="content" src="content.dat"/>

  <file src="items.ide"/>

  <stream src="*.wft"/>
  <stream src="*.wtd"/>

  <siren carmodel="newpolice" lights="1" />
</meta>
```

> **Tip**
>
> Both `<file>` and `<stream>` support glob patterns such as `*`, `**`, and `?`.
>
> This allows you to include multiple files or entire directories without listing each file individually.

- Use `<file>` elements to define files that should be downloaded by the client and loaded during startup.
  - Special file types include `content` and `audio` .
  - All files referenced through `<file>` are bundled into a single RPF archive.
- Use `<stream>` elements to specify files that are downloaded by the client and loaded dynamically by the streamer when needed.
- Use `<siren>` elements to set a siren for an added car model.
  - Lights: 0 = No Lights, 1 = Police, 2 = Ambulance, 3 = Fire Truck, 4-7 = Unknown

## Content File

Content data files are used to replace or add game files.

**content.dat**

```dat
IDE addons:/my-addon-01/items.ide

# Other usable tags:
# ANIMGRP (.dat)
# CARCOLS (.dat)
# CARGRP (.dat)
# PEDGRP (.dat)
# PEDVARS (.dat)
# HANDLING (.dat)
# TIMECYCLE (.dat)
# VEHICLEEXTRAS (.dat)
# PEDPERSONALITY (.dat)
# EXPLOSIONFX (.dat)
# PLSETTINGSMALE (.dat)
# PLSETTINGSFEMALE (.dat)
# PLSETTINGSLIGHT (.dat)
# RADIO (.dat)
# RADIOLOGOS (.dat)
# CREDITS (.dat)
# HUDCOLOR (.dat)
# SCROLLBAR (.dat)
# VISUALSETTINGS (.dat)
# MELEEANIMS (.dat)
# WEAPONFX (.dat)
# WATER (.dat)
# FONTDAT (.dat)
# FONTDATR (.dat)
# FONTTXD (.wtd)
# FONTTXDR (.wtd)
# FONTSTRTXD (.wtd)
# HUDDAT (.dat)
# HUDTXD (.wtd)
# RADARBLIPS (.wtd)
# FTXDFILE (.wtd)
# FMENUFILE (.xml)
# WEAPONINFO (.xml)
# THROWNWEAPONINFO (.xml)
# LBDATAFILE (.xml)
# LBICONSFILE (.wtd)
# TICKBOXFILE (.wtd)
# SAVEICON (.png)
# VEHOFF (.csv)
# ACTIONTABLE (.csv)
# IDE (.ide)
# DELAYED_IDE (.ide)
# IPL (.ipl)
# IMG (.img)
# IMGLIST (.txt)
# EPISODEVERSION (.txt)
# PLAYER (.rpf)
# RMPTFX (.wpfl)
# DISABLE_FILE 
```

## Stream Folder

Files loaded by game streamer are placed in the `stream` folder.

Valid file formats are: `wtd`, `nod`, `cut`, `wdr`, `wpl`, `wdd`, `rrr`, `sco`, `wnv`, `wad`, `wbn`, `wbd`, `wbs`, `wft`, `lod`, `nth`, `ipl`

Source: https://happinessmp.net/docs/scripting/addon


---

# Events

## Client Events

| Name | Description |
| --- | --- |
| [scriptInit](https://happinessmp.net/docs/scripting/events#scriptinit) | Called after the player has connected to the server, joined the default session for the first time and all scripts have been loaded. |
| [sessionInit](https://happinessmp.net/docs/scripting/events#sessioninit) | Called when the player has joined a session. |
| [sessionJoin](https://happinessmp.net/docs/scripting/events#sessionjoin) | Called for the host player when a player joins the session. |
| [sessionEnd](https://happinessmp.net/docs/scripting/events#sessionend) | Called when the player starts to leave the session. |
| [sessionFail](https://happinessmp.net/docs/scripting/events#sessionend) | Called when the player failed to host/join session. |
| [chatCommand](https://happinessmp.net/docs/scripting/events#chatcommand) | Called when a command is entered in the chat. |
| [chatSubmit](https://happinessmp.net/docs/scripting/events#chatsubmit) | Called when the player submits a message in the chat. |
| [webUIReady](https://happinessmp.net/docs/scripting/events#webuiready) | Called after the web page has been loaded successfully. |
| [windowFocusChange](https://happinessmp.net/docs/scripting/events#windowfocuschange) | Called when the game is focused/unfocused. |

## Server Events

| Name | Description |
| --- | --- |
| [playerDisconnect](https://happinessmp.net/docs/scripting/events#playerdisconnect) | Called when a player disconnects. |

## Shared Events

| Name | Description |
| --- | --- |
| [resourceStart](https://happinessmp.net/docs/scripting/events#resourcestart) | Called after a resource started. |
| [resourceStop](https://happinessmp.net/docs/scripting/events#resourcestop) | Called before a resource stops. |

### scriptInit

Called after the player has connected to the server, joined the default session for the first time and all scripts have been loaded.

`scriptInit()`

Example:

- Lua
- Squirrel

```lua
Events.Subscribe("scriptInit", function()
    Chat.AddMessage("Welcome to my server.")
end)
```

```squirrel
Events.Subscribe("scriptInit", function() {
    Chat.AddMessage("Welcome to my server.");
});
```

### sessionInit

Called when the player has joined a session.

`sessionInit()`

### sessionJoin

Called for the host player when a player joins the session.

`sessionJoin()`

### sessionEnd

Called when the player starts to leave the session.

`sessionEnd()`

### sessionFail

Called when the player failed to host/join session.

`sessionFail(int attempt)`

> **Info**
>
> You can cancel this event, to stop the default retry behaviour.

### chatCommand

Called when a command is entered in the chat.

`chatCommand(string fullChatMessage)`

> **Info**
>
> This event will be only called if the default chat is activated in the server settings.

Example:

- Lua
- Squirrel

```lua
Events.Subscribe("chatCommand", function(command)
    if command == "/testcmd" then
        Chat.AddMessage("Test Command!")
    end
end)
```

```squirrel
Events.Subscribe("chatCommand", function(command) {
    if (command == "/testcmd") {
        Chat.AddMessage("Test Command!");
    }
});
```

### chatSubmit

Called when the player submits a message in the chat.

`chatSubmit(string chatMessage)`

> **Info**
>
> You can cancel this event, to stop the message being sent.

Example:

- Lua
- Squirrel

```lua
Events.Subscribe("chatSubmit", function(message)
    if string.find(message, "bitch") ~= nil then
        Events.Cancel() -- don't send message with bad word
    end
end)
```

```squirrel
Events.Subscribe("chatSubmit", function(message) {
    if (message.find("bitch") != null) {
        Events.Cancel(); // don't send message with bad word
    }
});
```

### webUIReady

Called after the web page has been loaded successfully.

`webUIReady(int webuiID)`

### windowFocusChange

Called when the game is focused/unfocused.

`windowFocusChange(bool isFocused)`

### playerDisconnect

Called when a player disconnects.

`playerDisconnect(int serverID, string playerName, int reason)`

> **Info**
>
> Reason IDs:
>
> 0: timeout
>
> 1: quit
>
> 2: kick

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

### resourceStart

Called after a resource started.

`resourceStart(string resourceName)`

### resourceStop

Called before a resource stops.

`resourceStop(string resourceName)`

> **Info**
>
> If this event is canceled by a server-side handler, the resource is not stopped.

Source: https://happinessmp.net/docs/scripting/events


---

# Exports

You can export functions from a resource so that other resources can call them.

### Create exported function

First you have to make sure to define your function globally in your script:

- Lua
- Squirrel

```lua
function testExportFunc(arg1, arg2)
    Console.Log("testExportFunc called: " .. arg1 .. ", " .. arg2)
    return 400, 800
end
```

```squirrel
function testExportFunc(arg1, arg2)
{
    Console.Log("testExportFunc called: " + arg1 + ", " + arg2);
    return 400;
}
```

### Define exported function

You will then need to define it in the [meta file](https://happinessmp.net/docs/scripting/resource/#meta-file) of your resource:

- Lua
- Squirrel

```xml
<meta type="lua">
	<script type="server" src="server.lua" />
	<export type="server" function="testExportFunc" />
</meta>
```

```xml
<meta type="squirrel">
	<script type="server" src="server.nut" />
	<export type="server" function="testExportFunc" />
</meta>
```

### Call exported function

You can then call the function in several ways in any other resource:

- Lua
- Squirrel

```lua
local res1, res2 = Resource.Call("exporttest", "testExportFunc", { 8, 16 })
Console.Log("Result of testExportFunc: " .. res1 .. ", " .. res2)

res1, res2 = exports.exporttest:testExportFunc(8, 16)
Console.Log("Result of testExportFunc: " .. res1 .. ", " .. res2)

res1, res2 = exports["exporttest"]:testExportFunc(8, 16)
Console.Log("Result of testExportFunc: " .. res1 .. ", " .. res2)
```

```squirrel
local res = Resource.Call("exporttest", "testExportFunc", [ 8, 16 ]);
Console.Log("Result of testExportFunc: " + res);

res = exports.exporttest.testExportFunc(8, 16);
Console.Log("Result of testExportFunc: " + res);

res = exports["exporttest"].testExportFunc(8, 16);
Console.Log("Result of testExportFunc: " + res);
```

Source: https://happinessmp.net/docs/scripting/exports


---

# Resource

A resource is a collection of script files that enables interaction with the game. It can be started and stopped at any time during server operation.

## Structure

The structure is represented by a folder within the `resources` directory in the server files, accompanied by a [meta file](https://happinessmp.net/docs/scripting/resource#meta-file) (`meta.xml`). The meta file specifies the essential details about the resource. Inside this folder, you should organize all resource files as outlined in the meta file. The internal structure of the folder is flexible, allowing you to arrange files in a way that makes sense to you.

**Server Folder**

```treeview
HappinessMP.Server.exe
resources/
├── my-resource-01/
│	├── bank/
│	│   ├── cl_bank.lua
│	│   └── sv_bank.lua
│	├── client.lua
│	├── server.lua
│	└── meta.xml
├── my-resource-02/
│	├── meta.xml
│	└── ...
addons/
settings.xml
```

## Meta File

The meta file is the configuration file of a resource. It defines which files are loaded and how they should be handled.

**meta.xml**

```xml
<meta type="lua">
  <script type="client" src="cl_main.lua" />
  <script type="server" src="sv_main.lua" />

  <export type="client" function="myClientFunc" />
  <export type="server" function="myServerFunc" />

  <file src="UI/test.html" />
  <file src="UI/script.js" />
</meta>
```

> **Tip**
>
> Both `<script>` and `<file>` support glob patterns such as `*`, `**`, and `?`.
>
> This allows you to include multiple files or entire directories without listing each file individually.

- The **`<meta>`** element is used to specify the scripting language of the resource ( `lua` / `squirrel` ).
- Use **`<script>`** elements to specify the scripts to be loaded and define them as `client` / `server` or `shared` script.
  - Client scripts are stored encrypted in the server cache and are downloaded and executed by each connecting player.
  - Server scripts are executed exclusively by the server.
  - Shared scripts do both.
- Use **`<export>`** elements to export functions from this resource, so other resources can use them.
- With **`<file>`** elements, you can define files that are to be downloaded by the client in their raw version and are required at a later time. This is necessary for WebUIs, for example.

Source: https://happinessmp.net/docs/scripting/resource


---

# WebUI

A **WebUI** is essentially an in‑game browser that can display a custom website you’ve built using HTML, CSS, and JavaScript. It’s a powerful way to create GUI elements for your server quickly and flexibly.

## Preparing Your WebUI

The easiest workflow is:

1. Fully build and test your HTML page in your regular system browser.
2. Leave only the interfaces (functions, event hooks, etc.) open that will later communicate with your scripts or receive data.

## Adding the WebUI to Your Resource

For players to see your WebUI, they must download all required files when connecting to the server.

1. Place all your WebUI files in a dedicated folder inside your resource (e.g., `UI` ).
2. Define these files in your meta file so the client knows to download them:

```xml
<meta type="lua">
    <file src="UI/index.html" />
    <file src="UI/style.css" />
    <file src="UI/script.js" />
</meta>
```

## Creating the WebUI

Once the player has all the necessary files, you can create the WebUI at any time:

```lua
local l_webui = nil

Events.Subscribe("scriptInit", function()
    l_webui = WebUI.Create("file://myresource/UI/index.html", 1920, 1080, true)
end)
```

> **Info**
>
> When a WebUI is created, it is displayed immediately.
>
> The WebUI API is designed for **on‑demand** creation — you create it when you want to show it, and destroy it when it’s no longer needed.

> **Caution**
>
> Even if your WebUI consists of multiple files, you always create it using the **HTML file**. CSS and JS files should be loaded in the HTML using standard HTML syntax.

In the example above, the WebUI is created during the [scriptInit](https://happinessmp.net/docs/scripting/events#scriptinit) event — right when the player joins the server. The URL uses a local path, but external URLs are also supported.

**Local path format:**

```text
file://[RESOURCE_NAME]/[PATH_TO_HTML].html
```

## Communicating with Scripts

Communication between your script and the WebUI works via **events**, just like between regular scripts.

**From Lua to JavaScript:**

1. In your JavaScript file, subscribe to an event:

```js
Events.Subscribe("myJSEvent", function(arg1, arg2) {
    console.log("myJSEvent called!", arg1, arg2);
});
```

1. From Lua, trigger the event:

```lua
WebUI.CallEvent(l_webui, "myJSEvent", { "test", 11 })
```

> **Caution**
>
> If you want to send an event immediately after creating the WebUI, you must do it inside the [webUIReady](https://happinessmp.net/docs/scripting/events#webuiready) event — otherwise, the WebUI cannot receive events yet.

**From JavaScript to Lua:**

```js
Events.Call("myScriptEvent", [arg1, arg2]);
```

## Keyboard & Mouse Input

If your WebUI requires keyboard or mouse interaction (e.g., clicking buttons, typing text), you must first set focus to it:

```lua
WebUI.SetFocus(l_webui)
```

You can do this right after creation. Focus is **not** set automatically because some UIs (like a speedometer) don’t require input.

## Performance Tips

- The maximum WebUI size is currently **1080p (1920 × 1080)** .
- For best performance:
  - Limit the WebUI size to the actual element you need.
  - Use SetRect to position it precisely on the screen.

Source: https://happinessmp.net/docs/scripting/webui

