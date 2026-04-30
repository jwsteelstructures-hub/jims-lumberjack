-- company.lua
local Database = require 'server.database'
local Company = {}

-- Load a company by ID
function Company.get(companyId)
    local result = Database.query("SELECT * FROM companies WHERE id = ?", { companyId })
    return result[1] or nil
end

-- Create a new company
function Company.create(name)
    local id = Database.insert("INSERT INTO companies (name, funds) VALUES (?, 0)", { name })
    return id
end

-- Add funds
function Company.addFunds(companyId, amount)
    Database.update("UPDATE companies SET funds = funds + ? WHERE id = ?", { amount, companyId })
    Company.log(companyId, "add", amount)
end

-- Remove funds
function Company.removeFunds(companyId, amount)
    Database.update("UPDATE companies SET funds = funds - ? WHERE id = ?", { amount, companyId })
    Company.log(companyId, "remove", amount)
end

-- Log transactions
function Company.log(companyId, type, amount)
    Database.insert(
        "INSERT INTO company_transactions (company_id, type, amount) VALUES (?, ?, ?)",
        { companyId, type, amount }
    )
end

return Company
