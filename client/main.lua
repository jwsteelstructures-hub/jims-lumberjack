local currentPlacement = nil

RegisterNetEvent("lumber:receiveLedgerData", function(data)
    -- Open your UI here, pass `data`
    -- Tabs: Ledger, Upgrades, Stables, Inventory
end)

RegisterNetEvent("lumber:beginPlacement", function(info)
    currentPlacement = info
    -- spawn ghost prop, follow player, show "Press G to place"
end)

CreateThread(function()
    while true do
        Wait(0)
        if currentPlacement then
            -- draw placement preview
            if IsControlJustPressed(0, 0x760A9C6F) then -- G
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                local heading = GetEntityHeading(ped)

                TriggerServerEvent("lumber:confirmPlacement", {
                    type = currentPlacement.type,
                    storageType = currentPlacement.storageType,
                    x = coords.x,
                    y = coords.y,
                    z = coords.z,
                    heading = heading,
                    existingInventory = currentPlacement.existingInventory
                })

                currentPlacement = nil
            end
        end
    end
end)
