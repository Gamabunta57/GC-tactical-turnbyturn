local PlayerState = {}
PlayerState.__index = PlayerState

function PlayerState.new(game)
    local playerState = {
        game = game
    }
    setmetatable(playerState, PlayerState)
    return playerState
end

function PlayerState:update()

end

function PlayerState:draw()

    if nil ~= self.game.hoveringCell.info then
        love.graphics.print(self.game.hoveringCell.info, CELL_SIZE * 6, 10)
        love.graphics.setColor({0.8,0.5,0.8,0.5})
        love.graphics.rectangle("fill", self.game.hoveringCell.x * CELL_SIZE, self.game.hoveringCell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
        love.graphics.setColor({1,1,1,1})

        local unit = self.game:getUnit(self.game.hoveringCell.x, self.game.hoveringCell.y)
        if nil ~= unit then 
            love.graphics.print("Unit type:" ..unit.type,  CELL_SIZE * 6, 25)
        end
    end

    if nil ~= self.game.selectedUnit then
        love.graphics.print(self.game.selectedUnit.type, CELL_SIZE * 6, 40)
        love.graphics.setColor({0.9,0.2,0.9,0.5})
        love.graphics.rectangle("fill", self.game.selectedUnit.x * CELL_SIZE, self.game.selectedUnit.y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
    end

    if nil ~= self.game.hoveringUnit then
        love.graphics.print(self.game.hoveringUnit.type, CELL_SIZE * 6, 55)
    end

    if self.game.selectedUnit ~= nil then 
        if self.game.selectedUnit.player ~= self.game.turn then
            love.graphics.setColor({1,0.5,0.5,0.5})
        else
            love.graphics.setColor({0,0.5,1,0.5})
        end
        for i = 1, #self.movableCells do
            local cell = self.movableCells[i]
            love.graphics.rectangle("fill", cell.x * CELL_SIZE, cell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE )
        end
    end
end

function PlayerState:mouseMoved(x, y)
    self.game.hoveringCell.info, self.game.hoveringCell.x, self.game.hoveringCell.y = self.game.tilemap:getCell(x, y)
    if self.game.hoveringCell.info == nil then
        return
    end

    self.game.hoveringUnit = self.game:getUnit(self.game.hoveringCell.x, self.game.hoveringCell.y)
end


function PlayerState:mousePressed(x, y, button)
    local info, x, y = self.game.tilemap:getCell(love.mouse.getPosition())
    if button == 1 then
        local unit = self.game:getUnit(x, y)

        if  nil == unit and 
            nil ~= self.game.selectedUnit and 
            not(self.game.selectedUnit.hasMoved) then

                if  self.game.turn == self.game.selectedUnit.player 
                    and positionInTable(self.movableCells, {x = x, y = y}) then
                        self.game.selectedUnit.x = x
                        self.game.selectedUnit.y = y
                        self.game.selectedUnit.hasMoved = true
                        self.movableCells = {}
                end
        else 
            self.game.selectedUnit = unit
            if nil ~= self.game.selectedUnit and not(self.game.selectedUnit.hasMoved) then
                self.movableCells = self.game:getMovableCells(unit)
            else
                self.movableCells = {}
            end
        end

    elseif button == 2 then  
        local unit = self.game:getUnit(x, y)
        if  self.game.selectedUnit ~= nil and 
            self.game.selectedUnit.player ~= self.game.turn 
            then
                self.game.selectedUnit = nil
                self.movableCells = {}
        elseif self.game.selectedUnit ~= nil and 
            unit ~= nil and 
            unit.player ~= self.game.turn and
            self.game.selectedUnit.hasAttacked == false and
            self.game.selectedUnit:hasUnitInRange(unit)
            then
                self.game.selectedUnit:attackEnemy(unit)
        end
    end
end

function PlayerState:newTurn()
    self.game.selectedUnit = nil
end

function PlayerState:keyPressed(key)
    if key == "return" then
        self.game:finishTurn()
    end
end

return PlayerState