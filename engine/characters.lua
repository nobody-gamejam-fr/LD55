require("world")
activeChars = {}

Character = Body:new({speed = 512})
function Character:init()
  Body.init(self)
  table.insert(activeChars, self)
end
function Character:move(x, y, dt)
  local moved = {x = 0, y = 0}
  if y then
    self.dir.y = y
    --if self.dir.y ~= self.spriteDir.y then self.spriteDir.y = self.dir.y end -- no flipping y sprites rn
    moved.y = self.speed * self.dir.y * dt
    
    if mapBounds.y.max ~= nil and self.dir.y == 1 and self.y + self.h + moved.y > mapBounds.y.max * love.graphics.getHeight() then moved.y = mapBounds.y.max * love.graphics.getHeight() - self.y - self.h 
    elseif mapBounds.y.min ~= nil and self.y + moved.y < mapBounds.y.min * love.graphics.getHeight() then moved.y = mapBounds.y.min * love.graphics.getHeight() - self.y end
    
    if moved.y ~= 0 then 
      for i, v in ipairs(hazards) do 
        local collision = willCollide(self, v, {y = moved.y})
        if collision.y ~= false then
          moved.y = magmin(moved.y, findCollision(self, v, {y = moved.y}, collision).y)
        end
      end
      for i, v in ipairs(activeChars) do
        if v ~= self then 
          local collision = willCollide(self, v, {y = moved.y})
          if collision.y ~= false then
            moved.y = magmin(moved.y, findCollision(self, v, {y = moved.y}, collision).y)
          end
        end
      end
      self.y = self.y + moved.y
    end
  
  elseif not self.dir.y == 0 then
    self.dir.y = 0
  end
  
  if x then
    self.dir.x = x
    if self.dir.x ~= self.spriteDir.x then
      self.spriteDir.x = self.dir.x
      local unsafe = false
      for i, v in ipairs(hazards) do
        unsafe = isColliding(self, v) -- checks bbox collision first, so safe to spam like this
        if unsafe then break end
      end
      if not unsafe then
        for i, v in ipairs(activeChars) do
          if self ~= v then unsafe = isColliding(self, v) end
          if unsafe then break end
        end
      end
      if unsafe then self.spriteDir.x = self.dir.x * -1 end -- reset to original if flipping yet would collide
    end
    moved.x = self.speed * self.dir.x * dt
    
    if mapBounds.x.max ~= nil and self.dir.x == 1 and self.x + self.w + moved.x > mapBounds.x.max * love.graphics.getWidth() then moved.x = mapBounds.x.max * love.graphics.getWidth() - self.x - self.w
    elseif mapBounds.x.min ~= nil and self.x + moved.x < mapBounds.x.min * love.graphics.getWidth() then moved.x = mapBounds.x.min * love.graphics.getWidth() - self.x end
  
    if moved.x ~= 0 then
      for i, v in ipairs(hazards) do
        local collision = willCollide(self, v, {x = moved.x})
        if collision.x ~= false then
          moved.x = magmin(moved.x, findCollision(self, v, {x = moved.x}, collision).x)
        end
      end
      for i, v in ipairs(activeChars) do
        if v ~= self then 
          local collision = willCollide(self, v, {x = moved.x})
          if collision.x ~= false then
            moved.x = magmin(moved.x, findCollision(self, v, {x = moved.x}, collision).x)
          end
        end
      end
      self.x = self.x + moved.x
    end
    
  elseif not self.dir.x == 0 then
    self.dir.x = 0
  end
  return moved
end

Player = Character:new({spritePath='sappy.png', flags={player = true}})
function Player:move(x, y, dt)
  local moved = Character.move(self, x, y, dt)
  if moved.y then
    if mapBounds.scrollY.max ~= nil and self.y + gOff.y >= love.graphics.getHeight() * mapBounds.scrollY.max then
      gOff.y = love.graphics.getHeight() * mapBounds.scrollY.max - self.y
    elseif mapBounds.scrollY.min ~= nil  and self.y + gOff.y <= love.graphics.getHeight() * mapBounds.scrollY.min then
      gOff.y = love.graphics.getHeight() * mapBounds.scrollY.min - self.y
    end
  end
  if moved.x then
    if mapBounds.scrollX.max ~= nil  and self.x + gOff.x >= love.graphics.getWidth() * mapBounds.scrollX.max then
      gOff.x = love.graphics.getWidth() * mapBounds.scrollX.max - self.x
    elseif mapBounds.scrollX.min ~= nil  and self.x + gOff.x <= love.graphics.getWidth() * mapBounds.scrollX.min then
      gOff.x = love.graphics.getWidth() * mapBounds.scrollX.min - self.x
    end
  end
  return moved
end

Enemy = Character:new({flags = {hostile = true}})
function Enemy:init()
  Character.init(self)
  self.speed = self.speed / 4 -- temp
end
function Enemy:decideMove(dt) -- shittiest AI of all time, probably only good for testing
  self:move(iif(self.x < player.x, 1, -1), iif(self.y < player.y, 1, -1), dt)
end