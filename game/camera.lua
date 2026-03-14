local Class = require("libs.middleclass.middleclass")

---@class Camera
---@field new fun(self: Camera):Camera
---@field screenX number The `x` coordinate on screen to start drawing from
---@field screenY number The `y` coordinate on screen to start drawing from
local Camera = Class("Camera")

function Camera:initialize(x, y, worldW, worldH, cameraW, cameraH, screenX, screenY)
    local screenW, screenH = love.graphics.getDimensions()
    self.x = x or 0
    self.y = y or 0
    self.w = cameraW or screenW
    self.h = cameraH or screenH
    self.screenX = screenX or 0
    self.screenY = screenY or 0
    self.worldW = worldW
    self.worldH = worldH
    self.targetX = nil
    self.targetY = nil
    self.zoom = 1
    self.clip = true
end

---Moves the camera by `dx` and `dy` units. The camera is clamped to not exit world
---@param dx number
---@param dy number
function Camera:move(dx, dy)
    local targetX = self.x - dx
    local targetY = self.y - dy

    self.x = math.clamp(targetX, 0, self.worldW - self.w)
    self.y = math.clamp(targetY, 0, self.worldH - self.h)
end

---Executes drawing functions in camera space
---@param drawFunc fun(x:number,y:number,w:number,h:number)
function Camera:draw(drawFunc)
    local sx, sy, sw, sh = love.graphics.getScissor()
    love.graphics.setScissor(self.screenX, self.screenY, self.w, self.h)
    love.graphics.push()

    ---TEST: test if directly passing the transforms in map rendering prevents the jitters
    love.graphics.scale(self.zoom, self.zoom)
    love.graphics.translate(
        math.ceil(-(self.x - self.screenX)),
        math.ceil(-(self.y - self.screenY))
    )
    drawFunc(self.x, self.y, self.w, self.h)

    love.graphics.pop()
    love.graphics.setScissor(sx, sy, sw, sh)
end

return Camera
