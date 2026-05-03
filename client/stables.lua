-- STABLES PHASE UPGRADE
RegisterNUICallback("lumber_upgrade_stables", function(_, cb)
    TriggerServerEvent("lumber:upgradeStablesPhase")
    cb({})
end)

-- BUY WAGON
RegisterNUICallback("lumber_buy_wagon", function(data, cb)
    TriggerServerEvent("lumber:buyWagon", data.wagonType)
    cb({})
end)

-- SET WAGON SPAWN
RegisterNUICallback("lumber_set_wagon_spawn", function(_, cb)
    TriggerServerEvent("lumber:setWagonSpawn")
    cb({})
end)

RegisterNetEvent("lumber:stablesPhaseBuilt", function(phase)
    -- UI refresh if needed
end)

RegisterNetEvent("lumber:wagonPurchased", function(wagonType)
    -- UI refresh if needed
end)
