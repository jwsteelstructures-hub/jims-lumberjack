local function LoadImaps(list)
    for _, imap in ipairs(list) do
        RequestImap(imap)
    end
end

local function ClearAllImaps()
    for _, phase in pairs(Config.Construction.Imaps) do
        for _, imap in ipairs(phase) do
            RemoveImap(imap)
        end
    end
end

RegisterNetEvent("construction:beginPhase", function(camp, phase)
    ClearAllImaps()
    for i = 1, phase do
        LoadImaps(Config.Construction.Imaps[i])
    end
end)
