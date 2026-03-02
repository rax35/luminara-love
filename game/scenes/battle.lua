---@type State
local battle = {}
local image
local x, y = 0, 0

function battle:init()
	image = love.graphics.newImage("assets/forest1.png")
end

function battle:draw()
	local major, minor, revision, codename = love.getVersion()
	love.graphics.print("Hello World!", 400, 300)
	love.graphics.print(_VERSION, 400, 100)
	love.graphics.print(major .. " " .. minor .. " " .. revision .. " " .. codename, 400, 150)
	love.graphics.draw(image, x, y, 0, 4, 4)
end

---@diagnostic disable-next-line: unused-local
function battle:touchmoved(_id, _x, _y, dx, dy, _pressure)
	x = x + dx
	y = y + dy
end

function battle:keypressed(key)
	if key == "escape" then
		love.event.quit(0)
	end
end

return battle
