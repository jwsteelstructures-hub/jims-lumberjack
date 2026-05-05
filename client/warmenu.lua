local Warmenu = exports.warmenu

function OpenLumberMainMenu()
    Warmenu.CreateMenu('lumber_main', 'Lumber Company')
    Warmenu.SetSubTitle('lumber_main', 'Select an option')
    Warmenu.OpenMenu('lumber_main')

    while Warmenu.IsMenuOpened('lumber_main') do

        if Warmenu.Button('Ledger') then
            Warmenu.CloseMenu()
            TriggerEvent('lumber:openNUI', 'ledger')
        end

        if Warmenu.Button('Upgrades') then
            Warmenu.CloseMenu()
            TriggerEvent('lumber:openNUI', 'upgrades')
        end

        if Warmenu.Button('Manage Workers') then
            Warmenu.CloseMenu()
            TriggerEvent('lumber:openNUI', 'workers')
        end

        if Warmenu.Button('Inventory') then
            Warmenu.CloseMenu()
            TriggerEvent('lumber:openNUI', 'inventory')
        end

        Warmenu.Display()
        Wait(0)
    end
end
