-- ==========================================
-- COMPLICATIONS SYSTEM
-- Secondary medical complications
-- ==========================================

-- Track active complications
local activeComplications = {}

-- Complication definitions
local complications = {
    {
        id = 'sepsis',
        name = 'Sepsis',
        requiresInjury = {'laceration', 'stab_wound', 'gunshot_wound'},
        chance = 0.1,
        delay = 600000, -- 10 minutes
        effects = {
            heartRate = 20,
            temperature = 2.0,
            bloodPressure = -20
        }
    },
    {
        id = 'compartment_syndrome',
        name = 'Compartment Syndrome',
        requiresInjury = {'fracture_simple', 'fracture_compound', 'crush_injury'},
        chance = 0.15,
        delay = 300000, -- 5 minutes
        effects = {
            pain = 3,
            circulation = -30
        }
    },
    {
        id = 'shock',
        name = 'Hypovolemic Shock',
        requiresBloodLoss = 1000,
        chance = 0.8,
        delay = 120000, -- 2 minutes
        effects = {
            heartRate = 30,
            bloodPressure = -30,
            consciousness = -1
        }
    },
    {
        id = 'respiratory_failure',
        name = 'Respiratory Failure',
        requiresInjury = {'pneumothorax', 'tension_pneumothorax', 'smoke_inhalation'},
        chance = 0.3,
        delay = 180000, -- 3 minutes
        effects = {
            oxygenSaturation = -20,
            respiratoryRate = -10
        }
    }
}

-- Check for and trigger complications
function CheckComplications(injuries, vitals)
    for _, complication in ipairs(complications) do
        -- Check if complication already exists
        local hasComplication = false
        for _, active in ipairs(activeComplications) do
            if active.id == complication.id then
                hasComplication = true
                break
            end
        end
        
        if not hasComplication then
            local shouldTrigger = false
            
            -- Check injury-based triggers
            if complication.requiresInjury then
                for _, injury in ipairs(injuries) do
                    for _, required in ipairs(complication.requiresInjury) do
                        if injury.type == required then
                            if math.random() < complication.chance then
                                shouldTrigger = true
                                break
                            end
                        end
                    end
                end
            end
            
            -- Check blood loss triggers
            if complication.requiresBloodLoss and vitals.bloodVolume then
                local normalBlood = 5000
                local bloodLoss = normalBlood - vitals.bloodVolume
                if bloodLoss >= complication.requiresBloodLoss then
                    if math.random() < complication.chance then
                        shouldTrigger = true
                    end
                end
            end
            
            if shouldTrigger then
                -- Schedule complication
                Citizen.CreateThread(function()
                    Wait(complication.delay)
                    TriggerComplication(complication)
                end)
            end
        end
    end
end

-- Trigger a complication
function TriggerComplication(complication)
    table.insert(activeComplications, {
        id = complication.id,
        name = complication.name,
        effects = complication.effects,
        timestamp = GetGameTimer()
    })
    
    -- Notify player
    TriggerEvent('chat:addMessage', {
        args = {'Medical Alert', 'You are developing ' .. complication.name}
    })
    
    -- Trigger server event for sync
    TriggerServerEvent('csrp:medical:complicationTriggered', complication.id)
    
    if Config and Config.Debug then
        print('[CSRP Medical] Complication triggered: ' .. complication.name)
    end
end

-- Get active complications
function GetActiveComplications()
    return activeComplications
end

-- Apply complication effects to vitals
function ApplyComplicationEffects(vitals)
    if not vitals then
        return vitals
    end
    
    for _, complication in ipairs(activeComplications) do
        if complication.effects.heartRate and vitals.heartRate then
            vitals.heartRate = vitals.heartRate + complication.effects.heartRate
        end
        if complication.effects.bloodPressure then
            if vitals.systolicBP then
                vitals.systolicBP = vitals.systolicBP + complication.effects.bloodPressure
            end
            if vitals.diastolicBP then
                vitals.diastolicBP = vitals.diastolicBP + (complication.effects.bloodPressure * 0.6)
            end
        end
        if complication.effects.oxygenSaturation and vitals.oxygenSaturation then
            vitals.oxygenSaturation = vitals.oxygenSaturation + complication.effects.oxygenSaturation
        end
        if complication.effects.respiratoryRate and vitals.respiratoryRate then
            vitals.respiratoryRate = vitals.respiratoryRate + complication.effects.respiratoryRate
        end
        if complication.effects.temperature and vitals.temperature then
            vitals.temperature = vitals.temperature + complication.effects.temperature
        end
    end
    
    return vitals
end

-- Clear complication
RegisterNetEvent('csrp:medical:clearComplication')
AddEventHandler('csrp:medical:clearComplication', function(complicationId)
    for i = #activeComplications, 1, -1 do
        if activeComplications[i].id == complicationId then
            table.remove(activeComplications, i)
            if Config and Config.Debug then
                print('[CSRP Medical] Cleared complication: ' .. complicationId)
            end
        end
    end
end)

-- Clear all complications
RegisterNetEvent('csrp:medical:clearAllComplications')
AddEventHandler('csrp:medical:clearAllComplications', function()
    activeComplications = {}
    if Config and Config.Debug then
        print('[CSRP Medical] Cleared all complications')
    end
end)

-- Export functions
exports('CheckComplications', CheckComplications)
exports('GetActiveComplications', GetActiveComplications)
exports('ApplyComplicationEffects', ApplyComplicationEffects)
