-- =========================================================
--  Lumber Business - Office / Company Ledger Interaction
-- =========================================================

local buildingOffice = false
local officeBuilt = false
local campId = "lumber_1"
local blip = nil

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
--  Create Ledger Blip (Owner + Workers)
-- =========================================================
local function CreateLedgerBlip()
    if blip then
        RemoveBlip(blip)
        blip = nil
    end

    local pos = Config.Camps[campId].ledgerPrompt
    if not pos then
        print("^1[Ledger Blip] ledgerPrompt missing from config!^7")
        return
    end

    blip = N_0x554d9d53f696d002(1664425300, pos.x, pos.y, pos.z)

    -- Axes icon
    SetBlipSprite(blip, -1230993421, true)
    SetBlipScale(blip, 0.2)

    -- Name
    local label = CreateVarString(10, "LITERAL_STRING", "Ledger")
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, label)

    print("^2Ledger blip created.^7")
end

local function RemoveLedgerBlip()
    if blip then
        RemoveBlip(blip)
        blip = nil
        print("^3Ledger blip removed.^7")
    end
end

-- =========================================================
--  Blip Visibility Controller (Owner + Workers)
-- =========================================================
CreateThread(function()

    -- Wait until ownership data is available
    while LumberBusiness.IsOwner() == nil do
        Wait(500)
    end

    while true do
        Wait(1500)

        local isOwner = LumberBusiness.IsOwner()
        local isWorker = LumberBusiness.IsWorker and LumberBusiness.IsWorker(campId)

        if (isOwner or isWorker) and not blip then
            CreateLedgerBlip()
        end

        if not isOwner and not isWorker and blip then
            RemoveLedgerBlip()
        end
    end
end)

-- =========================================================
--  Main Loop: Invisible Ledger Interaction
-- =========================================================
CreateThread(function()
    while true do
        Wait(0)

        local ped = PlayerPedId()

        -- Force coords into a proper vector3
        local x, y, z = table.unpack(GetEntityCoords(ped))
        local coords = vector3(x, y, z)

        -- Your ONLY interaction point
        local ledgerPos = Config.Camps[campId].ledgerPrompt

        -- Distance check
        local dist = #(coords - ledgerPos)

        -- Owner OR worker can interact
        local isOwner = LumberBusiness.IsOwner()
        local isWorker = LumberBusiness.IsWorker and LumberBusiness.IsWorker(campId)

        if dist < 2.0 and (isOwner or isWorker) then
            if IsControlJustPressed(0, 0xCEFD9220) then
                TriggerEvent("lumber:openCompanyLedger", campId)
            end
        end
    end
end)
