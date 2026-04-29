Debug = {}

local levels = {
    error = 1,
    warn  = 2,
    info  = 3
}

function Debug:Print(level, msg)
    if not Config.Debug then return end

    local lvl = levels[level]
    if not lvl then return end

    if lvl <= Config.DebugLevel then
        print(("^3[Lumberjack:%s]^0 %s"):format(level, msg))
    end
end

function Debug:Info(msg)
    self:Print("info", msg)
end

function Debug:Warn(msg)
    self:Print("warn", msg)
end

function Debug:Error(msg)
    self:Print("error", msg)
end
