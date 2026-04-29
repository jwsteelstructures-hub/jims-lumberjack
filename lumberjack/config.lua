Config.Debug = true   -- Set to false for production
Config.DebugLevel = 3 -- 1 = errors only, 2 = warnings, 3 = full debug

Config = {}

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
