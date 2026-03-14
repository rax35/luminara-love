require("math_extensions")
require("input")

local Gamestate = require("libs.hump.gamestate")
local battle = require("scenes.battle")

Scheduler = {}
---@type thread[]
Scheduler.tasks = {}
function Scheduler:spawn(t)
    table.insert(self.tasks, t)
end

function love.update(_)
    for i = 1, #Scheduler.tasks do
        coroutine.resume(Scheduler.tasks[i])
    end
end

function love.load()
    local co = coroutine.create(function()
        while true do
            print("coroutine...")
            coroutine.yield()
        end
    end)
    Scheduler:spawn(co)
    love.graphics.setDefaultFilter("nearest")
    Input.registerCallbacks()
    Gamestate.registerEvents()
    Gamestate.switch(battle)
end
