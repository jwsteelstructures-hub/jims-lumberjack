require '@cfx.re/server/compat/module'

-- main.lua
local Company = require 'company'
local Payouts = require 'payouts'

-- Debug: create a company
RegisterCommand("lj_create_company", function(source, args)
    local name = table.concat(args, " ")
    if name == "" then
        print("Usage: /lj_create_company <name>")
        return
    end

    local id = Company.create(name)
    print("Created company with ID:", id)
end)

-- Debug: add funds
RegisterCommand("lj_add_funds", function(source, args)
    local id = tonumber(args[1])
    local amount = tonumber(args[2])
    Company.addFunds(id, amount)
    print("Added", amount, "to company", id)
end)

-- Debug: pay player
RegisterCommand("lj_pay", function(source, args)
    local companyId = tonumber(args[1])
    local playerId = tonumber(args[2])
    local amount = tonumber(args[3])

    local ok, msg = Payouts.payPlayer(companyId, playerId, amount)
    print(ok and "Paid player" or ("Failed: " .. msg))
end)
