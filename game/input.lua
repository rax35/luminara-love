-- TODO(feature): Tap, DoubleTap
-- TODO(required): keyboard, mouse input
-- TEST: How does mouse affect touch inputs

Input = {
    swipe = { x = 0, y = 0 },
    pan = { x = 0, y = 0 },
    pinch = 0,
}
local lastPinch = nil

local touches = {}
touches.n = 0

function Input.update()
    if touches.n == 0 then
        Input.swipe.x = 0
        Input.swipe.y = 0
        Input.pan.x = 0
        Input.pan.y = 0
        Input.pinch = 0
        lastPinch = nil
    end

    if touches.n == 1 then
        --- SWIPE
        for id, touch in pairs(touches) do
            if id ~= "n" then
                local dx = touch.dx
                local dy = touch.dy

                Input.swipe.x = dx
                Input.swipe.y = dy
                if Input.onSwipe then
                    Input.onSwipe(dx, dy)
                end

                touch.dx = 0
                touch.dy = 0
            end
        end
        Input.pan.x = 0
        Input.pan.y = 0
        Input.pinch = 0
        lastPinch = nil
    end

    if touches.n == 2 then
        Input.swipe.x = 0
        Input.swipe.y = 0

        local ids = {}
        for id in pairs(touches) do
            if id ~= "n" then
                table.insert(ids, id)
            end
        end
        local t1 = touches[ids[1]]
        local t2 = touches[ids[2]]

        --- PINCH
        -- TODO(feature): Also report the center of the pinch gesture
        local dist = ((t1.x - t2.x) ^ 2 + (t1.y - t2.y) ^ 2) ^ 0.5
        if lastPinch then
            local pinch = dist - lastPinch
            Input.pinch = pinch
            if Input.onPinch then
                Input.onPinch(pinch)
            end
        else
            Input.pinch = 0
        end
        lastPinch = dist

        --- PAN
        local dx = (t1.dx + t2.dx) / 2
        local dy = (t1.dy + t2.dy) / 2

        Input.pan.x = dx
        Input.pan.y = dy
        if Input.onPan then
            Input.onPan(dx, dy)
        end

        t1.dx = 0
        t1.dy = 0
        t2.dx = 0
        t2.dy = 0
    end
end

function Input.touchpressed(id, x, y)
    if touches.n >= 2 then
        return
    end
    touches[id] = { x = x, y = y, dx = 0, dy = 0, startX = x, startY = y }
    touches.n = touches.n + 1
end

function Input.touchmoved(id, x, y, dx, dy)
    local t = touches[id]
    if not t then
        return
    end
    t.x = x
    t.y = y
    t.dx = dx
    t.dy = dy
end

function Input.touchreleased(id)
    local t = touches[id]
    if not t then
        return
    end
    t = nil
    touches.n = touches.n - 1
end

local __NULL__ = function() end
local callbacks = { "update", "touchpressed", "touchmoved", "touchreleased" }
function Input.registerCallbacks()
    local registry = {}
    for _, callback in ipairs(callbacks) do
        registry[callback] = love[callback] or __NULL__
        love[callback] = function(...)
            registry[callback](...)
            return Input[callback](...)
        end
    end
end
