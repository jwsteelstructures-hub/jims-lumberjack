local json = json or require("json")

----------------------------------------------------------------
-- Helpers
----------------------------------------------------------------

local function getRank(identifier, cb)
    fetchScalar("SELECT rank FROM lumber_workers WHERE camp_id = ? AND identifier = ?", {
        Config.CampId, identifier
    }, function(rank)
        cb(rank or 0)
    end)
end

local function isManager(rank)
    return rank >= 3 -- Foreman or Owner
end

local function getCampFunds(cb)
    fetchScalar("SELECT funds FROM lumber_camps WHERE camp_id = ?", { Config.CampId }, function(funds)
        cb(funds or 0)
    end)
end

local function addFunds(amount)
    execute("UPDATE lumber_camps SET funds = funds + ? WHERE camp_id = ?", { amount, Config.CampId })
end

local function removeFunds(amount)
    execute("UPDATE lumber_camps SET funds = funds - ? WHERE camp_id = ?", { amount, Config.CampId })
end

----------------------------------------------------------------
-- OFFICE PHASE UPGRADES
----------------------------------------------------------------

RegisterNetEvent("lumber:upgradeOfficePhase", function()
    local src = source
    local identifier = getPlayerIdentifier(src)

    getRank(identifier, function(rank)
        if not isManager(rank) then return end

        fetchAll("SELECT office_phase FROM lumber_camps WHERE camp_id = ?", { Config.CampId }, function(rows)
            local phase = rows[1].office_phase
            if phase >= 3 then
                TriggerClientEvent("lumber:notify", src, "Office already fully built.")
                return
            end

            local cost = Config.Construction["phase" .. (phase + 1)]

            getCampFunds(function(funds)
                if funds < cost then
                    TriggerClientEvent("lumber:notify", src, "Not enough company funds.")
                    return
                end

                removeFunds(cost)
                execute("UPDATE lumber_camps SET office_phase = office_phase + 1 WHERE camp_id = ?", { Config.CampId })

                TriggerClientEvent("lumber:officePhaseBuilt", -1, phase + 1)
            end)
        end)
    end)
end)

----------------------------------------------------------------
-- PLAYER-PLACED UPGRADES (storage, workstations, tents)
----------------------------------------------------------------

local function getExistingPlacement(tableName, typeField, typeValue, cb)
    fetchAll("SELECT * FROM " .. tableName .. " WHERE camp_id = ? AND " .. typeField .. " = ?", {
        Config.CampId, typeValue
    }, function(rows)
        cb(rows[1] or nil)
    end)
end

-- Generic placement request
-- data: { upgradeType = "hardwood", category = "storage" }
RegisterNetEvent("lumber:requestPlaceUpgrade", function(data)
    local src = source
    local identifier = getPlayerIdentifier(src)

    getRank(identifier, function(rank)
        if not isManager(rank) then return end

        local category = data.category
        local upgradeType = data.upgradeType

        local cfg
        local tableName
        local typeField = "type"

        if category == "storage" then
            cfg = Config.Storages[upgradeType]
            tableName = "lumber_storages"
        elseif category == "workstation" then
            cfg = Config.Workstations[upgradeType]
            tableName = "lumber_workstations"
        elseif category == "tent" then
            cfg = Config.WorkerSlots
            tableName = "lumber_tents"
        else
            return
        end

        if not cfg then return end

        -- Check funds
        getCampFunds(function(funds)
            if funds < cfg.cost then
                TriggerClientEvent("lumber:notify", src, "Not enough company funds.")
                return
            end

            -- Check existing placement (max 1)
            getExistingPlacement(tableName, typeField, upgradeType, function(existing)
                local existingInventory = nil

                if existing then
                    if existing.inventory then
                        existingInventory = existing.inventory
                    end

                    execute("DELETE FROM " .. tableName .. " WHERE id = ?", { existing.id })
                end

                removeFunds(cfg.cost)

                TriggerClientEvent("lumber:beginPlacement", src, {
                    category = category,
                    upgradeType = upgradeType,
                    model = cfg.model,
                    existingInventory = existingInventory
                })
            end)
        end)
    end)
end)

-- Confirm placement
RegisterNetEvent("lumber:confirmPlacement", function(data)
    local src = source
    local category = data.category
    local upgradeType = data.upgradeType

    if category == "storage" then
        execute([[
            INSERT INTO lumber_storages (camp_id, type, x, y, z, heading, inventory)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ]], {
            Config.CampId,
            upgradeType,
            data.x, data.y, data.z, data.heading,
            data.existingInventory or json.encode({})
        })
    elseif category == "workstation" then
        execute([[
            INSERT INTO lumber_workstations (camp_id, type, x, y, z, heading)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ]], {
            Config.CampId,
            upgradeType,
            data.x, data.y, data.z, data.heading
        })
    elseif category == "tent" then
        execute([[
            INSERT INTO lumber_tents (camp_id, x, y, z, heading)
            VALUES (?, ?, ?, ?, ?)
        ]], {
            Config.CampId,
            data.x, data.y, data.z, data.heading
        })
    end
end)
