-- ==========================================
-- DEATH DETECTION SYSTEM
-- Detects player death, determines cause,
-- applies injuries, and keeps player down
-- for paramedic RP
-- ==========================================

-- Death state tracking
local isDead = false
local deathCause = nil
local isBeingTreated = false
local lastDeathTime = 0
local respawnBlocked = true

-- Map GTA weapon hashes/death causes to medical injuries
local DeathCauseMap = {
    -- Firearms
    [GetHashKey('WEAPON_PISTOL')] = {injury = 'gunshot_wound', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_COMBATPISTOL')] = {injury = 'gunshot_wound', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_PISTOL50')] = {injury = 'gunshot_wound', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_APPISTOL')] = {injury = 'gunshot_wound', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_HEAVYPISTOL')] = {injury = 'gunshot_wound', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_MARKSMANPISTOL')] = {injury = 'gunshot_wound', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_REVOLVER')] = {injury = 'gunshot_wound', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_MICROSMG')] = {injury = 'gunshot_wound', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_SMG')] = {injury = 'gunshot_wound', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_ASSAULTSMG')] = {injury = 'gunshot_wound', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_COMBATMG')] = {injury = 'gunshot_wound', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_ASSAULTRIFLE')] = {injury = 'gunshot_wound', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_CARBINERIFLE')] = {injury = 'gunshot_wound', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_ADVANCEDRIFLE')] = {injury = 'gunshot_wound', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_SPECIALCARBINE')] = {injury = 'gunshot_wound', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_BULLPUPRIFLE')] = {injury = 'gunshot_wound', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_SNIPERRIFLE')] = {injury = 'gunshot_wound', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_HEAVYSNIPER')] = {injury = 'gunshot_wound', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_PUMPSHOTGUN')] = {injury = 'gunshot_wound', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_SAWNOFFSHOTGUN')] = {injury = 'gunshot_wound', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_ASSAULTSHOTGUN')] = {injury = 'gunshot_wound', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_MUSKET')] = {injury = 'gunshot_wound', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_MINIGUN')] = {injury = 'gunshot_wound', zone = 'chest', severity = 4},

    -- Melee / Stabbing
    [GetHashKey('WEAPON_KNIFE')] = {injury = 'stab_wound', zone = 'chest', severity = 3},
    [GetHashKey('WEAPON_SWITCHBLADE')] = {injury = 'stab_wound', zone = 'chest', severity = 3},
    [GetHashKey('WEAPON_DAGGER')] = {injury = 'stab_wound', zone = 'chest', severity = 3},
    [GetHashKey('WEAPON_MACHETE')] = {injury = 'stab_wound', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_HATCHET')] = {injury = 'stab_wound', zone = 'chest', severity = 3},
    [GetHashKey('WEAPON_BATTLEAXE')] = {injury = 'stab_wound', zone = 'chest', severity = 4},

    -- Blunt Melee
    [GetHashKey('WEAPON_BAT')] = {injury = 'blunt_trauma', zone = 'head', severity = 3},
    [GetHashKey('WEAPON_CROWBAR')] = {injury = 'blunt_trauma', zone = 'head', severity = 3},
    [GetHashKey('WEAPON_GOLFCLUB')] = {injury = 'blunt_trauma', zone = 'head', severity = 3},
    [GetHashKey('WEAPON_HAMMER')] = {injury = 'blunt_trauma', zone = 'head', severity = 3},
    [GetHashKey('WEAPON_KNUCKLE')] = {injury = 'blunt_trauma', zone = 'head', severity = 2},
    [GetHashKey('WEAPON_NIGHTSTICK')] = {injury = 'blunt_trauma', zone = 'head', severity = 3},
    [GetHashKey('WEAPON_UNARMED')] = {injury = 'blunt_trauma', zone = 'head', severity = 2},
    [GetHashKey('WEAPON_WRENCH')] = {injury = 'blunt_trauma', zone = 'head', severity = 3},

    -- Explosives
    [GetHashKey('WEAPON_GRENADE')] = {injury = 'blunt_trauma', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_STICKYBOMB')] = {injury = 'blunt_trauma', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_RPG')] = {injury = 'blunt_trauma', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_GRENADELAUNCHER')] = {injury = 'blunt_trauma', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_EXPLOSION')] = {injury = 'blunt_trauma', zone = 'chest', severity = 4},

    -- Fire
    [GetHashKey('WEAPON_MOLOTOV')] = {injury = 'burn_3rd', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_PETROLCAN')] = {injury = 'burn_3rd', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_FLARE')] = {injury = 'burn_2nd', zone = 'chest', severity = 3},

    -- Vehicle
    [GetHashKey('WEAPON_RUN_OVER_BY_CAR')] = {injury = 'blunt_trauma', zone = 'chest', severity = 4},
    [GetHashKey('VEHICLE')] = {injury = 'blunt_trauma', zone = 'chest', severity = 4},

    -- Drowning
    [GetHashKey('WEAPON_DROWNING')] = {injury = 'drowning', zone = 'chest', severity = 4},
    [GetHashKey('WEAPON_DROWNING_IN_VEHICLE')] = {injury = 'drowning', zone = 'chest', severity = 4},

    -- Fall
    [GetHashKey('WEAPON_FALL')] = {injury = 'blunt_trauma', zone = 'left_leg', severity = 3},
}

-- Determine the body zone hit based on the bone index
local function GetBodyZoneFromBone(boneIndex)
    local headBones = {31086, 39317}
    local chestBones = {24818, 24816}
    local abdomenBones = {11816}
    local leftArmBones = {61163, 45509}
    local rightArmBones = {40269, 28252}
    local leftLegBones = {63931, 14201, 45454}
    local rightLegBones = {51826, 20781, 52301}

    for _, b in ipairs(headBones) do if b == boneIndex then return 'head' end end
    for _, b in ipairs(chestBones) do if b == boneIndex then return 'chest' end end
    for _, b in ipairs(abdomenBones) do if b == boneIndex then return 'abdomen' end end
    for _, b in ipairs(leftArmBones) do if b == boneIndex then return 'left_arm' end end
    for _, b in ipairs(rightArmBones) do if b == boneIndex then return 'right_arm' end end
    for _, b in ipairs(leftLegBones) do if b == boneIndex then return 'left_leg' end end
    for _, b in ipairs(rightLegBones) do if b == boneIndex then return 'right_leg' end end

    return 'chest' -- Default
end

-- Get injury info from the cause of death weapon hash
local function GetInjuryFromDeathCause(weaponHash, playerPed)
    local mapped = DeathCauseMap[weaponHash]

    if mapped then
        local result = {
            injury = mapped.injury,
            zone = mapped.zone,
            severity = mapped.severity
        }

        -- Try to get the bone that was hit for more accurate zone
        local success, boneIndex = GetPedLastDamageBone(playerPed)
        if success and boneIndex and boneIndex ~= 0 then
            result.zone = GetBodyZoneFromBone(boneIndex)
        end

        return result
    end

    -- Default: unknown cause of death → blunt trauma
    return {
        injury = 'blunt_trauma',
        zone = 'chest',
        severity = 3
    }
end

-- Main death detection thread
Citizen.CreateThread(function()
    while true do
        Wait(500)

        local playerPed = PlayerPedId()

        if IsEntityDead(playerPed) and not isDead then
            -- Player just died
            isDead = true
            lastDeathTime = GetGameTimer()

            -- Determine cause of death
            local weaponHash = GetPedCauseOfDeath(playerPed)
            local injuryInfo = GetInjuryFromDeathCause(weaponHash, playerPed)
            deathCause = injuryInfo

            if Config.Debug then
                print('[CSRP Medical] Player died - Cause: ' .. injuryInfo.injury .. ' Zone: ' .. injuryInfo.zone)
            end

            -- Apply the injury from death cause
            AddInjury(injuryInfo.injury, injuryInfo.zone, injuryInfo.severity)

            -- Set consciousness to Unresponsive
            local vitals = GetPlayerVitals()
            if vitals then
                vitals.consciousness = Config.VitalSigns.Consciousness.Unresponsive
                vitals.bloodVolume = math.min(vitals.bloodVolume, 30)
            end

            -- Notify server of death
            TriggerServerEvent('csrp_medical:playerDied', injuryInfo)

            -- Notify the player
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                args = {'Medical System', 'You are critically injured. Wait for paramedics or press /respawn after ' .. Config.DeathSystem.RespawnTimer .. ' seconds.'}
            })

        elseif IsEntityDead(playerPed) and isDead then
            -- Player is still dead - keep them on the ground and block default respawn
            if Config.DeathSystem.BlockRespawn then
                -- Disable respawn controls
                DisableControlAction(0, 0, true) -- Next Camera (respawn prompt uses this internally)

                -- Check if respawn timer has elapsed
                local timeDown = (GetGameTimer() - lastDeathTime) / 1000
                if timeDown >= Config.DeathSystem.RespawnTimer then
                    -- Show respawn hint after timer
                    DisplayHelpText('Press ~INPUT_PICKUP~ to respawn or wait for paramedics')
                    if IsControlJustReleased(0, 38) then -- E key
                        RespawnPlayer()
                    end
                end
            end

        elseif not IsEntityDead(playerPed) and isDead then
            -- Player has respawned (via native or our system)
            isDead = false
            deathCause = nil
            isBeingTreated = false
        end
    end
end)

-- Keep dead player in ragdoll on the ground for paramedic RP
Citizen.CreateThread(function()
    while true do
        Wait(0)

        if isDead then
            local playerPed = PlayerPedId()

            if IsEntityDead(playerPed) then
                -- Prevent the default GTA respawn screen from taking over
                -- by using a shorter wait and continuously blocking
                DisableAllControlActions(0)

                -- Allow certain controls even while dead
                EnableControlAction(0, 249, true) -- N key (push to talk)
                EnableControlAction(0, 38, true)  -- E key (respawn after timer)
            end
        end
    end
end)

-- Respawn the player
function RespawnPlayer()
    local playerPed = PlayerPedId()

    -- Find nearest hospital
    local playerCoords = GetEntityCoords(playerPed)
    local nearestHospital = Config.Hospitals[1]
    local nearestDist = 999999.0

    for _, hospital in ipairs(Config.Hospitals) do
        local dist = #(playerCoords - hospital.coords)
        if dist < nearestDist then
            nearestDist = dist
            nearestHospital = hospital
        end
    end

    -- Resurrect the player
    NetworkResurrectLocalPlayer(
        nearestHospital.coords.x,
        nearestHospital.coords.y,
        nearestHospital.coords.z,
        0.0, true, false
    )

    -- Clear injuries and reset vitals
    ClearAllInjuries()
    local vitals = GetPlayerVitals()
    if vitals then
        for key, value in pairs(InitializeVitals()) do
            vitals[key] = value
        end
    end

    -- Reset death state
    isDead = false
    deathCause = nil
    isBeingTreated = false

    TriggerEvent('chat:addMessage', {
        args = {'Medical System', 'You have been transported to ' .. (nearestHospital.name or 'hospital')}
    })

    TriggerServerEvent('csrp_medical:playerRespawned')
end

-- Allow paramedics to revive this player
RegisterNetEvent('csrp_medical:revivePlayer')
AddEventHandler('csrp_medical:revivePlayer', function()
    if isDead then
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        -- Resurrect in place
        NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(playerPed), true, false)

        -- Clear critical injuries, keep minor ones
        local injuries = GetPlayerInjuries()
        for i = #injuries, 1, -1 do
            if injuries[i].severity >= 4 then
                table.remove(injuries, i)
            end
        end

        -- Restore vitals partially
        local vitals = GetPlayerVitals()
        if vitals then
            vitals.consciousness = Config.VitalSigns.Consciousness.Pain
            vitals.bloodVolume = 60
            vitals.oxygenSaturation = 85
            vitals.heartRate = 100
        end

        isDead = false
        deathCause = nil
        isBeingTreated = false

        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            args = {'Medical System', 'You have been revived by a paramedic. Seek further treatment.'}
        })
    end
end)

-- Get death state (export)
function IsPlayerMedicallyDead()
    return isDead
end

function GetDeathCause()
    return deathCause
end

exports('IsPlayerMedicallyDead', IsPlayerMedicallyDead)
exports('GetDeathCause', GetDeathCause)
