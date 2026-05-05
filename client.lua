RegisterNetEvent("lumber:openUI", function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "open" })
end)

RegisterNUICallback("close", function()
    SetNuiFocus(false, false)
end)
