require("world")
activeChars = {}

Character = Body:new({speed = 512})
function Character:init()
  Body.init(self)
  table.insert(activeChars, self)
end

Player = Character:new({spritePath='walk19.png', name='player'})