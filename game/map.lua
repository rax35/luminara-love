local consts = require("consts")
local Camera = require("camera")

---@class lum.Map
local Map = {
    camera = Camera.new(0, 0),
    tileRenderSize = 32,
    width = 0,
    height = 0,
    canvas = nil,
    highlightTiles = {},
    redTiles = {},
}
Map.__index = Map

---comment
---@param map lum.Map
local function draw_map(map)
    local image = love.graphics.newImage("assets/atlas.png")
    local quad = {}
    quad[1] = love.graphics.newQuad(0, 0, 16, 16, image)
    quad[2] = love.graphics.newQuad(0, 16, 16, 16, image)
    quad[3] = love.graphics.newQuad(16, 0, 16, 16, image)
    quad[4] = love.graphics.newQuad(16, 16, 16, 16, image)

    local tileScale = consts.tileRenderSize / 16
    map.tileRenderSize = consts.tileRenderSize
    local canvas = love.graphics.newCanvas(
        map.width * consts.tileRenderSize,
        map.height * consts.tileRenderSize
    )
    map.canvas = canvas
    map.camera.worldW, map.camera.worldH = canvas:getDimensions()

    ---TODO(optimization?): This should be a named local function rather than closure
    local tiles = map.tiles
    for i = 0, map.height - 1 do
        for j = 0, map.width - 1 do
            canvas:renderTo(function()
                love.graphics.draw(
                    image,
                    quad[tiles[i + 1][j + 1]],
                    j * consts.tileRenderSize,
                    i * consts.tileRenderSize,
                    0,
                    tileScale,
                    tileScale
                )
            end)
        end
    end
end

---Construct a new Map
---@param width integer
---@param height integer
---@return lum.Map
function Map:new(width, height)
    ---@type number[][]
    local tiles = {}
    for i = 1, height do
        tiles[i] = {}
        for j = 1, width do
            tiles[i][j] = math.random(1, 4)
        end
    end

    local newMap = setmetatable({
        width = width,
        height = height,
        tiles = tiles,
        camera = Camera.new(0, 0),
    }, Map)

    draw_map(newMap)

    return newMap
end

function Map:draw()
    self.camera:attach()
    love.graphics.draw(self.canvas, 0.5, 0.5)

    love.graphics.setColor(0, 0.1, 0.8, 0.4)
    for idx, _ in pairs(self.highlightTiles) do
        local y = math.floor(idx / self.width) * self.tileRenderSize
        local x = math.fmod(idx, self.width) * self.tileRenderSize
        love.graphics.rectangle("fill", x, y, self.tileRenderSize, self.tileRenderSize)
    end

    love.graphics.setColor(0.8, 0, 0, 0.4)
    for idx, _ in pairs(self.redTiles) do
        local y = math.floor(idx / self.width) * self.tileRenderSize
        local x = math.fmod(idx, self.width) * self.tileRenderSize
        love.graphics.rectangle("fill", x, y, self.tileRenderSize, self.tileRenderSize)
    end

    self.camera:detach()
end

function Map:onTap(x, y)
    x, y = self.camera:screenToWorld(x, y)
    local idx = self:_posToTile(x, y)
    self.highlightTiles[idx] = true
end

function Map:onDoubleTap(x, y)
    x, y = self.camera:screenToWorld(x, y)
    local idx = self:_posToTile(x, y)
    self.redTiles[idx] = true
end

function Map:_posToTile(x, y)
    local idx = math.floor(y / self.tileRenderSize) * self.width
        + math.floor(x / self.tileRenderSize)

    return idx
end

return {
    new = function(width, height)
        return Map:new(width, height)
    end,
}
