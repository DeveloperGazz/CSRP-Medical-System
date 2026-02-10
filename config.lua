Config = {}

-- ==========================================
-- GENERAL SETTINGS
-- ==========================================
Config.Debug = false -- Enable debug prints
Config.UseKilometers = true -- false for miles (UK uses KM for medical)
Config.Language = 'en_GB' -- UK English

-- ==========================================
-- PERMISSIONS
-- ==========================================
Config.ParamedicJobs = {
    'ambulance',
    'paramedic',
    'ems',
    'nhs'
}

Config.AdminGroups = {
    'admin',
    'superadmin',
    'moderator'
}

-- ==========================================
-- VITAL SIGNS SETTINGS
-- ==========================================
Config.VitalRanges = {
    HeartRate = {
        normal = {60, 100},
        tachycardia = {100, 150},
        severe_tachycardia = {150, 200},
        bradycardia = {40, 60},
        severe_bradycardia = {0, 40},
        cardiac_arrest = 0
    },
    BloodPressure = {
        normal_systolic = {90, 140},
        normal_diastolic = {60, 90},
        hypotension_systolic = {0, 90},
        hypertension_systolic = {140, 200},
        shock_systolic = {0, 70}
    },
    RespiratoryRate = {
        normal = {12, 20},
        tachypnea = {20, 30},
        severe_tachypnea = {30, 50},
        bradypnea = {8, 12},
        respiratory_arrest = 0
    },
    SpO2 = {
        normal = {95, 100},
        mild_hypoxia = {90, 95},
        moderate_hypoxia = {85, 90},
        severe_hypoxia = {0, 85}
    },
    Temperature = {
        normal = {36.1, 37.2},
        hypothermia_mild = {32, 35},
        hypothermia_moderate = {28, 32},
        hypothermia_severe = {0, 28},
        hyperthermia_mild = {37.5, 38.5},
        hyperthermia_moderate = {38.5, 40},
        hyperthermia_severe = {40, 45}
    }
}

-- Update frequency for vital signs (milliseconds)
Config.VitalUpdateInterval = 5000 -- Every 5 seconds

-- ==========================================
-- INJURY PROGRESSION SETTINGS
-- ==========================================
Config.ProgressionEnabled = true
Config.ProgressionInterval = 10000 -- Check every 10 seconds

Config.BleedingRates = {
    minor = 0.5,      -- % blood loss per interval
    moderate = 1.5,
    severe = 3.0,
    critical = 5.0
}

Config.ShockThreshold = 30 -- % blood loss before shock begins
Config.DeathThreshold = 70 -- % blood loss before death

-- ==========================================
-- CONSCIOUSNESS SYSTEM (AVPU)
-- ==========================================
Config.AVPULevels = {
    'Alert',           -- Fully conscious
    'Voice',           -- Responds to voice
    'Pain',            -- Only responds to pain
    'Unresponsive'     -- Unconscious
}

Config.ConsciousnessThresholds = {
    unresponsive = 20,  -- Below 20% condition
    pain = 40,
    voice = 60
    -- Above 60 = Alert
}

-- ==========================================
-- EQUIPMENT MANAGEMENT
-- ==========================================
Config.EquipmentEnabled = true
Config.EquipmentCharges = {
    -- Dressings & Bleeding Control
    pressure_dressing = 10,
    tourniquet = 4,
    hemostatic_gauze = 6,
    chest_seal = 2,
    pelvic_binder = 1,
    
    -- Airway
    opa = 3,
    npa = 3,
    suction_unit = 5,
    bvm = 1,
    
    -- Breathing
    oxygen_mask = 10,
    nasal_cannula = 10,
    oxygen_time = 3600, -- 60 minutes in seconds
    
    -- Circulation
    iv_cannula = 5,
    iv_fluid_bag = 3,
    
    -- Fracture Management
    splint = 6,
    c_collar = 2,
    
    -- Monitoring
    bp_cuff = 999, -- Unlimited (reusable)
    thermometer = 999,
    pulse_oximeter = 999,
    
    -- Medications
    paracetamol = 5,
    morphine = 3,
    fentanyl = 2,
    entonox = 1,
    adrenaline = 4,
    aspirin = 5,
    gtn = 3,
    salbutamol = 3,
    glucose = 4,
    naloxone = 3,
    midazolam = 2,
    
    -- Emergency Equipment
    aed = 1,
    needle_decompression = 2
}

Config.ResupplyLocations = {
    {coords = vector3(298.5, -584.5, 43.3), name = "Pillbox Hospital"},
    {coords = vector3(1839.6, 3672.9, 34.3), name = "Sandy Shores Medical"},
    {coords = vector3(-247.3, 6331.0, 32.4), name = "Paleto Bay Medical"}
}

Config.ResupplyRadius = 10.0 -- meters

-- ==========================================
-- TREATMENT EFFECTIVENESS
-- ==========================================
Config.TreatmentEffectiveness = {
    -- Bleeding Control
    direct_pressure = 30,        -- % bleeding reduction
    pressure_dressing = 60,
    tourniquet = 100,           -- Complete stop for limbs
    hemostatic_gauze = 80,
    
    -- Fluid Resuscitation
    iv_fluids = 15,             -- % blood volume restored per bag
    
    -- Oxygen Therapy
    oxygen_low_flow = 2,        -- SpO2 increase per interval
    oxygen_high_flow = 5,
    oxygen_bvm = 8,
    
    -- Pain Relief (pain reduction %)
    paracetamol = 20,
    entonox = 40,
    morphine = 70,
    fentanyl = 80,
    
    -- Cardiac
    cpr_effectiveness = 30,     -- % chance per cycle to restore pulse
    aed_effectiveness = 60,     -- % chance to restore rhythm
    adrenaline_cardiac = 20     -- Bonus % to cardiac interventions
}

-- ==========================================
-- PSYCHOLOGICAL ELEMENTS
-- ==========================================
Config.PsychologicalEnabled = true

Config.AnxietyEffects = {
    enabled = true,
    heart_rate_increase = 20,   -- BPM increase when anxious
    bp_increase = 15            -- mmHg increase
}

Config.PainReactions = {
    enabled = true,
    scream_chance = 30,         -- % chance to scream when in severe pain
    flinch_chance = 60,         -- % chance to flinch during examination
    resistance_chance = 40      -- % chance to resist painful procedures
}

Config.ConsentSystem = {
    enabled = true,
    allow_refusal = true,
    unconscious_implied_consent = true
}

Config.MentalHealthScenarios = {
    'anxiety_attack',
    'depression',
    'psychosis',
    'suicidal_ideation',
    'ptsd_episode',
    'substance_withdrawal'
}

-- ==========================================
-- BYSTANDER SYSTEM
-- ==========================================
Config.BystandersEnabled = true

Config.BystanderReactions = {
    panic_chance = 40,          -- % chance bystanders panic
    crowd_radius = 15.0,        -- Radius bystanders gather
    interference_chance = 25,   -- % chance of getting in the way
    good_samaritan_chance = 15  -- % chance someone helps
}

Config.WitnessStatements = {
    enabled = true,
    provide_injury_cause = true,
    provide_time_info = true
}

Config.CivilianFirstAid = {
    enabled = true,
    can_perform_cpr = true,
    can_use_recovery_position = true,
    can_apply_pressure = true,
    effectiveness = 20          -- % effectiveness vs paramedic
}

-- ==========================================
-- MULTI-CASUALTY INCIDENTS
-- ==========================================
Config.MCIEnabled = true

Config.TriageCategories = {
    P1 = {name = "Immediate", color = "red", priority = 1},
    P2 = {name = "Urgent", color = "yellow", priority = 2},
    P3 = {name = "Delayed", color = "green", priority = 3},
    DEAD = {name = "Deceased", color = "black", priority = 4}
}

Config.MCIThreshold = 3 -- Number of patients to trigger MCI mode

Config.IncidentCommandEnabled = true
Config.ResourceSharingEnabled = true

-- ==========================================
-- REALISTIC COMPLICATIONS
-- ==========================================
Config.ComplicationsEnabled = true

Config.TreatmentFailureRates = {
    iv_insertion = 15,          -- % chance of failure
    intubation = 10,
    needle_decompression = 5,
    cpr_rib_fracture = 30      -- % chance CPR causes rib fractures
}

Config.MedicationReactions = {
    allergic_reaction_chance = 5,
    side_effects_chance = 15
}

Config.EquipmentMalfunction = {
    enabled = true,
    aed_failure = 5,            -- % chance
    iv_infiltration = 10,
    oxygen_leak = 3
}

Config.SuddenDeterioration = {
    enabled = true,
    check_interval = 30000,     -- Every 30 seconds
    cardiac_arrest_chance = 2,  -- % for critical patients
    airway_obstruction_chance = 5
}

-- ==========================================
-- ENHANCED PATIENT EXPERIENCE
-- ==========================================
Config.PatientEffectsEnabled = true

Config.PainSystem = {
    enabled = true,
    visual_blur = true,
    screen_shake = true,
    movement_reduction = true,
    pain_levels = {
        none = {blur = 0, shake = 0, movement = 100},
        mild = {blur = 5, shake = 1, movement = 90},
        moderate = {blur = 15, shake = 3, movement = 70},
        severe = {blur = 30, shake = 6, movement = 40},
        extreme = {blur = 50, shake = 10, movement = 20}
    }
}

Config.BloodLossEffects = {
    enabled = true,
    screen_desaturation = true,
    tunnel_vision = true,
    weakness = true,
    thresholds = {
        mild = 20,      -- % blood loss
        moderate = 40,
        severe = 60
    }
}

Config.UnconsciousnessSystem = {
    enabled = true,
    can_hear_paramedics = true,
    screen_blackout = true,
    ragdoll = true
}

Config.RecoveryTimeline = {
    enabled = true,
    minor_injury_heal_time = 300,     -- 5 minutes
    moderate_injury_heal_time = 1800, -- 30 minutes
    severe_injury_heal_time = 7200,   -- 2 hours
    critical_injury_heal_time = 14400 -- 4 hours
}

Config.PersistentInjuries = {
    enabled = true,
    show_bandages = true,
    show_splints = true,
    show_blood = true,
    scar_system = true
}

-- ==========================================
-- IMMERSIVE DETAILS
-- ==========================================
Config.ImmersionEnabled = true

Config.BloodTrails = {
    enabled = true,
    particle_effect = "core",
    particle_name = "ent_amb_blood_splash",
    drip_interval = 5000        -- Every 5 seconds while bleeding
}

Config.MedicalWaste = {
    enabled = true,
    spawn_props = true,
    disposal_required = true,
    props = {
        'prop_ld_binbag_01',
        'prop_cs_cotton_bud',
        'prop_syringe_01'
    }
}

Config.PatientBelongings = {
    enabled = true,
    track_valuables = true,
    secure_before_transport = true
}

Config.DeathProcedures = {
    enabled = true,
    confirm_death = true,
    notify_police = true,
    cover_body = true,
    time_of_death_log = true
}

-- ==========================================
-- NOTIFICATION SETTINGS
-- ==========================================
Config.NotificationType = 'native' -- 'native', 'custom', 'mythic', 'okokNotify'

-- ==========================================
-- KEY BINDINGS
-- ==========================================
Config.Keys = {
    OpenPatientMenu = 'F6',
    OpenParamedicMenu = 'F7',
    OpenMCIMenu = 'F8',
    InteractWithPatient = 'E',
    CancelAction = 'X'
}

-- ==========================================
-- ANIMATION SETTINGS
-- ==========================================
Config.UseAnimations = true
Config.TreatmentAnimations = {
    examine = {dict = "amb@medic@standing@kneel@base", anim = "base", duration = 5000},
    bandage = {dict = "amb@medic@standing@kneel@base", anim = "base", duration = 8000},
    cpr = {dict = "mini@cpr@char_a@cpr_str", anim = "cpr_pumpchest", duration = 3000},
    inject = {dict = "anim@amb@business@weed@weed_inspecting_high_dry@", anim = "weed_stand_checkingleaves_idle_01_inspector", duration = 4000}
}

-- ==========================================
-- SOUND SETTINGS
-- ==========================================
Config.UseSounds = true
Config.Sounds = {
    heartbeat = true,
    flatline = true,
    aed_shock = true,
    pain_moans = true,
    breathing = true
}

return Config
