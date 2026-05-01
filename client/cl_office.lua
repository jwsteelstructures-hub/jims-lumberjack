-- =========================================================
--  Lumber Business - Office / Company Ledger Prompt System
-- =========================================================

local buildingOffice = false
local officeBuilt = false
local campId = "lumber_1"

-- =========================================================
--  Debug Wrapper
-- =========================================================
local function Debug(msg, level)
    if not Config.Debug then return end
    if level > Config.DebugLevel then return end
    print(("^3[Lumber Debug]^7 %s"):format(msg))
end

-- =========================================================
--  Draw 3D Text Helper
-- =========================================================
local function Draw3DText(coords, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)
    if not onScreen then return end

    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 255)
    DisplayText(CreateVarString(10, "LITERAL_STRING", text), _x, _y)
end

-- =========================================================
--  Foundation Build Trigger (Phase 1)
-- =========================================================
RegisterNetEvent("construction:startFoundation", function(camp)
    if camp ~= campId then return end
    buildingOffice = true

    Debug("Foundation build started (60 seconds)", 2)

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
        Debug("Foundation build complete", 2)
    end)
end)

-- =========================================================
--  Main Loop: Prompt Logic
-- =========================================================
CreateThread(function()
    while true do
        Wait(0)

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local dist = #(coords - Config.Camps[campId].prompt)

        if dist > 3.0 then goto continue end

        local owner = LumberBusiness.IsOwner()

        -- =====================================================
        --  NOT OWNER → Show Buy Company Prompt
        -- =====================================================
        if not owner then
            Draw3DText(Config.Camps[campId].prompt + vector3(0, 0, 1.0), "Press [E] to buy company ($3,500)")

            if IsControlJustPressed(0, 0xCEFD9220) then
                TriggerServerEvent("construction:buyCompany", campId)
            end

            goto continue
        end

        -- =====================================================
        --  OWNER BUT FOUNDATION BUILDING
        -- =====================================================
        if buildingOffice then
            Draw3DText(Config.Camps[campId].prompt + vector3(0, 0, 1.0), "Please stand back while your foundation is built.")
            goto continue
        end

        -- =====================================================
        --  OWNER AND FOUNDATION COMPLETE → Company Ledger
        -- =====================================================
        if officeBuilt then
            Draw3DText(Config.Camps[campId].prompt + vector3(0, 0, 1.0), "Press [E] to open Company Ledger")

            if IsControlJustPressed(0, 0xCEFD9220) then
                -- This will open your business menu
                TriggerEvent("lumber:openCompanyLedger", campId)
            end

            goto continue
        end

        ::continue::
    end
end)
