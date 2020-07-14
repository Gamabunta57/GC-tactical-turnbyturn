require("src/constant")

local Tileset = {}
Tileset.__index = Tileset

function Tileset.new(image)
    local tileset = {
        image = image,
        cellSize = CELL_SIZE,
        quads = {}
    }

    local cellCountY = math.floor(image:getHeight() / CELL_SIZE)
    local cellCountX = math.floor(image:getWidth() / CELL_SIZE)
    for y = 0, cellCountY - 1 do
        for x = 0, cellCountX - 1 do
            table.insert(tileset.quads, love.graphics.newQuad(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE, image:getWidth(), image:getHeight()))
        end
    end

    setmetatable(tileset, Tileset)
    return tileset
end

function Tileset:draw(index, x, y)
    love.graphics.draw(self.image, self.quads[index + 1], x, y, 0, 1, 1, 1, 1)
end

return Tileset