-- database.lua
Database = {}

function Database.query(query, params)
    return MySQL.query.await(query, params)
end

function Database.scalar(query, params)
    return MySQL.scalar.await(query, params)
end

function Database.update(query, params)
    return MySQL.update.await(query, params)
end

function Database.insert(query, params)
    return MySQL.insert.await(query, params)
end

return Database
