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
