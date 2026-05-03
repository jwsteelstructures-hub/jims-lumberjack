-- Spawn shop front prop
RegisterNetEvent("lumber:spawnShopFront", function(data)
    local model = GetHashKey(data.model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local obj = CreateObject(model, data.location.x, data.location.y, data.location.z, false, false, false)
    SetEntityHeading(obj, data.location.w)
    FreezeEntityPosition(obj, true)
end)

-- Open as employee
RegisterNetEvent("lumber:openShopEmployeeUI", function(shop)
    SendNUIMessage({
        action = "lumber_shop_open_employee",
        data = shop
    })
    SetNuiFocus(true, true)
end)

-- Open as customer
RegisterNetEvent("lumber:openShopCustomerUI", function(shop)
    SendNUIMessage({
        action = "lumber_shop_open_customer",
        data = shop
    })
    SetNuiFocus(true, true)
end)

-- Close UI
RegisterNUICallback("lumber_shop_close", function(_, cb)
    SetNuiFocus(false, false)
    cb({})
end)

-- Employee deposit
RegisterNUICallback("lumber_shop_deposit", function(data, cb)
    TriggerServerEvent("lumber:shopDepositItem", data)
    cb({})
end)

-- Employee withdraw
RegisterNUICallback("lumber_shop_withdraw", function(data, cb)
    TriggerServerEvent("lumber:shopWithdrawItem", data)
    cb({})
end)

-- Employee set price
RegisterNUICallback("lumber_shop_set_price", function(data, cb)
    TriggerServerEvent("lumber:shopSetPrice", data)
    cb({})
end)

-- Customer buy
RegisterNUICallback("lumber_shop_buy", function(data, cb)
    TriggerServerEvent("lumber:shopBuyItem", data)
    cb({})
end)

-- World interaction (press G at shop front)
CreateThread(function()
    while true do
        Wait(0)

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local shop = Config.ShopFront.location

        if #(coords - vector3(shop.x, shop.y, shop.z)) < 2.0 then
            if IsControlJustPressed(0, 0x760A9C6F) then
                -- Worker or civ?
                TriggerServerEvent("lumber:openShopCustomer")
            end
        end
    end
end)
