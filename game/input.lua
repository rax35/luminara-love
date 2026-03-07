-- TODO(feature): Tap, DoubleTap
-- TODO(feature): keyboard, mouse input
-- TODO(fix): Don't register drag when one finger is removed after two finger gesture
-- TEST: How does mouse and touchpad affect touch inputs

Input = {
    drag = { x = 0, y = 0 },
    pan = { x = 0, y = 0 },
    pinch = 0,
}
local lastPinch = nil

local touches = {}
local touchCount = 0

function Input.update()
    if touchCount == 0 then
        Input.drag.x = 0
        Input.drag.y = 0
        Input.pan.x = 0
        Input.pan.y = 0
        Input.pinch = 0
        lastPinch = nil
    elseif touchCount == 1 then
        --- SWIPE
        for _, touch in pairs(touches) do
            local dx = touch.dx
            local dy = touch.dy

            Input.drag.x = dx
            Input.drag.y = dy
            if Input.onDrag then
                Input.onDrag(dx, dy)
            end

            touch.dx = 0
            touch.dy = 0
        end
        Input.pan.x = 0
        Input.pan.y = 0
        Input.pinch = 0
        lastPinch = nil
    elseif touchCount == 2 then
        Input.drag.x = 0
        Input.drag.y = 0

        local ids = {}
        for id, _ in pairs(touches) do
            table.insert(ids, id)
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
    if touchCount >= 2 then
        return
    end
    touches[id] = { x = x, y = y, dx = 0, dy = 0, startX = x, startY = y }
    touchCount = touchCount + 1
end

function Input.touchmoved(id, x, y, dx, dy)
    local t = touches[id]
    if not t then
        return
    end
    t.x = x
    t.y = y
    t.dx = t.dx + dx
    t.dy = t.dy + dy
end

function Input.touchreleased(id)
    if not touches[id] then
        return
    end
    touches[id] = nil
    touchCount = touchCount - 1
end

function Input.reset()
    Input.drag.x = 0
    Input.drag.y = 0
    Input.pan.x = 0
    Input.pan.y = 0
    Input.pinch = 0
    touches = {}
    touchCount = 0
end

function Input.focus(isFocus)
    if not isFocus then
        Input.reset()
    end
end

local __NULL__ = function() end
local callbacks = { "update", "touchpressed", "touchmoved", "touchreleased", "focus" }
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
