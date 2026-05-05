print("SERVER MAIN LOADED")

-----------------------------------------
-- VORP CORE + INVENTORY
-----------------------------------------

local VorpCore = {}
TriggerEvent("getCore", function(core) VorpCore = core end)

local Inventory = exports.vorp_inventory
local ox = exports.oxmysql

local CAMP_ID = Config.CampId or "lumber_1"
local CAMP_NAME = Config.CampName or "Lumber Company"


-----------------------------------------
-- SQL HELPERS
-----------------------------------------

local function fetch(query, params, cb)
    ox:execute(query, params, function(result)
        cb(result)
    end)
end

local function fetchScalar(query, params, cb)
    ox:scalar(query, params, function(result)
        cb(result)
    end)
end

local function exec(query, params)
    ox:execute(query, params)
end


-----------------------------------------
-- ENSURE CAMP EXISTS
-----------------------------------------

local function ensureCamp()
    fetchScalar("SELECT id FROM lumber_camps WHERE camp_id = ?", { CAMP_ID }, function(id)
        if not id then
            exec([[
                INSERT INTO lumber_camps (camp_id, name, owner_identifier, funds, income_from_deliveries, office_phase, stables_phase)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ]], { CAMP_ID, CAMP_NAME, "none", 0, 0, 1, 0 })
            print("[LUMBER] Created new camp:", CAMP_ID)
        end
    end)
end

CreateThread(ensureCamp)


-----------------------------------------
-- LEDGER DATA PACKAGE (SIMPLE)
-----------------------------------------

local function buildLedgerData(src, cb)
    fetch("SELECT funds, income_from_deliveries FROM lumber_camps WHERE camp_id = ?", { CAMP_ID }, function(rows)
        local camp = rows[1] or {}
        cb({
            funds = camp.funds or 0,
            income = camp.income_from_deliveries or 0
        })
    end)
end


-----------------------------------------
-- INVENTORY DATA PACKAGE
-----------------------------------------

local function buildInventoryData(src, cb)
    local playerItems = Inventory:getUserInventory(src)

    fetch("SELECT item, amount FROM lumber_storages WHERE camp_id = ?", { CAMP_ID }, function(rows)
        local storage = {}

        for _, row in ipairs(rows) do
            storage[row.item] = storage[row.item] or { items = {} }
            table.insert(storage[row.item].items, {
                name = row.item,
                count = row.amount
            })
        end

        cb({
            playerItems = playerItems,
            storages = storage
        })
    end)
end


-----------------------------------------
-- LEDGER: DEPOSIT
-----------------------------------------

RegisterNetEvent("lumber_ledger_deposit")
AddEventHandler("lumber_ledger_deposit", function(data)
    local src = source
    local amount = tonumber(data.amount)
    if not amount or amount <= 0 then return end

    local Character = VorpCore.getUser(src).getUsedCharacter()
    if Character.getCurrency(0) < amount then return end

    Character.removeCurrency(0, amount)

    exec("UPDATE lumber_camps SET funds = funds + ? WHERE camp_id = ?", {
        amount, CAMP_ID
    })

    buildLedgerData(src, function(pkg)
        TriggerClientEvent("lumber:receiveLedgerData", src, pkg)
    end)
end)


-----------------------------------------
-- LEDGER: WITHDRAW
-----------------------------------------

RegisterNetEvent("lumber_ledger_withdraw")
AddEventHandler("lumber_ledger_withdraw", function(data)
    local src = source
    local amount = tonumber(data.amount)
    if not amount or amount <= 0 then return end

    fetchScalar("SELECT funds FROM lumber_camps WHERE camp_id = ?", { CAMP_ID }, function(funds)
        if not funds or funds < amount then return end

        exec("UPDATE lumber_camps SET funds = funds - ? WHERE camp_id = ?", {
            amount, CAMP_ID
        })

        local Character = VorpCore.getUser(src).getUsedCharacter()
        Character.addCurrency(0, amount)

        buildLedgerData(src, function(pkg)
            TriggerClientEvent("lumber:receiveLedgerData", src, pkg)
        end)
    end)
end)


-----------------------------------------
-- INVENTORY: DEPOSIT ITEM
-----------------------------------------

RegisterNetEvent("lumber_inventory_deposit")
AddEventHandler("lumber_inventory_deposit", function(data)
    local src = source
    local item = data.item
    local amount = tonumber(data.amount)
    if not item or not amount or amount <= 0 then return end

    if Inventory:subItem(src, item, amount) then
        exec([[
            INSERT INTO lumber_storages (camp_id, item, amount)
            VALUES (?, ?, ?)
            ON DUPLICATE KEY UPDATE amount = amount + ?
        ]], { CAMP_ID, item, amount, amount })
    end

    buildInventoryData(src, function(pkg)
        TriggerClientEvent("lumber:receiveInventoryData", src, pkg)
    end)
end)


-----------------------------------------
-- INVENTORY: WITHDRAW ITEM
-----------------------------------------

RegisterNetEvent("lumber_inventory_withdraw")
AddEventHandler("lumber_inventory_withdraw", function(data)
    local src = source
    local item = data.item
    local amount = tonumber(data.amount)
    if not item or not amount or amount <= 0 then return end

    fetchScalar("SELECT amount FROM lumber_storages WHERE camp_id = ? AND item = ?", {
        CAMP_ID, item
    }, function(stored)
        if not stored or stored < amount then return end

        exec("UPDATE lumber_storages SET amount = amount - ? WHERE camp_id = ? AND item = ?", {
            amount, CAMP_ID, item
        })

        Inventory:addItem(src, item, amount)

        buildInventoryData(src, function(pkg)
            TriggerClientEvent("lumber:receiveInventoryData", src, pkg)
        end)
    end)
end)


-----------------------------------------
-- TAB SWITCHING (client → server)
-----------------------------------------

RegisterNetEvent("lumber:uiSwitchTab")
AddEventHandler("lumber:uiSwitchTab", function(tab)
    local src = source

    if tab == "ledger" then
        buildLedgerData(src, function(pkg)
            TriggerClientEvent("lumber:receiveLedgerData", src, pkg)
        end)

    elseif tab == "inventory" then
        buildInventoryData(src, function(pkg)
            TriggerClientEvent("lumber:receiveInventoryData", src, pkg)
        end)

    elseif tab == "upgrades" then
        TriggerClientEvent("lumber_open_upgrades", src, {})

    elseif tab == "stables" then
        TriggerClientEvent("lumber_open_stables", src, {})
    end
end)


-----------------------------------------
-- REQUEST LEDGER (client → server)
-----------------------------------------

RegisterNetEvent("lumber:requestLedgerData")
AddEventHandler("lumber:requestLedgerData", function()
    local src = source
    buildLedgerData(src, function(pkg)
        TriggerClientEvent("lumber:receiveLedgerData", src, pkg)
    end)
end)


-----------------------------------------
-- TEST COMMAND
-----------------------------------------

RegisterCommand("lumbertest", function(source)
    print("LUMBERTES COMMAND FIRED")
    TriggerClientEvent("lumber:openUI", source)
end)
