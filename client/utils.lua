-- Simple notification wrapper (replace with your preferred system)

RegisterNetEvent("lumber:notify", function(msg)
    print("[LUMBER] " .. tostring(msg))
end)
