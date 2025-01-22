require "shape"
-- red=ammo
-- green=health
-- yellow=fuel
function createStation(x,y,size,segments,r,g,b,a)
  s=createShape(x,y,r,g,b,a)
  s.type="station"
  s.segments=segments
  s.size=size
  s.draw=drawStation
  return s
end

function drawStation(self)
  love.graphics.setColor(self.color.red,self.color.green,self.color.blue,self.color.alpha)
  love.graphics.circle("fill",self.x,self.y,self.size,self.segments)
end

function createFuelStation(x,y,size,segments)
  s=createStation(x,y,size,segments,1,0,0,1)
end