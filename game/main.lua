require("math_extensions")
local Gamestate = require("libs.hump.gamestate")
local battle = require("scenes.battle")

function love.load()
    love.graphics.setDefaultFilter("nearest")
    Gamestate.registerEvents()
    Gamestate.switch(battle)
end
