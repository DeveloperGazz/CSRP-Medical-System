-- ==========================================
-- PATIENT EXPERIENCE SYSTEM
-- Patient-side effects and feedback
-- ==========================================

-- Patient state
local patientEffects = {
    visionBlur = 0.0,
    hearingMuffled = false,
    painLevel = 0,
    breathingDifficulty = false,
    consciousness = 4 -- AVPU: Alert=4, Voice=3, Pain=2, Unresponsive=1
}

-- Apply screen effects based on patient condition
Citizen.CreateThread(function()
    while true do
        Wait(100)
        
        local vitals = GetPlayerVitals()
        if vitals then
            -- Vision blur based on blood loss and consciousness
            local blurAmount = 0.0
            if vitals.consciousness then
                if vitals.consciousness == 1 then -- Unresponsive
                    blurAmount = 1.0
                elseif vitals.consciousness == 2 then -- Pain
                    blurAmount = 0.6
                elseif vitals.consciousness == 3 then -- Voice
                    blurAmount = 0.3
                end
            end
            
            -- Additional blur from blood loss
            if vitals.bloodVolume then
                local bloodLossPercent = (5000 - vitals.bloodVolume) / 5000
                blurAmount = blurAmount + (bloodLossPercent * 0.5)
            end
            
            -- Apply screen blur
            if blurAmount > 0 then
                SetTimecycleModifier('MenuMGHeistIn')
                SetTimecycleModifierStrength(blurAmount)
                patientEffects.visionBlur = blurAmount
            else
                ClearTimecycleModifier()
                patientEffects.visionBlur = 0.0
            end
            
            -- Check for breathing difficulty
            if vitals.oxygenSaturation and vitals.oxygenSaturation < 90 then
                patientEffects.breathingDifficulty = true
            else
                patientEffects.breathingDifficulty = false
            end
            
            -- Update pain level
            patientEffects.painLevel = vitals.pain or 0
            patientEffects.consciousness = vitals.consciousness or 4
        end
    end
end)

-- Movement restriction based on injuries
Citizen.CreateThread(function()
    while true do
        Wait(0)
        
        local playerPed = PlayerPedId()
        local injuries = GetPlayerInjuries()
        
        if injuries then
            local hasLegInjury = false
            local hasArmInjury = false
            local isCritical = false
            
            for _, injury in ipairs(injuries) do
                -- Check for leg injuries
                if injury.bodyZone == 'left_leg' or injury.bodyZone == 'right_leg' then
                    if injury.severity >= 2 then
                        hasLegInjury = true
                    end
                end
                
                -- Check for arm injuries
                if injury.bodyZone == 'left_arm' or injury.bodyZone == 'right_arm' then
                    if injury.severity >= 2 then
                        hasArmInjury = true
                    end
                end
                
                -- Check for critical condition
                if injury.severity >= 3 then
                    isCritical = true
                end
            end
            
            -- Apply movement restrictions
            if hasLegInjury then
                -- Reduce sprint speed
                if IsPedSprinting(playerPed) then
                    SetPedMoveRateOverride(playerPed, 0.7)
                end
            else
                -- Reset move rate when no leg injury
                SetPedMoveRateOverride(playerPed, 1.0)
            end
            
            -- Disable certain actions if critically injured
            if isCritical or patientEffects.consciousness < 3 then
                DisableControlAction(0, 21, true) -- Sprint
                DisableControlAction(0, 22, true) -- Jump
            end
            
            -- Disable combat if severely injured
            if patientEffects.consciousness < 2 then
                DisablePlayerFiring(playerPed, true)
                DisableControlAction(0, 24, true) -- Attack
                DisableControlAction(0, 25, true) -- Aim
            end
        end
    end
end)

-- Pain sounds and breathing effects
Citizen.CreateThread(function()
    while true do
        Wait(10000) -- Check every 10 seconds
        
        local playerPed = PlayerPedId()
        
        -- Play pain sounds
        if patientEffects.painLevel >= 7 then
            -- Severe pain - groan
            PlayPain(playerPed, 7, 0)
        elseif patientEffects.painLevel >= 4 then
            -- Moderate pain - occasional groan
            if math.random() < 0.3 then
                PlayPain(playerPed, 6, 0)
            end
        end
        
        -- Breathing difficulty
        if patientEffects.breathingDifficulty then
            -- Play breathing difficulty sound/animation
            if math.random() < 0.5 then
                PlayPain(playerPed, 8, 0)
            end
        end
    end
end)

-- Unconsciousness handling
Citizen.CreateThread(function()
    while true do
        Wait(500)
        
        if patientEffects.consciousness == 1 then
            local playerPed = PlayerPedId()
            
            -- Force ragdoll if unconscious
            if not IsPedRagdoll(playerPed) then
                SetPedToRagdoll(playerPed, 10000, 10000, 0, false, false, false)
            end
        end
    end
end)

-- Show status messages to patient
RegisterNetEvent('csrp:medical:showPatientMessage')
AddEventHandler('csrp:medical:showPatientMessage', function(message, messageType)
    -- Display message to patient
    TriggerEvent('chat:addMessage', {
        args = {'Medical Status', message}
    })
    
    -- Could also trigger UI notification
    TriggerEvent('csrp:medical:notification', {
        type = messageType or 'info',
        message = message
    })
end)

-- Get patient effects
function GetPatientEffects()
    return patientEffects
end

-- Export function
exports('GetPatientEffects', GetPatientEffects)
