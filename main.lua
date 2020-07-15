if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    print("debug on")
    require("lldebugger").start()
    io.stdout:setvbuf('no')
end

require("src/constant")
require("lib/table_extension")
require("src/db")
local Tilemap = require("src/tilemap")
local Tileset = require("src/tileset")
local Unit = require("src/unit")


local map = {
    {0, 1, 2, 3, 4},
    {6, 7, 8, 9, 10},
    {12, 13, 14, 15, 16},
    {18, 19, 20, 21, 22},
    {0, 0, 0, 0, 0},
}

local unitPosition = {
    {P1, DB.unit.melee, 0,0},
    {P1, DB.unit.melee, 1,2},
    {P1, DB.unit.melee, 3,2},

    {P2, DB.unit.melee, 0,1},
    {P2, DB.unit.melee, 1,3},
    {P2, DB.unit.melee, 3,3}
}

local Game = {}

local window = {
    width = 0,
    height = 0
}

function love.load()
    window.x, window.y = love.graphics.getWidth(), love.graphics.getHeight()

    local tileset = Tileset.new(love.graphics.newImage("assets/images/tileset.png"))
    Game = {
        tilemap = Tilemap.new(tileset, map),
        hoveringCell = {
            info = nil,
            x = -1,
            y = -1
        },        
        units = {},
        selectedUnit = nil,
        hoveringUnit = nil,
        movableCells = {},
        turn = P1
    }

    for i = 1, #unitPosition do
        local unit = unitPosition[i];
        table.insert(Game.units, Unit.create(unpack(unit)));
    end
    
end

function love.update(dt)
    
end

function love.draw()
    love.graphics.setColor({1,1,1,1})
    Game.tilemap:draw()

    for i=1, #Game.units do
        Game.units[i]:draw()
    end

    if nil ~= Game.hoveringCell.info then
        love.graphics.print(Game.hoveringCell.info, CELL_SIZE * 6, 10)
        love.graphics.setColor({0.8,0.5,0.8,0.5})
        love.graphics.rectangle("fill", Game.hoveringCell.x * CELL_SIZE, Game.hoveringCell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
        love.graphics.setColor({1,1,1,1})

        local unit = getUnit(Game.hoveringCell.x, Game.hoveringCell.y)
        if nil ~= unit then 
            love.graphics.print("Unit type:" ..unit.type,  CELL_SIZE * 6, 25)
        end
    end

    if nil ~= Game.selectedUnit then
        love.graphics.print(Game.selectedUnit.type, CELL_SIZE * 6, 40)
        love.graphics.setColor({0.9,0.2,0.9,0.5})
        love.graphics.rectangle("fill", Game.selectedUnit.x * CELL_SIZE, Game.selectedUnit.y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
    end

    if nil ~= Game.hoveringUnit then
        love.graphics.print(Game.hoveringUnit.type, CELL_SIZE * 6, 55)
    end

    if Game.selectedUnit ~= nil then 
        if Game.selectedUnit.player ~= Game.turn then
            love.graphics.setColor({1,0.5,0.5,0.5})
        else
            love.graphics.setColor({0,0.5,1,0.5})
        end
        for i = 1, #Game.movableCells do
            local cell = Game.movableCells[i]
            love.graphics.rectangle("fill", cell.x * CELL_SIZE, cell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE )
        end
    end
end


function love.mousemoved( x, y, dx, dy, istouch )
    Game.hoveringCell.info, Game.hoveringCell.x, Game.hoveringCell.y = Game.tilemap:getCell(x, y)
    if Game.hoveringCell.info == nil then
        return
    end

    Game.hoveringUnit = getUnit(Game.hoveringCell.x, Game.hoveringCell.y)
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        local info, x, y = Game.tilemap:getCell(love.mouse.getPosition())
        local unit = getUnit(x, y)

        if  nil == unit and 
            nil ~= Game.selectedUnit and 
            not(Game.selectedUnit.hasMoved) then

                if  Game.turn == Game.selectedUnit.player 
                    and positionInTable(Game.movableCells, {x = x, y = y}) then
                        Game.selectedUnit.x = x
                        Game.selectedUnit.y = y
                        Game.selectedUnit.hasMoved = true
                        Game.movableCells = {}
                end
        else 
            Game.selectedUnit = unit
            if nil ~= Game.selectedUnit and not(Game.selectedUnit.hasMoved) then
                setMovableCells(unit)
            else
                Game.movableCells = {}
            end
        end

    elseif button == 2 then
        Game.selectedUnit = nil
        Game.movableCells = {}
    end
end

function getUnit(cell_x, cell_y) 
    for i = 1, #Game.units do
        local unit = Game.units[i];
        if unit.x == cell_x and unit.y == cell_y then
            return unit
        end
    end
    return nil;
end

function setMovableCells(unit)
    local mv = unit.move
    local cellX = unit.x
    local cellY = unit.y

    local stack = {{mv = 0, x = unit.x, y = unit.y}}
    local index = 1
    local cellAvailable = {}

    while #stack > 0 do
        local elem = stack[1]
        table.remove(stack, 1)
        local cost = elem.mv 
        local isBlockingTile = table.contains(DB.blockingTile, Game.tilemap.grid[elem.y + 1][elem.x + 1])
        if(cost <= mv and not(isBlockingTile)) then
            table.insert(cellAvailable, {x = elem.x, y = elem.y})
            local newPos = {x = elem.x, y = elem.y - 1}
            if  elem.y - 1 >= 0 and 
                not(positionInTable(cellAvailable, newPos)) then

                table.insert(stack, {mv = cost + 1, x = newPos.x, y = newPos.y})
            end

            newPos = {x = elem.x, y = elem.y + 1}
            if  elem.y + 1 < Game.tilemap.height and
                not(positionInTable(cellAvailable, newPos)) then

                table.insert(stack, {mv = cost + 1, x = newPos.x, y = newPos.y})
            end
            
            newPos = {x = elem.x + 1, y = elem.y}
            if  elem.x + 1 < Game.tilemap.width and
                not(positionInTable(cellAvailable, newPos)) then

                table.insert(stack, {mv = cost + 1, x = newPos.x, y = newPos.y})
            end

            newPos = {x = elem.x - 1, y = elem.y}
            if  elem.x - 1 >= 0 and 
                not(positionInTable(cellAvailable, newPos)) then

                table.insert(stack, {mv = cost + 1, x = newPos.x, y = newPos.y})
            end
        end
    end

    Game.movableCells = cellAvailable
end

function positionInTable(table, search)
    for i = 1, #table do
        if  table[i].x == search.x and
            table[i].y == search.y then
            return true
        end
    end
    return false
end