local state = {}

local function LoadState()
    local saved = LoadResourceFile(GetCurrentResourceName(), "construction.json")
    if saved then
        state = json.decode(saved)
    end
end

local function SaveState()
    SaveResourceFile(GetCurrentResourceName(), "construction.json", json.encode(state), -1)
end

LoadState()

function GetCampPhase(camp)
    if not state[camp] then
        state[camp] = { phase = 0, owner = nil }
        SaveState()
    end
    return state[camp].phase
end

function SetCampPhase(camp, phase)
    if not state[camp] then return end
    state[camp].phase = phase
    SaveState()

    -- NEW: broadcast updated phase to all clients
    TriggerClientEvent("construction:client:updatePhase", -1, phase)
end

function SetCampOwner(camp, owner)
    if not state[camp] then return end
    state[camp].owner = owner
    SaveState()
end

function GetCampOwner(camp)
    if not state[camp] then return nil end
    return state[camp].owner
end

-- =========================================================
--  NEW: Client requests current phase
-- =========================================================
RegisterNetEvent("construction:server:getPhase", function(camp)
    local src = source
    local phase = GetCampPhase(camp)
    TriggerClientEvent("construction:client:updatePhase", src, phase)
end)
