VehicleSystemConfig = {
    resourceName = "vehicle-system",

    keys = {
        clutch = 42,    -- Left Shift
        shiftDown = 16, -- Q
        shiftUp = 18,   -- E
        ignition = 19   -- R (used together with the clutch)
    },

    transmission = {
        disconnectedRatio = 0.0001,
        shiftLockMs = 400,
        grindStatusMs = 600,
        messageStatusMs = 900,
        stallDelayMs = 400,
        stallGraceMs = 350,
        stallSpeed = 0.5,
        stallRevs = 0.18
    },

    ui = {
        url = "file://vehicle-system/ui/index.html",
        width = 380,
        height = 170,
        left = 16,
        top = 16,
        updateMs = 100
    },

    debugVehicle = {
        enabled = true,
        model = "SENTINEL",
        rightOffset = 3.5,
        fallbackDelayMs = 5000
    },

    vehicles = {
        SENTINEL = {
            name = "SENTINEL",
            idleRpm = 800,
            redlineRpm = 7000,
            fallbackHighGear = 5
        }
    }
}
