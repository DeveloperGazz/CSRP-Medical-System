-- ==========================================
-- EQUIPMENT SYSTEM
-- Medical equipment management
-- ==========================================

-- Local equipment state
local currentEquipment = {}

-- Initialize equipment when player becomes paramedic
Citizen.CreateThread(function()
    Wait(2000)
    
    -- Check if player is paramedic
    if Config.Permissions.UseParamedicMenu then
        currentEquipment = Equipment.Initialize()
        
        if Config.Debug then
            print('[CSRP Medical] Equipment initialized')
        end
    end
end)

-- Network event to use equipment
RegisterNetEvent('csrp:medical:useEquipment')
AddEventHandler('csrp:medical:useEquipment', function(equipmentType, amount)
    if Equipment.UseEquipment(currentEquipment, equipmentType, amount) then
        if Config.Debug then
            print('[CSRP Medical] Used ' .. amount .. 'x ' .. equipmentType)
        end
        
        -- Update UI
        TriggerEvent('csrp:medical:updateEquipmentUI', currentEquipment)
    else
        TriggerEvent('chat:addMessage', {
            args = {'Medical System', 'Insufficient ' .. equipmentType}
        })
    end
end)

-- Network event to resupply equipment
RegisterNetEvent('csrp:medical:resupplyEquipment')
AddEventHandler('csrp:medical:resupplyEquipment', function()
    currentEquipment = Equipment.Resupply(currentEquipment)
    
    if Config.Debug then
        print('[CSRP Medical] Equipment resupplied')
    end
    
    -- Update UI
    TriggerEvent('csrp:medical:updateEquipmentUI', currentEquipment)
end)

-- Get current equipment state
function GetCurrentEquipment()
    return currentEquipment
end

-- Export function
exports('GetCurrentEquipment', GetCurrentEquipment)
