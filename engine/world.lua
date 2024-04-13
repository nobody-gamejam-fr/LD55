require("helpers")
require("overlays")

gOff = {x = 0, y = 0} -- global offset

Body = { -- call Body:new() for a new class and body:spawn() for an instance (also applies to any subclass)
  new = function(self, obj)
    obj = obj or {}
    setmetatable(obj, self)
    self.__index = self
    if obj.spritePath then obj.sprite, obj.masks = clipMask(obj.spritePath) end
    return obj
  end,
  init = function(self)
    self.x = self.x or 0
    self.y = self.y or 0
    self.dir = self.dir or {x = 0, y = 0}
    self.spriteDir = self.spriteDir or {x = 1, y = 1}
    if not self.sprite then self.sprite, self.masks = clipMask(self.spritePath) end -- should usually already exist, so that sprites are shared between instances of classes
    self.w, self.h = self.sprite:getDimensions()
    if self.alignToBottom then self.y = love.graphics.getHeight() - self.h end
  end,
  spawn = function(self, obj)
    obj = self:new(obj)
    obj:init()
    return obj
  end,
  
  moveTo = function(self, x, y)
    self.x = x
    self.y = y
  end,
  bbox = function(self)
    return {x = self.x, y = self.y, w = self.w, h = self.h}
  end,
  isSolidAt = function(self, x, y)
    return self:isSolidAtLocal(x - self.x, y - self.y)
  end,
  isSolidAtLocal = function(self, x, y)
    if self.spriteDir.x ~= -1 then return self.masks.full[round(y)][round(x)]
    else return self.masks.full[round(y)][round(self.w - x)] end
  end,
  yProjSolidAt = function(self, x)  
    if self.spriteDir.x ~= -1 then return self.masks.yProj[round(x)]
    else return self.masks.yProj[round(self.w - x)] end
  end,
  xProjSolidAt = function(self, y)
    return self.masks.xProj[round(y)]
  end,
  draw = function(self) -- can only be called in love.draw
    if self.spriteDir.x == -1 then love.graphics.draw(self.sprite, self.x + gOff.x + self.sprite:getWidth()/2, self.y + gOff.y + self.sprite:getHeight()/2, 0, -1, 1, self.sprite:getWidth()/2, self.sprite:getHeight()/2)
    else love.graphics.draw(self.sprite, self.x + gOff.x, self.y + gOff.y, 0) end-- img, x, y, rotation (rad), scaleX, scaleY, originX, originY...
  end
}

hazards = {}
Hazard = Body:new()
function Hazard:init()
  Body.init(self)
  table.insert(hazards, self)
end

backgroundTiles = {}
BackgroundTile = Body:new()
function BackgroundTile:init()
    Body.init(self)
    table.insert(backgroundTiles, self)
end

local tiles = {
    roof = { Hazard:spawn({spritePath = 'roof.png'}) },
    floor = { --[[Hazard:spawn({spritePath = 'floor.png', alignToBottom = true})]] },
    floorBG = { BackgroundTile:spawn({spritePath = "floor.png", alignToBottom = true}) },
}
local add_tile = function(tab, tile, prop)
  if tile[prop] < tab[1][prop] then table.insert(tab, 1, tile)
  else table.insert(tab, tile) end
end

drawWorld = function()
    local xoff = nil
    if tiles.roof[1].x + gOff.x > 0 then xoff = tiles.roof[1].x - tiles.roof[1].w
    elseif tiles.roof[#tiles.roof].x + gOff.x < love.graphics.getWidth() then xoff = tiles.roof[#tiles.roof].x + tiles.roof[#tiles.roof].w end

    if xoff ~= nil then -- assumes floor and roof are same width
        add_tile(tiles.roof, Hazard:spawn({spritePath = 'roof.png', x = xoff}), 'x')
        --add_tile(tiles.floor, Hazard:spawn({spritePath = 'floor.png', x = xoff, alignToBottom = true}), 'y')
        add_tile(tiles.floorBG, BackgroundTile:spawn({spritePath = "floor.png", x = xoff, alignToBottom = true}), "y")
    end

  for k,v in pairs(tiles) do
    for _, tile in ipairs(v) do
      if not ((tile.x + tile.w + gOff.x) < 0 or (tile.x + gOff.x) > love.graphics.getWidth()) then tile:draw() end
    end
  end
end
