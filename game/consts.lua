local consts = {
    tileRenderSize = 48,
    tapMaxDuration = 0.25,
    doubleTapTime = 0.2,
    doubleTapDistance = 10,
    tapMoveThreshold = 3,
    mapPanFactor = 1.3,
}

return setmetatable({}, {
    __index = consts,
    __newindex = function()
        error("Attempted to modify constants")
    end,
    __metatable = false,
})
