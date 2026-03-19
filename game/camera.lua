---@class lum.Camera
local Camera = {
    x = 0,
    y = 0,
    w = 0,
    h = 0,
    screenX = 0,
    screenY = 0,
    worldW = 0,
    worldH = 0,
    targetX = nil,
    targetY = nil,
    zoom = 1,
    clip = true,
    _sx = 0,
    _sy = 0,
    _sw = 0,
    _sh = 0,
}

---Create a new camera
---@param worldW number
---@param worldH number
---@param x? number
---@param y? number
---@param cameraW? number
---@param cameraH? number
---@param screenX? number
---@param screenY? number
---@return lum.Camera
function Camera:new(worldW, worldH, x, y, cameraW, cameraH, screenX, screenY)
    local camera = {}
    camera.x = x or 0
    camera.y = y or 0
    camera.w = cameraW or 0
    camera.h = cameraH or 0
    camera.screenX = screenX or 0
    camera.screenY = screenY or 0
    camera.worldW = worldW
    camera.worldH = worldH
    camera.targetX = nil
    camera.targetY = nil
    camera.zoom = 1
    camera.clip = true

    self.__index = self
    setmetatable(camera, self)
    return camera
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

function Camera:attach()
    self._sx, self._sy, self._sw, self._sh = love.graphics.getScissor()
    love.graphics.setScissor(self.screenX, self.screenY, self.w, self.h)
    love.graphics.push()

    love.graphics.scale(self.zoom, self.zoom)
    love.graphics.translate(
        math.ceil(-(self.x - self.screenX)),
        math.ceil(-(self.y - self.screenY))
    )
end

function Camera:detach()
    love.graphics.pop()
    love.graphics.setScissor(self._sx, self._sy, self._sw, self._sh)
end

-- TODO: Check if the screen point is inside camera's render area
-- TODO: Take the zoom into account
---Converts screen space point to world space
---@param x number
---@param y number
---@return number
---@return number
function Camera:screenToWorld(x, y)
    return x + self.x - self.screenX, y + self.y - self.screenY
end

return {
    new = function(worldW, worldH)
        return Camera:new(worldW, worldH)
    end,
}
