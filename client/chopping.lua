local chopping = false
local currentTree = nil
local trees = {}

-- Receive tree list from server
RegisterNetEvent("lumber:syncTrees", function(serverTrees)
    trees = serverTrees
end)

-- Chop key (E)
local CHOP_KEY = 0xCEFD9220

-- Distance to interact
local INTERACT_DIST = 2.0

CreateThread(function()
    while true do
        Wait(0)

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for id, tree in pairs(trees) do
            local dist = #(coords - vector3(tree.x, tree.y, tree.z))

            if dist < INTERACT_DIST and not chopping and not tree.falling then
                -- Show prompt
                DrawTxt("Press [E] to Chop Tree", 0.5, 0.9)

                if IsControlJustPressed(0, CHOP_KEY) then
                    chopping = true
                    currentTree = id
                    TriggerServerEvent("lumber:startChop", id)
                end
            end
        end
    end
end)

-- Server tells client to play chop animation
RegisterNetEvent("lumber:playChopAnim", function()
    local ped = PlayerPedId()

    TaskStartScenarioInPlace(ped, GetHashKey("WORLD_HUMAN_CHOP_WOOD"), -1, true)
    Wait(1500)
    ClearPedTasks(ped)

    chopping = false
end)

-- Server tells client to play tree fall animation
RegisterNetEvent("lumber:treeFell", function(treeId)
    local tree = trees[treeId]
    if not tree then return end

    -- You can add a falling animation here later
    trees[treeId].falling = true
end)

-- Simple text draw
function DrawTxt(text, x, y)
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 215)
    SetTextCentre(true)
    DisplayText(CreateVarString(10, "LITERAL_STRING", text), x, y)
end
