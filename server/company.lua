-- ============================================
-- Lumberjack Job - Company Backend (Legacy oxmysql)
-- ============================================

Company = {
    id = nil,
    name = "Jim's Lumber Co.",
    funds = 0
}

-- ============================================
-- Load or Create Company
-- ============================================

function Company.Load()
    print("[Lumberjack] Loading company data...")

    exports.oxmysql:query(
        "SELECT * FROM companies LIMIT 1",
        {},
        function(result)
            if result and result[1] then
                Company.id = result[1].id
                Company.name = result[1].name
                Company.funds = result[1].funds

                print("[Lumberjack] Company loaded:", Company.name, "Funds:", Company.funds)
            else
                exports.oxmysql:insert(
                    "INSERT INTO companies (name, funds) VALUES (?, ?)",
                    { Company.name, 0 },
                    function(insertId)
                        Company.id = insertId
                        print("[Lumberjack] Created new company:", Company.name)
                    end
                )
            end
        end
    )
end

-- ============================================
-- Company Funds Management
-- ============================================

function Company.AddFunds(amount)
    Company.funds = Company.funds + amount

    exports.oxmysql:update(
        "UPDATE companies SET funds = ? WHERE id = ?",
        { Company.funds, Company.id }
    )

    Company.LogTransaction("add", amount)
end

function Company.RemoveFunds(amount)
    Company.funds = Company.funds - amount

    exports.oxmysql:update(
        "UPDATE companies SET funds = ? WHERE id = ?",
        { Company.funds, Company.id }
    )

    Company.LogTransaction("remove", amount)
end

-- ============================================
-- Transaction Logging
-- ============================================

function Company.LogTransaction(type, amount)
    exports.oxmysql:insert(
        "INSERT INTO company_transactions (company_id, type, amount) VALUES (?, ?, ?)",
        { Company.id, type, amount }
    )
end
