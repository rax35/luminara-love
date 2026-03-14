local consts = require("consts")
local Camera = require("camera")

local Map = {}
Map.__index = Map

local function draw_map(map)
    local image = love.graphics.newImage("assets/atlas.png")
    local quad = {}
    quad[1] = love.graphics.newQuad(0, 0, 16, 16, image)
    quad[2] = love.graphics.newQuad(0, 16, 16, 16, image)
    quad[3] = love.graphics.newQuad(16, 0, 16, 16, image)
    quad[4] = love.graphics.newQuad(16, 16, 16, 16, image)

    local tileScale = consts.tileRenderSize / 16
    map.canvas = love.graphics.newCanvas(
        map.width * consts.tileRenderSize,
        map.height * consts.tileRenderSize
    )
    local canvas = map.canvas
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

local function new(width, height)
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
        camera = Camera:new(0, 0, 0, 0),
    }, Map)

    draw_map(newMap)

    return newMap
end

return { new = new }
