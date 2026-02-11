-- ==========================================
-- PSYCHOLOGICAL SYSTEM
-- Mental health and psychological effects
-- ==========================================

-- Psychological state
local psychologicalState = {
    stress = 0, -- 0-100
    trauma = 0, -- 0-100
    anxiety = 0, -- 0-100
    ptsd = false,
    phobias = {}
}

-- Stress triggers
local stressTriggers = {
    witnessedDeath = 20,
    severeInjury = 15,
    gunfire = 10,
    explosion = 25,
    beingShot = 30,
    nearDeath = 40
}

-- Increase stress
function IncreaseStress(amount, reason)
    psychologicalState.stress = math.min(100, psychologicalState.stress + amount)
    
    if Config and Config.Debug then
        print('[CSRP Medical] Stress increased by ' .. amount .. ' (' .. reason .. '). Current: ' .. psychologicalState.stress)
    end
    
    -- Check for trauma development
    if psychologicalState.stress >= 80 then
        psychologicalState.trauma = math.min(100, psychologicalState.trauma + 5)
        
        -- PTSD development
        if psychologicalState.trauma >= 60 and not psychologicalState.ptsd then
            if math.random() < 0.3 then
                psychologicalState.ptsd = true
                TriggerEvent('chat:addMessage', {
                    args = {'Mental Health', 'You are experiencing symptoms of PTSD'}
                })
            end
        end
    end
end

-- Decrease stress over time
Citizen.CreateThread(function()
    while true do
        Wait(60000) -- Every minute
        
        -- Natural stress reduction
        if psychologicalState.stress > 0 then
            psychologicalState.stress = math.max(0, psychologicalState.stress - 2)
        end
        
        -- Anxiety reduction
        if psychologicalState.anxiety > 0 then
            psychologicalState.anxiety = math.max(0, psychologicalState.anxiety - 3)
        end
    end
end)

-- Event handlers for stress triggers
RegisterNetEvent('csrp:medical:witnessedDeath')
AddEventHandler('csrp:medical:witnessedDeath', function()
    IncreaseStress(stressTriggers.witnessedDeath, 'witnessed death')
end)

RegisterNetEvent('csrp:medical:severeInjuryReceived')
AddEventHandler('csrp:medical:severeInjuryReceived', function()
    IncreaseStress(stressTriggers.severeInjury, 'severe injury')
    psychologicalState.anxiety = math.min(100, psychologicalState.anxiety + 20)
end)

RegisterNetEvent('csrp:medical:heardGunfire')
AddEventHandler('csrp:medical:heardGunfire', function()
    IncreaseStress(stressTriggers.gunfire, 'heard gunfire')
end)

RegisterNetEvent('csrp:medical:nearExplosion')
AddEventHandler('csrp:medical:nearExplosion', function()
    IncreaseStress(stressTriggers.explosion, 'near explosion')
end)

RegisterNetEvent('csrp:medical:shotBy')
AddEventHandler('csrp:medical:shotBy', function()
    IncreaseStress(stressTriggers.beingShot, 'shot by weapon')
    psychologicalState.anxiety = math.min(100, psychologicalState.anxiety + 30)
end)

RegisterNetEvent('csrp:medical:nearDeath')
AddEventHandler('csrp:medical:nearDeath', function()
    IncreaseStress(stressTriggers.nearDeath, 'near death experience')
    psychologicalState.trauma = math.min(100, psychologicalState.trauma + 15)
end)

-- Visual effects based on psychological state
Citizen.CreateThread(function()
    while true do
        Wait(100)
        
        local playerPed = PlayerPedId()
        
        -- High stress effects
        if psychologicalState.stress >= 70 then
            -- Screen shake
            if math.random() < 0.1 then
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.05)
            end
        end
        
        -- High anxiety effects
        if psychologicalState.anxiety >= 60 then
            -- Increased heart rate (visual)
            if math.random() < 0.05 then
                PlaySoundFrontend(-1, 'HEARTBEAT', 'SHOOTING_RANGE_SOUNDSET', true)
            end
        end
        
        -- PTSD flashbacks
        if psychologicalState.ptsd then
            if math.random() < 0.001 then -- Very rare
                -- Trigger flashback
                SetTimecycleModifier('rply_motionblur')
                SetTimecycleModifierStrength(0.5)
                
                Citizen.CreateThread(function()
                    Wait(2000)
                    ClearTimecycleModifier()
                end)
                
                TriggerEvent('chat:addMessage', {
                    args = {'Mental Health', 'Experiencing flashback...'}
                })
            end
        end
    end
end)

-- Therapy/Treatment
RegisterNetEvent('csrp:medical:receivePsychotherapy')
AddEventHandler('csrp:medical:receivePsychotherapy', function()
    psychologicalState.stress = math.max(0, psychologicalState.stress - 20)
    psychologicalState.anxiety = math.max(0, psychologicalState.anxiety - 30)
    psychologicalState.trauma = math.max(0, psychologicalState.trauma - 10)
    
    TriggerEvent('chat:addMessage', {
        args = {'Mental Health', 'You feel calmer after talking to someone'}
    })
    
    if Config and Config.Debug then
        print('[CSRP Medical] Received psychotherapy')
    end
end)

-- Reset psychological state
RegisterNetEvent('csrp:medical:resetPsychological')
AddEventHandler('csrp:medical:resetPsychological', function()
    psychologicalState = {
        stress = 0,
        trauma = 0,
        anxiety = 0,
        ptsd = false,
        phobias = {}
    }
    
    if Config and Config.Debug then
        print('[CSRP Medical] Psychological state reset')
    end
end)

-- Get psychological state
function GetPsychologicalState()
    return psychologicalState
end

-- Export function
exports('GetPsychologicalState', GetPsychologicalState)
exports('IncreaseStress', IncreaseStress)
