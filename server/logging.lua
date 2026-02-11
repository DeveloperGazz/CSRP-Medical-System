-- ==========================================
-- LOGGING SYSTEM
-- Server-side event and action logging
-- ==========================================

-- Log storage
local logs = {}
local maxLogs = 1000 -- Maximum number of logs to keep in memory

-- Log levels
local LogLevel = {
    INFO = 'INFO',
    WARNING = 'WARNING',
    ERROR = 'ERROR',
    DEBUG = 'DEBUG',
    ADMIN = 'ADMIN'
}

-- Add log entry
function AddLog(level, category, message, source)
    local timestamp = os.date('%Y-%m-%d %H:%M:%S')
    
    local logEntry = {
        timestamp = timestamp,
        level = level,
        category = category,
        message = message,
        source = source or 'system'
    }
    
    table.insert(logs, 1, logEntry) -- Insert at beginning
    
    -- Remove old logs if exceeds max
    if #logs > maxLogs then
        table.remove(logs, #logs)
    end
    
    -- Print to console if debug enabled
    if Config.Debug or level == LogLevel.ERROR then
        print(string.format('[CSRP Medical %s] [%s] %s - %s', level, category, message, source))
    end
    
    -- Could also write to file or external logging service
    return logEntry
end

-- Event handlers for logging

-- Injury added
RegisterNetEvent('csrp:medical:logInjuryAdded')
AddEventHandler('csrp:medical:logInjuryAdded', function(targetId, injuryType, bodyZone, severity)
    local source = source
    AddLog(LogLevel.INFO, 'INJURY', 
        string.format('Player %s added %s injury (severity %d) to %s on %s', 
            source, injuryType, severity, targetId, bodyZone),
        source)
end)

-- Treatment applied
RegisterNetEvent('csrp:medical:logTreatment')
AddEventHandler('csrp:medical:logTreatment', function(targetId, treatmentType)
    local source = source
    AddLog(LogLevel.INFO, 'TREATMENT',
        string.format('Player %s applied %s to player %s', source, treatmentType, targetId),
        source)
end)

-- Player healed
RegisterNetEvent('csrp:medical:logHeal')
AddEventHandler('csrp:medical:logHeal', function(targetId)
    local source = source
    AddLog(LogLevel.ADMIN, 'HEAL',
        string.format('Admin %s healed player %s', source, targetId),
        source)
end)

-- Equipment resupply
RegisterNetEvent('csrp:medical:logResupply')
AddEventHandler('csrp:medical:logResupply', function()
    local source = source
    AddLog(LogLevel.INFO, 'EQUIPMENT',
        string.format('Player %s resupplied equipment', source),
        source)
end)

-- Complication triggered
RegisterNetEvent('csrp:medical:complicationTriggered')
AddEventHandler('csrp:medical:complicationTriggered', function(complicationId)
    local source = source
    AddLog(LogLevel.WARNING, 'COMPLICATION',
        string.format('Player %s developed complication: %s', source, complicationId),
        source)
end)

-- MCI events
RegisterNetEvent('csrp:medical:logMCIStart')
AddEventHandler('csrp:medical:logMCIStart', function(incidentType, location)
    local source = source
    AddLog(LogLevel.ADMIN, 'MCI',
        string.format('MCI started by %s: %s at location %s', source, incidentType, tostring(location)),
        source)
end)

RegisterNetEvent('csrp:medical:logMCIEnd')
AddEventHandler('csrp:medical:logMCIEnd', function()
    local source = source
    AddLog(LogLevel.ADMIN, 'MCI',
        string.format('MCI ended by %s', source),
        source)
end)

RegisterNetEvent('csrp:medical:syncTriage')
AddEventHandler('csrp:medical:syncTriage', function(patientId, category)
    local source = source
    AddLog(LogLevel.INFO, 'TRIAGE',
        string.format('Player %s triaged patient %s as %s', source, patientId, category),
        source)
end)

-- Admin command usage
RegisterNetEvent('csrp:medical:logAdminCommand')
AddEventHandler('csrp:medical:logAdminCommand', function(command, args)
    local source = source
    AddLog(LogLevel.ADMIN, 'COMMAND',
        string.format('Admin %s executed: %s %s', source, command, table.concat(args, ' ')),
        source)
end)

-- Error logging
RegisterNetEvent('csrp:medical:logError')
AddEventHandler('csrp:medical:logError', function(errorMessage)
    local source = source
    AddLog(LogLevel.ERROR, 'ERROR',
        string.format('Error from player %s: %s', source, errorMessage),
        source)
end)

-- Get logs (admin command)
RegisterCommand('getmedlogs', function(source, args, rawCommand)
    -- Check permissions
    if source == 0 or IsPlayerAceAllowed(source, Config.Permissions.AdminAcePermission) then
        local count = tonumber(args[1]) or 50
        local category = args[2] or nil
        
        local filteredLogs = {}
        local found = 0
        
        for _, log in ipairs(logs) do
            if not category or log.category == string.upper(category) then
                table.insert(filteredLogs, log)
                found = found + 1
                if found >= count then
                    break
                end
            end
        end
        
        -- Print logs
        print('===== CSRP Medical System Logs =====')
        for _, log in ipairs(filteredLogs) do
            print(string.format('[%s] [%s] [%s] %s (Source: %s)',
                log.timestamp, log.level, log.category, log.message, log.source))
        end
        print('===== End of Logs =====')
        
        if source ~= 0 then
            TriggerClientEvent('chat:addMessage', source, {
                args = {'Logs', 'Printed ' .. #filteredLogs .. ' log entries to server console'}
            })
        end
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = {'Error', 'You do not have permission to view logs'}
        })
    end
end)

-- Clear logs (admin command)
RegisterCommand('clearmedlogs', function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, Config.Permissions.AdminAcePermission) then
        local oldCount = #logs
        logs = {}
        
        AddLog(LogLevel.ADMIN, 'SYSTEM',
            string.format('Logs cleared by %s. %d entries removed.', source, oldCount),
            source)
        
        if source ~= 0 then
            TriggerClientEvent('chat:addMessage', source, {
                args = {'Logs', 'Cleared ' .. oldCount .. ' log entries'}
            })
        end
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = {'Error', 'You do not have permission to clear logs'}
        })
    end
end)

-- Export functions
exports('AddLog', AddLog)
exports('GetLogs', function() return logs end)
