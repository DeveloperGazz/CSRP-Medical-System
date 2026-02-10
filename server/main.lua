-- ==========================================
-- SERVER MAIN
-- Core server initialization and management
-- ==========================================

-- Player data storage
local PlayerData = {}

-- Initialize player data
function InitializePlayerData(source)
    PlayerData[source] = {
        injuries = {},
        vitals = {},
        equipment = {}
    }
end

-- Get player data
function GetPlayerData(source)
    if not PlayerData[source] then
        InitializePlayerData(source)
    end
    return PlayerData[source]
end

-- Player connect
AddEventHandler('playerConnecting', function()
    local source = source
    InitializePlayerData(source)
    
    if Config.Debug then
        print('[CSRP Medical] Player ' .. source .. ' initialized')
    end
end)

-- Player disconnect
AddEventHandler('playerDropped', function()
    local source = source
    if PlayerData[source] then
        PlayerData[source] = nil
        if Config.Debug then
            print('[CSRP Medical] Player ' .. source .. ' data cleared')
        end
    end
end)

-- Export functions
exports('GetPlayerData', GetPlayerData)
