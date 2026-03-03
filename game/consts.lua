local consts = {
    tileRenderSize = 48,
}

return setmetatable({}, {
    __index = consts,
    __newindex = function()
        error("Attempted to modify constants")
    end,
    __metatable = false,
})
