RegisterNetEvent("construction:buyCompany", function(camp)
    local src = source
    local owner = GetCampOwner(camp)
    if owner then return end

    local price = Config.Construction.PurchasePrice
    local ok = true

    if not ok then
        TriggerClientEvent("construction:notify", src, "Not enough money.")
        return
    end

    SetCampOwner(camp, src)
    SetCampPhase(camp, 1)

    TriggerClientEvent("construction:startFoundation", src, camp)
end)

RegisterNetEvent("construction:startPhase", function(camp, phase)
    local src = source
    local owner = GetCampOwner(camp)
    if owner ~= src then return end

    local current = GetCampPhase(camp)
    if phase ~= current + 1 then return end

    local cost = Config.Construction.Phases[phase].cost
    if cost > 0 then
        local ok = true
        if not ok then
            TriggerClientEvent("construction:notify", src, "Not enough money.")
            return
        end
    end

    SetCampPhase(camp, phase)
    TriggerClientEvent("construction:beginPhase", -1, camp, phase)
end)
