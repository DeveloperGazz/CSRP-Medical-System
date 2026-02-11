-- ==========================================
-- CSRP MEDICAL SYSTEM - CONFIGURATION
-- ==========================================

Config = {}

-- ==========================================
-- DEBUG & PERMISSIONS
-- ==========================================

Config.Debug = false -- Enable debug messages

Config.Permissions = {
    UseParamedicMenu = true,    -- Allow all players to use paramedic menu (set false for job restriction)
    UsePatientMenu = true,       -- Allow all players to use patient menu
    AdminCommands = true,        -- Enable admin commands
    UseAcePermissions = false,   -- Use ACE permissions for admin commands
    AdminAcePermission = 'csrp.medical.admin' -- ACE permission for admin commands
}

-- ==========================================
-- COMMANDS
-- ==========================================

Config.Commands = {
    AddInjury = 'addinjury',
    HealPlayer = 'healplayer', 
    Resupply = 'resupply',
    SpawnDummy = 'spawndummy',
    ToggleDebug = 'medebug',
    CheckVitals = 'checkvitals'
}

-- ==========================================
-- VITAL SIGNS
-- ==========================================

Config.VitalSigns = {
    Consciousness = {
        Alert = 4,
        Voice = 3,
        Pain = 2,
        Unresponsive = 1
    },
    
    -- Normal ranges
    NormalHeartRate = {min = 60, max = 100},
    NormalBloodPressure = {systolic = 120, diastolic = 80},
    NormalRespiratoryRate = {min = 12, max = 20},
    NormalOxygenSaturation = {min = 95, max = 100},
    NormalTemperature = {min = 36.1, max = 37.2}
}

-- ==========================================
-- PROGRESSION SYSTEM
-- ==========================================

Config.Progression = {
    Enabled = true,
    ProgressionInterval = 5000,      -- Update interval in ms
    BleedingProgressionRate = 0.1,   -- How fast bleeding worsens
    BleedingRate = 1.0,              -- Base bleeding rate
    BloodLossPerTick = 0.5,          -- Blood loss per tick
    ShockThreshold = 60,             -- Blood volume % for shock
    EnableComplications = true,      -- Enable secondary complications
    CardiacArrestChance = 0.01,      -- Chance per tick when critical
    AirwayObstructionChance = 0.05   -- Chance for unconscious patients
}

-- ==========================================
-- TRAINING & FEATURES
-- ==========================================

Config.Training = {
    Enabled = false,  -- Training mode with dummies
    DummyModel = 'a_m_m_business_01'
}

-- ==========================================
-- ANIMATIONS
-- ==========================================

Config.Animations = {
    bandage = {dict = 'amb@world_human_clipboard@male@idle_a', anim = 'idle_c'},
    tourniquet = {dict = 'amb@world_human_clipboard@male@idle_a', anim = 'idle_c'},
    cpr = {dict = 'mini@cpr@char_a@cpr_str', anim = 'cpr_pumpchest'}
}

-- ==========================================
-- HOSPITALS & RESUPPLY
-- ==========================================

Config.Hospitals = {
    {coords = vector3(298.6, -584.5, 43.3), radius = 10.0, name = 'Pillbox Hill Medical Center', resupply = true},
    {coords = vector3(-247.8, 6331.5, 32.4), radius = 10.0, name = 'Paleto Bay Medical Center', resupply = true},
    {coords = vector3(1839.6, 3672.9, 34.3), radius = 10.0, name = 'Sandy Shores Medical Center', resupply = true}
}

-- ==========================================
-- DEATH SYSTEM
-- ==========================================

Config.DeathSystem = {
    Enabled = true,
    BlockRespawn = true,              -- Block default GTA respawn to allow paramedic RP
    RespawnTimer = 120,               -- Seconds before player can self-respawn (default: 2 minutes)
    AutoApplyInjuries = true,         -- Automatically apply injuries based on death cause
    KeepPlayerDown = true             -- Keep player on ground for paramedic treatment
}

-- ==========================================
-- MEDICAL SCENARIOS
-- ==========================================

Config.Scenarios = {
    Enabled = true,
    Cooldown = 60000,                 -- Cooldown between scenarios in ms (60 seconds)
    AllowedInVehicle = false          -- Whether scenarios can be triggered while in a vehicle
}

-- ==========================================
-- EQUIPMENT QUANTITIES
-- ==========================================

Config.Equipment = {
    -- Bleeding Control
    Bandages = 15,
    PressureDressings = 10,
    Tourniquets = 4,
    HemostaticGauze = 5,
    PelvicBinder = 2,
    
    -- Wound/Burn Dressings
    ChestSeals = 4,
    BurnDressings = 8,
    
    -- Airway Management
    OPA = 3,
    NPA = 3,
    SuctionUses = 5,
    
    -- Breathing Support
    OxygenMinutes = 120,
    BVM = 1,
    NeedleDecompression = 3,
    
    -- Circulation
    IVBags = 6,
    IVLines = 6,
    
    -- Immobilization
    Splints = 6,
    CervicalCollars = 3,
    SpineBoards = 1,
    
    -- Pain Relief
    Paracetamol = 10,
    Morphine = 5,
    Fentanyl = 3,
    Entonox = 5,
    
    -- Cardiac Medications
    Adrenaline = 5,
    Aspirin = 10,
    GTN = 5,
    
    -- Other Medications
    Salbutamol = 5,
    Glucose = 5,
    Naloxone = 3,
    Midazolam = 3,
    
    -- Equipment
    Defibrillator = 1,
    ThermalBlanket = 2,
    CoolingPacks = 4
}
