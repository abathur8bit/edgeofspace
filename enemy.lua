require "world"
require "player"
require "station"
require "particle"

function createEnemy(x,y,type,r,g,b,a,world,player)
  s=createShape(x,y,r,g,b,a)
  s.name=type
  s.draw=drawEnemy
  s.update=updateEnemy
  s.size=10
  s.world=world
  s.player=player
  return s
end

function drawEnemy(self)
  love.graphics.setColor(self.color.red,self.color.green,self.color.blue,self.color.alpha)
  love.graphics.rectangle("fill",self.x,self.y,self.size,self.size)
end

function updateEnemy(self,dt)
  local dx=0
  local dy=0
  if self.x<player.x then dx=1 end
  if self.x>player.x then dx=-1 end
  if self.y<player.y then dy=1 end
  if self.y>player.y then dy=-1 end

  self.x=self.x+dx
  self.y=self.y+dy
end