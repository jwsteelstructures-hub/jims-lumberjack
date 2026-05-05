print("CLIENT UI LOADED")

---------------------------------------------------------------------
-- WARMENU MAIN MENU
---------------------------------------------------------------------

function OpenLumberMainMenu()
    -- Create the main menu
    WarMenu.CreateMenu('lumber_main', 'Lumber Company')
    WarMenu.SetSubTitle('lumber_main', 'Select an option')

    -- Open it
    WarMenu.OpenMenu('lumber_main')

    -- Menu loop
    while WarMenu.IsMenuOpened('lumber_main') do

        if WarMenu.Button('Ledger') then
            WarMenu.CloseMenu()
            TriggerEvent('lumber:openNUI', 'ledger')
        end

        if WarMenu.Button('Upgrades') then
            WarMenu.CloseMenu()
            TriggerEvent('lumber:openNUI', 'upgrades')
        end

        if WarMenu.Button('Manage Workers') then
            WarMenu.CloseMenu()
            TriggerEvent('lumber:openNUI', 'workers')
        end

        if WarMenu.Button('Inventory') then
            WarMenu.CloseMenu()
            TriggerEvent('lumber:openNUI', 'inventory')
        end

        WarMenu.Display()
        Wait(0)
    end
end

---------------------------------------------------------------------
-- COMMAND TO OPEN MENU (TEMPORARY)
---------------------------------------------------------------------

RegisterCommand("lumbermenu", function()
    OpenLumberMainMenu()
end)

---------------------------------------------------------------------
-- WARMENU → NUI BRIDGE
---------------------------------------------------------------------

RegisterNetEvent("lumber:openNUI")
AddEventHandler("lumber:openNUI", function(tab)
    print("NUI OPEN EVENT RECEIVED (TAB: " .. tostring(tab) .. ")")
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        tab = tab
    })
end)

---------------------------------------------------------------------
-- NUI CLOSE CALLBACK
---------------------------------------------------------------------

RegisterNUICallback("lumber_ui_close", function()
    SetNuiFocus(false, false)
end)
