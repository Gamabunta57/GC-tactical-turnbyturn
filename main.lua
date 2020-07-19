require("src/constant")
require("lib/table_extension")
require("src/db")
local Game = require("src/game")
local Unit = require("src/unit")
local Tileset = require("src/tileset")

if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    print("debug on")
    require("lldebugger").start()
    io.stdout:setvbuf('no')
end

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

local game = Game.new()

local window = {
    width = 0,
    height = 0
}

function love.load()
    window.x, window.y = love.graphics.getWidth(), love.graphics.getHeight()

    local tileset = Tileset.new(love.graphics.newImage("assets/images/tileset.png"))
    game:setMap(tileset, map)
    game:setUnit(unitPosition)
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.mousemoved( x, y, dx, dy, istouch )
    game:mouseMoved(x, y)
end

function love.mousepressed(x, y, button, istouch, presses)
    game:mousePressed(x, y, button)
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
 
function love.keypressed(key)
    game:keyPressed(key)
end