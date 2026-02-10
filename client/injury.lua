-- ==========================================
-- INJURY SYSTEM
-- Injury application and management
-- ==========================================

-- Add injury to player
function AddInjury(injuryType, bodyZone, severity)
    local injuries = GetPlayerInjuries()
    
    local injury = {
        id = #injuries + 1,
        type = injuryType,
        zone = bodyZone or 'chest',
        severity = severity or Injuries.Severity.MODERATE,
        timestamp = GetGameTimer(),
        bleeding = 0,
        treated = false,
        treatments = {}
    }
    
    -- Check if injury causes bleeding
    local injuryDef = Injuries.GetInjury(injuryType)
    if injuryDef and injuryDef.effects then
        if injuryDef.effects.severe_bleeding or injuryDef.effects.arterial_bleeding then
            injury.bleeding = 100
        elseif injuryDef.effects.bleeding then
            injury.bleeding = 50
        elseif injuryDef.effects.minor_bleeding then
            injury.bleeding = 20
        end
    end
    
    table.insert(injuries, injury)
    
    if Config.Debug then
        print('[CSRP Medical] Added injury: ' .. injuryType .. ' to ' .. bodyZone)
    end
    
    -- Sync to server
    TriggerServerEvent('csrp_medical:syncInjury', injury)
    
    return injury.id
end

-- Remove injury
function RemoveInjury(injuryId)
    local injuries = GetPlayerInjuries()
    
    for i, injury in ipairs(injuries) do
        if injury.id == injuryId then
            table.remove(injuries, i)
            if Config.Debug then
                print('[CSRP Medical] Removed injury: ' .. injuryId)
            end
            return true
        end
    end
    
    return false
end

-- Get injury by ID
function GetInjuryById(injuryId)
    local injuries = GetPlayerInjuries()
    
    for _, injury in ipairs(injuries) do
        if injury.id == injuryId then
            return injury
        end
    end
    
    return nil
end

-- Update injury
function UpdateInjury(injuryId, updates)
    local injury = GetInjuryById(injuryId)
    
    if injury then
        for key, value in pairs(updates) do
            injury[key] = value
        end
        return true
    end
    
    return false
end

-- Get injuries by zone
function GetInjuriesByZone(zone)
    local injuries = GetPlayerInjuries()
    local result = {}
    
    for _, injury in ipairs(injuries) do
        if injury.zone == zone then
            table.insert(result, injury)
        end
    end
    
    return result
end

-- Clear all injuries (heal)
function ClearAllInjuries()
    local injuries = GetPlayerInjuries()
    
    for i = #injuries, 1, -1 do
        table.remove(injuries, i)
    end
    
    if Config.Debug then
        print('[CSRP Medical] Cleared all injuries')
    end
end

-- Register network events
RegisterNetEvent('csrp_medical:addInjury')
AddEventHandler('csrp_medical:addInjury', function(injuryType, bodyZone, severity)
    AddInjury(injuryType, bodyZone, severity)
end)

RegisterNetEvent('csrp_medical:removeInjury')
AddEventHandler('csrp_medical:removeInjury', function(injuryId)
    RemoveInjury(injuryId)
end)

RegisterNetEvent('csrp_medical:healPlayer')
AddEventHandler('csrp_medical:healPlayer', function()
    ClearAllInjuries()
    local vitals = GetPlayerVitals()
    for key, value in pairs(InitializeVitals()) do
        vitals[key] = value
    end
end)
