if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    print("debug on")
    require("lldebugger").start()
    io.stdout:setvbuf('no')
end

require("src/constant")
local Tilemap = require("src/tilemap")
local Tileset = require("src/tileset")

local map = {
    {0, 1, 2, 3, 4},
    {6, 7, 8, 9, 10},
    {12, 13, 14, 15, 16},
    {18, 19, 20, 21, 22},
    {0, 0, 0, 0, 0},
}

local Game = {}

function love.load()
    local tileset = Tileset.new(love.graphics.newImage("assets/images/tileset.png"))
    Game = {
        tilemap = Tilemap.new(tileset, map),
        hoveringCell = {
            info = nil,
            x = -1,
            y = -1
        },
        selectedCell = {
            info = nil,
            x = -1,
            y = -1
        }
    }
    
end

function love.update(dt)
    Game.hoveringCell.info, Game.hoveringCell.x, Game.hoveringCell.y = Game.tilemap:getCell(love.mouse.getPosition())
end

function love.draw()
    love.graphics.setColor({1,1,1,1})
    Game.tilemap:draw()

    if nil ~= Game.hoveringCell.info then
        love.graphics.print(Game.hoveringCell.info, CELL_SIZE * 6, 10)
        love.graphics.setColor({0.8,0.5,0.8,0.5})
        love.graphics.rectangle("fill", Game.hoveringCell.x * CELL_SIZE, Game.hoveringCell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
        love.graphics.setColor({1,1,1,1})
    end

    if nil ~= Game.selectedCell.info then
        love.graphics.print(Game.selectedCell.info, CELL_SIZE * 6, 20)
        love.graphics.setColor({0.9,0.2,0.9,0.5})
        love.graphics.rectangle("fill", Game.selectedCell.x * CELL_SIZE, Game.selectedCell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if button ~= 1 then
        return;
    end

    Game.selectedCell.info, Game.selectedCell.x, Game.selectedCell.y = Game.tilemap:getCell(love.mouse.getPosition())
end