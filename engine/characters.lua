require("world")
activeChars = {}

Character = Body:new({speed = 512})
function Character:init()
  Body.init(self)
  table.insert(activeChars, self)
end

Player = Character:new({spritePath='sappy.png', name='player'})

Enemy = Character:new({flags = {'hostile'}})
function Enemy:init()
  Character.init(self)
end