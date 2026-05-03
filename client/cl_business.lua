-- =========================================================
--  Lumber Business - Client Ownership + Phase Handler
-- =========================================================

local isOwner = false
local businessData = nil
local campId = "lumber_1"
local currentPhase = 1

LumberBusiness = {
    IsOwner = function()
        return isOwner
    end,

    GetBusiness = function()
        return businessData
    end,

    GetPhase = function()
        return currentPhase
    end
}

-- =========================================================
--  Client Notifications
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

    print("^2You are now the owner of ^7" .. data.camp_id)
end)

-- =========================================================
--  Ownership Revoked
-- =========================================================
RegisterNetEvent("lumber:client:OwnershipRevoked", function()
    isOwner = false
    businessData = nil

    print("^1Your lumber business ownership has been revoked.")
end)

-- =========================================================
--  Phase Updates From Server
-- =========================================================
RegisterNetEvent("construction:client:updatePhase", function(phase)
    currentPhase = phase
end)

-- =========================================================
--  Request Phase When Opening Ledger
-- =========================================================
local function RequestPhase()
    TriggerServerEvent("construction:server:getPhase", campId)
end

-- =========================================================
--  Company Ledger Menu
-- =========================================================
local function OpenCompanyLedger()
    if not isOwner then
        print("^1You do not own this company.")
        return
    end

    RequestPhase()
    Wait(200)

    print("^3--- Company Ledger ---^7")
    print("Current Phase: " .. tostring(currentPhase))

    print("1. Build Phase 2 - $500")
    print("2. Build Phase 3 - $500")
    print("3. Build Phase 4 - $500")
    print("4. Exit")

    CreateThread(function()
        local waiting = true

        while waiting do
            Wait(0)

            if IsControlJustPressed(0, 0x05CA7C52) then -- 1
                TriggerServerEvent("construction:startPhase", campId, 2)
                waiting = false
            end

            if IsControlJustPressed(0, 0x0ADEF539) then -- 2
                TriggerServerEvent("construction:startPhase", campId, 3)
                waiting = false
            end

            if IsControlJustPressed(0, 0x6180C54C) then -- 3
                TriggerServerEvent("construction:startPhase", campId, 4)
                waiting = false
            end

            if IsControlJustPressed(0, 0x156F7119) then -- 4
                waiting = false
            end
        end
    end)
end

RegisterNetEvent("lumber:openCompanyLedger", function()
    OpenCompanyLedger()
end)
