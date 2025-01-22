require "player"
require "station"
require "particle"

function createWorld(width,height,screenWidth,screenHeight)
  w={}
  
  -- world vars
  w.shapes={}
  w.particles={}
  w.width=width
  w.height=height
  w.screenWidth=screenWidth
  w.screenHeight=screenHeight
  
  -- functions
  w.update=updateWorld
  w.draw=drawWorld
  w.addShape=addWorldShape
  w.addParticle=addWorldParticle
  w.createStars=createStars
  
  return w
end

function addWorldParticle(self,particle)
  if particle==nil then error("Particle is nil.") end
  table.insert(self.particles,particle)
end

function addWorldShape(self,s)
  if s==nil then error("shape is nil. Did you forget to return in the create?") end
  table.insert(self.shapes,s)
  table.sort(self.shapes,
    function(a,b) 
      return a.z<b.z 
    end)
end

function updateWorld(self,dt)
  local player=nil
  for i,s in ipairs(self.shapes) do 
    if s:update(dt) == false then 
      table.remove(self.shapes,i) 
    else
      if s.type=="player" then 
        player=s
      end
    end
  end
  
  if player~=nil then
    for i,s in ipairs(self.shapes) do 
      if s.type=="station" then
        if s.color:compare(fuelColor) then
          if inside(player.x,player.y,s.x,s.y,s.size) and player.fuel<player.fuelMax then
            player.fuel=player.fuel+player.fuelRefillSpeed*dt
          end
        elseif s.color:compare(ammoColor) then
          if inside(player.x,player.y,s.x,s.y,s.size) and player.ammo<player.ammoMax then
            player.ammo=player.ammo+player.ammoRefillSpeed*dt
          end
        elseif s.color:compare(healthColor) then
          if inside(player.x,player.y,s.x,s.y,s.size) and player.health<player.healthMax then
            player.health=player.health+player.healthRefillSpeed*dt
          end
        end
      end
    end
  end

  for i,p in ipairs(self.particles) do 
    p.emitter:update(dt) 
  end
end

function inside(px,py,sx,sy,size) 
  return  px>=sx-size and 
          px<sx+size and 
          py>=sy-size and 
          py<=sy+size
end 

function drawWorld(self,playerx,playery)
  local tx=self.screenWidth/2-playerx   -- translate world to keep player in middle of screen
  local ty=self.screenHeight/2-playery
  for i,s in ipairs(self.shapes) do 
    s:translate(tx,ty)    -- offset from player
    s:draw() 
    s:translate(-tx,-ty)  -- restore
  end
  
--  -- particles
--  for i,p in ipairs(self.particles) do 
    
--    love.graphics.draw(p.emitter,self.screenWidth/2,self.screenHeight/2) 
--  end
end

function createStars(self,amount) 
  for i=1,amount do
    local x=math.random(50,self.width-50)
    local y=math.random(50,self.height-50)
    local star=createStar(x,y)
    table.insert(self.shapes,star)
  end
end
