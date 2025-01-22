require "shape"

function createPlayer(x,y,filename,scale,worldWidth,worldHeight,bufferx,buffery)
  s=createShape(x,y)
  s.type="player"
  s.worldWidth=worldWidth
  s.worldHeight=worldHeight
  s.bufferx=bufferx   -- how much from edges player must stay
  s.buffery=buffery
  s.update=updatePlayer
  s.draw=drawPlayer
  s.sprite=love.graphics.newImage(filename)
  s.anglespeed=math.pi
  s.maxspeed=400
  s.thrust=100
  s.friction = 0.25
  s.scale=scale
  s.z=1
  s.health=100
  s.healthMax=100
  s.healthRefillSpeed=4
  s.fuel=100
  s.fuelMax=100
  s.fuelUsageSpeed=2    -- how fast used up
  s.fuelRefillSpeed=10  -- how fast refueled
  s.ammo=100
  s.ammoMax=100
  s.ammoUsageSpeed=1  
  s.ammoRefillSpeed=20
  s.fireRate=0.2
  s.fireRateTimer=s.fireRate
  return s
end

function updatePlayer(self,dt)
  local ax,ay=0,0
  if keystate.left then
    self.angle = self.angle - self.anglespeed*dt
  end
  if keystate.right then
    self.angle = self.angle + self.anglespeed*dt
  end
  if keystate.thrust then
    ax = math.sin(self.angle)*self.thrust
    ay = -math.cos(self.angle)*self.thrust
    if self.fuel>0 then
      self.fuel=self.fuel-self.fuelUsageSpeed*dt
      if self.fuel<0 then self.fuel=0 end
    else
    end
  end
--  if keystate.down then
--    ax = -math.sin(self.angle)*self.thrust
--    ay = math.cos(self.angle)*self.thrust
--    if self.fuel>0 then
--      self.fuel=self.fuel-self.fuelspeed*dt
--      if self.fuel<0 then self.fuel=0 end
--    end
--  end
  
  if self.fuel==0 then
    -- out of fuel, move really slow
    ax=ax*0.2 -- 20% of thrust allowed on empty tank
    ay=ay*0.2 -- 20% of thrust allowed on empty tank
  end
  
  ax = ax - self.vx * self.friction
  ay = ay - self.vy * self.friction
   
  self.vx = self.vx + ax*dt
  self.vy = self.vy + ay*dt
  self.x = self.x + self.vx*dt
  self.y = self.y + self.vy*dt
   
  if self.x<0 then 
    self.x=self.worldWidth+self.x
  end
  if self.x>self.worldWidth then 
    self.x=self.x-self.worldWidth
  end
  if self.y<0 then 
    self.y=self.worldHeight+self.y
  end
  if self.y>self.worldHeight then 
    self.y=self.y-self.worldHeight
  end
   
  return true
end


function drawPlayer(self)
  love.graphics.setColor(self.color.red,self.color.green,self.color.blue,self.color.alpha)
  love.graphics.draw(self.sprite,
    self.x,self.y,self.angle,self.scale,self.scale,
    self.sprite:getWidth()/2,self.sprite:getHeight()/2)
end