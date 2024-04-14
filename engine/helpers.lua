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

clipMask = function(imgPath)
  local masks = {full = {}, xProj = {}, yProj = {}}
  local data = love.image.newImageData(imgPath)
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
