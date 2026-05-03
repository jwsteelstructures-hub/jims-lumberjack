print("^2[Lumber] sv_business.lua loaded (Admin Ownership System)")

-- =========================================================
--  CONFIG
-- =========================================================

local ADMIN_ACE = "lumber.admin"   -- ACE permission name
local DEFAULT_CAMP = "lumber_1"    -- Your only camp for now

-- =========================================================
--  UTILITIES
-- =========================================================

local function Notify(src, msg)
    TriggerClientEvent("lumber:client:Notify", src, msg)
end

local function GetLicense(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:sub(1, 7) == "license" then
            return id
        end
    end
    return nil
end

local function IsAdmin(src)
    return IsPlayerAceAllowed(src, ADMIN_ACE)
end

-- =========================================================
--  LOAD CAMP DATA ON RESOURCE START
-- =========================================================

local CampData = {}

CreateThread(function()
    local result = MySQL.query.await("SELECT * FROM lumber_camps")
    for _, row in ipairs(result) do
        CampData[row.camp_id] = row
    end

    print("^2[Lumber] Loaded " .. tostring(#result) .. " lumber camps.")
end)

-- =========================================================
--  SYNC OWNERSHIP TO PLAYER ON JOIN
-- =========================================================

AddEventHandler("playerJoining", function()
    local src = source
    local license = GetLicense(src)
    if not license then return end

    for campId, camp in pairs(CampData) do
        if camp.owner_identifier == license then
            TriggerClientEvent("lumber:client:OwnershipGranted", src, camp)
        end
    end
end)

-- =========================================================
--  ADMIN COMMAND: /lumber assign <playerID> <campID>
-- =========================================================

RegisterCommand("lumber", function(src, args)
    if not IsAdmin(src) then
        return Notify(src, "You do not have permission to use this command.")
    end

    local sub = args[1]
    local target = tonumber(args[2])
    local campId = args[3] or DEFAULT_CAMP

    if not sub then
        return Notify(src, "Usage: /lumber <assign/unassign/info> <playerID> <campID>")
    end

    local camp = CampData[campId]
    if not camp then
        return Notify(src, "Camp does not exist: " .. tostring(campId))
    end

    ---------------------------------------------------------
    -- ASSIGN OWNERSHIP
    ---------------------------------------------------------
    if sub == "assign" then
        if not target then return Notify(src, "Invalid player ID.") end

        local license = GetLicense(target)
        if not license then return Notify(src, "Could not get player license.") end

        MySQL.update.await(
            "UPDATE lumber_camps SET owner_identifier = ? WHERE camp_id = ?",
            { license, campId }
        )

        camp.owner_identifier = license

        TriggerClientEvent("lumber:client:OwnershipGranted", target, camp)
        Notify(src, "Ownership assigned to player " .. target)
        return
    end

    ---------------------------------------------------------
    -- UNASSIGN OWNERSHIP
    ---------------------------------------------------------
    if sub == "unassign" then
        MySQL.update.await(
            "UPDATE lumber_camps SET owner_identifier = NULL WHERE camp_id = ?",
            { campId }
        )

        camp.owner_identifier = nil

        -- Notify all players who might be the owner
        for _, player in ipairs(GetPlayers()) do
            local license = GetLicense(player)
            if license == camp.owner_identifier then
                TriggerClientEvent("lumber:client:OwnershipRevoked", player)
            end
        end

        Notify(src, "Ownership removed for camp " .. campId)
        return
    end

    ---------------------------------------------------------
    -- INFO
    ---------------------------------------------------------
    if sub == "info" then
        local owner = camp.owner_identifier or "None"
        Notify(src, "Camp: " .. campId .. " | Owner: " .. owner)
        return
    end

    Notify(src, "Unknown subcommand.")
end)
