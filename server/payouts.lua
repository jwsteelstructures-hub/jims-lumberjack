-- payouts.lua
local Company = require 'server.company'
local Payouts = {}

function Payouts.payPlayer(companyId, playerId, amount)
    local company = Company.get(companyId)
    if not company then return false, "Company not found" end

    if company.funds < amount then
        return false, "Insufficient company funds"
    end

    Company.removeFunds(companyId, amount)

    -- Add money to player (placeholder)
    -- Replace with your framework's money function
    print(("Paid %s to player %s"):format(amount, playerId))

    return true
end

return Payouts
