local Map = {}
Map.__index = Map

function Map.load(file)
    local map = {
        units = nil,
        terrain = nil,
        width = 0,
        height = 0
    }
    setmetatable(map, Map)

    local mapFile = love.filesystem.load(file..".lua")()

    for i = 1, #mapFile.layers do
        local layer = mapFile.layers[i]
        if layer.name == "units" then
            map.units = layer.data
        elseif layer.name == "terrain" then
            map.terrain = layer.data
            map.width = layer.width
            map.height = layer.height
        end
    end

    return map
end

function Map:getUnits()
    return self.units
end

function Map:getTerrain()
    return self.terrain
end

function Map:getWidth()
    return self.width
end

function Map:getHeight()
    return self.height
end

return Map