-- TODO(feature): Tap and hold (tap, hold and drag)
-- TODO(feature): keyboard, mouse input
-- TODO(fix): Don't register drag when one finger is removed after two finger gesture
-- TEST: How does mouse and touchpad affect touch inputs
local consts = require("consts")
Input = {
    drag = { x = 0, y = 0 },
    pan = { x = 0, y = 0 },
    pinch = 0,
}

local touches = {}
local touchCount = 0
local lastPinchDist = nil
local pendingTap = nil

local tapMaxDuration = consts.tapMaxDuration
local doubleTapTime = consts.doubleTapTime
local doubleTapDistance = consts.doubleTapDistance
local tapMoveThreshold = consts.tapMoveThreshold

local function resetMovement()
    Input.drag.x = 0
    Input.drag.y = 0
    Input.pan.x = 0
    Input.pan.y = 0
    Input.pinch = 0
end

local function getTwoTouches()
    local t1, t2
    for _, t in pairs(touches) do
        if not t1 then
            t1 = t
        else
            t2 = t
            break
        end
    end
    return t1, t2
end

function Input.update()
    resetMovement()

    if pendingTap then
        local now = love.timer.getTime()

        if (now - pendingTap.time) > doubleTapTime then
            if Input.onTap then
                Input.onTap(pendingTap.x, pendingTap.y)
            end
            pendingTap = nil
        end
    end

    if touchCount == 1 then
        local t
        for _, v in pairs(touches) do
            t = v
            break
        end

        if t.moved then
            Input.drag.x = t.dx
            Input.drag.y = t.dy
            if Input.onDrag then
                Input.onDrag(t.dx, t.dy)
            end
            t.dx = 0
            t.dy = 0
        end
    elseif touchCount == 2 then
        local t1, t2 = getTwoTouches()

        local panX = (t1.dx + t2.dx) * 0.5
        local panY = (t1.dy + t2.dy) * 0.5

        Input.pan.x = panX
        Input.pan.y = panY
        if Input.onPan then
            Input.onPan(panX, panY)
        end

        --- PINCH
        -- TODO(feature): Also report the center of the pinch gesture
        local dx = t1.x - t2.x
        local dy = t1.y - t2.y
        local dist = math.sqrt(dx * dx + dy * dy)

        if lastPinchDist then
            -- TODO(test): pinch = (dist-lastPinchDist)/lastPinchDist
            local pinch = dist - lastPinchDist
            Input.pinch = pinch
            if Input.onPinch then
                Input.onPinch(pinch)
            end
        end
        lastPinchDist = dist

        t1.dx, t1.dy = 0, 0
        t2.dx, t2.dy = 0, 0
    end
end

function Input.touchpressed(id, x, y)
    touches[id] = {
        x = x,
        y = y,
        dx = 0,
        dy = 0,
        startX = x,
        startY = y,
        moved = false,
        startTime = love.timer.getTime(),
    }

    touchCount = touchCount + 1

    lastPinchDist = nil

    for _, t in pairs(touches) do
        t.dx, t.dy = 0, 0
    end
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

    if math.abs(x - t.startX) > tapMoveThreshold or math.abs(y - t.startY) > tapMoveThreshold then
        t.moved = true
    end
end

function Input.touchreleased(id)
    local t = touches[id]
    if not t then
        return
    end

    local now = love.timer.getTime()
    local held = now - t.startTime

    if touchCount ~= 1 then
        goto reset
    end

    if t.moved or held > tapMaxDuration then
        goto reset
    end

    if pendingTap then
        local dx = t.startX - pendingTap.x
        local dy = t.startY - pendingTap.y
        local dist = math.sqrt(dx * dx + dy * dy)

        if (now - pendingTap.time) < doubleTapTime and dist < doubleTapDistance then
            if Input.onDoubleTap then
                Input.onDoubleTap(pendingTap.x, pendingTap.y)
            end
            pendingTap = nil
        end
    else
        pendingTap = { x = t.startX, y = t.startY, time = now }
    end

    ::reset::
    touches[id] = nil
    touchCount = touchCount - 1
    lastPinchDist = nil
    for _, v in pairs(touches) do
        v.dx, v.dy = 0, 0
    end
end

function Input.reset()
    Input.drag.x = 0
    Input.drag.y = 0
    Input.pan.x = 0
    Input.pan.y = 0
    Input.pinch = 0
    touches = {}
    touchCount = 0
    lastPinchDist = nil
    pendingTap = nil
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
