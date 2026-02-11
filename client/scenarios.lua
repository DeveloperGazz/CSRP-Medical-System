-- ==========================================
-- MEDICAL SCENARIOS SYSTEM
-- Allows players to trigger medical emergencies
-- (heart attack, seizure, stroke, etc.) for RP
-- ==========================================

-- Scenario cooldown tracking
local lastScenarioTime = 0
local activeScenario = nil

-- Available scenarios that players can trigger
local MedicalScenarios = {
    heart_attack = {
        name = 'Heart Attack',
        injury = 'heart_attack',
        zone = 'chest',
        severity = 3,
        duration = 30000, -- ms of animation/effect
        animation = {dict = 'amb@world_human_bum_slumped@male@idle_a', anim = 'idle_a'},
        message = 'You are experiencing severe chest pain!',
        effects = {consciousness = 3, pain = 8}
    },
    cardiac_arrest = {
        name = 'Cardiac Arrest',
        injury = 'cardiac_arrest',
        zone = 'chest',
        severity = 4,
        duration = 0, -- Permanent until treated
        animation = {dict = 'dead', anim = 'dead_a'},
        message = 'You have gone into cardiac arrest!',
        effects = {consciousness = 1, pain = 0}
    },
    seizure = {
        name = 'Seizure',
        injury = 'seizure',
        zone = 'head',
        severity = 3,
        duration = 20000,
        animation = {dict = 'missarmenian2', anim = 'corpse_search_exit_ped'},
        message = 'You are having a seizure!',
        effects = {consciousness = 1, pain = 5}
    },
    stroke = {
        name = 'Stroke',
        injury = 'stroke',
        zone = 'head',
        severity = 3,
        duration = 0,
        animation = {dict = 'amb@world_human_bum_slumped@male@idle_a', anim = 'idle_a'},
        message = 'You are experiencing stroke symptoms!',
        effects = {consciousness = 2, pain = 6}
    },
    asthma_attack = {
        name = 'Asthma Attack',
        injury = 'asthma_attack',
        zone = 'chest',
        severity = 2,
        duration = 15000,
        animation = {dict = 'amb@world_human_bum_slumped@male@idle_a', anim = 'idle_a'},
        message = 'You are having a severe asthma attack!',
        effects = {consciousness = 3, pain = 4}
    },
    anaphylaxis = {
        name = 'Anaphylaxis',
        injury = 'anaphylaxis',
        zone = 'chest',
        severity = 3,
        duration = 0,
        animation = {dict = 'amb@world_human_bum_slumped@male@idle_a', anim = 'idle_a'},
        message = 'You are going into anaphylactic shock!',
        effects = {consciousness = 2, pain = 7}
    },
    overdose = {
        name = 'Drug Overdose',
        injury = 'overdose',
        zone = 'head',
        severity = 3,
        duration = 0,
        animation = {dict = 'dead', anim = 'dead_a'},
        message = 'You are experiencing a drug overdose!',
        effects = {consciousness = 1, pain = 0}
    }
}

-- Trigger a medical scenario
function TriggerMedicalScenario(scenarioId)
    if not Config.Scenarios.Enabled then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {'Medical System', 'Medical scenarios are disabled.'}
        })
        return false
    end

    -- Check cooldown
    local now = GetGameTimer()
    if (now - lastScenarioTime) < Config.Scenarios.Cooldown then
        local remaining = math.ceil((Config.Scenarios.Cooldown - (now - lastScenarioTime)) / 1000)
        TriggerEvent('chat:addMessage', {
            color = {255, 165, 0},
            args = {'Medical System', 'Please wait ' .. remaining .. ' seconds before triggering another scenario.'}
        })
        return false
    end

    -- Check if scenario exists
    local scenario = MedicalScenarios[scenarioId]
    if not scenario then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {'Medical System', 'Unknown scenario: ' .. tostring(scenarioId)}
        })
        return false
    end

    -- Check if already in a scenario
    if activeScenario then
        TriggerEvent('chat:addMessage', {
            color = {255, 165, 0},
            args = {'Medical System', 'You are already in an active medical scenario.'}
        })
        return false
    end

    activeScenario = scenarioId
    lastScenarioTime = now

    -- Apply the injury
    AddInjury(scenario.injury, scenario.zone, scenario.severity)

    -- Update vitals based on scenario effects
    local vitals = GetPlayerVitals()
    if vitals and scenario.effects then
        if scenario.effects.consciousness then
            vitals.consciousness = scenario.effects.consciousness
        end
        if scenario.effects.pain then
            vitals.pain = scenario.effects.pain
        end
    end

    -- Play scenario animation
    local playerPed = PlayerPedId()
    if scenario.animation then
        RequestAnimDict(scenario.animation.dict)
        local timeout = 0
        while not HasAnimDictLoaded(scenario.animation.dict) and timeout < 50 do
            Wait(100)
            timeout = timeout + 1
        end

        if HasAnimDictLoaded(scenario.animation.dict) then
            local duration = scenario.duration > 0 and scenario.duration or -1
            TaskPlayAnim(playerPed, scenario.animation.dict, scenario.animation.anim, 8.0, -8.0, duration, 1, 0, false, false, false)
        end
    end

    -- Notify the player
    TriggerEvent('chat:addMessage', {
        color = {255, 0, 0},
        args = {'Medical System', scenario.message}
    })

    -- Sync to server so paramedics see this player
    TriggerServerEvent('csrp_medical:scenarioStarted', scenarioId, scenario.name)

    if Config.Debug then
        print('[CSRP Medical] Scenario triggered: ' .. scenario.name)
    end

    -- If scenario has a fixed duration, clear it after
    if scenario.duration > 0 then
        Citizen.SetTimeout(scenario.duration, function()
            if activeScenario == scenarioId then
                ClearPedTasks(PlayerPedId())
                activeScenario = nil

                if Config.Debug then
                    print('[CSRP Medical] Scenario animation ended: ' .. scenario.name)
                end
            end
        end)
    end

    return true
end

-- Cancel active scenario (used by paramedics treating the patient)
function CancelMedicalScenario()
    if activeScenario then
        local playerPed = PlayerPedId()
        ClearPedTasks(playerPed)
        activeScenario = nil

        if Config.Debug then
            print('[CSRP Medical] Active scenario cancelled')
        end
    end
end

-- Register the /scenario command
RegisterCommand('scenario', function(source, args, rawCommand)
    if not args[1] then
        TriggerEvent('chat:addMessage', {
            args = {'Medical System', 'Usage: /scenario [type]'}
        })
        TriggerEvent('chat:addMessage', {
            args = {'Medical System', 'Available: heart_attack, cardiac_arrest, seizure, stroke, asthma_attack, anaphylaxis, overdose'}
        })
        return
    end

    TriggerMedicalScenario(args[1])
end, false)

-- Register NUI callback for scenario triggers
RegisterNUICallback('triggerScenario', function(data, cb)
    if data.scenarioId then
        TriggerMedicalScenario(data.scenarioId)
        cb('ok')
    else
        cb('error')
    end
end)

-- Network event: paramedic cancels scenario
RegisterNetEvent('csrp_medical:cancelScenario')
AddEventHandler('csrp_medical:cancelScenario', function()
    CancelMedicalScenario()
end)

-- Get active scenario (export)
function GetActiveScenario()
    return activeScenario
end

exports('GetActiveScenario', GetActiveScenario)
exports('TriggerMedicalScenario', TriggerMedicalScenario)
