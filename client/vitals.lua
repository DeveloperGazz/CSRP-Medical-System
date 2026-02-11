-- ==========================================
-- VITALS SYSTEM
-- Dynamic vital signs monitoring
-- ==========================================

-- Initialize vitals with normal values
function InitializeVitals()
    if not Config or not Config.VitalSigns then
        print("^1[ERROR] Config.VitalSigns not loaded!^7")
        return {
            heartRate = 75,
            bloodPressureSystolic = 120,
            bloodPressureDiastolic = 80,
            respiratoryRate = 16,
            oxygenSaturation = 98,
            temperature = 36.8,
            consciousness = 4,
            pupilResponse = 'normal',
            bloodVolume = 100,
            pain = 0
        }
    end
    
    return {
        heartRate = 75,
        bloodPressureSystolic = 120,
        bloodPressureDiastolic = 80,
        respiratoryRate = 16,
        oxygenSaturation = 98,
        temperature = 36.8,
        consciousness = Config.VitalSigns.Consciousness.Alert,
        pupilResponse = 'normal',
        bloodVolume = 100,
        pain = 0
    }
end

-- Vitals monitoring thread
function VitalsThread()
    Citizen.CreateThread(function()
        while true do
            Wait(5000)
            
            local vitals = GetPlayerVitals()
            local injuries = GetPlayerInjuries()
            
            if vitals and injuries then
                local updatedVitals = CalculateVitals(injuries, vitals)
                SendNUIMessage({
                    action = 'updateVitals',
                    vitals = updatedVitals
                })
            end
        end
    end)
end

-- Calculate vitals based on injuries
function CalculateVitals(injuries, currentVitals)
    local vitals = {}
    vitals.heartRate = 75
    vitals.bloodPressureSystolic = 120
    vitals.bloodPressureDiastolic = 80
    vitals.respiratoryRate = 16
    vitals.oxygenSaturation = 98
    vitals.temperature = 36.8
    vitals.consciousness = Config.VitalSigns.Consciousness.Alert
    vitals.pupilResponse = 'normal'
    vitals.pain = 0
    vitals.bloodVolume = currentVitals.bloodVolume or 100
    
    for _, injury in pairs(injuries) do
        if injury.bleeding and injury.bleeding > 0 then
            vitals.heartRate = vitals.heartRate + (injury.bleeding / 10)
            vitals.bloodPressureSystolic = vitals.bloodPressureSystolic - (injury.bleeding / 5)
        end
        if injury.severity then
            vitals.pain = vitals.pain + (injury.severity * 2)
        end
    end
    
    if vitals.bloodVolume < 80 then
        vitals.heartRate = vitals.heartRate + (20 * (1 - vitals.bloodVolume/100))
        vitals.bloodPressureSystolic = vitals.bloodPressureSystolic - (40 * (1 - vitals.bloodVolume/100))
        vitals.oxygenSaturation = vitals.oxygenSaturation - (10 * (1 - vitals.bloodVolume/100))
    end
    
    vitals.heartRate = math.max(0, math.min(200, vitals.heartRate))
    vitals.bloodPressureSystolic = math.max(0, math.min(250, vitals.bloodPressureSystolic))
    vitals.oxygenSaturation = math.max(0, math.min(100, vitals.oxygenSaturation))
    vitals.pain = math.max(0, math.min(100, vitals.pain))
    
    return vitals
end
