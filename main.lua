-- run:
-- C:> cd C:\util\love2d\love-11.5-win64
-- C:> love ..\..\ZeroBraneStudioEduPack-2.01\myprograms\lee"

require "world"
require "player"
require "station"
require "particle"
require "enemy"
require "gui"

io.stdout:setvbuf("no")
--love.graphics.setDefaultFilter("nearest","nearest")

love.window.setTitle("Edge of Space")
flags={}
flags.fullscreen=false
flags.borderless=false
flags.fullscreentype="desktop"
flags.display=2

love.window.setMode(1400,1400,flags) 

screenWidth=love.graphics.getWidth()
screenHeight=love.graphics.getHeight()

fuelColor=createColor(1,1,0,1)
healthColor=createColor(0,1,0,1)
ammoColor=createColor(1,0,0,1)

keystate={up=false,down=false,left=false,right=false,thrust=false,fire=false}
print("keystate: ",keystate["up"])

activeMenu=nil
menuOne=nil

function love.load()
  local joysticks = love.joystick.getJoysticks()
  joystick = joysticks[1]
  love.graphics.setLineStyle("rough");
  particleImage=love.graphics.newImage("particle-star.png")
  
  world=createWorld(4000,4000,screenWidth,screenHeight)
  
  player=createPlayer(world.width/2,world.height/2,"ship_49.png",1,world.width,world.height,screenWidth/2,screenHeight/2)
  world:addShape(player)
--  world:addParticle(createParticle(player.x,player.y,player.angle,particleImage))
  
  world:addShape(createStation(world.width-screenWidth/2-75,screenHeight+75,75,9,
      healthColor.red,healthColor.green,healthColor.blue,healthColor.alpha))
  s=createStation(1000,1000,40,9,
    ammoColor.red,ammoColor.green,ammoColor.blue,ammoColor.alpha)
  s.z=2
  world:addShape(s)
  
  s=createStation(world.width-screenWidth/2,world.height-screenHeight/2,50,10,
    fuelColor.red,fuelColor.green,fuelColor.blue,fuelColor.alpha)
  world:addShape(s)
  
  world:createStars(1000)
  
--  world:addShape(createBorder(world.width/2,world.height/2,world.width,world.height))
  
  fontLarge=love.graphics.newImageFont("wolf-font-sheet.png",
    "!\"#$%&'()*+,-./0123456789:;<=>?@"..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ ")
  fontSmall=love.graphics.newImageFont("wolf-font-sheet-small.png",
    "!\"#$%&'()*+,-./0123456789:;<=>?@"..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ ")
  
  normalColor=createColor255(3,251,255)
  selectedColor=createColor(1,1,0)

  local x=screenWidth/2-150
  local y=screenHeight/2-200
  local w=250
  local h=300
  menuOne=createMenu(nil,{"Play","Quit"},x,y,w,h,true,normalColor,selectedColor,handleMenu,fontLarge,27)
  titlePage=createImageTitle("edgeofspacetitle.png")
  titleShowing=true
end

function fireBullet(dt) 
  if player.ammo>0 and (player.fireRateTimer>player.fireRate or player.fireRateTimer==-1) then
    player.fireRateTimer=0
    player.ammo=player.ammo-player.ammoUsageSpeed
    if player.ammo<0 then player.ammo=0 end
    
    local distance=15
    local x=player.x
    local y=player.y
    local angle=player.angle
    dx = math.sin(angle)*distance
    dy = -math.cos(angle)*distance
    world:addShape(createBullet(player.x+dx,player.y+dy,player.angle,player.vx,player.vy))
  end
end

function love.keypressed(key)
  if titleShowing then
    -- if title, then just turn off title and continue
    titleShowing=false
    return
  end
  if key == "escape" then 
    if activeMenu==nil then
      activeMenu=menuOne  -- open menu
    else
      activeMenu=nil      -- close menu
    end
  end
  
  if activeMenu~=nil then
    if key=="up" then
      activeMenu:selectPrevious()
    elseif key=="down" then
      activeMenu:selectNext()
    elseif key=="return" then
      activeMenu:handle()
    end
  else
    -- process keypressed normally
    if key == "1" then
      s=createEnemy(math.random(100,200),math.random(100,200),"enemy",0,0,1,1,world,player)
      world:addShape(s)
      print("create enemy at x,y=",s.x,s.y) 
    elseif key == "2" then
      player.health=player.health-10
    end
  end
end

function handleMenu(menu)
  local index=menu.selectedIndex
  local text=menu.options[index]
  print("handle menu called with menu",index,text)
  if menu==menuOne and index==2 then
    love.event.quit() -- user selected quit
  else
    activeMenu=nil    -- just close
  end
end

function love.update(dt)
  if activeMenu~=nil then
    activeMenu:update(dt)
  else 
    player.fireRateTimer=player.fireRateTimer+dt
    
    keystate.left=false
    keystate.right=false
    keystate.up=false
    keystate.down=false
    keystate.fire=false
    keystate.thrust=false
    
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then keystate.left=true end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then keystate.right=true end
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then keystate.thrust=true end
    if love.keyboard.isDown("space") or love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then 
      keystate.fire=true 
    end
    
    if joystick~=nil then
      local hat=joystick:getHat(1) -- c=nothing l,r,u,d for directions
      if hat=="l" then keystate.left=true end
      if hat=="r" then keystate.right=true end
      if hat=="u" then keystate.up=true end
      if hat=="d" then keystate.down=true end
      
      if joystick:isDown(1) then keystate.fire=true end
      if joystick:isDown(2) then keystate.thrust=true end
    end
    
    if keystate.fire then fireBullet(dt) end
    world:update(dt)
  end
end

function love.draw()
  if titleShowing then
    titlePage:draw()
  else
    world:draw(player.x,player.y)
    showInfo()
    frame(screenWidth,screenHeight)
    if activeMenu~=nil then
      activeMenu:draw()
    end
  end
end

function showInfo()
  love.graphics.setColor(1,0,0,1)
  love.graphics.setFont(fontSmall)
  local statsWidth=150
  local statsHeight=200
  local x=screenWidth-statsWidth
  local y=0
--  love.graphics.rectangle("line",1,0,love.graphics.getWidth()-1,love.graphics.getHeight()-1)

--  drawCrosshair(love.graphics.getWidth()/2,love.graphics.getHeight()/2)
  drawFrame(x,y,statsWidth,statsHeight)
  drawCompass(x+statsWidth/2,y+13)
  drawHealth(x,y+22,statsWidth,statsHeight)
  drawMap(x,y+statsHeight+10,statsWidth,statsHeight)
  
  love.graphics.setColor(0,1,0,1) -- green
  love.graphics.print(
    string.format("fps=%d\nwidth=%d\nheight=%d\nplayer=%d,%d\nfuel=%d\n",
      love.timer.getFPS(),love.graphics.getWidth(),love.graphics.getHeight(),
      player.x,player.y,player.fuel
      ),
    x+5,y+statsHeight-85)
end

function drawFrame(x,y,width,height)
  love.graphics.setColor(0,0,0,1)
  love.graphics.rectangle("fill",x,y,width,height)
  love.graphics.setColor(1,0,0,1)
  
  love.graphics.rectangle("line",x,y,width,height)
  -- left corner piece
  love.graphics.line(x-2,y+height-4,x-2,y+height+2, x+4,y+height+2)
  love.graphics.line(x-4,y+height-6,x-4,y+height+4, x+6,y+height+4)
  -- bottom lines
  love.graphics.line(x+width/2-10,y+height+2,x+width-10,y+height+2)
  love.graphics.line(x+width/2   ,y+height+4,x+width-5 ,y+height+4)
end

function drawCrosshair(x,y)
  love.graphics.setColor(255,0,0,255)
  love.graphics.line(x,1,x,love.graphics.getHeight()-1)
  love.graphics.line(1,y,love.graphics.getWidth()-1,y)
end

function drawCompass(x,y)
  local size=10
  local x1,y1,x2,y2=x,y,0,0
  local distance=size-3
  local dx = math.sin(player.angle)*distance
  local dy = -math.cos(player.angle)*distance
  x2=x1+dx
  y2=y1+dy
  love.graphics.line(x1,y1,x2,y2)
  love.graphics.ellipse("line",x1,y1,size,size)
end

function drawHealth(x,y,width,height) 
  local w=width-6
  local h=20
  x=x+3
  y=y+3
  drawBar("health",x,y,w,h,player.health/player.healthMax,healthColor)
  y=y+h+5
  drawBar("fuel",x,y,w,h,player.fuel/player.fuelMax,fuelColor)
  y=y+h+5
  drawBar("ammo",x,y,w,h,player.ammo/player.ammoMax,ammoColor)
end

function drawBar(label,x,y,w,h,percent,color)
  love.graphics.setColor(color.red,color.green,color.blue,1)
  love.graphics.rectangle("line",x,y,w,h)
  love.graphics.setColor(color.red,color.green,color.blue,0.6)
  love.graphics.rectangle("fill",x,y+1,(w-1)*percent,h-1)
  love.graphics.setColor(1,1,1,1)
  love.graphics.print(label,x+10,y+3)
end

function drawMap(x,y,width,height)
  drawFrame(x,y,width,height)
--  love.graphics.setColor(0,0,0,1)
--  love.graphics.rectangle("fill",x,y,width,height)
--  love.graphics.setColor(1,0,0,1)
--  love.graphics.rectangle("line",x,y,width,height)
  
  local pixel=2
  local scalex=width/world.width
  local scaley=height/world.height
  for i,s in ipairs(world.shapes) do
    if s.type~="star" then -- and s.type~="bullet" then
      if s.type=="player" then 
        love.graphics.setColor(1,1,1,1) 
      else
        love.graphics.setColor(s.color.red,s.color.green,s.color.blue,s.color.alpha) 
      end
      local sx=x+s.x*scalex
      local sy=y+s.y*scaley
      love.graphics.rectangle("fill",sx,sy,pixel,pixel)
    end
  end
end