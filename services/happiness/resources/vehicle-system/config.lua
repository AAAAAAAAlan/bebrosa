VehicleSystemConfig = {
    -- Used to filter resourceStop events and to build the local WebUI URL.
    resourceName = "vehicle-system",

    -- GTA IV keyboard scan codes from the HappinessMP key reference.
    keys = {
        clutch = 42,    -- Left Shift
        shiftDown = 16, -- Q
        shiftUp = 18,   -- E
        ignition = 19,  -- R (used together with the clutch)
        accelerate = 17, -- W
        brakeReverse = 31 -- S
    },

    -- Drivetrain thresholds and input-feedback timings shared by all cars.
    transmission = {
        -- Tiny nonzero ratio emulates an open clutch without risking division by zero.
        disconnectedRatio = 0.0001,
        -- Defensive bounds reject corrupt or unsupported native transmission data.
        minimumHighGear = 1,
        maximumHighGear = 8,
        -- Millisecond timings for missed shifts, messages, and stalling behavior.
        shiftLockMs = 400,
        grindStatusMs = 600,
        messageStatusMs = 900,
        stallDelayMs = 400,
        stallGraceMs = 350,
        -- Speeds are metres per second because GTA IV vehicle natives use m/s.
        stallSpeed = 0.5,
        directionLockSpeed = 0.25
    },

    -- Small non-focused telemetry browser placed in the top-left of the screen.
    ui = {
        url = "file://vehicle-system/ui/index.html",
        width = 380,
        height = 170,
        left = 16,
        top = 16,
        updateMs = 100
    },

    -- Approximate RPM display calibration used by every car without an override.
    defaultCarProfile = {
        idleRpm = 800,
        redlineRpm = 7000
    },

    -- Optional per-model display tuning; native gear counts and ratios are still captured live.
    vehicleOverrides = {
        SENTINEL = {
            name = "SENTINEL",
            idleRpm = 800,
            redlineRpm = 7000
        }
    }
}
