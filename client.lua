print("CLIENT UI LOADED")

RegisterNetEvent("lumber:openUI")
AddEventHandler("lumber:openUI", function()
    print("NUI OPEN EVENT RECEIVED")
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "open" })
end)

RegisterCommand("lumbermenu", function()
    OpenLumberMainMenu()
end)

RegisterNetEvent("lumber:openNUI")
AddEventHandler("lumber:openNUI", function(tab)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        tab = tab
    })
end)
