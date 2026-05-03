local json = json or require("json")

local function getShop(cb)
    fetchAll("SELECT * FROM lumber_shopfront WHERE camp_id = ?", { Config.CampId }, function(rows)
        cb(rows[1] or nil)
    end)
end

local function getShopItems(shopId, cb)
    fetchAll("SELECT * FROM lumber_shopfront_items WHERE shop_id = ?", { shopId }, function(rows)
        cb(rows or {})
    end)
end

local function getShopPrices(shopId, cb)
    fetchAll("SELECT * FROM lumber_shopfront_prices WHERE shop_id = ?", { shopId }, function(rows)
        cb(rows or {})
    end)
end

local function isWorker(identifier, cb)
    fetchScalar("SELECT rank FROM lumber_workers WHERE camp_id = ? AND identifier = ?", {
        Config.CampId, identifier
    }, function(rank)
        cb(rank ~= nil, rank or 0)
    end)
end

-- Build shop data for UI
local function buildShopData(cb)
    getShop(function(shop)
        if not shop then cb(nil) return end

        getShopItems(shop.id, function(items)
        getShopPrices(shop.id, function(prices)

            local priceMap = {}
            for _, p in ipairs(prices) do
                priceMap[p.item_name] = p.price
            end

            local list = {}
            for _, it in ipairs(items) do
                list[#list+1] = {
                    name = it.item_name,
                    count = it.count,
                    price = priceMap[it.item_name] or 0
                }
            end

            cb({
                id = shop.id,
                capacity = shop.capacity,
                items = list
            })

        end) end)
    end)
end

-- Open shop (employees)
RegisterNetEvent("lumber:openShopEmployee", function()
    local src = source
    local identifier = getPlayerIdentifier(src)

    isWorker(identifier, function(isW, rank)
        if not isW then return end

        buildShopData(function(shop)
            if not shop then return end
            TriggerClientEvent("lumber:openShopEmployeeUI", src, shop)
        end)
    end)
end)

-- Open shop (civilians)
RegisterNetEvent("lumber:openShopCustomer", function()
    local src = source

    buildShopData(function(shop)
        if not shop then return end
        TriggerClientEvent("lumber:openShopCustomerUI", src, shop)
    end)
end)

-- Helper: get total items in shop
local function getShopItemCount(shopId, cb)
    fetchScalar("SELECT COALESCE(SUM(count), 0) FROM lumber_shopfront_items WHERE shop_id = ?", {
        shopId
    }, function(total)
        cb(total or 0)
    end)
end

-- Employee deposits items into shop
-- data: { item = "plank_oak", amount = 10 }
RegisterNetEvent("lumber:shopDepositItem", function(data)
    local src = source
    local identifier = getPlayerIdentifier(src)
    local item = data.item
    local amount = tonumber(data.amount or 0) or 0
    if amount <= 0 then return end

    isWorker(identifier, function(isW, rank)
        if not isW then return end

        getShop(function(shop)
            if not shop then return end

            getShopItemCount(shop.id, function(total)
                if total + amount > shop.capacity then
                    TriggerClientEvent("lumber:notify", src, "Shop is full.")
                    return
                end

                -- TODO: remove items from player inventory (VORP hook)
                -- if not removeItemFromPlayer(src, item, amount) then return end

                execute([[
                    INSERT INTO lumber_shopfront_items (shop_id, item_name, count)
                    VALUES (?, ?, ?)
                    ON DUPLICATE KEY UPDATE count = count + VALUES(count)
                ]], { shop.id, item, amount })

                buildShopData(function(updated)
                    TriggerClientEvent("lumber:openShopEmployeeUI", src, updated)
                end)
            end)
        end)
    end)
end)

-- Employee withdraws items from shop
-- data: { item = "plank_oak", amount = 5 }
RegisterNetEvent("lumber:shopWithdrawItem", function(data)
    local src = source
    local identifier = getPlayerIdentifier(src)
    local item = data.item
    local amount = tonumber(data.amount or 0) or 0
    if amount <= 0 then return end

    isWorker(identifier, function(isW, rank)
        if not isW then return end

        getShop(function(shop)
            if not shop then return end

            fetchAll("SELECT * FROM lumber_shopfront_items WHERE shop_id = ? AND item_name = ?", {
                shop.id, item
            }, function(rows)
                local row = rows[1]
                if not row or row.count < amount then
                    TriggerClientEvent("lumber:notify", src, "Not enough stock.")
                    return
                end

                -- TODO: give items to player (VORP hook)
                -- addItemToPlayer(src, item, amount)

                if row.count == amount then
                    execute("DELETE FROM lumber_shopfront_items WHERE id = ?", { row.id })
                else
                    execute("UPDATE lumber_shopfront_items SET count = count - ? WHERE id = ?", {
                        amount, row.id
                    })
                end

                buildShopData(function(updated)
                    TriggerClientEvent("lumber:openShopEmployeeUI", src, updated)
                end)
            end)
        end)
    end)
end)

-- Employee sets price / buy list entry
-- data: { item = "plank_oak", price = 3 }
RegisterNetEvent("lumber:shopSetPrice", function(data)
    local src = source
    local identifier = getPlayerIdentifier(src)
    local item = data.item
    local price = tonumber(data.price or 0) or 0
    if price < 0 then price = 0 end

    isWorker(identifier, function(isW, rank)
        if not isW then return end

        getShop(function(shop)
            if not shop then return end

            execute([[
                INSERT INTO lumber_shopfront_prices (shop_id, item_name, price)
                VALUES (?, ?, ?)
                ON DUPLICATE KEY UPDATE price = VALUES(price)
            ]], { shop.id, item, price })

            buildShopData(function(updated)
                TriggerClientEvent("lumber:openShopEmployeeUI", src, updated)
            end)
        end)
    end)
end)

-- Customer buys item
-- data: { item = "plank_oak", amount = 5 }
RegisterNetEvent("lumber:shopBuyItem", function(data)
    local src = source
    local item = data.item
    local amount = tonumber(data.amount or 0) or 0
    if amount <= 0 then return end

    getShop(function(shop)
        if not shop then return end

        fetchAll("SELECT * FROM lumber_shopfront_items WHERE shop_id = ? AND item_name = ?", {
            shop.id, item
        }, function(rows)
            local row = rows[1]
            if not row or row.count < amount then
                TriggerClientEvent("lumber:notify", src, "Not enough stock.")
                return
            end

            fetchAll("SELECT price FROM lumber_shopfront_prices WHERE shop_id = ? AND item_name = ?", {
                shop.id, item
            }, function(priceRows)
                local price = priceRows[1] and priceRows[1].price or 0
                if price <= 0 then
                    TriggerClientEvent("lumber:notify", src, "Item not for sale.")
                    return
                end

                local totalCost = price * amount

                -- TODO: check player money, remove money (framework hook)
                -- if not removeMoneyFromPlayer(src, totalCost) then return end

                -- Add to company ledger
                execute("UPDATE lumber_camps SET funds = funds + ?, income_from_deliveries = income_from_deliveries + ? WHERE camp_id = ?", {
                    totalCost, totalCost, Config.CampId
                })

                -- Give items to player
                -- addItemToPlayer(src, item, amount)

                if row.count == amount then
                    execute("DELETE FROM lumber_shopfront_items WHERE id = ?", { row.id })
                else
                    execute("UPDATE lumber_shopfront_items SET count = count - ? WHERE id = ?", {
                        amount, row.id
                    })
                end

                buildShopData(function(updated)
                    TriggerClientEvent("lumber:openShopCustomerUI", src, updated)
                end)
            end)
        end)
    end)
end)
