-- ==========================================
-- INJURY DEFINITIONS MODULE
-- Comprehensive injury system with all types
-- ==========================================

Injuries = {}

-- Body zones
Injuries.BodyZones = {
    HEAD = 'head',
    CHEST = 'chest',
    ABDOMEN = 'abdomen',
    LEFT_ARM = 'left_arm',
    RIGHT_ARM = 'right_arm',
    LEFT_LEG = 'left_leg',
    RIGHT_LEG = 'right_leg'
}

-- Severity levels
Injuries.Severity = {
    MINOR = 1,
    MODERATE = 2,
    SEVERE = 3,
    CRITICAL = 4
}

-- Injury categories
Injuries.Categories = {
    TRAUMA = 'trauma',
    BURN = 'burn',
    MEDICAL = 'medical',
    ENVIRONMENTAL = 'environmental',
    INTERNAL = 'internal'
}

-- All injury definitions are pre-loaded
Injuries.Definitions = {}

-- Helper functions
function Injuries.GetInjury(injuryId)
    return Injuries.Definitions[injuryId]
end

function Injuries.GetByCategory(category)
    local result = {}
    for id, injury in pairs(Injuries.Definitions) do
        if injury.category == category then
            result[id] = injury
        end
    end
    return result
end

function Injuries.GetByZone(zone)
    local result = {}
    for id, injury in pairs(Injuries.Definitions) do
        if injury.zones == 'all' then
            result[id] = injury
        elseif type(injury.zones) == 'table' then
            for _, z in ipairs(injury.zones) do
                if z == zone then
                    result[id] = injury
                    break
                end
            end
        end
    end
    return result
end

-- TRAUMA INJURIES
Injuries.Definitions['gunshot_wound'] = {
    name = 'Gunshot Wound', category = Injuries.Categories.TRAUMA,
    description = 'Penetrating ballistic trauma', zones = 'all',
    effects = {bleeding = true, severe_bleeding = true, pain = true, shock_risk = true},
    vitals_impact = {heart_rate = 20, blood_pressure = -15, oxygen_sat = -5, consciousness = -1}
}

Injuries.Definitions['stab_wound'] = {
    name = 'Stab Wound', category = Injuries.Categories.TRAUMA,
    description = 'Penetrating sharp force trauma', zones = 'all',
    effects = {bleeding = true, pain = true, infection_risk = true},
    vitals_impact = {heart_rate = 15, blood_pressure = -10, oxygen_sat = -3}
}

Injuries.Definitions['blunt_trauma'] = {
    name = 'Blunt Force Trauma', category = Injuries.Categories.TRAUMA,
    description = 'Impact injury from falls, collisions, or assault',
    zones = {Injuries.BodyZones.HEAD, Injuries.BodyZones.CHEST, Injuries.BodyZones.ABDOMEN},
    effects = {bleeding = true, pain = true, swelling = true},
    vitals_impact = {heart_rate = 10, blood_pressure = -5}
}

Injuries.Definitions['fracture'] = {
    name = 'Fracture', category = Injuries.Categories.TRAUMA,
    description = 'Broken bone', zones = {Injuries.BodyZones.LEFT_ARM, Injuries.BodyZones.RIGHT_ARM, Injuries.BodyZones.LEFT_LEG, Injuries.BodyZones.RIGHT_LEG},
    effects = {pain = true, immobility = true, swelling = true},
    vitals_impact = {heart_rate = 10}
}

-- BURNS
Injuries.Definitions['burn_1st'] = {
    name = '1st Degree Burn', category = Injuries.Categories.BURN,
    description = 'Superficial burn', zones = 'all',
    effects = {pain = true}, vitals_impact = {heart_rate = 5}
}

Injuries.Definitions['burn_2nd'] = {
    name = '2nd Degree Burn', category = Injuries.Categories.BURN,
    description = 'Partial thickness burn', zones = 'all',
    effects = {severe_pain = true, blistering = true},
    vitals_impact = {heart_rate = 15, temperature = 0.5}
}

Injuries.Definitions['burn_3rd'] = {
    name = '3rd Degree Burn', category = Injuries.Categories.BURN,
    description = 'Full thickness burn', zones = 'all',
    effects = {severe_pain = true, shock_risk = true},
    vitals_impact = {heart_rate = 30, blood_pressure = -20, consciousness = -1}
}

-- MEDICAL EMERGENCIES
Injuries.Definitions['cardiac_arrest'] = {
    name = 'Cardiac Arrest', category = Injuries.Categories.MEDICAL,
    description = 'Heart stopped', zones = {Injuries.BodyZones.CHEST},
    effects = {no_pulse = true, unconscious = true, no_breathing = true},
    vitals_impact = {heart_rate = -100, blood_pressure = -100, oxygen_sat = -50, consciousness = -4}
}

Injuries.Definitions['heart_attack'] = {
    name = 'Heart Attack', category = Injuries.Categories.MEDICAL,
    description = 'Myocardial infarction', zones = {Injuries.BodyZones.CHEST},
    effects = {chest_pain = true, breathing_difficulty = true},
    vitals_impact = {heart_rate = -20, blood_pressure = -25, oxygen_sat = -10}
}

Injuries.Definitions['stroke'] = {
    name = 'Stroke', category = Injuries.Categories.MEDICAL,
    description = 'Brain blood flow interruption', zones = {Injuries.BodyZones.HEAD},
    effects = {neuro_impairment = true, weakness = true},
    vitals_impact = {blood_pressure = 20, consciousness = -2}
}

Injuries.Definitions['asthma_attack'] = {
    name = 'Asthma Attack', category = Injuries.Categories.MEDICAL,
    description = 'Severe bronchospasm', zones = {Injuries.BodyZones.CHEST},
    effects = {breathing_difficulty = true, wheezing = true},
    vitals_impact = {heart_rate = 25, respiratory_rate = 20, oxygen_sat = -15}
}

Injuries.Definitions['seizure'] = {
    name = 'Seizure', category = Injuries.Categories.MEDICAL,
    description = 'Abnormal brain activity', zones = {Injuries.BodyZones.HEAD},
    effects = {convulsions = true, consciousness_loss = true},
    vitals_impact = {heart_rate = 30, consciousness = -3}
}

Injuries.Definitions['overdose'] = {
    name = 'Drug Overdose', category = Injuries.Categories.MEDICAL,
    description = 'Drug toxicity', zones = {Injuries.BodyZones.HEAD},
    effects = {respiratory_depression = true, unconscious = true},
    vitals_impact = {heart_rate = -30, respiratory_rate = -15, oxygen_sat = -30, consciousness = -3}
}

Injuries.Definitions['anaphylaxis'] = {
    name = 'Anaphylaxis', category = Injuries.Categories.MEDICAL,
    description = 'Severe allergic reaction', zones = {Injuries.BodyZones.CHEST},
    effects = {breathing_difficulty = true, swelling = true},
    vitals_impact = {heart_rate = 30, blood_pressure = -35, oxygen_sat = -25, consciousness = -2}
}

-- ENVIRONMENTAL
Injuries.Definitions['hypothermia'] = {
    name = 'Hypothermia', category = Injuries.Categories.ENVIRONMENTAL,
    description = 'Dangerously low body temperature', zones = 'all',
    effects = {shivering = true, confusion = true},
    vitals_impact = {heart_rate = -25, temperature = -5, consciousness = -2}
}

Injuries.Definitions['heat_stroke'] = {
    name = 'Heat Stroke', category = Injuries.Categories.ENVIRONMENTAL,
    description = 'Life-threatening hyperthermia', zones = 'all',
    effects = {confusion = true, seizure_risk = true},
    vitals_impact = {heart_rate = 35, temperature = 5, consciousness = -2}
}

Injuries.Definitions['drowning'] = {
    name = 'Drowning', category = Injuries.Categories.ENVIRONMENTAL,
    description = 'Water aspiration', zones = {Injuries.BodyZones.CHEST},
    effects = {respiratory_distress = true, hypoxia = true},
    vitals_impact = {oxygen_sat = -40, consciousness = -3}
}

-- INTERNAL INJURIES
Injuries.Definitions['internal_bleeding'] = {
    name = 'Internal Bleeding', category = Injuries.Categories.INTERNAL,
    description = 'Hidden hemorrhage', zones = {Injuries.BodyZones.CHEST, Injuries.BodyZones.ABDOMEN},
    effects = {hidden_bleeding = true, shock_risk = true},
    vitals_impact = {heart_rate = 25, blood_pressure = -20}
}

Injuries.Definitions['pneumothorax'] = {
    name = 'Pneumothorax', category = Injuries.Categories.INTERNAL,
    description = 'Collapsed lung', zones = {Injuries.BodyZones.CHEST},
    effects = {breathing_difficulty = true, chest_pain = true},
    vitals_impact = {respiratory_rate = 15, oxygen_sat = -20, heart_rate = 20}
}

Injuries.Definitions['concussion'] = {
    name = 'Concussion', category = Injuries.Categories.INTERNAL,
    description = 'Mild brain injury', zones = {Injuries.BodyZones.HEAD},
    effects = {confusion = true, headache = true},
    vitals_impact = {consciousness = -1}
}
