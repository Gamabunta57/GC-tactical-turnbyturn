require("src/db")

local Unit = {}
Unit.__index = Unit;

function Unit.new()
    local unit = {
        x = 0,
        y = 0,
        type = 0
    }
    setmetatable(unit, Unit)
    return unit
end

function Unit.create(player, type, x, y)
    local unit = {
        x = x,
        y = y,
        type = type,
        hasMoved = false,
        hasAttacked = false,
        player = player
    }

    for k in pairs(DB.unit[type]) do
        unit[k] = DB.unit[type][k]
    end
    setmetatable(unit, Unit)
    return unit
end

function Unit:draw()
    love.graphics.setColor({0.5, 0.5, 0.8, 1})
    love.graphics.rectangle("fill", self.x * CELL_SIZE + 2, self.y * CELL_SIZE + 2, CELL_SIZE - 4, CELL_SIZE - 4)
end

function Unit:hasPlayed()
    return self.hasMoved and self.hasPlayed
end

return Unit