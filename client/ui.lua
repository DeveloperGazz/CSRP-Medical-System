-- ==========================================
-- UI SYSTEM
-- NUI interface management
-- 
-- This system manages the menu interface (NUI) for both:
-- - Patient Menu (F6): Shows player's own vitals and injuries
-- - Paramedic Menu (F7): Shows nearby patients, treatments, and equipment
-- 
-- MENU WORKFLOW:
-- 1. Key press detected in client/main.lua
-- 2. Toggle function called (TogglePatientMenu or ToggleParamedicMenu)
-- 3. SetNuiFocus enables/disables mouse and keyboard input for the UI
-- 4. SendNUIMessage sends data to JavaScript (html/js/app.js)
-- 5. JavaScript renders the menu and handles user interactions
-- 6. User actions trigger NUI callbacks back to Lua
-- 7. Menu closes via Escape key, close button, or pressing F6/F7 again
-- ==========================================

-- Menu state tracking
local uiOpen = false          -- Is any menu currently visible?
local currentMenu = nil       -- Which menu is open? ('patient' or 'paramedic')

-- Toggle patient menu (called when F6 is pressed)
-- Shows player's current vitals and injuries
function TogglePatientMenu()
    if Config.Debug then
        print('[CSRP Medical Debug] TogglePatientMenu called - uiOpen: ' .. tostring(uiOpen) .. ', currentMenu: ' .. tostring(currentMenu))
    end

    if uiOpen and currentMenu == 'patient' then
        -- Menu is open, close it
        if Config.Debug then
            print('[CSRP Medical Debug] Closing patient menu')
        end
        uiOpen = false
        currentMenu = nil
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = 'closeMenu'
        })
        if Config.Debug then
            print('[CSRP Medical Debug] Patient menu closed - NUI focus released')
        end
    else
        -- Open the patient menu (close any other menu first)
        if Config.Debug then
            print('[CSRP Medical Debug] Opening patient menu')
        end
        uiOpen = true
        currentMenu = 'patient'
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'openMenu',
            menuType = 'patient',
            data = {
                injuries = GetInjuriesForNUI(),
                vitals = GetPlayerVitals()
            }
        })
        if Config.Debug then
            print('[CSRP Medical Debug] Patient menu opened - NUI focus set')
        end
    end
end

-- Toggle paramedic menu (called when F7 is pressed)
-- Shows nearby patients, available treatments, and equipment inventory
function ToggleParamedicMenu()
    if Config.Debug then
        print('[CSRP Medical Debug] ToggleParamedicMenu called - uiOpen: ' .. tostring(uiOpen) .. ', currentMenu: ' .. tostring(currentMenu))
    end

    if uiOpen and currentMenu == 'paramedic' then
        -- Menu is open, close it
        if Config.Debug then
            print('[CSRP Medical Debug] Closing paramedic menu')
        end
        uiOpen = false
        currentMenu = nil
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = 'closeMenu'
        })
        if Config.Debug then
            print('[CSRP Medical Debug] Paramedic menu closed - NUI focus released')
        end
    else
        -- Open the paramedic menu (close any other menu first)
        if Config.Debug then
            print('[CSRP Medical Debug] Opening paramedic menu')
        end
        uiOpen = true
        currentMenu = 'paramedic'
        SetNuiFocus(true, true)

        local nearbyPlayers = GetNearbyPlayers(10.0)
        SendNUIMessage({
            action = 'openMenu',
            menuType = 'paramedic',
            data = {
                equipment = FormatEquipmentForNUI(GetParamedicEquipment()),
                nearbyPlayers = nearbyPlayers,
                treatments = Treatments.Definitions
            }
        })
        if Config.Debug then
            print('[CSRP Medical Debug] Paramedic menu opened - NUI focus set')
        end
    end
end

-- Format equipment for NUI display
function FormatEquipmentForNUI(equipment)
    local formatted = {}
    
    if not equipment then
        return formatted
    end
    
    for key, value in pairs(equipment) do
        -- Always use Config.Equipment for max value to ensure accuracy
        local maxValue = 0
        if Config.Equipment and Config.Equipment[key] then
            maxValue = Config.Equipment[key]
        else
            if Config.Debug then
                print('[CSRP Medical] Warning: Equipment type "' .. key .. '" not found in Config.Equipment')
            end
            -- Use current value as fallback for unknown equipment types
            maxValue = value
        end
        
        formatted[key] = {
            name = key,
            current = value,
            max = maxValue
        }
    end
    
    return formatted
end

-- Get nearby players
function GetNearbyPlayers(radius)
    local players = {}
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    for _, player in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(player)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)
            
            if distance <= radius then
                table.insert(players, {
                    serverId = GetPlayerServerId(player),
                    name = GetPlayerName(player),
                    distance = math.floor(distance * 100) / 100
                })
            end
        end
    end
    
    return players
end

-- NUI Callbacks - These functions are called when JavaScript sends data back to Lua
-- JavaScript sends via: postNUI('callbackName', {data})
-- Lua receives via: RegisterNUICallback('callbackName', function)

-- Close menu callback
-- Called when user presses Escape or clicks the × button
RegisterNUICallback('closeMenu', function(data, cb)
    if Config.Debug then
        print('[CSRP Medical Debug] closeMenu NUI callback received - uiOpen was: ' .. tostring(uiOpen) .. ', currentMenu was: ' .. tostring(currentMenu))
    end
    uiOpen = false
    currentMenu = nil
    SetNuiFocus(false, false)  -- CRITICAL: Returns keyboard/mouse control to game
    if Config.Debug then
        print('[CSRP Medical Debug] closeMenu NUI callback complete - NUI focus released')
    end
    cb('ok')  -- Must respond to JavaScript
end)

RegisterNUICallback('addInjury', function(data, cb)
    if data.injuryType and data.bodyZone then
        AddInjury(data.injuryType, data.bodyZone, data.severity or Injuries.Severity.MODERATE)
        cb('ok')
    else
        cb('error')
    end
end)

RegisterNUICallback('applyTreatment', function(data, cb)
    if data.targetId and data.treatmentId then
        ApplyTreatment(data.targetId, data.treatmentId, data.injuryId)
        cb('ok')
    else
        cb('error')
    end
end)

RegisterNUICallback('checkVitals', function(data, cb)
    if data.targetId then
        CheckVitals(data.targetId)
        cb('ok')
    else
        cb('error')
    end
end)

RegisterNUICallback('performABCDE', function(data, cb)
    if data.targetId then
        PerformABCDE(data.targetId)
        cb('ok')
    else
        cb('error')
    end
end)

RegisterNUICallback('performSecondarySurvey', function(data, cb)
    if data.targetId then
        PerformSecondarySurvey(data.targetId)
        cb('ok')
    else
        cb('error')
    end
end)

RegisterNUICallback('applyCPR', function(data, cb)
    if data.targetId then
        ApplyCPR(data.targetId)
        cb('ok')
    else
        cb('error')
    end
end)

RegisterNUICallback('defibrillate', function(data, cb)
    if data.targetId then
        Defibrillate(data.targetId)
        cb('ok')
    else
        cb('error')
    end
end)

RegisterNUICallback('selectPatient', function(data, cb)
    if data.patientId then
        -- Request patient data from server
        TriggerServerEvent('csrp_medical:requestPatientData', data.patientId)
        cb('ok')
    else
        cb('error')
    end
end)

RegisterNUICallback('revivePatient', function(data, cb)
    if data.targetId then
        TriggerServerEvent('csrp_medical:requestRevive', data.targetId)
        cb('ok')
    else
        cb('error')
    end
end)

-- Network event handlers

-- When paramedic requests this player's data
RegisterNetEvent('csrp_medical:sendPatientData')
AddEventHandler('csrp_medical:sendPatientData', function(paramedicId)
    local playerData = {
        injuries = GetInjuriesForNUI(),
        vitals = GetPlayerVitals(),
        name = GetPlayerName(PlayerId()),
        id = GetPlayerServerId(PlayerId())
    }
    
    -- Send data back to the requesting paramedic
    TriggerServerEvent('csrp_medical:sendPatientDataToParamedic', paramedicId, playerData)
end)

-- When paramedic receives patient data
RegisterNetEvent('csrp_medical:receivePatientData')
AddEventHandler('csrp_medical:receivePatientData', function(patientData)
    -- Update the paramedic's NUI with patient information
    SendNUIMessage({
        action = 'updatePatientData',
        patient = patientData
    })
end)

-- Safety thread: ensure NUI focus is released when menu is not open
-- This prevents the cursor from getting stuck on screen
Citizen.CreateThread(function()
    while true do
        Wait(1000)
        if not uiOpen then
            SetNuiFocus(false, false)
        end
        if Config.Debug then
            print('[CSRP Medical Debug] Safety thread check - uiOpen: ' .. tostring(uiOpen) .. ', currentMenu: ' .. tostring(currentMenu))
        end
    end
end)
