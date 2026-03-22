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

function Map:onDoubleTap(x, y)
    x, y = self.camera:screenToWorld(x, y)
    local idx = self:_posToTile(x, y)
    self.redTiles[idx] = true
end
