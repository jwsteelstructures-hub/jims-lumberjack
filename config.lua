Config = {}

Config.Debug = true   -- Set to false for production
Config.DebugLevel = 3 -- 1 = errors only, 2 = warnings, 3 = full debug
Config.OfficeLocation = vector3(-1399.3911, -214.0309, 102.4017)
Config.OfficeBuildTime = 60

-- Logging companies players can work for
Config.Companies = {
    {
        id = "jims_logging",
        name = "Jim's Logging Co.",
        payoutMultiplier = 1.0
    },
    {
        id = "ridgewood_logging",
        name = "Ridgewood Timberworks",
        payoutMultiplier = 1.15
    },
    {
        id = "ironwood_mill",
        name = "Ironwood Mill & Co.",
        payoutMultiplier = 1.25
    }
}

-- Tree locations (we'll expand this later)
Config.Trees = {
    { x = -500.0, y = 1200.0, z = 100.0 },
    { x = -520.0, y = 1180.0, z = 102.0 },
}

-- Base payout per log
Config.BasePayout = 4.0

-- Construction camp data
Config.Camps = {
    lumber_1 = {
        prompt = vector3(-1400.12, -214.45, 102.40), -- Appleseed sign
        office = vector3(-1395.80, -210.32, 102.40), -- office foundation location

        workerPoints = {
            taskA = {
                vector3(-1398.2, -212.1, 102.3),
                vector3(-1396.4, -215.0, 102.2)
            },
            taskB = {
                vector3(-1402.5, -217.3, 102.1),
                vector3(-1393.9, -209.4, 102.4)
            }
        }
    }
}
