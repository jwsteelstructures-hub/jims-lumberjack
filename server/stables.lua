local function getRank(identifier, cb)
    fetchScalar("SELECT rank FROM lumber_workers WHERE camp_id = ? AND identifier = ?", {
        Config.CampId, identifier
    }, function(rank)
        cb(rank or 0)
    end)
end

local function isManager(rank)
    return rank >= 3
end

----------------------------------------------------------------
-- STABLES PHASE UPGRADES
----------------------------------------------------------------

RegisterNetEvent("lumber:upgradeStablesPhase", function()
    local src = source
    local identifier = getPlayerIdentifier(src)

    getRank(identifier, function(rank)
        if not isManager(rank) then return end

        fetchAll("SELECT stables_phase FROM lumber_camps WHERE camp_id = ?", { Config.CampId }, function(rows)
            local phase = rows[1].stables_phase
            if phase >= 3 then
                TriggerClientEvent("lumber:notify", src, "Stables already fully built.")
                return
            end

            local cost = Config.Stables["phase" .. (phase + 1)]

            fetchScalar("SELECT funds FROM lumber_camps WHERE camp_id = ?", { Config.CampId }, function(funds)
                if funds < cost then
                    TriggerClientEvent("lumber:notify", src, "Not enough company funds.")
                    return
                end

                execute("UPDATE lumber_camps SET funds = funds - ?, stables_phase = stables_phase + 1 WHERE camp_id = ?", {
                    cost, Config.CampId
                })

                TriggerClientEvent("lumber:stablesPhaseBuilt", -1, phase + 1)
            end)
        end)
    end)
end)

----------------------------------------------------------------
-- WAGON SHOP
----------------------------------------------------------------

RegisterNetEvent("lumber:buyWagon", function(wagonType)
    local src = source
    local identifier = getPlayerIdentifier(src)

    getRank(identifier, function(rank)
        if rank < 3 then return end

        local cfg = Config.Wagons[wagonType]
        if not cfg then return end

        fetchScalar("SELECT funds FROM lumber_camps WHERE camp_id = ?", { Config.CampId }, function(funds)
            if funds < cfg.price then
                TriggerClientEvent("lumber:notify", src, "Not enough company funds.")
                return
            end

            -- Check if already owned
            fetchScalar("SELECT id FROM lumber_wagons WHERE camp_id = ? AND type = ?", {
                Config.CampId, wagonType
            }, function(id)
                if id then
                    TriggerClientEvent("lumber:notify", src, "Wagon already owned.")
                    return
                end

                execute("UPDATE lumber_camps SET funds = funds - ? WHERE camp_id = ?", {
                    cfg.price, Config.CampId
                })

                execute([[
                    INSERT INTO lumber_wagons (camp_id, type, health, inventory)
                    VALUES (?, ?, ?, ?)
                ]], {
                    Config.CampId,
                    wagonType,
                    1000,
                    wagonType == "cargo" and json.encode({}) or nil
                })

                TriggerClientEvent("lumber:wagonPurchased", src, wagonType)
            end)
        end)
    end)
end)

----------------------------------------------------------------
-- SET WAGON SPAWN POINT
----------------------------------------------------------------

RegisterNetEvent("lumber:setWagonSpawn", function()
    local src = source
    local identifier = getPlayerIdentifier(src)

    getRank(identifier, function(rank)
        if rank < 3 then return end

        TriggerClientEvent("lumber:beginWagonSpawnPlacement", src)
    end)
end)

RegisterNetEvent("lumber:confirmWagonSpawn", function(data)
    execute([[
        INSERT INTO lumber_stables (camp_id, phase, spawn_x, spawn_y, spawn_z, spawn_heading)
        VALUES (?, 3, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            spawn_x = VALUES(spawn_x),
            spawn_y = VALUES(spawn_y),
            spawn_z = VALUES(spawn_z),
            spawn_heading = VALUES(spawn_heading)
    ]], {
        Config.CampId,
        data.x, data.y, data.z, data.heading
    })
end)
