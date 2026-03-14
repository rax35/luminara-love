local Map = require("map")

local mapPanFactor = require("consts").mapPanFactor
---@type State
local battle = {}

---@type number,number,number,number
local screenX, screenY, screenW, screenH = 0, 0, 0, 0

local map
local mapW = 30
local mapH = 15

---@type love.DisplayOrientation
local orientation

local taps = 0
local dTaps = 0

local function recalculateSizes()
    print("Resizing.....")

    local leftMargin = 0
    local rightMargin = 10

    if orientation == "landscapeflipped" then
        leftMargin, rightMargin = rightMargin, leftMargin
    elseif orientation == "portrait" or orientation == "portraitflipped" then
        error("Portrait Orientation should not be possible")
    end

    local x = screenX + leftMargin
    local w = screenW - (leftMargin + rightMargin)

    -- TODO(fix): This should be a function in camera that adjusts current view
    -- if this change will show out of bounds area
    map.camera.screenX = x
    map.camera.screenY = screenY
    map.camera.w = w
    map.camera.h = screenH
end

function battle:init()
    map = Map.new(mapW, mapH)

    screenX, screenY, screenW, screenH = love.window.getSafeArea()
end

function battle:enter()
    Input.onPan = function(dx, dy)
        map.camera:move(dx, dy)
    end
    Input.onDrag = function(dx, dy)
        map.camera:move(dx * mapPanFactor, dy * mapPanFactor)
    end
    Input.onTap = function(_, _)
        taps = taps + 1
    end
    Input.onDoubleTap = function(_, _)
        dTaps = dTaps + 1
    end

    screenX, screenY, screenW, screenH = love.window.getSafeArea()
    orientation = love.window.getDisplayOrientation()
    recalculateSizes()
end

function battle:leave()
    Input.onDrag = nil
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
    -- viewQuad:setViewport(x, y, w, h)
    love.graphics.draw(map.canvas, 0.5, 0.5)
    -- love.graphics.draw(map.canvas, viewQuad, x, y)
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
    map.camera:draw(draw_map)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(orientation, 300, 200)
    love.graphics.print(love.timer.getFPS(), 300, 225)
    love.graphics.print(taps .. "," .. dTaps, 300, 250)
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
