-- ==========================================
-- BYSTANDERS SYSTEM
-- Civilian AI responses to medical incidents
-- ==========================================

-- Bystander behavior configuration
local bystanderReactions = {
    'WORLD_HUMAN_SMOKING',
    'WORLD_HUMAN_STAND_MOBILE',
    'WORLD_HUMAN_CLIPBOARD',
    'WORLD_HUMAN_TOURIST_MOBILE'
}

-- Track active bystanders
local activeBystanders = {}

-- Create bystander at incident location
function CreateBystander(coords, reaction)
    local pedModel = GetHashKey('a_m_m_beach_01')
    
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(100)
    end
    
    local bystander = CreatePed(4, pedModel, coords.x, coords.y, coords.z, 0.0, false, true)
    
    -- Set bystander behavior
    SetEntityAsMissionEntity(bystander, true, true)
    SetBlockingOfNonTemporaryEvents(bystander, true)
    
    -- Set scenario
    if reaction then
        TaskStartScenarioInPlace(bystander, reaction, 0, true)
    end
    
    table.insert(activeBystanders, bystander)
    
    return bystander
end

-- Spawn bystanders around medical incident
RegisterNetEvent('csrp:medical:spawnBystanders')
AddEventHandler('csrp:medical:spawnBystanders', function(incidentCoords)
    -- Spawn 2-4 bystanders around incident
    local numBystanders = math.random(2, 4)
    
    for i = 1, numBystanders do
        local offset = vector3(
            math.random(-5, 5),
            math.random(-5, 5),
            0
        )
        
        local bystanderCoords = incidentCoords + offset
        local reaction = bystanderReactions[math.random(#bystanderReactions)]
        
        CreateBystander(bystanderCoords, reaction)
    end
    
    if Config.Debug then
        print('[CSRP Medical] Spawned ' .. numBystanders .. ' bystanders')
    end
end)

-- Clear all bystanders
RegisterNetEvent('csrp:medical:clearBystanders')
AddEventHandler('csrp:medical:clearBystanders', function()
    for _, bystander in ipairs(activeBystanders) do
        if DoesEntityExist(bystander) then
            DeleteEntity(bystander)
        end
    end
    
    activeBystanders = {}
    
    if Config.Debug then
        print('[CSRP Medical] Cleared all bystanders')
    end
end)

-- Cleanup thread
Citizen.CreateThread(function()
    while true do
        Wait(60000) -- Check every minute
        
        -- Remove bystanders that are too far away
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        for i = #activeBystanders, 1, -1 do
            local bystander = activeBystanders[i]
            if DoesEntityExist(bystander) then
                local bystanderCoords = GetEntityCoords(bystander)
                if #(playerCoords - bystanderCoords) > 100.0 then
                    DeleteEntity(bystander)
                    table.remove(activeBystanders, i)
                end
            else
                table.remove(activeBystanders, i)
            end
        end
    end
end)
