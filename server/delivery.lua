local json = json or require("json")

----------------------------------------------------------------
-- START DELIVERY
----------------------------------------------------------------

RegisterNetEvent("lumber:startDelivery", function(data)
    local src = source
    local wagonType = data.wagonType
    local species = data.species -- oak/pine/maple/cedar OR "sap"

    -- Validate wagon
    fetchAll("SELECT * FROM lumber_wagons WHERE camp_id = ? AND type = ?", {
        Config.CampId, wagonType
    }, function(rows)
        local wagon = rows[1]
        if not wagon then
            TriggerClientEvent("lumber:notify", src, "You do not own this wagon.")
            return
        end

        -- Validate storage
        fetchAll("SELECT * FROM lumber_bulkstorage WHERE camp_id = ? AND type = ?", {
            Config.CampId,
            species == "sap" and "sap" or "logs"
        }, function(storageRows)
            local storage = storageRows[1]
            if not storage then
                TriggerClientEvent("lumber:notify", src, "Storage not built.")
                return
            end

            local dataJson = storage.data and json.decode(storage.data) or {}
            local count = dataJson[species] or 0

            if count < 10 then
                TriggerClientEvent("lumber:notify", src, "Not enough materials to start delivery.")
                return
            end

            -- Deduct 10 units
            dataJson[species] = count - 10

            execute("UPDATE lumber_bulkstorage SET data = ? WHERE id = ?", {
                json.encode(dataJson),
                storage.id
            })

            -- Determine destination
            local destination
            if species == "oak" or species == "pine" then
                destination = "blackwater"
            elseif species == "maple" or species == "cedar" then
                destination = "strawberry"
            elseif species == "sap" then
                destination = "strawberry"
            end

            TriggerClientEvent("lumber:deliveryStarted", src, {
                species = species,
                destination = destination
            })
        end)
    end)
end)

----------------------------------------------------------------
-- COMPLETE DELIVERY
----------------------------------------------------------------

RegisterNetEvent("lumber:completeDelivery", function(data)
    local src = source
    local species = data.species

    local payout = 20 -- placeholder

    execute("UPDATE lumber_camps SET funds = funds + ?, income_from_deliveries = income_from_deliveries + ? WHERE camp_id = ?", {
        payout, payout, Config.CampId
    })

    TriggerClientEvent("lumber:notify", src, "Delivery complete. Company earned $" .. payout)
end)
