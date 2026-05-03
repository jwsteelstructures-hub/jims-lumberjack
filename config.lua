Config = {}

Config.Debug = true   -- Set to false for production
Config.DebugLevel = 3 -- 1 = errors only, 2 = warnings, 3 = full debug
Config.OfficeLocation = vector3(-1400.58, -205.13, 101.91)
Config.OfficeBuildTime = 60
-- Tree locations (we'll expand this later)
Config.Trees = {
    { x = -500.0, y = 1200.0, z = 100.0 },
    { x = -520.0, y = 1180.0, z = 102.0 },
}
-- Base payout per log
Config.BasePayout = 4.0

Config.CampId = "lumber_1"
Config.CampName = "Jim's Logging Co."

Config.Construction = {
    phase1 = 50,   -- Foundation + partial walls
    phase2 = 75,   -- Full frame + roof frame
    phase3 = 100   -- Office complete
}

Config.Stables = {
    phase1 = 40,   -- Small barn
    phase2 = 60,   -- Half fencing
    phase3 = 90    -- Full barn + fenced area
}

Config.WorkerSlots = {
    baseSlots = 4,
    slotsPerTent = 2,
    maxTents = 2,
    tentModel = "p_tent_leanto01x",
    upgradeCost = 50
}

Config.Wagons = {
    lumber = {
        type = "lumber",
        model = "cart01",
        name = "Lumber Wagon",
        price = 50,
        capacity = 10
    },
    sap = {
        type = "sap",
        model = "cart02",
        name = "Sap Wagon",
        price = 75,
        capacity = 10
    },
    cargo = {
        type = "cargo",
        model = "cart03",
        name = "Cargo Wagon",
        price = 120,
        capacity = 5000
    }
}

Config.Storages = {
    hardwood = {
        capacity = 2000,
        model = "p_woodpile01x"
    },
    plank = {
        capacity = 2000,
        model = "p_woodpile02x"
    },
    sap = {
        capacity = 2000,
        model = "p_barrel03x"
    }
}

Config.BulkStorage = {
    logs = {
        model = "p_woodpile03x",
        location = vector4(0.0, 0.0, 0.0, 0.0) -- set later
    },
    sap = {
        model = "p_water_tower01x",
        location = vector4(0.0, 0.0, 0.0, 0.0) -- set later
    }
}

Config.ShopFront = {
    model = "p_storefront01x",
    location = vector4(0.0, 0.0, 0.0, 0.0),
    baseCapacity = 500,
    baseCost = 100,
    baseUpgradeCost = 50,
    slotsPerUpgrade = 100
}


Config.Ranks = {
    [1] = "Lumberjack",
    [2] = "Senior Lumberjack",
    [3] = "Foreman",
    [4] = "Owner"
}

