-- ==========================================
-- UI SYSTEM
-- NUI interface management
-- ==========================================

local uiOpen = false
local currentMenu = nil

-- Toggle patient menu
function TogglePatientMenu()
    uiOpen = not uiOpen
    currentMenu = 'patient'
    
    SetNuiFocus(uiOpen, uiOpen)
    
    if uiOpen then
        SendNUIMessage({
            action = 'openMenu',
            menuType = 'patient',
            data = {
                injuries = GetInjuriesForNUI(),
                vitals = GetPlayerVitals()
            }
        })
    else
        SendNUIMessage({
            action = 'closeMenu'
        })
    end
end

-- Toggle paramedic menu
function ToggleParamedicMenu()
    uiOpen = not uiOpen
    currentMenu = 'paramedic'
    
    SetNuiFocus(uiOpen, uiOpen)
    
    if uiOpen then
        -- Get nearby players
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
    else
        SendNUIMessage({
            action = 'closeMenu'
        })
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
        local maxValue = Config.Equipment and Config.Equipment[key] or 0
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

-- NUI Callbacks
RegisterNUICallback('closeMenu', function(data, cb)
    uiOpen = false
    currentMenu = nil
    SetNuiFocus(false, false)
    cb('ok')
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
