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
    if self.player == P1 then
        love.graphics.setColor({0.5, 0.5, 0.8, 1})
    else
        love.graphics.setColor({0.8, 0.5, 0.5, 1})
    end
    love.graphics.rectangle("fill", self.x * CELL_SIZE + 2, self.y * CELL_SIZE + 2, CELL_SIZE - 4, CELL_SIZE - 4)
end

function Unit:hasPlayed()
    return self.hasMoved and self.hasPlayed
end

function Unit:resetTurn()
    self.hasMoved = false
    self.hasAttacked = false
end

function Unit:hasUnitInRange(unit)
    return (math.abs(unit.x - self.x) + math.abs(unit.y - self.y)) <= self.range
end

function Unit:attackEnemy(other)
    self.hasAttacked = true
    local damage = math.max(self.attack - other.defence, 1)
    other.hp = other.hp - damage
end

function Unit:canAttack()
    return not(self.hasAttacked)
end

function Unit:canMove()
    return not(self.hasMoved)
end

return Unit