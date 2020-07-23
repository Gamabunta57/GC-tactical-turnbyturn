require("src/constant")
require("lib/table_extension")
require("src/db")
local Map = require("src/map")
local Game = require("src/game")
local Unit = require("src/unit")
local Tileset = require("src/tileset")

if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    print("debug on")
    require("lldebugger").start()
    io.stdout:setvbuf('no')
end

local game = Game.new()

local window = {
    width = 0,
    height = 0
}

local map = nil
local level = 1

function love.load()
    window.x, window.y = love.graphics.getWidth(), love.graphics.getHeight()

    map = Map.load("assets/map/lvl_"..level)

    local tileset = Tileset.new(love.graphics.newImage("assets/images/tileset.png"))
    game:setMap(tileset, map:getTerrain(), map:getWidth(), map:getHeight())
    game:setUnit(map:getUnits(), map:getWidth(), map:getHeight())
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