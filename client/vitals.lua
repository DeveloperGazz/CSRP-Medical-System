-- ==========================================
-- VITALS SYSTEM
-- Dynamic vital signs monitoring
-- ==========================================

-- Initialize vitals with normal values
function InitializeVitals()
    return {
        heartRate = 75,
        bloodPressureSystolic = 120,
        bloodPressureDiastolic = 80,
        respiratoryRate = 16,
        oxygenSaturation = 98,
        temperature = 36.8,
        consciousness = Config.VitalSigns.Consciousness.Alert,
        pupilResponse = 'normal',
        bloodVolume = 100, -- Percentage
        pain = 0 -- 0-10 scale
    }
end

-- Calculate vitals based on injuries
function CalculateVitals(injuries, currentVitals)
    local vitals = {}
    
    -- Start with baseline normal values
    vitals.heartRate = 75
    vitals.bloodPressureSystolic = 120
    vitals.bloodPressureDiastolic = 80
    vitals.respiratoryRate = 16
    vitals.oxygenSaturation = 98
    vitals.temperature = 36.8
    vitals.consciousness = Config.VitalSigns.Consciousness.Alert
    vitals.pupilResponse = 'normal'
    vitals.pain = 0
    
    -- Apply injury effects
    for _, injury in pairs(injuries) do
        local injuryDef = Injuries.GetInjury(injury.type)
        if injuryDef and injuryDef.vitals_impact then
            local impact = injuryDef.vitals_impact
            local severity = injury.severity or 1
            
            if impact.heart_rate then
                vitals.heartRate = vitals.heartRate + (impact.heart_rate * severity)
            end
            
            if impact.blood_pressure then
                vitals.bloodPressureSystolic = vitals.bloodPressureSystolic + (impact.blood_pressure * severity)
                vitals.bloodPressureDiastolic = vitals.bloodPressureDiastolic + (impact.blood_pressure * Config.Progression.DiastolicRatio * severity)
            end
            
            if impact.oxygen_sat then
                vitals.oxygenSaturation = vitals.oxygenSaturation + (impact.oxygen_sat * severity)
            end
            
            if impact.respiratory_rate then
                vitals.respiratoryRate = vitals.respiratoryRate + (impact.respiratory_rate * severity)
            end
            
            if impact.temperature then
                vitals.temperature = vitals.temperature + (impact.temperature * severity)
            end
            
            if impact.consciousness then
                vitals.consciousness = math.max(1, vitals.consciousness + (impact.consciousness * severity))
            end
            
            if impact.pupil_abnormal then
                vitals.pupilResponse = 'abnormal'
            end
            
            -- Increase pain based on injury effects
            if injuryDef.effects.pain or injuryDef.effects.severe_pain then
                vitals.pain = vitals.pain + (severity * 2)
            end
        end
    end
    
    -- Blood loss effects
    local bloodVolume = currentVitals.bloodVolume or 100
    if bloodVolume < 80 then
        vitals.heartRate = vitals.heartRate + (20 * (1 - bloodVolume/100))
        vitals.bloodPressureSystolic = vitals.bloodPressureSystolic - (40 * (1 - bloodVolume/100))
        vitals.oxygenSaturation = vitals.oxygenSaturation - (20 * (1 - bloodVolume/100))
    end
    
    -- Clamp values to realistic ranges
    vitals.heartRate = math.max(0, math.min(200, vitals.heartRate))
    vitals.bloodPressureSystolic = math.max(0, math.min(200, vitals.bloodPressureSystolic))
    vitals.bloodPressureDiastolic = math.max(0, math.min(140, vitals.bloodPressureDiastolic))
    vitals.respiratoryRate = math.max(0, math.min(60, vitals.respiratoryRate))
    vitals.oxygenSaturation = math.max(0, math.min(100, vitals.oxygenSaturation))
    vitals.temperature = math.max(30, math.min(45, vitals.temperature))
    vitals.consciousness = math.max(1, math.min(4, vitals.consciousness))
    vitals.pain = math.max(0, math.min(10, vitals.pain))
    vitals.bloodVolume = bloodVolume
    
    return vitals
end

-- Vitals update thread
function VitalsThread()
    Citizen.CreateThread(function()
        while true do
            Wait(Config.VitalSigns.HeartRate.UpdateInterval)
            
            local injuries = GetPlayerInjuries()
            local currentVitals = GetPlayerVitals()
            
            -- Recalculate vitals
            local newVitals = CalculateVitals(injuries, currentVitals)
            
            -- Update player vitals
            for key, value in pairs(newVitals) do
                currentVitals[key] = value
            end
            
            -- Send to UI
            SendNUIMessage({
                type = 'updateVitals',
                vitals = currentVitals
            })
            
            -- Check for critical conditions
            CheckCriticalConditions(currentVitals)
        end
    end)
end

-- Check for critical vital signs
function CheckCriticalConditions(vitals)
    -- Cardiac arrest
    if vitals.heartRate <= 0 then
        if Config.Debug then
            print('[CSRP Medical] Cardiac arrest detected')
        end
    end
    
    -- Severe hypoxia
    if vitals.oxygenSaturation < 70 then
        if Config.Debug then
            print('[CSRP Medical] Severe hypoxia')
        end
    end
    
    -- Unconscious
    if vitals.consciousness <= 1 then
        if Config.Debug then
            print('[CSRP Medical] Patient unconscious')
        end
    end
end

-- Get vital sign status (normal, low, high, critical)
function GetVitalStatus(vitalName, value)
    local config = Config.VitalSigns[vitalName]
    if not config then return 'unknown' end
    
    if config.Critical then
        if value >= config.Critical.min and value <= config.Critical.max then
            return 'critical'
        end
    end
    
    if config.Normal then
        if value >= config.Normal.min and value <= config.Normal.max then
            return 'normal'
        end
    end
    
    if config.Low then
        if value >= config.Low.min and value <= config.Low.max then
            return 'low'
        end
    end
    
    if config.High then
        if value >= config.High.min and value <= config.High.max then
            return 'high'
        end
    end
    
    return 'abnormal'
end
