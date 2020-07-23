require("src/unit")
require("src/constant")
local Tilemap = require("src/tilemap")
local Unit = require("src/unit")
local Ai = require("src/ai")
local PlayerState = require("src/playerState")

local Game = {}
Game.__index = Game

function Game.new()
    local game = {
        tilemap = nil,
        hoveringCell = {
            info = nil,
            x = -1,
            y = -1
        },        
        units = {},
        selectedUnit = nil,
        hoveringUnit = nil,
        movableCells = {},
        turn = P1,
        playerUnits = {
            P1 = {},
            P2 = {}
        },
        ai = nil,
        playerState = nil,
        state = nil
    }
    game.ai = Ai.new(game)
    game.playerState = PlayerState.new(game)
    game.state = game.playerState
    setmetatable(game, Game)
    return game
end

function Game:setMap(tileset, map, width, height)
    self.tilemap = Tilemap.new(tileset, map, width, height)
end

function Game:finishTurn()
    if self.turn == P1 then
        self.turn = P2
        self.state = self.ai
    else
        self.turn = P1
        self.state = self.playerState
    end

    for i=1, #self.units do
        self.units[i]:resetTurn()
   end

    self.state:newTurn()
end

function Game:setUnit(units, width, height)
    local counter = 0
    for y = 1, height do
        for x = 1, width do
            counter = counter + 1
            local unitInfo = units[counter] - 1
            local key = "_"..unitInfo
            if DB.unitTileId[key] ~= nil then 
                local unitData = DB.unitTileId[key]
                local playerUnits = Unit.create(unitData.player, unitData.type, x, y)
                table.insert(self.units, playerUnits);
                table.insert(self.playerUnits[unitData.player], playerUnits);
            end
        end
    end
end

function Game:update(dt)
    self.state:update(dt)

    for i = #self.units, 1, -1 do 
        local unit = self.units[i]
        if(unit.hp < 0) then
            self:removeUnit(unit)
        end
    end
end

function Game:draw()
    love.graphics.setColor({1,1,1,1})
    self.tilemap:draw()

    for i=1, #self.units do
        self.units[i]:draw()
    end

    self.state:draw()
end

function Game:mouseMoved(x, y)
    self.state:mouseMoved(x, y)
end

function Game:mousePressed(x, y, button)
    self.state:mousePressed(x, y, button)
end

function Game:removeUnit(unitToRemove)
    if self.hoveringUnit == unitToRemove then
        self.hoveringUnit = nil
    end
    for i = 1, #self.units do
        local unit = self.units[i];
        if unitToRemove == unit then
            table.remove(self.units, i)
            break
        end
    end
    
    for i = 1, #self.playerUnits[unitToRemove.player] do
        local unit = self.playerUnits[unitToRemove.player][i];
        if unitToRemove == unit then
            table.remove(self.playerUnits[unitToRemove.player], i)
            break;
        end
    end

    if #self.playerUnits[unitToRemove.player] == 0 then
        print(self.turn.. " wins the match")
    end
end

function Game:getUnit(cell_x, cell_y) 
    for i = 1, #self.units do
        local unit = self.units[i];
        if unit.x == cell_x and unit.y == cell_y then
            return unit
        end
    end
    return nil;
end

function Game:getMovableCells(unit)
    local mv = unit.move
    local stack = {{mv = 0, x = unit.x, y = unit.y}}
    local cellAvailable = {}

    while #stack > 0 do
        local elem = stack[1]
        table.remove(stack, 1)
        local cost = elem.mv 
        local isBlockingTile = table.contains(DB.blockingTile, self.tilemap:getCellAtCoord(elem.x, elem.y))
        local unitOnCell = self:getUnit(elem.x , elem.y)
        local hasUnit = unitOnCell ~= nil and unitOnCell ~= unit
        if cost <= mv and not(isBlockingTile) and not(hasUnit) then
            if  (elem.x ~= unit.x or
                elem.y ~= unit.y) and 
                not(positionInTable(cellAvailable, {x = elem.x, y = elem.y})) 
                then
                    table.insert(cellAvailable, {x = elem.x, y = elem.y})
                end
                
            local newPos = {x = elem.x, y = elem.y - 1}
            if  elem.y - 1 >= 0 and 
                not(positionInTable(stack, newPos)) then

                table.insert(stack, {mv = cost + 1, x = newPos.x, y = newPos.y})
            end

            newPos = {x = elem.x, y = elem.y + 1}
            if  elem.y + 1 < self.tilemap.height and
                not(positionInTable(stack, newPos)) then

                table.insert(stack, {mv = cost + 1, x = newPos.x, y = newPos.y})
            end
            
            newPos = {x = elem.x + 1, y = elem.y}
            if  elem.x + 1 < self.tilemap.width and
                not(positionInTable(stack, newPos)) then

                table.insert(stack, {mv = cost + 1, x = newPos.x, y = newPos.y})
            end

            newPos = {x = elem.x - 1, y = elem.y}
            if  elem.x - 1 >= 0 and 
                not(positionInTable(stack, newPos)) then

                table.insert(stack, {mv = cost + 1, x = newPos.x, y = newPos.y})
            end
        end
    end

   return cellAvailable
end

function Game:keyPressed(key)
    self.state:keyPressed(key)
end

function Game:isAiTurn()
    return self.player == P2
end

return Game