------------------------------------------------------------
-- LUMBER COMPANY UI CONTROLLER
-- Handles all NUI messaging, tab switching, and UI routing
------------------------------------------------------------

local uiOpen = false

------------------------------------------------------------
-- OPEN UI (Triggered when ledger data arrives)
------------------------------------------------------------
RegisterNetEvent("lumber:receiveLedgerData", function(data)
    uiOpen = true
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = "lumber_open",
        data = data
    })
end)

RegisterCommand("lumbertest", function()
    TriggerServerEvent("lumber:requestLedgerData")
end)

------------------------------------------------------------
-- CLOSE UI
------------------------------------------------------------
RegisterNUICallback("lumber_ui_close", function(_, cb)
    uiOpen = false
    SetNuiFocus(false, false)
    cb({})
end)

------------------------------------------------------------
-- TAB SWITCHING
------------------------------------------------------------
RegisterNUICallback("lumber_ui_switch_tab", function(data, cb)
    SendNUIMessage({
        action = "lumber_switch_tab",
        tab = data.tab
    })
    cb({})
end)

------------------------------------------------------------
-- LEDGER TAB
------------------------------------------------------------
RegisterNUICallback("lumber_ledger_deposit", function(data, cb)
    TriggerServerEvent("lumber:depositFunds", data.amount)
    cb({})
end)

RegisterNUICallback("lumber_ledger_withdraw", function(data, cb)
    TriggerServerEvent("lumber:withdrawFunds", data.amount)
    cb({})
end)

------------------------------------------------------------
-- UPGRADES TAB
------------------------------------------------------------
RegisterNUICallback("lumber_upgrade_office", function(_, cb)
    TriggerServerEvent("lumber:upgradeOfficePhase")
    cb({})
end)

RegisterNUICallback("lumber_place_upgrade", function(data, cb)
    TriggerServerEvent("lumber:requestPlaceUpgrade", data)
    cb({})
end)

------------------------------------------------------------
-- STABLES TAB
------------------------------------------------------------
RegisterNUICallback("lumber_upgrade_stables", function(_, cb)
    TriggerServerEvent("lumber:upgradeStablesPhase")
    cb({})
end)

RegisterNUICallback("lumber_buy_wagon", function(data, cb)
    TriggerServerEvent("lumber:buyWagon", data.wagonType)
    cb({})
end)

RegisterNUICallback("lumber_set_wagon_spawn", function(_, cb)
    TriggerServerEvent("lumber:setWagonSpawn")
    cb({})
end)

------------------------------------------------------------
-- INVENTORY TAB
------------------------------------------------------------
RegisterNUICallback("lumber_inventory_withdraw", function(data, cb)
    TriggerServerEvent("lumber:inventoryWithdraw", data)
    cb({})
end)

RegisterNUICallback("lumber_inventory_deposit", function(data, cb)
    TriggerServerEvent("lumber:inventoryDeposit", data)
    cb({})
end)

------------------------------------------------------------
-- SHOP FRONT (EMPLOYEE)
------------------------------------------------------------
RegisterNUICallback("lumber_shop_deposit", function(data, cb)
    TriggerServerEvent("lumber:shopDepositItem", data)
    cb({})
end)

RegisterNUICallback("lumber_shop_withdraw", function(data, cb)
    TriggerServerEvent("lumber:shopWithdrawItem", data)
    cb({})
end)

RegisterNUICallback("lumber_shop_set_price", function(data, cb)
    TriggerServerEvent("lumber:shopSetPrice", data)
    cb({})
end)

------------------------------------------------------------
-- SHOP FRONT (CUSTOMER)
------------------------------------------------------------
RegisterNUICallback("lumber_shop_buy", function(data, cb)
    TriggerServerEvent("lumber:shopBuyItem", data)
    cb({})
end)

------------------------------------------------------------
-- DELIVERY TAB
------------------------------------------------------------
RegisterNUICallback("lumber_start_delivery", function(data, cb)
    TriggerServerEvent("lumber:startDelivery", data)
    cb({})
end)

RegisterNUICallback("lumber_complete_delivery", function(data, cb)
    TriggerServerEvent("lumber:completeDelivery", data)
    cb({})
end)


------------------------------------------------------------
-- WORLD INTERACTION (Press G near shop front)
------------------------------------------------------------
CreateThread(function()
    while true do
        Wait(0)

        if not uiOpen then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local shop = Config.ShopFront.location

            if #(coords - vector3(shop.x, shop.y, shop.z)) < 2.0 then
                if IsControlJustPressed(0, 0x760A9C6F) then
                    TriggerServerEvent("lumber:openShopCustomer")
                end
            end
        end
    end
end)
