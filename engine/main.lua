require("world")
require("characters")
require("collisions")
function love.load() -- game init
    player = Player:spawn()
    player:moveTo(math.floor(love.graphics.getWidth()/2), math.floor(love.graphics.getHeight()/2))
    
    enemy = Enemy:spawn({spritePath = 'Walk19.png'})
    enemy:moveTo(300, 300)
    
    love.graphics.setBackgroundColor(6/255,21/255,24/255)
    love.graphics.setNewFont(12)
    
    mapBounds = {  -- in fractions of screen size so resizing is less of a pain
            y = {min = nil, max = nil}, x = {min = -0.5, max = 1.5},
            scrollY = {min = nil, max = nil}, scrollX = {min = 0.2, max = 0.8}
        }
end 

function love.update(dt) -- dt in seconds
    local moved = {x = 0, y = 0}
    if love.keyboard.isDown('w') or love.keyboard.isDown('s') then
        if love.keyboard.isDown('w') then
            player.dir.y = -1
        else
            player.dir.y = 1
        end
        moved.y = player.speed * dt * player.dir.y
        
        if mapBounds.y.max ~= nil and player.dir.y == 1 and player.y + player.h + moved.y > mapBounds.y.max * love.graphics.getHeight() then moved.y = mapBounds.y.max * love.graphics.getHeight() - player.y - player.h 
        elseif mapBounds.y.min ~= nil and player.y + moved.y < mapBounds.y.min * love.graphics.getHeight() then moved.y = mapBounds.y.min * love.graphics.getHeight() - player.y end
        
        if moved.y ~= 0 then 
            for i, v in ipairs(hazards) do 
                local collision = willCollide(player, v, {y = moved.y})
                if collision.y ~= false then
                    moved.y = magmin(moved.y, findCollision(player, v, {y = moved.y}, collision).y)
                end
            end
            for i, v in ipairs(activeChars) do
                if v ~= player then 
                    local collision = willCollide(player, v, {y = moved.y})
                    if collision.y ~= false then
                        print('colliding')
                        moved.y = magmin(moved.y, findCollision(player, v, {y = moved.y}, collision).y)
                    end
                end
            end
            player.y = player.y + moved.y
        end
        
        if mapBounds.scrollY.max ~= nil and player.y + gOff.y >= love.graphics.getHeight() * mapBounds.scrollY.max then
            gOff.y = love.graphics.getHeight() * mapBounds.scrollY.max - player.y
        elseif mapBounds.scrollY.min ~= nil  and player.y + gOff.y <= love.graphics.getHeight() * mapBounds.scrollY.min then
            gOff.y = love.graphics.getHeight() * mapBounds.scrollY.min - player.y
        end
        
    elseif not player.dir.y == 0 then
        player.dir.y = 0
    end
    if love.keyboard.isDown('a') or love.keyboard.isDown('d') then
        if love.keyboard.isDown('a') then
            player.dir.x = -1
        else 
            player.dir.x = 1
        end
        moved.x = player.speed * dt * player.dir.x
        
        if mapBounds.x.max ~= nil and player.dir.x == 1 and player.x + player.w + moved.x > mapBounds.x.max * love.graphics.getWidth() then moved.x = mapBounds.x.max * love.graphics.getWidth() - player.x - player.w
        elseif mapBounds.x.min ~= nil and player.x + moved.x < mapBounds.x.min * love.graphics.getWidth() then moved.x = mapBounds.x.min * love.graphics.getWidth() - player.x end
        
        if moved.x ~= 0 then
            for i,v in ipairs(hazards) do
                local collision = willCollide(player, v, {x = moved.x})
                if collision.x ~= false then
                    moved.x = magmin(moved.x, findCollision(player, v, {x = moved.x}, collision).x)
                end
            end
            player.x = player.x + moved.x
        end
        for i, v in ipairs(activeChars) do
            if v ~= player then 
                local collision = willCollide(player, v, {x = moved.x})
                if collision.x ~= false then
                    moved.x = magmin(moved.x, findCollision(player, v, {x = moved.x}, collision).x)
                end
            end
        end
        
        if mapBounds.scrollX.max ~= nil  and player.x + gOff.x >= love.graphics.getWidth() * mapBounds.scrollX.max then
            gOff.x = love.graphics.getWidth() * mapBounds.scrollX.max - player.x
        elseif mapBounds.scrollX.min ~= nil  and player.x + gOff.x <= love.graphics.getWidth() * mapBounds.scrollX.min then
            gOff.x = love.graphics.getWidth() * mapBounds.scrollX.min - player.x
        end

    elseif not player.dir.x == 0 then
        player.dir.x = 0
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