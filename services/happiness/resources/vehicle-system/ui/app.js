const fields = {
    vehicle: document.getElementById("vehicle"),
    gear: document.getElementById("gear"),
    rpm: document.getElementById("rpm"),
    ratio: document.getElementById("ratio"),
    clutch: document.getElementById("clutch"),
    engine: document.getElementById("engine"),
    status: document.getElementById("status"),
    speed: document.getElementById("speed")
};

Events.Subscribe(
    "vehicleSystem:update",
    function(vehicle, gear, rpm, ratio, clutch, engine, status, speed) {
        fields.vehicle.textContent = vehicle;
        fields.gear.textContent = gear;
        fields.rpm.textContent = rpm;
        fields.ratio.textContent = ratio;
        fields.clutch.textContent = clutch;
        fields.engine.textContent = engine;
        fields.status.textContent = status;
        fields.speed.textContent = speed;
    }
);
