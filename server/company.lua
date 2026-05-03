-- =========================================================
--  Company.lua - Lumber Camp Backend (Funds + Ledger)
-- =========================================================

Company = {}

-- =========================================================
--  Get Camp Data
-- =========================================================
function Company.get(campId)
    local result = MySQL.query.await(
        "SELECT * FROM lumber_camps WHERE camp_id = ?",
        { campId }
    )
    return result[1] or nil
end

-- =========================================================
--  Create Camp (Only needed if adding new camps manually)
-- =========================================================
function Company.create(campId)
    MySQL.insert.await(
        "INSERT INTO lumber_camps (camp_id, owner_identifier, funds, phase) VALUES (?, NULL, 0, 1)",
        { campId }
    )
end

-- =========================================================
--  Add Funds
-- =========================================================
function Company.addFunds(campId, amount)
    MySQL.update.await(
        "UPDATE lumber_camps SET funds = funds + ? WHERE camp_id = ?",
        { amount, campId }
    )
    Company.log(campId, "add", amount)
end

-- =========================================================
--  Remove Funds
-- =========================================================
function Company.removeFunds(campId, amount)
    MySQL.update.await(
        "UPDATE lumber_camps SET funds = funds - ? WHERE camp_id = ?",
        { amount, campId }
    )
    Company.log(campId, "remove", amount)
end

-- =========================================================
--  Log Transactions
-- =========================================================
function Company.log(campId, type, amount)
    MySQL.insert.await(
        "INSERT INTO lumber_transactions (camp_id, type, amount) VALUES (?, ?, ?)",
        { campId, type, amount }
    )
end
