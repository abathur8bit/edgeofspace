function createShape(x,y,red,green,blue,alpha)
  s={}
  s.type=nil
  s.x=x
  s.y=y
  s.z=0
  s.color=createColor(red,green,blue,alpha)
  s.vx=0
  s.vy=0
  s.angle=0
  s.scale=1
  s.draw=function(self) end
  s.update=function(self,dt) return true end
  s.setColor=function(self,r,g,b,a) self.color:setColor(r,g,b,a) end
  s.translate=translateShape
  return s
end


-- Create color table with red,green,blue,alpha, setColor() and compare()
-- setColor(r,g,b,a)
-- setColor255(r,g,b,a) - Set the color using 0-255, which is mapped to 0-1. 
function createColor(red,green,blue,alpha)
  if alpha==nil then alpha=1 end
  c={}
  c.red=red or 1
  c.green=green or 1
  c.blue=blue or 1
  c.alpha=alpha or 1
  c.setColor=function(self,r,g,b,a) self.red=r; self.green=g; self.blue=b; self.alpha=a end
  c.setColor255=function(self,r,g,b,a) self.red=r/255; self.green=g/255; self.blue=b/255; self.alpha=a/255; end
  c.compare=function(self,c) return self.red==c.red and self.green==c.green and self.blue==c.blue and self.alpha==c.alpha end
  c.components=function(self) return self.red,self.green,self.blue end
  return c
end

-- create color table using 0-255 as r,g,b,a values, which get converted to 0-1.
function createColor255(red,green,blue,alpha)
  if alpha==nil then alpha=255 end
  return createColor(red/255,green/255,blue/255,alpha/255)
end

function translateShape(self,x,y)
  self.x=self.x+x
  self.y=self.y+y
end

function createBullet(x,y,angle,vx,vy)
  s=createShape(x,y)
  s.type="bullet"
  s.vx=vx
  s.vy=vy
  s.angle=angle
  s.sprite=love.graphics.newImage("bullet.png")
  s.anglespeed=0
  s.maxspeed=500
  s.thrust=500
  s.friction=0
  s.scale=2
  s.update=updateBullet
  s.draw=drawBullet
  s.time=4
  return s
end

function updateBullet(self,dt)
  self.time=self.time-dt
  if self.time<=0 then 
    self.time=0 
    return false 
  end
  
  local ax,ay=0,0
  ax = math.sin(self.angle)*self.thrust
  ay = -math.cos(self.angle)*self.thrust

  self.vx = self.vx + ax*dt
  self.vy = self.vy + ay*dt
  self.x = self.x + self.vx*dt
  self.y = self.y + self.vy*dt
  return true
end

function drawBullet(self)
  love.graphics.setColor(self.color.red,self.color.green,self.color.blue,self.color.alpha)
  love.graphics.draw(self.sprite,self.x,self.y,self.angle,self.scale,self.scale,self.sprite:getWidth()/2,self.sprite:getHeight()/2)
end

function createBorder(x,y,width,height)
  s=createShape(x,y,1,1,0,1)
  s.z=100
  s.w=width
  s.h=height
  s.draw=function(self)
      local x=self.x-self.w/2
      local y=self.y-self.h/2
      print("border draw x,y=",x,y)
      love.graphics.setColor(self.color.red,self.color.green,self.color.blue,self.color.alpha)
      love.graphics.rectangle("line",x,y,self.w,self.h)
    end
  return s
end