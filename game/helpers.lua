sign = function(n)
  return (n > 0 and 1) or (n < 0 and -1) or 0
end

round = function(n)
  return math.floor(n + 0.5)
end

iif = function(cond, y, n)
  if cond then return y else return n end
end

deepEq = function(a1, a2)
  if #a1 ~= #a2 then return false end
  for i, v in ipairs(a1) do
    if v ~= a2[i] then return false end
  end
  return true
end

magmax = function(n, m)  -- returns whichever n or m has larger magnitude, or the positive one if magnitude is equal but sign is not
  if math.abs(n) > math.abs(m) then return n
  elseif math.abs(m) > math.abs(n) then return m
  elseif n >= m then return n end
  return m
end

magmin = function(n, m) -- returns whichever n or m has lower magnitude, or the negative one if magnitude is equal but sign is not
  if math.abs(n) < math.abs(m) then return n
  elseif math.abs(m) < math.abs(n) then return m
  elseif n <= m then return n end
  return m
end

clipMask = function(args)
  local masks = {full = {}, xProj = {}, yProj = {}}
  local data = love.image.newImageData(args.spritePath)
  for y=0, data:getHeight() - 1 do
    masks.full[y] = {}
    for x=0, data:getWidth() - 1 do
      local r,g,b,a = data:getPixel(x, y)
      masks.full[y][x] = a ~= 0
      masks.yProj[x] = masks.yProj[x] or a ~= 0
      masks.xProj[y] = masks.xProj[y] or a ~= 0
    end
  end
  return love.graphics.newImage(data), masks
end

fuck = function(s)
  mask = s.masks.full
  local shit = {}
  local k = 0
  for j = 0, #mask do
    for i = 0, #mask[0] do
      if mask[j][i] then 
        shit[k] = {s.x + gOff.x + i, s.y + gOff.y + j, 1, 0, 0, 0.5}
        k = k + 1
      end
    end
  end
  love.graphics.points(shit)
end

range = function(a, b, c)
  local step = round(c or 1)
  local start = iif(b ~= nil, round(a), 0)
  local stop = b ~= nil and round(b) or round(a - (1 * sign(step)))  -- not using iif cuz need the skipped evaluation if b is nil
  return function()
    if start - step == stop then return nil end
    start = start + step
    return start - step
  end
end

reduce = function(list, init, func)
    local acc = init
    for i, v in ipairs(list) do
        -- typechecking is for pussies
        acc = func(acc, v)
    end 
    return acc
end

reduceIndexed = function(list, init, func)
    local acc = init
    for i, v in ipairs(list) do
        acc = func(acc, i, v)
    end
    return acc
end

loadSpriteSheet = function(args)
  local anim = Animation:new(args)
  local w = anim.w
  local data = love.image.newImageData(anim.spritePath)
  anim.spriteSheet = love.graphics.newImage(data)
  anim.quads = {}
  anim.frame = 1
  anim._ticks = 0
  anim.speed = 20
  anim.x = 400
  anim.y = 400
    
  anim.quads[0] = love.graphics.newQuad(0, 0, w, anim.spriteSheet:getHeight(), anim.spriteSheet:getDimensions())
  for x = w, anim.spriteSheet:getWidth() - w, w do
    table.insert(anim.quads, love.graphics.newQuad(x, 0, w, anim.spriteSheet:getHeight(), anim.spriteSheet:getDimensions()))
  end
  masks = {full = {}, xProj = {}, yProj = {}}
  for i = 0, #anim.quads do
    for y=0, anim.spriteSheet:getHeight() - 1 do
      masks.full[y] = masks.full[y] or {}
      for x=0, w - 1 do
        local r,g,b,a = data:getPixel(i * w + x, y)
        masks.full[y][x] = masks.full[y][x] or a ~= 0
        masks.yProj[x] = masks.yProj[x] or a ~= 0
        masks.xProj[y] = masks.xProj[y] or a ~= 0
      end
    end
  end
  return anim, masks
end

Animation = {
  new = function(self, obj)
    setmetatable(obj, self)
    self.__index = self
    return obj
  end,
  next = function(self)
    self.frame = self.frame + 1
    if self.frame > #self.quads then self.frame = 1 end
  end,
  stop = function(self)
    self.frame = 0
    self._ticks = 0
  end,
  tick = function(self, ticks)
    self._ticks = self._ticks + ticks
    if self._ticks > self.speed then
      self.frame = self.frame + math.floor(self._ticks / self.speed)
      if self.frame > #self.quads then self.frame = 1 end
      self._ticks = self._ticks % self.speed
    end
  end,
  getDimensions = function(self)
    return self.w, self.spriteSheet:getHeight()
  end
}