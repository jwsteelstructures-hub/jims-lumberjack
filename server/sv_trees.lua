--========================================================--
--  JIMS LUMBERJACK - SERVER TREE SYSTEM
--========================================================--

local data = LumberServer.GetData()

--========================================================--
--  SAVE + SYNC HELPERS
--========================================================--
local function SaveTrees()
    Utils.SaveJSON("data/trees.json", data.trees)
end

local function SyncTrees()
    TriggerClientEvent("jims-lumberjack:updateTrees", -1, data.trees)
end

--========================================================--
--  VALIDATE TREE EXISTS
--========================================================--
local function TreeExists(treeId)
    return data.trees[treeId] ~= nil
end

--========================================================--
--  CHOP TREE EVENT
--========================================================--
RegisterNetEvent("jims-lumberjack:treeChopped", function(treeId)
    local src = source

    -- Permission check
    if not LumberPerms.Require(src, "Processing") then return end

    -- Validate tree
    if not TreeExists(treeId) then
        print(("^1[ERROR]^0 Player %s attempted to chop invalid tree %s"):format(src, tostring(treeId)))
        return
    end

    local tree = data.trees[treeId]

    -- Prevent double-chop
    if tree.state == "cooldown" then
        print(("^3[WARN]^0 Player %s attempted to chop a tree on cooldown"):format(src))
        return
    end

    -- Mark tree as chopped
    tree.state = "cooldown"
    tree.respawn = os.time() + Config.TreeRespawnTime

    -- Give reward
    local reward = 1 -- 1 hardwood per tree
    TriggerEvent("jims-lumberjack:giveItem", src, "hardwood", reward)

    -- Save + sync
    SaveTrees()
    SyncTrees()

    -- Respawn timer
    CreateThread(function()
        Wait(Config.TreeRespawnTime * 1000)

        tree.state = "ready"
        tree.respawn = nil

        SaveTrees()
        SyncTrees()
    end)
end)

--========================================================--
--  AUTO-RESPAWN CHECK ON RESOURCE START
--========================================================--
AddEventHandler("onResourceStart", function(res)
    if res ~= GetCurrentResourceName() then return end

    CreateThread(function()
        Wait(1000)

        for id, tree in pairs(data.trees) do
            if tree.state == "cooldown" and tree.respawn then
                local remaining = tree.respawn - os.time()

                if remaining <= 0 then
                    -- Respawn immediately
                    tree.state = "ready"
                    tree.respawn = nil
                else
                    -- Schedule respawn
                    CreateThread(function()
                        Wait(remaining * 1000)
                        tree.state = "ready"
                        tree.respawn = nil
                        SaveTrees()
                        SyncTrees()
                    end)
                end
            end
        end

        SaveTrees()
        SyncTrees()
    end)
end)

--========================================================--
--  EXPORT FOR OTHER SERVER MODULES
--========================================================--
LumberTrees = {}

function LumberTrees.SyncAll()
    SyncTrees()
end

return LumberTrees
