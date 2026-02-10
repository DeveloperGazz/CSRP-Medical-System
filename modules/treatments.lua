-- ==========================================
-- TREATMENT DEFINITIONS MODULE
-- All UK paramedic treatments and interventions
-- ==========================================

Treatments = {}

-- Treatment categories
Treatments.Categories = {
    AIRWAY = 'airway',
    BREATHING = 'breathing',
    CIRCULATION = 'circulation',
    FRACTURE = 'fracture',
    MEDICATION = 'medication',
    OTHER = 'other'
}

-- Treatment definitions
Treatments.Definitions = {
    -- AIRWAY MANAGEMENT
    ['head_tilt'] = {
        name = 'Head Tilt/Chin Lift',
        category = Treatments.Categories.AIRWAY,
        description = 'Open airway by tilting head',
        duration = 2000,
        uses_equipment = false,
        effects = {airway_open = true},
        vitals_effect = {consciousness = 1}
    },
    
    ['recovery_position'] = {
        name = 'Recovery Position',
        category = Treatments.Categories.AIRWAY,
        description = 'Place unconscious patient on side',
        duration = 3000,
        uses_equipment = false,
        effects = {airway_protected = true, aspiration_prevented = true},
        vitals_effect = {consciousness = 1}
    },
    
    ['opa'] = {
        name = 'Oropharyngeal Airway (OPA)',
        category = Treatments.Categories.AIRWAY,
        description = 'Insert oral airway adjunct',
        duration = 5000,
        uses_equipment = true,
        equipment = 'OPA',
        effects = {airway_open = true},
        vitals_effect = {oxygen_sat = 5}
    },
    
    ['npa'] = {
        name = 'Nasopharyngeal Airway (NPA)',
        category = Treatments.Categories.AIRWAY,
        description = 'Insert nasal airway adjunct',
        duration = 5000,
        uses_equipment = true,
        equipment = 'NPA',
        effects = {airway_open = true},
        vitals_effect = {oxygen_sat = 5}
    },
    
    ['suction'] = {
        name = 'Suction',
        category = Treatments.Categories.AIRWAY,
        description = 'Clear airway of fluids',
        duration = 4000,
        uses_equipment = true,
        equipment = 'SuctionUses',
        effects = {airway_clear = true},
        vitals_effect = {oxygen_sat = 10}
    },
    
    -- BREATHING SUPPORT
    ['oxygen_cannula'] = {
        name = 'Nasal Cannula O2',
        category = Treatments.Categories.BREATHING,
        description = 'Low-flow oxygen delivery',
        duration = 3000,
        uses_equipment = true,
        equipment = 'OxygenMinutes',
        equipment_usage = 15,
        effects = {oxygen_therapy = true},
        vitals_effect = {oxygen_sat = 10}
    },
    
    ['oxygen_mask'] = {
        name = 'Non-Rebreather Mask',
        category = Treatments.Categories.BREATHING,
        description = 'High-flow oxygen delivery',
        duration = 3000,
        uses_equipment = true,
        equipment = 'OxygenMinutes',
        equipment_usage = 30,
        effects = {oxygen_therapy = true},
        vitals_effect = {oxygen_sat = 20}
    },
    
    ['bvm'] = {
        name = 'Bag-Valve-Mask',
        category = Treatments.Categories.BREATHING,
        description = 'Manual ventilation',
        duration = 10000,
        uses_equipment = true,
        equipment = 'BVM',
        effects = {assisted_breathing = true},
        vitals_effect = {oxygen_sat = 25, respiratory_rate = 12}
    },
    
    ['chest_seal'] = {
        name = 'Chest Seal',
        category = Treatments.Categories.BREATHING,
        description = 'Seal penetrating chest wound',
        duration = 7000,
        uses_equipment = true,
        equipment = 'ChestSeals',
        effects = {chest_wound_sealed = true},
        vitals_effect = {oxygen_sat = 15, respiratory_rate = -5}
    },
    
    ['needle_decompression'] = {
        name = 'Needle Decompression',
        category = Treatments.Categories.BREATHING,
        description = 'Relieve tension pneumothorax',
        duration = 8000,
        uses_equipment = true,
        equipment = 'NeedleDecompression',
        effects = {tension_pneumothorax_relieved = true},
        vitals_effect = {oxygen_sat = 30, respiratory_rate = -10, blood_pressure = 15}
    },
    
    -- BLEEDING CONTROL
    ['direct_pressure'] = {
        name = 'Direct Pressure',
        category = Treatments.Categories.CIRCULATION,
        description = 'Apply direct pressure to wound',
        duration = 5000,
        uses_equipment = false,
        effects = {bleeding_reduced = 0.3},
        vitals_effect = {}
    },
    
    ['pressure_dressing'] = {
        name = 'Pressure Dressing',
        category = Treatments.Categories.CIRCULATION,
        description = 'Bandage with pressure',
        duration = 8000,
        uses_equipment = true,
        equipment = 'PressureDressings',
        effects = {bleeding_reduced = 0.6},
        vitals_effect = {}
    },
    
    ['tourniquet'] = {
        name = 'Tourniquet',
        category = Treatments.Categories.CIRCULATION,
        description = 'Stop limb hemorrhage',
        duration = 6000,
        uses_equipment = true,
        equipment = 'Tourniquets',
        effects = {bleeding_stopped = 1.0},
        vitals_effect = {blood_pressure = 5}
    },
    
    ['hemostatic_gauze'] = {
        name = 'Hemostatic Gauze',
        category = Treatments.Categories.CIRCULATION,
        description = 'Clotting agent dressing',
        duration = 10000,
        uses_equipment = true,
        equipment = 'HemostaticGauze',
        effects = {bleeding_reduced = 0.8},
        vitals_effect = {}
    },
    
    ['pelvic_binder'] = {
        name = 'Pelvic Binder',
        category = Treatments.Categories.CIRCULATION,
        description = 'Stabilize pelvic fracture',
        duration = 12000,
        uses_equipment = true,
        equipment = 'PelvicBinder',
        effects = {pelvic_stabilized = true, bleeding_reduced = 0.5},
        vitals_effect = {blood_pressure = 10}
    },
    
    ['iv_fluids'] = {
        name = 'IV Fluid Administration',
        category = Treatments.Categories.CIRCULATION,
        description = 'Intravenous crystalloid',
        duration = 15000,
        uses_equipment = true,
        equipment = 'IVBags',
        effects = {blood_volume_restored = 0.2},
        vitals_effect = {blood_pressure = 15, heart_rate = -10}
    },
    
    -- FRACTURE MANAGEMENT
    ['splint'] = {
        name = 'Splinting',
        category = Treatments.Categories.FRACTURE,
        description = 'Immobilize fracture',
        duration = 10000,
        uses_equipment = true,
        equipment = 'Splints',
        effects = {fracture_stabilized = true, pain_reduced = 0.4},
        vitals_effect = {heart_rate = -5}
    },
    
    ['cervical_collar'] = {
        name = 'Cervical Collar',
        category = Treatments.Categories.FRACTURE,
        description = 'Spinal precaution',
        duration = 5000,
        uses_equipment = true,
        equipment = 'CervicalCollars',
        effects = {c_spine_protected = true},
        vitals_effect = {}
    },
    
    -- CPR/DEFIB
    ['cpr'] = {
        name = 'CPR',
        category = Treatments.Categories.OTHER,
        description = 'Cardiopulmonary resuscitation',
        duration = 30000,
        uses_equipment = false,
        effects = {circulation_maintained = true},
        vitals_effect = {heart_rate = 60, consciousness = 1}
    },
    
    ['defibrillation'] = {
        name = 'Defibrillation',
        category = Treatments.Categories.OTHER,
        description = 'Shock heart rhythm',
        duration = 10000,
        uses_equipment = true,
        equipment = 'Defibrillator',
        effects = {rhythm_restored = true},
        vitals_effect = {heart_rate = 80, consciousness = 2}
    },
    
    -- MEDICATIONS
    ['paracetamol'] = {
        name = 'Paracetamol',
        category = Treatments.Categories.MEDICATION,
        description = 'Mild pain relief',
        duration = 5000,
        uses_equipment = true,
        equipment = 'Paracetamol',
        effects = {pain_reduced = 0.3},
        vitals_effect = {}
    },
    
    ['morphine'] = {
        name = 'Morphine',
        category = Treatments.Categories.MEDICATION,
        description = 'Strong opioid analgesia',
        duration = 7000,
        uses_equipment = true,
        equipment = 'Morphine',
        effects = {pain_reduced = 0.7},
        vitals_effect = {heart_rate = -10, respiratory_rate = -3}
    },
    
    ['adrenaline'] = {
        name = 'Adrenaline',
        category = Treatments.Categories.MEDICATION,
        description = 'Emergency cardiac/anaphylaxis',
        duration = 5000,
        uses_equipment = true,
        equipment = 'Adrenaline',
        effects = {cardiac_support = true, anaphylaxis_reversed = true},
        vitals_effect = {heart_rate = 20, blood_pressure = 20}
    },
    
    ['aspirin'] = {
        name = 'Aspirin',
        category = Treatments.Categories.MEDICATION,
        description = 'Antiplatelet for chest pain',
        duration = 4000,
        uses_equipment = true,
        equipment = 'Aspirin',
        effects = {antiplatelet = true},
        vitals_effect = {}
    },
    
    ['gtn'] = {
        name = 'GTN Spray',
        category = Treatments.Categories.MEDICATION,
        description = 'Vasodilator for angina',
        duration = 3000,
        uses_equipment = true,
        equipment = 'GTN',
        effects = {vasodilation = true},
        vitals_effect = {blood_pressure = -10}
    },
    
    ['salbutamol'] = {
        name = 'Salbutamol',
        category = Treatments.Categories.MEDICATION,
        description = 'Bronchodilator for asthma',
        duration = 5000,
        uses_equipment = true,
        equipment = 'Salbutamol',
        effects = {bronchodilation = true},
        vitals_effect = {oxygen_sat = 15, respiratory_rate = -5}
    },
    
    ['glucose'] = {
        name = 'Glucose Gel',
        category = Treatments.Categories.MEDICATION,
        description = 'Treat hypoglycemia',
        duration = 4000,
        uses_equipment = true,
        equipment = 'Glucose',
        effects = {blood_sugar_raised = true},
        vitals_effect = {consciousness = 2}
    },
    
    ['naloxone'] = {
        name = 'Naloxone',
        category = Treatments.Categories.MEDICATION,
        description = 'Opioid reversal agent',
        duration = 5000,
        uses_equipment = true,
        equipment = 'Naloxone',
        effects = {opioid_reversed = true},
        vitals_effect = {respiratory_rate = 10, consciousness = 3, oxygen_sat = 20}
    },
    
    ['midazolam'] = {
        name = 'Midazolam',
        category = Treatments.Categories.MEDICATION,
        description = 'Stop seizures',
        duration = 6000,
        uses_equipment = true,
        equipment = 'Midazolam',
        effects = {seizure_stopped = true},
        vitals_effect = {consciousness = -1}
    },
    
    -- WOUND CARE
    ['bandage'] = {
        name = 'Bandage',
        category = Treatments.Categories.OTHER,
        description = 'Basic wound dressing',
        duration = 5000,
        uses_equipment = true,
        equipment = 'Bandages',
        effects = {wound_dressed = true, bleeding_reduced = 0.4},
        vitals_effect = {}
    },
    
    ['burn_dressing'] = {
        name = 'Burn Dressing',
        category = Treatments.Categories.OTHER,
        description = 'Specialized burn care',
        duration = 8000,
        uses_equipment = true,
        equipment = 'BurnDressings',
        effects = {burn_treated = true},
        vitals_effect = {heart_rate = -5}
    },
    
    ['thermal_blanket'] = {
        name = 'Thermal Blanket',
        category = Treatments.Categories.OTHER,
        description = 'Warming for hypothermia',
        duration = 5000,
        uses_equipment = true,
        equipment = 'ThermalBlanket',
        effects = {warming = true},
        vitals_effect = {temperature = 1}
    },
    
    ['cooling'] = {
        name = 'Cooling Measures',
        category = Treatments.Categories.OTHER,
        description = 'Cool for heat stroke',
        duration = 10000,
        uses_equipment = true,
        equipment = 'CoolingPacks',
        effects = {cooling = true},
        vitals_effect = {temperature = -2}
    }
}

-- Helper functions
function Treatments.GetTreatment(treatmentId)
    return Treatments.Definitions[treatmentId]
end

function Treatments.GetByCategory(category)
    local result = {}
    for id, treatment in pairs(Treatments.Definitions) do
        if treatment.category == category then
            result[id] = treatment
        end
    end
    return result
end
