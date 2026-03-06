local consts = require("consts")

local Camera = require("camera")

---@type State
local battle = {}
local image

---@type number,number,number,number
local screenX, screenY, screenW, screenH = 0, 0, 0, 0

---@type number[][]
local map = {}
local mapW = 30
local mapH = 15
local mapPixelW = mapW * consts.tileRenderSize
local mapPixelH = mapH * consts.tileRenderSize

local tileScale

---@type love.Canvas
local canvas
---@type love.Quad
local viewQuad
---@type Camera
local cam

---@type love.DisplayOrientation
local orientation = "landscape"

local panId

local function recalculateSizes()
    screenX, screenY, screenW, screenH = love.window.getSafeArea()

    local leftMargin = 0
    local rightMargin = 10

    if orientation == "landscapeflipped" then
        leftMargin, rightMargin = rightMargin, leftMargin
    elseif orientation == "portrait" or orientation == "portraitflipped" then
        error("Portrait Orientation should not be possible")
    end

    screenX = screenX + leftMargin
    screenW = screenW - (leftMargin + rightMargin)

    local x, y = viewQuad:getViewport()
    x = math.clamp(x, 0, mapPixelW - screenW)
    y = math.clamp(y, 0, mapPixelH - screenH)
    cam.screenX = screenX
    cam.screenY = screenY
    cam.w = screenW
    cam.h = screenH
    -- viewQuad:setViewport(x, y, screenW, screenH)
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

    screenX, screenY, screenW, screenH = love.window.getSafeArea()
    canvas = love.graphics.newCanvas(mapPixelW, mapPixelH)
    viewQuad = love.graphics.newQuad(0, 0, screenW, screenH, canvas)

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
end

function battle:enter()
    Input.onPan = function(dx, dy)
        cam:move(dx, dy)
    end

    local worldW, worldH = canvas:getDimensions()
    cam = Camera:new(0, 0, worldW, worldH)
    screenX, screenY, screenW, screenH = love.window.getSafeArea()
    cam.screenX = screenX
    cam.screenY = screenY
    cam.w = screenW
    cam.h = screenH
    orientation = love.window.getDisplayOrientation()
    recalculateSizes()
end

function battle:leave()
    Input.onSwipe = nil
    Input.onPan = nil
    Input.onPinch = nil
end

function battle:update()
    local x, y, w, h = love.window.getSafeArea()
    local orient = love.window.getDisplayOrientation()
    if screenX ~= x or screenY ~= y or screenW ~= w or screenH ~= h or orientation ~= orient then
        screenX, screenY, screenW, screenH, orientation = x, y, w, h, orient
        recalculateSizes()
    end

    -- local dx, dy = Input.pan.x, Input.pan.y
    -- cam:move(dx, dy)
    -- local zoom = cam.zoom + Input.pinch * 0.004
    -- cam.zoom = math.clamp(zoom, 0.5, 2)
end

local function draw_map(x, y, w, h)
    viewQuad:setViewport(x, y, w, h)
    -- love.graphics.draw(canvas)
    love.graphics.draw(canvas, viewQuad, x, y)
end

function battle:draw()
    love.graphics.clear(1, 1, 1, 1)

    --[[
    love.graphics.push()
    love.graphics.translate(screenX, screenY)
    love.graphics.draw(canvas, viewQuad, 0, 0)
    love.graphics.pop()

    love.graphics.rectangle("line", screenX, screenY, screenW, screenH)
    --]]
    cam:draw(draw_map)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(orientation, 300, 200)
    love.graphics.print(Input.pan.x .. "," .. Input.pan.y, 300, 250)

    love.graphics.reset()
end

-- ---@diagnostic disable-next-line: unused-local
-- function battle:touchpressed(id, _x, _y, _dx, _dy, _pressure)
--     if not panId then
--         panId = id
--     end
-- end

-- function battle:touchmoved(id, _, _, dx, dy, _)
--     if id == panId then
--         cam:move(dx, dy)
--     end
-- end

-- ---@diagnostic disable-next-line: unused-local
-- function battle:touchreleased(id, _x, _y_dx, _dy, _pressure)
--     if id == panId then
--         panId = nil
--     end
-- end

function battle:keypressed(key)
    if key == "escape" then
        love.event.quit(0)
    end
end

return battle
