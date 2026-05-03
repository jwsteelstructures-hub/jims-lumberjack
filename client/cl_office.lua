-- =========================================================
--  Lumber Business - Office / Company Ledger Interaction
-- =========================================================

local buildingOffice = false
local officeBuilt = false
local campId = "lumber_1"

-- =========================================================
--  Foundation Build Trigger (Phase 1)
-- =========================================================
RegisterNetEvent("construction:startFoundation", function(camp)
    if camp ~= campId then return end
    buildingOffice = true

    CreateThread(function()
        local timeLeft = Config.OfficeBuildTime

        while timeLeft > 0 do
            print(("^2Building foundation... ^7%d seconds remaining"):format(timeLeft))
            Wait(1000)
            timeLeft -= 1
        end

        buildingOffice = false
        officeBuilt = true

        print("^2Your foundation has been completed.")
    end)
end)

-- =========================================================
--  Main Loop: Invisible Ledger Interaction
-- =========================================================
CreateThread(function()
    while true do
        Wait(0)

        local ped = PlayerPedId()

        -- FIX: Force coords into a proper vector3
        local x, y, z = table.unpack(GetEntityCoords(ped))
        local coords = vector3(x, y, z)

        local ledgerPos = Config.Camps[campId].ledgerPrompt

        -- Distance check
        local dist = #(coords - ledgerPos)

        -- Only owners can interact
        if dist < 2.0 and LumberBusiness.IsOwner() then
            if IsControlJustPressed(0, 0xCEFD9220) then
                TriggerEvent("lumber:openCompanyLedger", campId)
            end
        end
    end
end)
