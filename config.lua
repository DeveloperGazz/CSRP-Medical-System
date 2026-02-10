Config = {}

-- ==========================================
-- GENERAL SETTINGS
-- ==========================================
Config.Debug = false -- Enable debug messages
Config.Language = 'en' -- Language for UI/messages

-- ==========================================
-- PERMISSIONS
-- ==========================================
Config.Permissions = {
    UsePatientMenu = true, -- Everyone can use patient menu
    UseParamedicMenu = true, -- Set to false to restrict to specific jobs
    ParamedicJobs = {'ambulance', 'doctor', 'ems'}, -- Job names that can use paramedic menu
    AdminCommands = true, -- Allow admin commands
    AdminAcePermission = 'csrp.medical.admin', -- ACE permission for admin commands (optional)
    UseAcePermissions = false -- Set to true to use ACE permissions instead of simple toggle
}

-- ==========================================
-- VITAL SIGNS SETTINGS
-- ==========================================
Config.VitalSigns = {
    -- Heart Rate (BPM)
    HeartRate = {
        Normal = {min = 60, max = 100},
        Low = {min = 0, max = 59},
        High = {min = 101, max = 200},
        Critical = {min = 0, max = 40},
        UpdateInterval = 5000 -- Update every 5 seconds
    },
    
    -- Blood Pressure (mmHg)
    BloodPressure = {
        Normal = {systolic = {min = 90, max = 140}, diastolic = {min = 60, max = 90}},
        Low = {systolic = {min = 0, max = 89}, diastolic = {min = 0, max = 59}},
        High = {systolic = {min = 141, max = 200}, diastolic = {min = 91, max = 140}},
        UpdateInterval = 10000
    },
    
    -- Respiratory Rate (breaths per minute)
    RespiratoryRate = {
        Normal = {min = 12, max = 20},
        Low = {min = 0, max = 11},
        High = {min = 21, max = 60},
        UpdateInterval = 8000
    },
    
    -- Oxygen Saturation (%)
    OxygenSaturation = {
        Normal = {min = 95, max = 100},
        Low = {min = 90, max = 94},
        Critical = {min = 0, max = 89},
        UpdateInterval = 5000
    },
    
    -- Temperature (Celsius)
    Temperature = {
        Normal = {min = 36.1, max = 37.2},
        Low = {min = 0, max = 36.0},
        High = {min = 37.3, max = 45},
        UpdateInterval = 15000
    },
    
    -- Consciousness (AVPU)
    Consciousness = {
        Alert = 4,
        Voice = 3,
        Pain = 2,
        Unresponsive = 1
    }
}

-- ==========================================
-- INJURY PROGRESSION SETTINGS
-- ==========================================
Config.Progression = {
    BleedingRate = 1.0, -- Multiplier for bleeding progression (1.0 = normal)
    BleedingProgressionRate = 0.1, -- Base rate of bleeding increase (10% per tick)
    BloodLossPerTick = 2, -- Percentage of blood lost per tick based on bleeding severity
    ShockThreshold = 30, -- Blood loss % before shock develops
    CardiacArrestChance = 0.05, -- 5% chance per tick in critical condition
    AirwayObstructionChance = 0.10, -- 10% chance for unconscious patients
    ProgressionInterval = 10000, -- Check every 10 seconds
    EnableComplications = true, -- Enable secondary injuries
    DiastolicRatio = 0.7 -- Ratio of systolic to diastolic blood pressure
}

-- ==========================================
-- EQUIPMENT QUANTITIES
-- ==========================================
Config.Equipment = {
    -- Bandages and Dressings
    Bandages = 15,
    PressureDressings = 10,
    ChestSeals = 2,
    BurnDressings = 5,
    
    -- Hemorrhage Control
    Tourniquets = 4,
    HemostaticGauze = 6,
    PelvicBinder = 1,
    
    -- Airway Management
    OPA = 3,
    NPA = 3,
    SuctionUses = 10,
    
    -- Breathing Support
    OxygenMinutes = 60,
    BVM = 1,
    NeedleDecompression = 2,
    
    -- IV Therapy
    IVBags = 3,
    IVLines = 5,
    
    -- Fracture Management
    Splints = 6,
    CervicalCollars = 2,
    SpineBoards = 1,
    
    -- Medications (doses)
    Paracetamol = 5,
    Morphine = 3,
    Fentanyl = 2,
    Entonox = 1,
    Adrenaline = 5,
    Aspirin = 5,
    GTN = 3,
    Salbutamol = 3,
    Glucose = 5,
    Naloxone = 3,
    Midazolam = 2,
    
    -- Other
    Defibrillator = 1,
    ThermalBlanket = 2,
    CoolingPacks = 5
}

-- ==========================================
-- TREATMENT EFFECTIVENESS
-- ==========================================
Config.Treatments = {
    -- How effective each treatment is (0.0 - 1.0)
    DirectPressure = 0.3, -- Reduces bleeding by 30%
    PressureDressing = 0.6, -- Reduces bleeding by 60%
    Tourniquet = 1.0, -- Stops limb bleeding completely
    HemostaticGauze = 0.8, -- Reduces bleeding by 80%
    
    -- IV Fluid restoration
    IVFluidRestoration = 20, -- Restores 20% blood volume
    
    -- Medication effects (vitals improvement)
    MorphineEffect = 0.7, -- Pain reduction
    AdrenalineEffect = 0.5, -- Cardiac support
    
    -- Oxygen therapy
    OxygenEffectiveness = 1.5, -- SpO2 improvement multiplier
    
    -- Splint effectiveness
    SplintPainReduction = 0.4 -- 40% pain reduction
}

-- ==========================================
-- HOSPITAL/RESUPPLY LOCATIONS
-- ==========================================
Config.Hospitals = {
    {
        name = "Pillbox Hill Medical Center",
        coords = vector3(307.7, -1433.5, 29.9),
        blip = true,
        resupply = true
    },
    {
        name = "Sandy Shores Medical Center",
        coords = vector3(1839.6, 3672.9, 34.3),
        blip = true,
        resupply = true
    },
    {
        name = "Paleto Bay Medical Center",
        coords = vector3(-247.3, 6331.1, 32.4),
        blip = true,
        resupply = true
    }
}

-- ==========================================
-- UI SETTINGS
-- ==========================================
Config.UI = {
    -- Color scheme (NHS Blue)
    PrimaryColor = '#005EB8',
    SecondaryColor = '#41B6E6',
    DangerColor = '#DA291C',
    WarningColor = '#FFB81C',
    SuccessColor = '#009639',
    
    -- Positioning
    Position = 'right', -- left, center, right
    Scale = 1.0,
    
    -- Keybinds
    OpenPatientMenu = 'F6',
    OpenParamedicMenu = 'F7',
    
    -- Animation duration
    AnimationSpeed = 300 -- milliseconds
}

-- ==========================================
-- ANIMATIONS
-- ==========================================
Config.Animations = {
    Bandaging = {dict = 'amb@medic@standing@kneel@base', anim = 'base', duration = 5000},
    CPR = {dict = 'mini@cpr@char_a@cpr_str', anim = 'cpr_pumpchest', duration = 15000},
    Examination = {dict = 'amb@code_human_police_investigate@idle_a', anim = 'idle_b', duration = 8000},
    IVInsertion = {dict = 'amb@medic@standing@tendtodead@base', anim = 'base', duration = 7000},
    Splinting = {dict = 'amb@prop_human_parking_meter@female@idle_a', anim = 'idle_a_female', duration = 10000}
}

-- ==========================================
-- SOUNDS
-- ==========================================
Config.Sounds = {
    Enabled = true,
    HeartMonitor = true,
    PainSounds = true,
    TreatmentSounds = true,
    Volume = 0.3
}

-- ==========================================
-- TRAINING MODE
-- ==========================================
Config.Training = {
    Enabled = true,
    AllowDummyPatients = true,
    DummyPedModels = {'a_m_m_beach_01', 'a_f_m_beach_01'},
    RandomInjuries = true
}

-- ==========================================
-- RESPAWN INTEGRATION
-- ==========================================
Config.Respawn = {
    Enabled = false, -- Enable death/respawn handling
    RespawnTime = 300, -- Seconds before respawn option
    KeepInjuries = false, -- Keep injuries after respawn
    HospitalSpawn = true -- Spawn at hospital
}

-- ==========================================
-- DEBUG COMMANDS
-- ==========================================
Config.Commands = {
    AddInjury = 'addinjury',
    HealPlayer = 'healplayer',
    CheckVitals = 'checkvitals',
    Resupply = 'resupply',
    SpawnDummy = 'spawndummy',
    ToggleDebug = 'medebug'
}
