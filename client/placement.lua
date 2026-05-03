local placing = false
local placeData = nil
local ghost = nil

local function loadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(0) end
    return hash
end

local function deleteGhost()
    if ghost then
        DeleteObject(ghost)
        ghost = nil
    end
end

RegisterNetEvent("lumber:beginPlacement", function(data)
    placing = true
    placeData = data

    local model = loadModel(data.model)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    ghost = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
    SetEntityAlpha(ghost, 150, false)
    SetEntityCollision(ghost, false, false)
end)

RegisterNetEvent("lumber:beginWagonSpawnPlacement", function()
    placing = true
    placeData = { category = "wagonSpawn" }

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    ghost = CreateObject(GetHashKey("p_stoolfolding01x"), coords.x, coords.y, coords.z, false, false, false)
    SetEntityAlpha(ghost, 150, false)
    SetEntityCollision(ghost, false, false)
end)

CreateThread(function()
    while true do
        Wait(0)

        if placing and ghost then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)

            SetEntityCoords(ghost, coords.x, coords.y, coords.z - 1.0)
            SetEntityHeading(ghost, heading)

            -- Press G to confirm
            if IsControlJustPressed(0, 0x760A9C6F) then
                local x, y, z = table.unpack(GetEntityCoords(ghost))
                local h = GetEntityHeading(ghost)

                if placeData.category == "wagonSpawn" then
                    TriggerServerEvent("lumber:confirmWagonSpawn", {
                        x = x, y = y, z = z, heading = h
                    })
                else
                    TriggerServerEvent("lumber:confirmPlacement", {
                        category = placeData.category,
                        upgradeType = placeData.upgradeType,
                        x = x, y = y, z = z, heading = h,
                        existingInventory = placeData.existingInventory
                    })
                end

                deleteGhost()
                placing = false
                placeData = nil
            end
        end
    end
end)
