local function getRank(identifier, cb)
    fetchScalar("SELECT rank FROM lumber_workers WHERE camp_id = ? AND identifier = ?", {
        Config.CampId, identifier
    }, function(rank)
        cb(rank or 0)
    end)
end

local function canManageWorkers(rank)
    return rank >= 3 -- Foreman + Owner
end

RegisterNetEvent("lumber:hireWorker", function(targetIdentifier)
    local src = source
    local srcIdentifier = getPlayerIdentifier(src)

    getRank(srcIdentifier, function(rank)
        if not canManageWorkers(rank) then return end

        local name, charId = getCharacterInfo(src) -- you may want target src instead if online

        execute([[
            INSERT INTO lumber_workers (camp_id, identifier, character_name, character_id, rank)
            VALUES (?, ?, ?, ?, ?)
        ]], { Config.CampId, targetIdentifier, name, charId, 1 })
    end)
end)

RegisterNetEvent("lumber:fireWorker", function(targetIdentifier)
    local src = source
    local srcIdentifier = getPlayerIdentifier(src)

    getRank(srcIdentifier, function(rank)
        if not canManageWorkers(rank) then return end

        -- Foreman cannot fire Owner/Foreman
        fetchAll("SELECT rank FROM lumber_workers WHERE camp_id = ? AND identifier = ?", {
            Config.CampId, targetIdentifier
        }, function(rows)
            local targetRank = rows[1] and rows[1].rank or 0
            if rank == 3 and targetRank >= 3 then return end

            execute("DELETE FROM lumber_workers WHERE camp_id = ? AND identifier = ?", {
                Config.CampId, targetIdentifier
            })
        end)
    end)
end)
