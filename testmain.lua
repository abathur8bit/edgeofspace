red=0
function love.load()
    io.stdout:setvbuf("no")
    local joysticks = love.joystick.getJoysticks()
    joystick = joysticks[1]

    position = {x = 400, y = 300}
    speed = 300
end

function love.update(dt)
    if not joystick then return end

    if joystick:isGamepadDown("dpleft") then
        position.x = position.x - speed * dt
    elseif joystick:isGamepadDown("dpright") then
        position.x = position.x + speed * dt
    end

    if joystick:isGamepadDown("dpup") then
        position.y = position.y - speed * dt
    elseif joystick:isGamepadDown("dpdown") then
        position.y = position.y + speed * dt
    end
    if joystick:isDown(1) then red=red+1*dt ; print("click") end
    
    
    if red>1 then red=0 end
end

function love.draw()
  love.graphics.setColor(red,0,1,1)
    love.graphics.circle("fill", position.x, position.y, 50)
end