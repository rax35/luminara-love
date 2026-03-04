local consts = require("consts")

---@type State
local battle = {}
local image

---@type number,number,number,number
local screenX, screenY, screenW, screenH = 0, 0, 0, 0

---@type number[][]
local map = {}
local mapW = 20
local mapH = 10
local viewW = 0
local viewH = 0

local tileScale

---@type love.Canvas
local canvas
---@type love.Quad
local viewQuad

local panId

local function recalculateSizes()
    screenX, screenY, screenW, screenH = love.window.getSafeArea()

    local orientation = love.window.getDisplayOrientation()

    if orientation == "landscape" then
        screenW = screenW - 10
    elseif orientation == "landscapeflipped" then
        screenX = screenX + 10
        screenW = screenW - 10
    elseif orientation == "portrait" or orientation == "portraitflipped" then
        error("Portrait Orientation should not be possible")
    end

    viewW = math.min(mapW, math.ceil(screenW / consts.tileRenderSize))
    viewH = math.min(mapH, math.ceil(screenH / consts.tileRenderSize))

    local x, y = viewQuad:getViewport()
    x = math.clamp(x, 0, (mapW * consts.tileRenderSize) - screenW)
    y = math.clamp(y, 0, (mapH * consts.tileRenderSize) - screenH)
    viewQuad:setViewport(x, y, screenW, screenH)
end

function battle:init()
    image = love.graphics.newImage("assets/atlas.png")
    local quad = {}
    quad[1] = love.graphics.newQuad(0, 0, 16, 16, image)
    quad[2] = love.graphics.newQuad(0, 16, 16, 16, image)
    quad[3] = love.graphics.newQuad(16, 0, 16, 16, image)
    quad[4] = love.graphics.newQuad(16, 16, 16, 16, image)

    tileScale = consts.tileRenderSize / 16

    for i = 1, mapH do
        map[i] = {}
        for j = 1, mapW do
            map[i][j] = math.random(1, 4)
        end
    end

    canvas = love.graphics.newCanvas(mapW * consts.tileRenderSize, mapH * consts.tileRenderSize)
    viewQuad = love.graphics.newQuad(
        0,
        0,
        viewW * consts.tileRenderSize,
        viewH * consts.tileRenderSize,
        canvas
    )

    ---TODO(Optimization): This should be a named local function rather than closure
    canvas:renderTo(function()
        for i = 0, mapH - 1 do
            for j = 0, mapW - 1 do
                love.graphics.draw(
                    image,
                    quad[map[i + 1][j + 1]],
                    j * consts.tileRenderSize,
                    i * consts.tileRenderSize,
                    0,
                    tileScale,
                    tileScale
                )
            end
        end
    end)

    recalculateSizes()
end

function battle:enter()
    recalculateSizes()
end

function battle:draw()
    love.graphics.clear(1, 1, 1, 1)

    love.graphics.push()
    love.graphics.translate(screenX, screenY)
    love.graphics.draw(canvas, viewQuad, 0, 0)
    love.graphics.pop()

    love.graphics.rectangle("line", screenX, screenY, screenW, screenH)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(love.window.getDisplayOrientation(), 300, 200)

    love.graphics.reset()
end

---@diagnostic disable-next-line: unused-local
function battle:touchpressed(id, _x, _y, _dx, _dy, _pressure)
    if not panId then
        panId = id
    end
end

---@diagnostic disable-next-line: unused-local
function battle:touchmoved(id, _x, _y, dx, dy, _pressure)
    if id == panId then
        local x, y, w, h = viewQuad:getViewport()
        x = math.clamp(x - dx, 0, mapPixelW - screenW)
        y = math.clamp(y - dy, 0, mapPixelH - screenH)
        viewQuad:setViewport(x, y, w, h)
    end
end

---@diagnostic disable-next-line: unused-local
function battle:touchreleased(id, _x, _y_dx, _dy, _pressure)
    if id == panId then
        panId = nil
    end
end

function battle:keypressed(key)
    if key == "escape" then
        love.event.quit(0)
    end
end

function battle:resize()
    recalculateSizes()
end

function battle:displayrotated()
    recalculateSizes()
end

return battle
