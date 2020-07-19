local Ai = {}

local Waiting = "Waiting"
local AttackEnemy = "AttackEnemy"
local NoActionPossible = "NoActionPossible"

Ai.__index = Ai

function Ai.new(game)
    local ai = {
        state = Waiting,
        actionDelay = 1,
        timer = 0,
        game = game;
        movableCells = {}
    }

    ai.timer = ai.actionDelay
    setmetatable(ai, Ai)
    return ai
end

function Ai:update(dt)
    self["update"..self.state](self, dt)
end

function Ai:updateNoActionPossible(dt)
    self.game:finishTurn()
end

function Ai:updateWaiting(dt)
    if self:canViewEnemy() then
        self.state = AttackEnemy
        self.timer = self.actionDelay
        return;
    end
    self.timer = self.timer - dt
    if self.timer > 0 then
        return;
    end

    self.state = NoActionPossible
end

function Ai:updateAttackEnemy(dt)
    self.timer = self.timer - dt
    if self.timer > 0 then
        return
    end

    self.timer = self.timer + self.actionDelay

    if self.selectedUnit == nil then
        local unit = self:getUnitThatCanAttackWithEnemyInRange() 
        if unit == nil then
            unit = self:getUnitThatCanMove()
        end

        if unit == nil then
            self.state = NoActionPossible
        else
            self:selectUnit(unit)
        end
        return;
    end

    local enemy = self:getUnitInRange(self.selectedUnit, self.game.playerUnits[P1])
    if enemy ~= nil then
        self.selectedUnit.hasMoved = true;
        self.selectedUnit.hasAttacked = true;
        self.selectedUnit:attackEnemy(enemy)
        self:unselectUnit(self.selectedUnit)
    else
        enemy = Ai.getClosestUnit(self.selectedUnit, self.game.playerUnits[P1])
        if enemy ~= nil then
            self:moveSelectedUnitToward(enemy)
            self:unselectUnit(self.selectedUnit)
        else
            self.state = NoActionPossible
        end
    end
end

function Ai:selectUnit(unit)
    if unit == nil then
        self.selectedUnit = nil
        self.movableCells = {}
    else
        self.selectedUnit = unit
        self.movableCells = self.game:getMovableCells(unit)
    end
end

function Ai:unselectUnit(unit)
    self:selectUnit(nil)
end

function Ai:getUnitThatCanAttackWithEnemyInRange()
    local units =  self.game.playerUnits[P2]
    local enemy =  self.game.playerUnits[P1]
    for i = 1, #units do
        local unit = units[i]
        if unit:canAttack() then
            local enemyInRange = self:getUnitInRange(unit, enemy)
            if enemyInRange ~= nil then
                return unit
            end
        end
    end 
    return nil
end

function Ai:getUnitThatCanMove()
    local units =  self.game.playerUnits[P2]
    for i = 1, #units do
        if units[i]:canMove() then
            return units[i]
        end
    end
end

function Ai:getUnitInRange(unit, targetUnits) 
    for i = 1, #targetUnits do
        if unit:hasUnitInRange(targetUnits[i]) then
            return targetUnits[i]
        end
    end
    return nil
end

function Ai.getClosestUnit(unit, targetUnits)
    local data = {
        unit = nil,
        distance = 9999
    }

    for i = 1, #targetUnits do
        local distance = Ai.getDistance(unit, targetUnits[i])
        if distance < data.distance then
            data.unit = targetUnits[i]
            data.distance = distance
        end
    end
    return data.unit
end

function Ai.getDistance(lhs, rhs)
    return math.abs(lhs.x - rhs.x) + math.abs(lhs.y - rhs.y)
end

function Ai:moveSelectedUnitToward(target)
    local data = {
        distance = 9999,
        cell = nil
    }
    for i = 1, #self.movableCells do
        local cell = self.movableCells[i]
        local distance = Ai.getDistance(cell, target)
        if distance < data.distance then
            data.distance = distance
            data.cell = cell
        end
    end

    if data.cell ~= nil then
        self.selectedUnit.x = data.cell.x 
        self.selectedUnit.y = data.cell.y

        self.selectedUnit.hasMoved = true
        self:unselectUnit(self.selectedUnit)
    end
end

function Ai:canViewEnemy() 
    return true; --[[ TODO: improve when fog of war is there ]]
end

function Ai:draw()
    if self.movableCells ~= nil then
        love.graphics.setColor({0.8,0.5,0.5,0.5})
        for i = 1, #self.movableCells do
            local cell = self.movableCells[i]
            love.graphics.rectangle("fill", cell.x * CELL_SIZE, cell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE )
        end
    end
end

function Ai:mouseMoved()
end

function Ai:mousePressed()
end

function Ai:keyPressed()
end

function Ai:newTurn()
    self.timer = self.actionDelay
    self:selectUnit(nil)
    self.state = Waiting
end

return Ai