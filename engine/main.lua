require("world")
require("characters")
require("collisions")
function love.load() -- game init
    player = Player:spawn()
    player:moveTo(math.floor(love.graphics.getWidth()/2), math.floor(love.graphics.getHeight()/2))
    
    enemy = Enemy:spawn({spritePath = 'Walk19.png'}) -- REMOVE
    enemy:moveTo(300, 300)
    
    love.graphics.setBackgroundColor(6/255,21/255,24/255)
    love.graphics.setNewFont(12)
    
    mapBounds = {  -- in fractions of screen size so resizing is less of a pain
            y = {min = nil, max = nil}, x = {min = -0.5, max = 1.5},
            scrollY = {min = nil, max = nil}, scrollX = {min = 0.2, max = 0.8}
        }
end 

function love.update(dt) -- dt in seconds
    if love.keyboard.isDown('w') or love.keyboard.isDown('s') then
        player:move(nil, iif(love.keyboard.isDown('w'), -1, 1), dt)
    end
    if love.keyboard.isDown('a') or love.keyboard.isDown('d') then
        player:move(iif(love.keyboard.isDown('a'), -1, 1), nil, dt)
    end
end

function love.draw()
    drawWorld()
    for i, v in ipairs(activeChars) do
        v:draw()
    end
end

function love.keypressed(key)
    if key == 'r' then
        activeChars = {}
        player = Player:spawn()
        player:moveTo(math.floor(love.graphics.getWidth()/2), math.floor(love.graphics.getHeight()/2))
        gOff = {x = 0, y = 0}
    end
end