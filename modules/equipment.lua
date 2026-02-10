-- ==========================================
-- EQUIPMENT MODULE
-- Equipment tracking and management
-- ==========================================

Equipment = {}

-- Initialize equipment for a player
function Equipment.Initialize()
    return {
        Bandages = Config.Equipment.Bandages,
        PressureDressings = Config.Equipment.PressureDressings,
        ChestSeals = Config.Equipment.ChestSeals,
        BurnDressings = Config.Equipment.BurnDressings,
        Tourniquets = Config.Equipment.Tourniquets,
        HemostaticGauze = Config.Equipment.HemostaticGauze,
        PelvicBinder = Config.Equipment.PelvicBinder,
        OPA = Config.Equipment.OPA,
        NPA = Config.Equipment.NPA,
        SuctionUses = Config.Equipment.SuctionUses,
        OxygenMinutes = Config.Equipment.OxygenMinutes,
        BVM = Config.Equipment.BVM,
        NeedleDecompression = Config.Equipment.NeedleDecompression,
        IVBags = Config.Equipment.IVBags,
        IVLines = Config.Equipment.IVLines,
        Splints = Config.Equipment.Splints,
        CervicalCollars = Config.Equipment.CervicalCollars,
        SpineBoards = Config.Equipment.SpineBoards,
        Paracetamol = Config.Equipment.Paracetamol,
        Morphine = Config.Equipment.Morphine,
        Fentanyl = Config.Equipment.Fentanyl,
        Entonox = Config.Equipment.Entonox,
        Adrenaline = Config.Equipment.Adrenaline,
        Aspirin = Config.Equipment.Aspirin,
        GTN = Config.Equipment.GTN,
        Salbutamol = Config.Equipment.Salbutamol,
        Glucose = Config.Equipment.Glucose,
        Naloxone = Config.Equipment.Naloxone,
        Midazolam = Config.Equipment.Midazolam,
        Defibrillator = Config.Equipment.Defibrillator,
        ThermalBlanket = Config.Equipment.ThermalBlanket,
        CoolingPacks = Config.Equipment.CoolingPacks
    }
end

-- Check if player has equipment
function Equipment.HasEquipment(inventory, equipmentType, amount)
    amount = amount or 1
    if not inventory[equipmentType] then
        return false
    end
    return inventory[equipmentType] >= amount
end

-- Use equipment
function Equipment.UseEquipment(inventory, equipmentType, amount)
    amount = amount or 1
    if Equipment.HasEquipment(inventory, equipmentType, amount) then
        inventory[equipmentType] = inventory[equipmentType] - amount
        return true
    end
    return false
end

-- Resupply all equipment
function Equipment.Resupply(inventory)
    for key, value in pairs(Config.Equipment) do
        inventory[key] = value
    end
    return inventory
end
