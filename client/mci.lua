-- ==========================================
-- MCI SYSTEM
-- Mass Casualty Incident management
-- ==========================================

-- MCI State
local activeMCI = nil
local triagePatients = {}

-- Triage categories (UK METHANE)
local triageCategories = {
    T1 = {name = 'Immediate', color = {255, 0, 0}, priority = 1}, -- Red
    T2 = {name = 'Urgent', color = {255, 165, 0}, priority = 2}, -- Orange
    T3 = {name = 'Delayed', color = {255, 255, 0}, priority = 3}, -- Yellow
    T4 = {name = 'Expectant', color = {0, 0, 0}, priority = 4}, -- Black
    T5 = {name = 'Dead', color = {128, 128, 128}, priority = 5} -- Grey
}

-- Start MCI
RegisterNetEvent('csrp:medical:startMCI')
AddEventHandler('csrp:medical:startMCI', function(location, incidentType)
    activeMCI = {
        location = location,
        type = incidentType,
        startTime = GetGameTimer(),
        patients = {}
    }
    
    -- Notify
    TriggerEvent('chat:addMessage', {
        args = {'MCI Alert', 'Mass Casualty Incident declared: ' .. incidentType}
    })
    
    -- Spawn bystanders/patients if needed
    TriggerEvent('csrp:medical:spawnBystanders', location)
    
    if Config and Config.Debug then
        print('[CSRP Medical] MCI started: ' .. incidentType)
    end
end)

-- End MCI
RegisterNetEvent('csrp:medical:endMCI')
AddEventHandler('csrp:medical:endMCI', function()
    if activeMCI then
        local duration = (GetGameTimer() - activeMCI.startTime) / 1000 / 60
        
        TriggerEvent('chat:addMessage', {
            args = {'MCI', 'Mass Casualty Incident concluded. Duration: ' .. string.format('%.1f', duration) .. ' minutes'}
        })
        
        activeMCI = nil
        triagePatients = {}
        
        -- Clear bystanders
        TriggerEvent('csrp:medical:clearBystanders')
    end
    
    if Config and Config.Debug then
        print('[CSRP Medical] MCI ended')
    end
end)

-- Triage patient
RegisterNetEvent('csrp:medical:triagePatient')
AddEventHandler('csrp:medical:triagePatient', function(patientId, category)
    if activeMCI then
        triagePatients[patientId] = {
            category = category,
            timestamp = GetGameTimer(),
            triager = PlayerId()
        }
        
        -- Notify
        local catInfo = triageCategories[category]
        if catInfo then
            TriggerEvent('chat:addMessage', {
                args = {'Triage', 'Patient classified as: ' .. catInfo.name}
            })
        end
        
        -- Sync to server
        TriggerServerEvent('csrp:medical:syncTriage', patientId, category)
        
        if Config and Config.Debug then
            print('[CSRP Medical] Patient ' .. patientId .. ' triaged as ' .. category)
        end
    end
end)

-- Get MCI status
function GetMCIStatus()
    if activeMCI then
        return {
            active = true,
            type = activeMCI.type,
            location = activeMCI.location,
            duration = (GetGameTimer() - activeMCI.startTime) / 1000,
            patientCount = #activeMCI.patients
        }
    else
        return {active = false}
    end
end

-- Get triage patients
function GetTriagePatients()
    return triagePatients
end

-- Auto-triage based on vitals
function AutoTriage(vitals)
    -- T1 (Immediate) - Life-threatening but salvageable
    if vitals.consciousness == 1 or vitals.heartRate > 120 or vitals.oxygenSaturation < 90 or vitals.systolicBP < 90 then
        return 'T1'
    end
    
    -- T2 (Urgent) - Serious but stable
    if vitals.heartRate > 100 or vitals.oxygenSaturation < 95 or vitals.pain >= 7 then
        return 'T2'
    end
    
    -- T3 (Delayed) - Minor injuries
    if vitals.pain >= 3 then
        return 'T3'
    end
    
    -- Walking wounded
    return 'T3'
end

-- MCI UI Toggle
function ToggleMCIMenu()
    if activeMCI then
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'showMCI',
            data = {
                status = GetMCIStatus(),
                patients = GetTriagePatients(),
                categories = triageCategories
            }
        })
    else
        TriggerEvent('chat:addMessage', {
            args = {'MCI', 'No active Mass Casualty Incident'}
        })
    end
end

-- NUI Callback for MCI actions
RegisterNUICallback('mciAction', function(data, cb)
    if data.action == 'triage' then
        TriggerEvent('csrp:medical:triagePatient', data.patientId, data.category)
    elseif data.action == 'endMCI' then
        TriggerServerEvent('csrp:medical:endMCI')
    elseif data.action == 'close' then
        SetNuiFocus(false, false)
    end
    
    cb('ok')
end)

-- Export functions
exports('GetMCIStatus', GetMCIStatus)
exports('GetTriagePatients', GetTriagePatients)
exports('AutoTriage', AutoTriage)
exports('ToggleMCIMenu', ToggleMCIMenu)
