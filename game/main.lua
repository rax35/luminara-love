local image
local x = 0
local y = 0

function love.load()
  image = love.graphics.newImage("assets/forest1.png")
  image:setFilter("nearest","nearest")
end

function love.update()
end

function love.draw()
  local test = "Bye"
  local major,minor,revision,codename = love.getVersion()
  love.graphics.print("Hello World!", 400,300)
  love.graphics.print(test,400,200)
  love.graphics.print(_VERSION,400,100)
  love.graphics.print(major .. " " .. minor .. " " .. revision .. " " .. codename,400,150)
  love.graphics.draw(image,x,y,0,4,4)
end

function love.touchmoved(_id,_x,_y,dx,dy,_pressure)
  x = x + dx
  y = y + dy
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit(0)
  end
end
