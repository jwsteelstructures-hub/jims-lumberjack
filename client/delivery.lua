local deliveryBlip = nil

RegisterNUICallback("lumber_start_delivery", function(data, cb)
    -- data = { wagonType = "lumber", species = "oak" }
    TriggerServerEvent("lumber:startDelivery", data)
    cb({})
end)

RegisterNetEvent("lumber:deliveryStarted", function(data)
    -- data = { species = "oak", destination = "blackwater" }

    if deliveryBlip then
        RemoveBlip(deliveryBlip)
    end

    local dest = nil

    if data.destination == "blackwater" then
        dest = vector3(-875.0, -1330.0, 43.0)
    elseif data.destination == "strawberry" then
        dest = vector3(-1800.0, -350.0, 100.0)
    end

    deliveryBlip = N_0x554d9d53f696d002(1664425300, dest.x, dest.y, dest.z)
    SetBlipSprite(deliveryBlip, -1230993421, true)

    TriggerEvent("lumber:notify", "Delivery started. Check your map.")
end)

-- Civ presses G at destination
RegisterNUICallback("lumber_complete_delivery", function(data, cb)
    TriggerServerEvent("lumber:completeDelivery", data)
    cb({})
end)
