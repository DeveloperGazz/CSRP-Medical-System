-- ==========================================
-- PROGRESSION SYSTEM
-- Real-time injury progression and deterioration
-- ==========================================

-- Progression thread
function ProgressionThread()
    Citizen.CreateThread(function()
        while true do
            Wait(Config.Progression.ProgressionInterval)
            
            local injuries = GetPlayerInjuries()
            local vitals = GetPlayerVitals()
            
            -- Process each injury
            for _, injury in pairs(injuries) do
                if not injury.treated then
                    ProgressInjury(injury, vitals)
                end
            end
            
            -- Check for complications
            if Config.Progression.EnableComplications then
                CheckForComplications(injuries, vitals)
            end
        end
    end)
end

-- Progress individual injury
function ProgressInjury(injury, vitals)
    local injuryDef = Injuries.GetInjury(injury.type)
    if not injuryDef then return end
    
    -- Bleeding progression
    if injury.bleeding > 0 then
        local bleedingIncrease = injury.bleeding * Config.Progression.BleedingProgressionRate * Config.Progression.BleedingRate
        injury.bleeding = math.min(100, injury.bleeding + bleedingIncrease)
        
        -- Reduce blood volume
        local bloodLoss = (injury.bleeding / 100) * Config.Progression.BloodLossPerTick
        vitals.bloodVolume = math.max(0, vitals.bloodVolume - bloodLoss)
        
        if Config.Debug then
            print('[CSRP Medical] Bleeding progression: ' .. injury.type .. ' - ' .. injury.bleeding .. '%')
        end
    end
    
    -- Check for shock
    if vitals.bloodVolume < Config.Progression.ShockThreshold then
        if Config.Debug then
            print('[CSRP Medical] Patient in hypovolemic shock')
        end
    end
    
    -- Oxygen desaturation for respiratory injuries
    if injuryDef.effects.breathing_difficulty or injuryDef.effects.respiratory_distress then
        vitals.oxygenSaturation = math.max(0, vitals.oxygenSaturation - 1)
    end
    
    -- Cardiac deterioration in critical condition
    if vitals.bloodVolume < 30 or vitals.oxygenSaturation < 70 then
        if math.random() < Config.Progression.CardiacArrestChance then
            AddInjury('cardiac_arrest', 'chest', Injuries.Severity.CRITICAL)
            if Config.Debug then
                print('[CSRP Medical] Cardiac arrest from deterioration')
            end
        end
    end
    
    -- Airway obstruction for unconscious patients
    if vitals.consciousness <= Config.VitalSigns.Consciousness.Unresponsive then
        if math.random() < Config.Progression.AirwayObstructionChance then
            vitals.oxygenSaturation = math.max(0, vitals.oxygenSaturation - 5)
            if Config.Debug then
                print('[CSRP Medical] Airway obstruction in unconscious patient')
            end
        end
    end
end

-- Check for secondary complications
function CheckForComplications(injuries, vitals)
    -- Check for infection risk
    for _, injury in pairs(injuries) do
        local injuryDef = Injuries.GetInjury(injury.type)
        if injuryDef and injuryDef.effects.infection_risk then
            local timeSinceInjury = (GetGameTimer() - injury.timestamp) / 1000 / 60 -- minutes
            if timeSinceInjury > 30 and math.random() < 0.01 then
                if Config.Debug then
                    print('[CSRP Medical] Infection risk increasing')
                end
            end
        end
    end
    
    -- Check for compartment syndrome from crush injuries
    for _, injury in pairs(injuries) do
        local injuryDef = Injuries.GetInjury(injury.type)
        if injuryDef and injuryDef.effects.compartment_syndrome_risk then
            local timeSinceInjury = (GetGameTimer() - injury.timestamp) / 1000 / 60
            if timeSinceInjury > 60 and math.random() < 0.05 then
                if Config.Debug then
                    print('[CSRP Medical] Compartment syndrome developing')
                end
            end
        end
    end
end
