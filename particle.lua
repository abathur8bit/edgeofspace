function createParticle(x,y,angle,particleImage)
  p=createShape(x,y)
  p.type="particle"
  p.emitter=love.graphics.newParticleSystem(particleImage,100)
  p.emitter:setParticleLifetime(1,5)
  p.emitter:setEmissionRate(50)
  p.emitter:setSizeVariation(1)
  p.emitter:setLinearAcceleration(-100,-100,100,100)
  p.emitter:setColors(1,1,1,1,1,1,1,0)
--  p.emitter:setEmitterLifetime(0.5)
  return p
end

function createStar(x,y)
  p=createShape(x,y,1,1,1,math.random(100)/100)
  p.type="star"
  p.fadeSpeed=math.random(20,100)/100
  p.fadeDir=1
  p.update=updateStar
  p.draw=drawStar
  return p
end

function updateStar(self,dt)
  self.color.alpha=self.color.alpha+self.fadeSpeed*dt*self.fadeDir
  if self.color.alpha>1 then 
    self.color.alpha=1
    self.fadeDir=self.fadeDir*-1
  end
  if self.color.alpha<0 then
    self.color.alpha=0
    self.fadeDir=self.fadeDir*-1
  end
end

function drawStar(self)
  love.graphics.setColor(self.color.red,self.color.green,self.color.blue,self.color.alpha)
  love.graphics.rectangle("fill",self.x,self.y,2,2)
end