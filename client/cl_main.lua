--========================================================--
--  JIMS LUMBERJACK - CLIENT MAIN
--========================================================--

local PlayerRank = 0
local BusinessData = {}
local UIOpen = false

--========================================================--
--  GET PLAYER RANK (EXPORTED TO OTHER CLIENT FILES)
--========================================================--
function GetLumberRank()
    return PlayerRank
end

--========================================================--
--  GET BUSINESS DATA (EXPORTED)
--========================================================--
function GetBusinessData()
    return BusinessData
end

--========================================================--
--  OPEN UI
--========================================================--
function OpenLumberUI(page, data)
    if UIOpen then return end
    UIOpen = true

    SetNuiFocus(true, true)

    SendNUIMessage({
        action = "open",
        page = page,
        payload = data or {}
    })
end

--========================================================--
--  CLOSE UI
--========================================================--
function CloseLumberUI()
    UIOpen = false
    SetNuiFocus(false, false)

    SendNUIMessage({
        action = "close"
    })
end

--========================================================--
--  NUI CALLBACKS
--========================================================--
RegisterNUICallback("close", function(_, cb)
    CloseLumberUI()
    cb("ok")
end)

RegisterNUICallback("officeAction", function(data, cb)
    TriggerServerEvent("jims-lumberjack:officeAction", data)
    cb("ok")
end)

RegisterNUICallback("shopAction", function(data, cb)
    TriggerServerEvent("jims-lumberjack:shopAction", data)
    cb("ok")
end)

RegisterNUICallback("upgradeAction", function(data, cb)
    TriggerServerEvent("jims-lumberjack:upgradeAction", data)
    cb("ok")
end)

--========================================================--
--  RECEIVE PLAYER RANK FROM SERVER
--========================================================--
RegisterNetEvent("jims-lumberjack:setRank", function(rank)
    PlayerRank = rank
    Utils.Debug("Rank updated: " .. tostring(rank))
end)

--========================================================--
--  RECEIVE BUSINESS DATA FROM SERVER
--========================================================--
RegisterNetEvent("jims-lumberjack:updateBusinessData", function(data)
    BusinessData = data
    Utils.Debug("Business data synced.")
end)

--========================================================--
--  OPEN OFFICE MENU (FROM WORLD INTERACTION)
--========================================================--
RegisterNetEvent("jims-lumberjack:openOffice", function()
    OpenLumberUI("office", BusinessData)
end)

--========================================================--
--  OPEN SHOPFRONT MENU
--========================================================--
RegisterNetEvent("jims-lumberjack:openShopfront", function(shopData)
    OpenLumberUI("shopfront", shopData)
end)

--========================================================--
--  OPEN UPGRADES MENU
--========================================================--
RegisterNetEvent("jims-lumberjack:openUpgrades", function(upgradeData)
    OpenLumberUI("upgrades", upgradeData)
end)

--========================================================--
--  INITIAL SYNC ON PLAYER JOIN
--========================================================--
AddEventHandler("vorp:SelectedCharacter", function()
    TriggerServerEvent("jims-lumberjack:requestSync")
end)

--========================================================--
--  ESC KEY CLOSES UI
--========================================================--
CreateThread(function()
    while true do
        Wait(0)
        if UIOpen and IsControlJustPressed(0, 0x156F7119) then -- ESC
            CloseLumberUI()
        end
    end
end)
