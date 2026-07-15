# Api Services

Fetched from the official HappinessMP documentation on 2026-07-12.

## Source pages

- [Database](https://happinessmp.net/docs/scripting/functions/database)
- [HTTP](https://happinessmp.net/docs/scripting/functions/http)
- [Text](https://happinessmp.net/docs/scripting/functions/text)
- [Thread](https://happinessmp.net/docs/scripting/functions/thread)
- [Timer](https://happinessmp.net/docs/scripting/functions/timer)

---

# Database

HappinessMP natively supports MySQL X and SQLite.

## Quick Reference

| Name | Type | Description |
| --- | --- | --- |
| [Connect](https://happinessmp.net/docs/scripting/functions/database#connect) | Server | Connects to the database server. |
| [Close](https://happinessmp.net/docs/scripting/functions/database#close) | Server | Closes the database connection. |
| [Execute](https://happinessmp.net/docs/scripting/functions/database#execute) | Server | Executes a SQL statement with given arguments. |
| [Select](https://happinessmp.net/docs/scripting/functions/database#select) | Server | Retrieves data based on a SQL query and arguments. |
| [Insert](https://happinessmp.net/docs/scripting/functions/database#insert) | Server | Inserts data into a table and returns the insert ID. |

## Server Functions

### Connect

Connects to the database server.

`Database.Connect(int type, string url)`

> **Info**
>
> The MySQL implementation is based on the X DevAPI. A MySQL server with X plugin is therefore required.

Example:

- Lua
- Squirrel

```lua
-- MySQL
Database.Connect(0, "mysqlx://user:password@host:port/database")

-- SQLite
Database.Connect(1, "database.db")
```

```squirrel
// MySQL
Database.Connect(0, "mysqlx://user:password@host:port/database");

// SQLite
Database.Connect(1, "database.db");
```

### Close

Closes the database connection.

`Database.Close()`

### Execute

This function executes a SQL statement using the provided arguments. It returns the number of rows affected by the execution.

Synchronous (blocking):

`int affectedRows = Database.Execute(string statement, list params)`

Asynchronous (non-blocking):

`Database.ExecuteAsync(string statement, list params, [optional] function callback)`

Example:

- Lua
- Squirrel

```lua
-- in client script:
Events.Subscribe("chatCommand", function(command)
    if command == "/register" then
        Events.CallRemote("registerPlayer", { Player.GetRockstarID() })
    end
end)

-- in server script:
Events.Subscribe("registerPlayer", function(rid)
    -- sync:
    local affectedRows = Database.Execute("INSERT INTO users (rockstarid, money, admin) VALUES (?, ?, ?)", { rid, 1000, 0 })

    -- async:
    Database.ExecuteAsync("INSERT INTO users (rockstarid, money, admin) VALUES (?, ?, ?)", { rid, 1000, 0 }, function(affectedRows)
        Console.Log(affectedRows)
    end)
end, true)
```

```squirrel
// in client script:
Events.Subscribe("chatCommand", function(command) {
    if (command == "/register") {
        Events.CallRemote("registerPlayer", [ Player.GetRockstarID() ]);
    }
});

// in server script:
Events.Subscribe("registerPlayer", function(rid) {
    // sync:
    local affectedRows = Database.Execute("INSERT INTO users (rockstarid, money, admin) VALUES (?, ?, ?)", [ rid, 1000, 0 ]);

    // async:
    Database.ExecuteAsync("INSERT INTO users (rockstarid, money, admin) VALUES (?, ?, ?)", [ rid, 1000, 0 ], function(affectedRows) {
        Console.Log(affectedRows);
    });
}, true);
```

### Select

This function executes a SQL statement with the given arguments. It returns the resulting data as a table.

Synchronous (blocking):

`list result = Database.Select(string statement, list params)`

Asynchronous (non-blocking):

`Database.SelectAsync(string statement, list params, [optional] function callback)`

Example:

- Lua
- Squirrel

```lua
-- in client script:
Events.Subscribe("chatCommand", function(command)
    if command == "/login" then
        Events.CallRemote("loginPlayer", { Player.GetRockstarID() })
    end
end)

-- in server script:
Events.Subscribe("loginPlayer", function(rid)
    -- sync:
    local result = Database.Select("SELECT * FROM users WHERE rockstarid = ?", { rid })

    if #result > 0 then
        Console.Log("Player exist (money: " .. result[1]["money"] .. ", admin: " .. result[1]["admin"] .. ")")
    end

    -- async:
    Database.SelectAsync("SELECT * FROM users WHERE rockstarid = ?", { rid }, function(result)
        if #result > 0 then
            Console.Log("Player exist (money: " .. result[1]["money"] .. ", admin: " .. result[1]["admin"] .. ")")
        end
    end)
end, true)
```

```squirrel
// in client script:
Events.Subscribe("chatCommand", function(command) {
    if (command == "/login") {
        Events.CallRemote("loginPlayer", [ Player.GetRockstarID() ]);
    }
});

// in server script:
Events.Subscribe("loginPlayer", function(rid) {
    // sync:
    local result = Database.Select("SELECT * FROM users WHERE rockstarid = ?", [ rid ]);

    if (result.len() > 0) {
        Console.Log("Player exist (money: " + result[0]["money"] + ", admin: " + result[0]["admin"] + ")");
    }

    // async:
    Database.SelectAsync("SELECT * FROM users WHERE rockstarid = ?", [ rid ], function(result) {
        if (result.len() > 0) {
            Console.Log("Player exist (money: " + result[0]["money"] + ", admin: " + result[0]["admin"] + ")");
        }
    });
}, true);
```

### Insert

This function inserts data into a table using the provided SQL statement and arguments. It returns the ID of the newly inserted row.

Synchronous (blocking):

`int insertId = Database.Insert(string statement, list params)`

Asynchronous (non-blocking):

`Database.InsertAsync(string statement, list params, [optional] function callback)`

> **Warning**
>
> Needs an auto-incremented primary key to work.

Example:

- Lua
- Squirrel

```lua
-- in client script:
Events.Subscribe("chatCommand", function(command)
    if command == "/register" then
        Events.CallRemote("registerPlayer", { Player.GetRockstarID() })
    end
end)

-- in server script:
Events.Subscribe("registerPlayer", function(rid)
    -- sync:
    local insertId = Database.Insert("INSERT INTO users (rockstarid, money, admin) VALUES (?, ?, ?)", { rid, 1000, 0 })

    -- async:
    Database.InsertAsync("INSERT INTO users (rockstarid, money, admin) VALUES (?, ?, ?)", { rid, 1000, 0 }, function(insertId)
        Console.Log(insertId)
    end)
end, true)
```

```squirrel
// in client script:
Events.Subscribe("chatCommand", function(command) {
    if (command == "/register") {
        Events.CallRemote("registerPlayer", [ Player.GetRockstarID() ]);
    }
});

// in server script:
Events.Subscribe("registerPlayer", function(rid) {
    // sync:
    local insertId = Database.Insert("INSERT INTO users (rockstarid, money, admin) VALUES (?, ?, ?)", [ rid, 1000, 0 ]);

    // async:
    Database.InsertAsync("INSERT INTO users (rockstarid, money, admin) VALUES (?, ?, ?)", [ rid, 1000, 0 ], function(insertId) {
        Console.Log(insertId);
    });
}, true);
```

Source: https://happinessmp.net/docs/scripting/functions/database


---

# HTTP

## Quick Reference

| Name | Type | Description |
| --- | --- | --- |
| [Request](https://happinessmp.net/docs/scripting/functions/http#request) | Server | Makes a synchronous http request. |
| [RequestAsync](https://happinessmp.net/docs/scripting/functions/http#requestasync) | Server | Makes an asynchronous http request. |

## Server Functions

### Request

Makes a synchronous http request.

`int status, string data = HTTP.Request(string host, string method, string data, string contentType, table headers)`

> **Info**
>
> Available HTTP methods are `get`, `post`, `put`, `head`, `delete`, `patch`, `options`.

Example:

- Lua
- Squirrel

```lua
local status, data = HTTP.Request("https://httpbin.org/post", "post", "{}", "application/json", { ["testHeader"] = "test" })
Console.Log("status: " .. status .. ", data: " .. data)
```

```squirrel
local result = HTTP.Request("https://httpbin.org/post", "post", "{}", "application/json", { ["testHeader"] = "test" });
Console.Log("status: " + result[0] + ", data: " + result[1]);
```

### RequestAsync

Makes an asynchronous http request.

`HTTP.RequestAsync(string host, string method, string data, string contentType, table headers, [optional] function callback)`

> **Info**
>
> Available HTTP methods are `get`, `post`, `put`, `head`, `delete`, `patch`, `options`.

Example:

- Lua
- Squirrel

```lua
HTTP.RequestAsync("https://httpbin.org/post", "post", "{}", "application/json", { ["testHeader"] = "test" }, function(status, data)
    Console.Log("status: " .. status .. ", data: " .. data)
end)
```

```squirrel
HTTP.RequestAsync("https://httpbin.org/post", "post", "{}", "application/json", { ["testHeader"] = "test" }, function(status, data) {
    Console.Log("status: " + status + ", data: " + data);
});
```

Source: https://happinessmp.net/docs/scripting/functions/http


---

# Text

## Quick Reference

| Name | Type | Description |
| --- | --- | --- |
| [AddEntry](https://happinessmp.net/docs/scripting/functions/text#addentry) | Client | Add GXT entry. |
| [AddEntryByHash](https://happinessmp.net/docs/scripting/functions/text#addentrybyhash) | Client | Add GXT entry by hash. |
| [SetLoadingText](https://happinessmp.net/docs/scripting/functions/text#setloadingtext) | Client | Set loading screen text. |

## Client Functions

### AddEntry

Add GXT entry.

`Text.AddEntry(string key, string label)`

> **Tip**
>
> This function can also be used to overwrite existing GXT entries.

Example:

- Lua
- Squirrel

```lua
Text.AddEntry("MenuHelp", "~INPUT_PICKUP~ Open Menu")

Thread.Create(function()
    while true do
        Thread.Pause(0)

        Game.DrawFrontendHelperText("", "MenuHelp", false)
    end
end)
```

```squirrel
Text.AddEntry("MenuHelp", "~INPUT_PICKUP~ Open Menu");

Thread.Create(function() {
    while (true) {
        Thread.Pause(0);

        Game.DrawFrontendHelperText("", "MenuHelp", false);
    }
});
```

### AddEntryByHash

Add GXT entry by hash.

`Text.AddEntryByHash(uint key, string label)`

> **Tip**
>
> This function can also be used to overwrite existing GXT entries.

### SetLoadingText

Set loading screen text.

`Text.SetLoadingText(string text)`

Example:

- Lua
- Squirrel

```lua
Events.Subscribe("sessionInit", function()
    Text.SetLoadingText("Loading Freeroam...")
end)
```

```squirrel
Events.Subscribe("sessionInit", function() {
    Text.SetLoadingText("Loading Freeroam...");
});
```

Source: https://happinessmp.net/docs/scripting/functions/text


---

# Thread

Threads utilize the coroutines of the underlying script VM and are designed to execute loops or delays without blocking the game. A thread exists until its code has finished executing or it is manually terminated using [Kill](https://happinessmp.net/docs/scripting/functions/thread#kill).

> **Info**
>
> All threads run sequentially (synchronously) on the main thread. Therefore, there is no need to worry about writing thread-safe code.

> **Warning**
>
> If you use an infinite loop inside a thread, you **must** call `Thread.Pause()` (even `Thread.Pause(0)` is sufficient). Failing to do so will freeze the entire game or server, as the thread will never yield control back to the main thread.

## Quick Reference

| Name | Type | Description |
| --- | --- | --- |
| [Create](https://happinessmp.net/docs/scripting/functions/thread#create) | Shared | Creates a new thread with a function that is executed asynchronously. |
| [Pause](https://happinessmp.net/docs/scripting/functions/thread#pause) | Shared | Pauses the current thread for the specified duration. |
| [Kill](https://happinessmp.net/docs/scripting/functions/thread#kill) | Shared | Kills the specified thread on the next script tick. |
| [IsAlive](https://happinessmp.net/docs/scripting/functions/thread#isalive) | Shared | Returns whether the specified thread is currently alive and running. |

## Shared Functions

### Create

Creates a thread with a function that is executed on the next script tick.

`int threadId = Thread.Create(function threadFunc, any ...)`

Example:

- Lua
- Squirrel

```lua
Events.Subscribe("sessionInit", function()
    Thread.Create(function()
        -- Get player model hash key.
        local playerModel = Game.GetHashKey("M_Y_MULTIPLAYER")

        -- Request model.
        Game.RequestModel(playerModel)

        -- Wait until model loaded.
        while not Game.HasModelLoaded(playerModel) do
            Game.RequestModel(playerModel)
            Thread.Pause(0)
        end

        -- Change player model.
        Game.ChangePlayerModel(Game.GetPlayerId(), playerModel)

        -- Release model.
        Game.MarkModelAsNoLongerNeeded(playerModel)
    end)
end)
```

```squirrel
Events.Subscribe("sessionInit", function() {
    Thread.Create(function() {
        // Get player model hash key.
        local playerModel = Game.GetHashKey("M_Y_MULTIPLAYER");

        // Request model.
        Game.RequestModel(playerModel);

        // Wait until model loaded.
        while (!Game.HasModelLoaded(playerModel)) {
            Game.RequestModel(playerModel);
            Thread.Pause(0);
        }

        // Change player model.
        Game.ChangePlayerModel(Game.GetPlayerId(), playerModel);

        // Release model.
        Game.MarkModelAsNoLongerNeeded(playerModel);
    });
});
```

### Pause

Pauses the current thread for the specified duration.

`Thread.Pause(int milliseconds)`

> **Warning**
>
> This function can only be used within a running thread.

Example:

- Lua
- Squirrel

```lua
Events.Subscribe("scriptInit", function()
    Thread.Create(function()
        while true do
            Thread.Pause(5000)

            -- This message is sent every 5 seconds.
            Chat.AddMessage("5 seconds are over.")
        end
    end)
end)
```

```squirrel
Events.Subscribe("scriptInit", function() {
    Thread.Create(function() {
        while (true) {
            Thread.Pause(5000);

            // This message is sent every 5 seconds.
            Chat.AddMessage("5 seconds are over.");
        }
    });
});
```

### Kill

Kills the specified thread on the next script tick.

`Thread.Kill(int threadId)`

### IsAlive

Returns whether the specified thread is currently alive and running.

`bool alive = Thread.IsAlive(int threadId)`

> **Warning**
>
> A thread marked for termination (via `Kill`) will continue to return `true` until it is actually terminated during the next script tick.

Source: https://happinessmp.net/docs/scripting/functions/thread


---

# Timer

Timers provide an easy way to execute functions after a specific time delay (timeout) or at recurring intervals.

> **Info**
>
> Under the hood, the Timer API is entirely based on the Thread API. Therefore, timers share the exact same characteristics: they utilize the script VM's coroutines, do not block the game's main process, and run sequentially, meaning you don't have to worry about thread safety.

## Quick Reference

| Name | Type | Description |
| --- | --- | --- |
| [SetInterval](https://happinessmp.net/docs/scripting/functions/timer#setinterval) | Shared | Sets a recurring timer. |
| [SetTimeout](https://happinessmp.net/docs/scripting/functions/timer#settimeout) | Shared | Executes a function once after a specified delay. |
| [Kill](https://happinessmp.net/docs/scripting/functions/timer#kill) | Shared | Stops and removes a timer immediately. |
| [IsAlive](https://happinessmp.net/docs/scripting/functions/timer#isalive) | Shared | Checks if a specific timer is currently registered and active. |
| [GetRemaining](https://happinessmp.net/docs/scripting/functions/timer#getremaining) | Shared | Returns the milliseconds remaining until the next execution. |
| [GetRepeatsLeft](https://happinessmp.net/docs/scripting/functions/timer#getrepeatsleft) | Shared | Returns the number of remaining executions for finite timers. |
| [GetState](https://happinessmp.net/docs/scripting/functions/timer#getstate) | Shared | Returns the current state of the timer as a string. |

## Shared Functions

### SetInterval

Sets a recurring timer.

`int timerId = Timer.SetInterval(int intervalMs, function func, int count, any ...)`

### SetTimeout

Executes a function once after a specified delay.

`int timerId = Timer.SetTimeout(int delayMs, function func, any ...)`

### Kill

Stops and removes a timer immediately.

`Timer.Kill(int timerId)`

### IsAlive

Checks if a specific timer is currently registered and active.

`bool alive = Timer.IsAlive(int timerId)`

### GetRemaining

Returns the milliseconds remaining until the next execution.

`int time = Timer.GetRemaining(int timerId)`

### GetRepeatsLeft

Returns the number of remaining executions for finite timers.

`int repeats = Timer.GetRepeatsLeft(int timerId)`

### GetState

Returns the current state of the timer as a string ("running" or "dead").

`string state = Timer.GetState(int timerId)`

Source: https://happinessmp.net/docs/scripting/functions/timer

