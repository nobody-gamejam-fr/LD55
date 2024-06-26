require("helpers")

function hasIntersection(a, b)
  return b.x <= a.x + a.w and b.x + b.w >= a.x and b.y <= a.y + a.h and b.y + b.h > a.y
end

function getIntersection(a, b)
    local lo = iif(a.x <= b.x, a, b)
    local hi = iif(lo==a, b, a)
    local intersection = {x = round(hi.x), w = math.min(hi.w, math.floor(lo.w + lo.x - hi.x))}
    lo = iif(a.y <= b.y, a, b)
    hi = iif(lo==a, b, a)
    intersection.y = round(hi.y)
    intersection.h = math.min(hi.h, math.floor(lo.h + lo.y - hi.y)) 
    return intersection
end

function isColliding(a, b)
-- brute force check for collision, only called when path tracing the mask projection onto x or y detects a possible collision 
  if not hasIntersection(a, b) then return false end
  local intrs = getIntersection(a:bbox(), b:bbox())
  if a.dir ~= nil and a.dir.x == 1 then  -- range generator would need to be redefined each loop, so using ugly code repetition to save cpu cycles. outer for duplicated to save this single if loop, cuz i'm extra like that
    for j in iif(a.dir ~= nil and a.dir.y == 1, range(intrs.y + intrs.h - 1, intrs.y, -1), range(intrs.y, intrs.h + intrs.y - 1)) do
      for i = intrs.x + intrs.w - 1, intrs.x, -1 do
        if a:isSolidAt(i,j) and b:isSolidAt(i,j) then return true end
      end
    end
  else
    for j in iif(a.dir ~= nil and a.dir.y == 1, range(intrs.y + intrs.h - 1, intrs.y, -1), range(intrs.y, intrs.h + intrs.y - 1)) do
      for i = intrs.x, intrs.x + intrs.w - 1 do
        if a:isSolidAt(i,j) and b:isSolidAt(i,j) then return true end
      end
    end
  end
  return false
end

function fuzzyCheckY(a, b, yi, yf, dir)
  local amin, bmin, len
  amin = round(math.max(0, b.x - a.x))
  bmin = round(math.max(0, a.x - b.x))
  len = round(math.min(a.w - 1, a.x + a.w - b.x, b.w - bmin - 1))
  for j = round(yi), round(yf), dir do 
    for i = 0, len do
      if a:yProjSolidAt(amin + i) and b:isSolidAtLocal(bmin + i, j) then
        return j + round(b.y)
      end
    end
  end
  return false
end

function  fuzzyCheckX(a, b, xi, xf, dir)
  local amin, bmin, len
  amin = round(math.max(0, b.y - a.y))
  bmin = round(math.max(0, a.y - b.y))
  len = round(math.min(a.h - 1, a.y + a.h - b.y, b.h - bmin - 1))
  for i = round(xi), round(xf), dir do  
    for j = 0, len do
      if a:xProjSolidAt(amin + j) and b:isSolidAtLocal(i, bmin + j) then
        return i + round(b.x)
      end
    end
  end
  return false
end

function willCollide(a, b, travel) -- a must be the moving object
  -- returns the coordinates (roughly) if the objects collide as object a travels the pixel distance/direction specified by travel. use findCollision for slower but precise coordinates
  local x, y, dy, dx, hit, amin, bmin, len
  if travel.y ~= nil and travel.x == nil and not (a.x + a.w < b.x or b.x + b.w < a.x) then
    if sign(travel.y) == 1 then
      if a.y < b.y + b.h and b.y <= a.y + a.h + travel.y then
        y = fuzzyCheckY(a, b, math.min(b.h - 1, math.max(0, a.y - b.y)), math.min(b.h - 1, a.y - b.y + a.h - 1 + travel.y), 1)
      else y = false end
    else -- moving up, or not at all
      if (a.y > b.y and a.y + travel.y <= b.y + b.h) or (a.y + travel.y <= b.y and a.y + a.h > b.y) then -- if you're thinking what i was and want to only scan the movement vector and not the whole intersection... don't
        y = fuzzyCheckY(a, b, math.min(b.h - 1, math.max(0, a.y - b.y + a.h - 1)), math.max(a.y - b.y + travel.y, 0), -1)
      else y = false end
    end
  elseif travel.y == nil and travel.x ~= nil and not (a.y + a.h < b.y or b.y + b.h < a.y) then
    if sign(travel.x) == 1 then
      if a.x < b.x + b.w and b.x <= a.x + a.w + travel.x then
        x = fuzzyCheckX(a, b, math.min(b.w - 1, math.max(0, a.x - b.x)), math.min(b.w - 1, a.x - b.x + a.w - 1 + travel.x), 1)
      else x = false end
    else
      if (a.x > b.x and a.x + travel.x <= b.x + b.w) or (a.x + travel.x <= b.x and a.x + a.w > b.x) then
        x = fuzzyCheckX(a, b, math.min(b.w - 1, math.max(0, a.x - b.x + a.w - 1)), math.max(a.x - b.x + travel.x, 0), -1)
      else x = false end
    end
  elseif (travel.y == nil and travel.x == nil) or (travel.y ~= nil and travel.x ~= nil) then error('invalid travel value passed to willCollide - must have exactly one of x or y')
  else return {y = false, x = false} end
  return {y = y, x = x}
end

function findCollision(a, b, travel, coords) -- a must be the moving object
  -- does a full check to see exactly when a hits b. assumes a collision has already been established by willCollide and coords is the resulting (x,y) pair.
  if travel.y ~= nil and travel.x == nil then
    local original_y = a.y
    local iter = range(round(iif(sign(travel.y) ~= -1, math.min(travel.y, math.max(0, coords.y - a.y - a.h)), math.min(coords.y, a.y) - a.y)), round(travel.y), iif(sign(travel.y) ~= -1, 1, -1))
    for dy in iter do
      a.y = original_y + dy
      if isColliding(a, b) then
        a.y = original_y
        return {y=dy - iif(sign(travel.y)~=-1, 1, -1)} -- want the last non-colliding position. if collision is immediate (step==0) this can be 1px away from coords in the directon opposite travel
      end
    end
    return {y=travel.y}  -- no collision found
  elseif travel.y == nil and travel.x ~= nil then
    local original_x = a.x
    local iter = range(round(iif(sign(travel.x) ~= -1, math.min(travel.x, math.max(0, coords.x - a.x - a.w)), math.min(coords.x, a.x) - a.x)), round(travel.x), iif(sign(travel.x) ~= -1, 1, -1))
    for dx in iter do
      a.x = original_x + dx
      if isColliding(a, b) then
        a.x = original_x
        return {x=dx - iif(sign(travel.x)~=-1, 1, -1)} 
      end
    end
    return {x=travel.x}
  else error('invalid travel value passed to findCollision - must have exactly one of x or y') end
end