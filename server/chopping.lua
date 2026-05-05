local Trees = {}
local RESPAWN_TIME = 5 * 60 -- 5 minutes

-- Example tree registry (you can expand this)
Trees = {
    [1] = { x = -200.0, y = 800.0, z = 120.0, health = 100, falling = false, respawn = 0 },
    [2] = { x = -210.0, y = 805.0, z = 120.0, health = 100, falling = false, respawn = 0 },
}

-- Sync trees to client
RegisterNetEvent("lumber:requestTrees", function()
    local src = source
    TriggerClientEvent("lumber:syncTrees", src, Trees)
end)

-- Player starts chopping
RegisterNetEvent("lumber:startChop", function(treeId)
    local src = source
    local tree = Trees[treeId]
    if not tree then return end
    if tree.falling then return end

    -- Reduce health
    tree.health = tree.health - 25

    -- Tell client to play chop animation
    TriggerClientEvent("lumber:playChopAnim", src)

    -- If tree falls
    if tree.health <= 0 then
        tree.falling = true
        tree.respawn = os.time() + RESPAWN_TIME

        -- Add logs to storage
        exports.oxmysql:update(
            "UPDATE lumber_storages SET logs = logs + 2 WHERE camp_id = ?",
            { Config.CampId }
        )

        -- Notify client tree fell
        TriggerClientEvent("lumber:treeFell", -1, treeId)
    end
end)

-- Respawn loop
CreateThread(function()
    while true do
        Wait(5000)

        local now = os.time()

        for id, tree in pairs(Trees) do
            if tree.falling and now >= tree.respawn then
                tree.health = 100
                tree.falling = false
                tree.respawn = 0

                -- Sync to all clients
                TriggerClientEvent("lumber:syncTrees", -1, Trees)
            end
        end
    end
end)
