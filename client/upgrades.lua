-- Handles upgrade UI callbacks and triggers server events

RegisterNUICallback("lumber_upgrade_office", function(_, cb)
    TriggerServerEvent("lumber:upgradeOfficePhase")
    cb({})
end)

RegisterNUICallback("lumber_place_upgrade", function(data, cb)
    -- data = { category = "storage", upgradeType = "hardwood" }
    TriggerServerEvent("lumber:requestPlaceUpgrade", data)
    cb({})
end)

RegisterNetEvent("lumber:officePhaseBuilt", function(phase)
    -- Optional: notify UI or player
end)
