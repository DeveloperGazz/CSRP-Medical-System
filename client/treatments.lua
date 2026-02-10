-- ==========================================
-- TREATMENTS SYSTEM
-- Apply treatments to patients
-- ==========================================

-- Apply treatment to target player
function ApplyTreatment(targetServerId, treatmentId, injuryId)
    local treatment = Treatments.GetTreatment(treatmentId)
    if not treatment then
        if Config.Debug then
            print('[CSRP Medical] Invalid treatment: ' .. tostring(treatmentId))
        end
        return false
    end
    
    -- Check equipment
    if treatment.uses_equipment then
        local equipment = GetParamedicEquipment()
        local equipmentType = treatment.equipment
        local usage = treatment.equipment_usage or 1
        
        if not Equipment.HasEquipment(equipment, equipmentType, usage) then
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                args = {'Medical System', 'Insufficient equipment: ' .. equipmentType}
            })
            return false
        end
        
        -- Use equipment
        Equipment.UseEquipment(equipment, equipmentType, usage)
    end
    
    -- Play animation
    if Config.Animations and Config.Animations[treatmentId] then
        local anim = Config.Animations[treatmentId]
        PlayTreatmentAnimation(anim.dict, anim.anim, anim.duration)
    else
        Wait(treatment.duration)
    end
    
    -- Apply treatment effects
    TriggerServerEvent('csrp_medical:applyTreatment', targetServerId, treatmentId, injuryId)
    
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        args = {'Medical System', 'Applied: ' .. treatment.name}
    })
    
    return true
end

-- Play treatment animation
function PlayTreatmentAnimation(dict, anim, duration)
    local playerPed = PlayerPedId()
    
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
    
    TaskPlayAnim(playerPed, dict, anim, 8.0, -8.0, duration, 0, 0, false, false, false)
    Wait(duration)
    ClearPedTasks(playerPed)
end

-- Perform ABCDE assessment
function PerformABCDE(targetServerId)
    TriggerEvent('chat:addMessage', {
        args = {'Medical System', 'Performing ABCDE Assessment...'}
    })
    
    PlayTreatmentAnimation('amb@code_human_police_investigate@idle_a', 'idle_b', 8000)
    
    TriggerServerEvent('csrp_medical:requestVitals', targetServerId)
end

-- Perform secondary survey
function PerformSecondarySurvey(targetServerId)
    TriggerEvent('chat:addMessage', {
        args = {'Medical System', 'Performing Secondary Survey...'}
    })
    
    PlayTreatmentAnimation('amb@code_human_police_investigate@idle_a', 'idle_b', 12000)
    
    TriggerServerEvent('csrp_medical:requestFullAssessment', targetServerId)
end

-- Check vitals
function CheckVitals(targetServerId)
    TriggerServerEvent('csrp_medical:requestVitals', targetServerId)
end

-- Apply CPR
function ApplyCPR(targetServerId)
    local treatment = Treatments.GetTreatment('cpr')
    if not treatment then return end
    
    TriggerEvent('chat:addMessage', {
        args = {'Medical System', 'Starting CPR...'}
    })
    
    -- CPR animation loop
    local dict = 'mini@cpr@char_a@cpr_str'
    local anim = 'cpr_pumpchest'
    
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
    
    local playerPed = PlayerPedId()
    TaskPlayAnim(playerPed, dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
    
    -- Simulate CPR for 30 seconds
    Wait(30000)
    ClearPedTasks(playerPed)
    
    TriggerServerEvent('csrp_medical:applyTreatment', targetServerId, 'cpr', nil)
end

-- Defibrillate
function Defibrillate(targetServerId)
    local equipment = GetParamedicEquipment()
    
    if not Equipment.HasEquipment(equipment, 'Defibrillator', 1) then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {'Medical System', 'No defibrillator available'}
        })
        return false
    end
    
    TriggerEvent('chat:addMessage', {
        args = {'Medical System', 'Charging defibrillator...'}
    })
    
    Wait(3000)
    
    TriggerEvent('chat:addMessage', {
        args = {'Medical System', 'CLEAR! Shocking...'}
    })
    
    Wait(2000)
    
    TriggerServerEvent('csrp_medical:applyTreatment', targetServerId, 'defibrillation', nil)
    
    return true
end

-- Register network events for receiving treatment
RegisterNetEvent('csrp_medical:receiveTreatment')
AddEventHandler('csrp_medical:receiveTreatment', function(treatmentId, injuryId)
    local treatment = Treatments.GetTreatment(treatmentId)
    if not treatment then return end
    
    local injuries = GetPlayerInjuries()
    local vitals = GetPlayerVitals()
    
    -- Apply vital effects
    if treatment.vitals_effect then
        for vitalName, change in pairs(treatment.vitals_effect) do
            if vitals[vitalName] then
                vitals[vitalName] = vitals[vitalName] + change
            end
        end
    end
    
    -- Apply injury-specific effects
    if injuryId then
        local injury = GetInjuryById(injuryId)
        if injury and treatment.effects then
            -- Reduce bleeding
            if treatment.effects.bleeding_reduced then
                injury.bleeding = injury.bleeding * (1 - treatment.effects.bleeding_reduced)
            end
            
            if treatment.effects.bleeding_stopped then
                injury.bleeding = 0
            end
            
            -- Mark as treated
            injury.treated = true
            table.insert(injury.treatments, treatmentId)
        end
    end
    
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        args = {'Medical System', 'Received treatment: ' .. treatment.name}
    })
end)
