require("src/constant")

local Tilemap = {}
Tilemap.__index = Tilemap

function Tilemap.new(tileset, grid, width, height)
    local tilemap = {
        grid = grid,
        tileset = tileset,
        width = width,
        height = height
    }
    setmetatable(tilemap, Tilemap)
    return tilemap
end

function Tilemap:draw()
    local counter = 1
    for y = 1, self.height do
        for x = 1, self.width do
            self.tileset:draw(self.grid[counter] - 1, (x - 1) * CELL_SIZE, (y - 1) * CELL_SIZE)
            counter = counter + 1
        end 
    end 
end

function Tilemap:getCell(mouseX, mouseY)
    local cellX = math.floor(mouseX / CELL_SIZE) + 1
    local cellY = math.floor(mouseY / CELL_SIZE) + 1

    if  cellY <= self.height and 
        cellY > 0  and
        cellX <= self.width and 
        cellX > 0 then
            return self.grid[cellY * self.width + cellX], cellX - 1, cellY - 1;
    end
    return nil;
end

function Tilemap:getCellAtCoord(cellX, cellY)
    return self.grid[cellY * self.width + cellX], cellX - 1, cellY - 1;
end

return Tilemap