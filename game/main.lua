require("math_extensions")
require("input")

local Gamestate = require("libs.hump.gamestate")
local battle = require("scenes.battle")

function love.load()
    love.graphics.setDefaultFilter("nearest")
    Input.registerCallbacks()
    Gamestate.registerEvents()
    Gamestate.switch(battle)
end
