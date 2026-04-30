function Company.Load()
    print("[Lumberjack] Loading company data...")

    local result = exports.oxmysql:executeSync(
        "SELECT * FROM companies LIMIT 1",
        {}
    )

    if result and result[1] then
        Company.id = result[1].id
        Company.name = result[1].name
        Company.funds = result[1].funds
        print("[Lumberjack] Company loaded:", Company.name, "Funds:", Company.funds)
    else
        local insertId = exports.oxmysql:insertSync(
            "INSERT INTO companies (name, funds) VALUES (?, ?)",
            { Company.name, 0 }
        )

        Company.id = insertId
        print("[Lumberjack] Created new company:", Company.name)
    end
end
