-- =========================================================
--  Lumber Business - Client Ownership Handler
-- =========================================================

local isOwner = false
local businessData = nil
local campId = "lumber_1"
local currentPhase = 0

-- Expose these for other client scripts
LumberBusiness = {
    IsOwner = function()
        return isOwner
    end,

    GetBusiness = function()
        return businessData
    end
}

-- =========================================================
--  Debug Notify Wrapper
-- =========================================================
local function Debug(msg, level)
    if not Config.Debug then return end
    if level > Config.DebugLevel then return end

    print(("^3[Lumber Debug]^7 %s"):format(msg))
end

-- =========================================================
--  Client Notifications (simple for now)
-- =========================================================
RegisterNetEvent("lumber:client:Notify", function(msg)
    print("^2[Lumber]^7 " .. msg)
end)

-- =========================================================
--  Ownership Granted
-- =========================================================
RegisterNetEvent("lumber:client:OwnershipGranted", function(data)
    isOwner = true
    businessData = data

    Debug("Ownership granted for business: " .. data.name, 3)

    print("^2You are now the owner of ^7" .. data.name)
end)

-- =========================================================
--  Ownership Revoked
-- =========================================================
RegisterNetEvent("lumber:client:OwnershipRevoked", function()
    isOwner = false
    businessData = nil

    Debug("Ownership revoked", 3)

    print("^1Your lumber business ownership has been revoked.")
end)

-- =========================================================
--  Receive Phase Updates From Server
-- =========================================================
RegisterNetEvent("construction:client:updatePhase", function(phase)
    currentPhase = phase
    Debug("Updated local phase to: " .. tostring(phase), 3)
end)

-- =========================================================
--  Request Phase From Server When Opening Menu
-- =========================================================
local function RequestPhase()
    TriggerServerEvent("construction:server:getPhase", campId)
end

-- =========================================================
--  Company Ledger Menu (Phase Purchases)
-- =========================================================
local function OpenCompanyLedger()
    if not isOwner then
        print("^1You do not own this company.")
        return
    end

    RequestPhase()
    Wait(200) -- small sync delay

    print("^3--- Company Ledger ---^7")
    print("Current Phase: " .. tostring(currentPhase))

    -- Phase 2
    if currentPhase < 1 then
        print("1. Build Phase 2 (Locked)")
    elseif currentPhase == 1 then
        print("1. Build Phase 2 (Framing) - $500")
    else
        print("1. Phase 2 Complete")
    end

    -- Phase 3
    if currentPhase < 2 then
        print("2. Build Phase 3 (Locked)")
    elseif currentPhase == 2 then
        print("2. Build Phase 3 (Walls & Roof) - $500")
    else
        print("2. Phase 3 Complete")
    end

    -- Phase 4
    if currentPhase < 3 then
        print("3. Build Phase 4 (Locked)")
    elseif currentPhase == 3 then
        print("3. Build Phase 4 (Interior & Exterior) - $500")
    else
        print("3. Phase 4 Complete")
    end

    print("4. Exit")

    CreateThread(function()
        local waiting = true

        while waiting do
            Wait(0)

            -- Phase 2
            if IsControlJustPressed(0, 0x05CA7C52) then -- 1
                if currentPhase == 1 then
                    TriggerServerEvent("construction:startPhase", campId, 2)
                else
                    print("^1Phase locked or already complete.")
                end
                waiting = false
            end

            -- Phase 3
            if IsControlJustPressed(0, 0x0ADEF539) then -- 2
                if currentPhase == 2 then
                    TriggerServerEvent("construction:startPhase", campId, 3)
                else
                    print("^1Phase locked or already complete.")
                end
                waiting = false
            end

            -- Phase 4
            if IsControlJustPressed(0, 0x6180C54C) then -- 3
                if currentPhase == 3 then
                    TriggerServerEvent("construction:startPhase", campId, 4)
                else
                    print("^1Phase locked or already complete.")
                end
                waiting = false
            end

            -- Exit
            if IsControlJustPressed(0, 0x156F7119) then -- 4
                waiting = false
            end
        end
    end)
end

RegisterNetEvent("lumber:openCompanyLedger", function()
    OpenCompanyLedger()
end)
