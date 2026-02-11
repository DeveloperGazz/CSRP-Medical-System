-- ==========================================
-- CLIENT MAIN
-- Core client initialization and management
-- ==========================================

-- Player state
local playerInjuries = {}
local playerVitals = {}
local paramedicEquipment = {}
local isParamedic = false

-- Initialize player on resource start
Citizen.CreateThread(function()
    Wait(1000)
    
    -- Initialize vitals
    playerVitals = InitializeVitals()
    
    -- Initialize equipment if paramedic
    if Config.Permissions.UseParamedicMenu then
        isParamedic = true
        if Equipment and Equipment.Initialize then
            paramedicEquipment = Equipment.Initialize()
        else
            print('[CSRP Medical] ERROR: Equipment module not loaded. Check that modules/equipment.lua is loaded before client scripts in fxmanifest.lua')
            paramedicEquipment = {}
        end
    end
    
    -- Start vital signs update thread
    VitalsThread()
    
    -- Start progression thread
    ProgressionThread()
    
    if Config.Debug then
        print('[CSRP Medical] Client initialized')
    end
end)

-- Key bindings
-- This thread runs continuously to detect F6 and F7 key presses
-- Wait(0) checks every frame (~60 times per second)
Citizen.CreateThread(function()
    while true do
        Wait(0)  -- Yield to other threads each frame
        
        -- Patient Menu (F6) - Control code 167
        -- IsControlJustReleased ensures key was pressed AND released (prevents holding)
        if IsControlJustReleased(0, 167) then -- F6
            if Config.Permissions.UsePatientMenu then
                TogglePatientMenu()  -- Defined in client/ui.lua
            end
        end
        
        -- Paramedic Menu (F7) - Control code 168
        -- Only works if player has paramedic permission
        if IsControlJustReleased(0, 168) then -- F7
            if Config.Permissions.UseParamedicMenu and isParamedic then
                ToggleParamedicMenu()  -- Defined in client/ui.lua
            end
        end
    end
end)

-- Hospital resupply zones
Citizen.CreateThread(function()
    while true do
        Wait(500)
        
        if isParamedic then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            for _, hospital in ipairs(Config.Hospitals) do
                if hospital.resupply then
                    local distance = #(playerCoords - hospital.coords)
                    
                    if distance < 5.0 then
                        -- Show help text
                        DisplayHelpText('Press ~INPUT_CONTEXT~ to resupply equipment')
                        
                        if IsControlJustReleased(0, 38) then -- E key
                            if Equipment and Equipment.Resupply then
                                paramedicEquipment = Equipment.Resupply(paramedicEquipment)
                                TriggerEvent('chat:addMessage', {
                                    args = {'Medical System', 'Equipment resupplied'}
                                })
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Helper function to display help text
function DisplayHelpText(text)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

-- Get player injuries
function GetPlayerInjuries()
    return playerInjuries
end

-- Get player vitals
function GetPlayerVitals()
    return playerVitals
end

-- Get paramedic equipment
function GetParamedicEquipment()
    return paramedicEquipment
end

-- Export functions
exports('GetPlayerInjuries', GetPlayerInjuries)
exports('GetPlayerVitals', GetPlayerVitals)
exports('GetParamedicEquipment', GetParamedicEquipment)
