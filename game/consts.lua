local consts = {
    tileRenderSize = 48,
    tapMaxDuration = 0.25,
    doubleTapTime = 0.3,
    doubleTapDistance = 20,
    tapMoveThreshold = 3,
}

return setmetatable({}, {
    __index = consts,
    __newindex = function()
        error("Attempted to modify constants")
    end,
    __metatable = false,
})
