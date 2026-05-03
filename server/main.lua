local Camp = {}
local json = json or require("json") -- adjust if needed

-- Simple DB helpers (replace with your wrapper)
local function fetchAll(query, params, cb) exports.ghmattimysql:execute(query, params, cb) end
local function fetchScalar(query, params, cb) exports.ghmattimysql:scalar(query, params, cb) end
local function execute(query, params, cb) exports.ghmattimysql:execute(query, params, cb) end

local function ensureCamp()
    fetchScalar("SELECT id FROM lumber_camps WHERE camp_id = ?", { Config.CampId }, function(id)
        if not id then
            execute([[
                INSERT INTO lumber_camps (camp_id, name, owner_identifier, funds)
                VALUES (?, ?, ?, ?)
            ]], { Config.CampId, Config.CampName, "none", 0 })
        end
    end)
end

CreateThread(ensureCamp)

local function getPlayerIdentifier(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:sub(1, 5) == "steam" or id:sub(1, 7) == "license" then
            return id
        end
    end
    return GetPlayerIdentifier(src, 0)
end

local function getCharacterInfo(src)
    -- VORP hook here if present
    local name = GetPlayerName(src) or "Unknown"
    local charId = src
    return name, charId
end

local function getCampData(cb)
    fetchAll("SELECT * FROM lumber_camps WHERE camp_id = ?", { Config.CampId }, function(rows)
        if not rows or not rows[1] then cb(nil) return end
        cb(rows[1])
    end)
end

local function getWorkers(cb)
    fetchAll("SELECT * FROM lumber_workers WHERE camp_id = ?", { Config.CampId }, function(rows)
        cb(rows or {})
    end)
end

local function getStables(cb)
    fetchAll("SELECT * FROM lumber_stables WHERE camp_id = ?", { Config.CampId }, function(rows)
        cb(rows[1] or { phase = 0 })
    end)
end

local function getStorages(cb)
    fetchAll("SELECT * FROM lumber_storages WHERE camp_id = ?", { Config.CampId }, function(rows)
        cb(rows or {})
    end)
end

local function getWagons(cb)
    fetchAll("SELECT * FROM lumber_wagons WHERE camp_id = ?", { Config.CampId }, function(rows)
        cb(rows or {})
    end)
end

local function getShopFront(cb)
    fetchAll("SELECT * FROM lumber_shopfront WHERE camp_id = ?", { Config.CampId }, function(rows)
        cb(rows[1] or nil)
    end)
end

local function buildLedgerData(cb)
    getCampData(function(camp)
        if not camp then cb(nil) return end

        getWorkers(function(workers)
        getStables(function(stables)
        getStorages(function(storages)
        getWagons(function(wagons)
        getShopFront(function(shop)

            local workerList = {}
            for _, w in ipairs(workers) do
                workerList[#workerList+1] = {
                    identifier = w.identifier,
                    characterName = w.character_name,
                    characterId = w.character_id,
                    rank = w.rank
                }
            end

            local stablesPhase = stables.phase or 0

            local stablesData = {
                phase = stablesPhase,
                spawn = stables.spawn_x and {
                    x = stables.spawn_x,
                    y = stables.spawn_y,
                    z = stables.spawn_z,
                    heading = stables.spawn_heading
                } or nil,
                ownedWagons = {},
                availableWagons = Config.Wagons
            }

            for _, w in ipairs(wagons) do
                stablesData.ownedWagons[#stablesData.ownedWagons+1] = {
                    id = w.id,
                    type = w.type,
                    health = w.health
                }
            end

            local ledger = {
                campId = Config.CampId,
                companyName = camp.name,
                ownerIdentifier = camp.owner_identifier,
                funds = camp.funds,
                incomeFromDeliveries = camp.income_from_deliveries,

                phase = camp.office_phase,
                stablesPhase = camp.stables_phase,

                workers = workerList,
                stables = stablesData,

                shopFront = shop and {
                    capacity = shop.capacity
                } or nil
            }

            cb(ledger)
            
            RegisterNetEvent("lumber:requestLedgerData", function()
    local src = source
    buildLedgerData(function(data)
        if not data then return end
        TriggerClientEvent("lumber:receiveLedgerData", src, data)
    end)
end)

        end) end) end) end)
    end)
end


