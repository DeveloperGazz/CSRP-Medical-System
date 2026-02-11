-- ==========================================
-- SYNC SYSTEM
-- Synchronize player states across clients
-- ==========================================

-- Sync injury to other players
RegisterNetEvent('csrp_medical:syncInjury')
AddEventHandler('csrp_medical:syncInjury', function(injury)
    local source = source
    local playerData = GetPlayerData(source)
    
    table.insert(playerData.injuries, injury)
    
    if Config.Debug then
        print('[CSRP Medical] Synced injury for player ' .. source)
    end
end)

-- Apply treatment from paramedic to patient
RegisterNetEvent('csrp_medical:applyTreatment')
AddEventHandler('csrp_medical:applyTreatment', function(targetId, treatmentId, injuryId)
    local source = source
    
    if Config.Debug then
        print('[CSRP Medical] Player ' .. source .. ' applying ' .. treatmentId .. ' to player ' .. targetId)
    end
    
    -- Send treatment to target player
    TriggerClientEvent('csrp_medical:receiveTreatment', targetId, treatmentId, injuryId)
    
    -- Log treatment
    local playerData = GetPlayerData(targetId)
    if not playerData.treatmentLog then
        playerData.treatmentLog = {}
    end
    
    table.insert(playerData.treatmentLog, {
        treatment = treatmentId,
        injuryId = injuryId,
        treatedBy = source,
        timestamp = os.time()
    })
end)

-- Request vitals from target player
RegisterNetEvent('csrp_medical:requestVitals')
AddEventHandler('csrp_medical:requestVitals', function(targetId)
    local source = source
    
    -- In a real implementation, this would query the target's vitals
    -- For now, we'll send a request to the target client
    TriggerClientEvent('csrp_medical:sendVitals', targetId, source)
end)

-- Send vitals to requesting paramedic
RegisterNetEvent('csrp_medical:sendVitals')
AddEventHandler('csrp_medical:sendVitals', function(paramedicId, vitals)
    TriggerClientEvent('csrp_medical:receiveVitals', paramedicId, vitals)
end)

-- Request full assessment
RegisterNetEvent('csrp_medical:requestFullAssessment')
AddEventHandler('csrp_medical:requestFullAssessment', function(targetId)
    local source = source
    TriggerClientEvent('csrp_medical:sendFullAssessment', targetId, source)
end)

-- Request patient data for paramedic menu
RegisterNetEvent('csrp_medical:requestPatientData')
AddEventHandler('csrp_medical:requestPatientData', function(targetId)
    local source = source
    
    if Config.Debug then
        print('[CSRP Medical] Player ' .. source .. ' requesting data for patient ' .. targetId)
    end
    
    -- Request patient to send their data to the paramedic
    TriggerClientEvent('csrp_medical:sendPatientData', targetId, source)
end)

-- Relay patient data back to paramedic
RegisterNetEvent('csrp_medical:sendPatientDataToParamedic')
AddEventHandler('csrp_medical:sendPatientDataToParamedic', function(paramedicId, patientData)
    if Config.Debug then
        print('[CSRP Medical] Sending patient data to paramedic ' .. paramedicId)
    end
    
    TriggerClientEvent('csrp_medical:receivePatientData', paramedicId, patientData)
end)

-- Player death notification
RegisterNetEvent('csrp_medical:playerDied')
AddEventHandler('csrp_medical:playerDied', function(injuryInfo)
    local source = source
    local playerData = GetPlayerData(source)
    playerData.isDead = true
    playerData.deathCause = injuryInfo
    playerData.deathTime = os.time()

    if Config.Debug then
        print('[CSRP Medical] Player ' .. source .. ' died - Cause: ' .. (injuryInfo.injury or 'unknown'))
    end
end)

-- Player respawned
RegisterNetEvent('csrp_medical:playerRespawned')
AddEventHandler('csrp_medical:playerRespawned', function()
    local source = source
    local playerData = GetPlayerData(source)
    playerData.isDead = false
    playerData.deathCause = nil

    if Config.Debug then
        print('[CSRP Medical] Player ' .. source .. ' respawned')
    end
end)

-- Scenario started
RegisterNetEvent('csrp_medical:scenarioStarted')
AddEventHandler('csrp_medical:scenarioStarted', function(scenarioId, scenarioName)
    local source = source
    local playerData = GetPlayerData(source)
    playerData.activeScenario = scenarioId

    if Config.Debug then
        print('[CSRP Medical] Player ' .. source .. ' started scenario: ' .. (scenarioName or scenarioId))
    end
end)

-- Revive player command (paramedic)
RegisterNetEvent('csrp_medical:requestRevive')
AddEventHandler('csrp_medical:requestRevive', function(targetId)
    local source = source

    if Config.Debug then
        print('[CSRP Medical] Player ' .. source .. ' requesting revive for player ' .. targetId)
    end

    TriggerClientEvent('csrp_medical:revivePlayer', targetId)

    local playerData = GetPlayerData(targetId)
    playerData.isDead = false
    playerData.deathCause = nil
end)
