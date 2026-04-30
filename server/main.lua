-- ============================================
-- Lumberjack Job - Server Main
-- Phase 1 Backend Initialization
-- ============================================

Debug:Info("Server script loaded.")

-- ============================================
-- Initialize Backend
-- ============================================

CreateThread(function()
    Wait(500)
    print("[Lumberjack] Initializing backend...")
    Company.Load()
end)

-- ============================================
-- Debug Commands
-- ============================================

RegisterCommand("lj_info", function()
    print("----- Lumberjack Company Info -----")
    print("Company Name:", Company.name)
    print("Company Funds:", Company.funds)
    print("-----------------------------------")
end)

RegisterCommand("lj_addfunds", function(source, args)
    local amount = tonumber(args[1]) or 0
    Company.AddFunds(amount)
    print("[Lumberjack] Added funds:", amount)
end)

-- ============================================
-- Server Events
-- ============================================

RegisterNetEvent("lumberjack:chopped", function(amount)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)

    print("[Lumberjack] Player chopped:", amount)

    exports.oxmysql:insert(
        "INSERT INTO lumberjack_logs (identifier, amount) VALUES (?, ?)",
        { identifier, amount }
    )
end)

RegisterNetEvent("lumberjack:payPlayer", function(amount)
    local src = source

    Company.RemoveFunds(amount)

    print("[Lumberjack] Paying player:", src, "Amount:", amount)
end)
