Config = {}

Config.VitalSigns = {
    Consciousness = {
        Alert = 4,
        Voice = 3,
        Pain = 2,
        Unresponsive = 1
    }
}

Config.Permissions = {
    UsePatientMenu = true,
    UseParamedicMenu = false
}

Config.Hospitals = {
    {
        name = "Pillbox Hospital",
        coords = vector3(298.5, -584.5, 43.3),
        resupply = true
    }
}

Config.Progression = {
    ProgressionInterval = 10000,
    BleedingProgressionRate = 0.1,
    BleedingRate = 1.0,
    BloodLossPerTick = 0.5,
    ShockThreshold = 50,
    EnableComplications = true,
    CardiacArrestChance = 0.01,
    AirwayObstructionChance = 0.05,
    DiastolicRatio = 0.6
}

Config.Animations = {}
Config.Debug = true

return Config