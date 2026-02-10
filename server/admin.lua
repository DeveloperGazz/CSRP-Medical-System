-- ==========================================
-- ADMIN COMMANDS
-- Administrative commands for testing and management
-- ==========================================

-- Add injury command
RegisterCommand(Config.Commands.AddInjury, function(source, args, rawCommand)
    if source == 0 or Config.Permissions.AdminCommands then
        local targetId = tonumber(args[1]) or source
        local injuryType = args[2] or 'gunshot_wound'
        local bodyZone = args[3] or 'chest'
        local severity = tonumber(args[4]) or 2
        
        TriggerClientEvent('csrp_medical:addInjury', targetId, injuryType, bodyZone, severity)
        
        if source > 0 then
            TriggerClientEvent('chat:addMessage', source, {
                args = {'Admin', 'Added injury ' .. injuryType .. ' to player ' .. targetId}
            })
        else
            print('[CSRP Medical] Added injury ' .. injuryType .. ' to player ' .. targetId)
        end
    end
end, false)

-- Heal player command
RegisterCommand(Config.Commands.HealPlayer, function(source, args, rawCommand)
    if source == 0 or Config.Permissions.AdminCommands then
        local targetId = tonumber(args[1]) or source
        
        TriggerClientEvent('csrp_medical:healPlayer', targetId)
        
        if source > 0 then
            TriggerClientEvent('chat:addMessage', source, {
                args = {'Admin', 'Healed player ' .. targetId}
            })
        else
            print('[CSRP Medical] Healed player ' .. targetId)
        end
    end
end, false)

-- Resupply command
RegisterCommand(Config.Commands.Resupply, function(source, args, rawCommand)
    if source > 0 and Config.Permissions.AdminCommands then
        TriggerClientEvent('chat:addMessage', source, {
            args = {'Admin', 'Equipment resupplied'}
        })
        -- The client will handle resupply through hospital zones
    end
end, false)

-- Spawn dummy patient command
RegisterCommand(Config.Commands.SpawnDummy, function(source, args, rawCommand)
    if Config.Training.Enabled and (source == 0 or Config.Permissions.AdminCommands) then
        -- This would spawn a ped with random injuries for training
        if source > 0 then
            TriggerClientEvent('chat:addMessage', source, {
                args = {'Training', 'Dummy patient spawned (feature coming soon)'}
            })
        else
            print('[CSRP Medical] Dummy patient feature coming soon')
        end
    end
end, false)

-- Toggle debug command
RegisterCommand(Config.Commands.ToggleDebug, function(source, args, rawCommand)
    if source == 0 or Config.Permissions.AdminCommands then
        Config.Debug = not Config.Debug
        
        local status = Config.Debug and 'enabled' or 'disabled'
        
        if source > 0 then
            TriggerClientEvent('chat:addMessage', source, {
                args = {'Admin', 'Debug mode ' .. status}
            })
        else
            print('[CSRP Medical] Debug mode ' .. status)
        end
    end
end, false)

-- Check vitals command
RegisterCommand(Config.Commands.CheckVitals, function(source, args, rawCommand)
    if source > 0 then
        -- Request own vitals to be printed to chat
        TriggerClientEvent('csrp_medical:printVitals', source)
    end
end, false)
