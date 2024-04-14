require("world")
require("characters")
require("collisions")
require("overlays")
function love.load() -- game init
    gameState = {playing = true}
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
    if gameState.playing then
        if love.keyboard.isDown('w') or love.keyboard.isDown('s') then
            player:move(nil, iif(love.keyboard.isDown('w'), -1, 1), dt)
        end
        if love.keyboard.isDown('a') or love.keyboard.isDown('d') then
            player:move(iif(love.keyboard.isDown('a'), -1, 1), nil, dt)
        end
        for i, v in ipairs(activeChars) do
            --if player ~= v then v:decideMove(dt) end
        end
    end
end

function love.draw()
    if gameState.playing then
        drawWorld()
        for i, v in ipairs(activeChars) do
            v:draw()
        end
        for i, v in ipairs(activeUIElements) do
            v:draw()
        end
    else
        -- if paused?
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

function love.mousepressed(x, y, button) dispatchMouseEvent({x=x, y=y, type="mousepressed", button=button}) end
function love.mousereleased(x, y, button) dispatchMouseEvent({x=x, y=y, type="mousereleased", button=button}) end
function love.mousemoved(x, y, dx, dy) dispatchMouseEvent({x=x, y=y, type="mousemoved", dx=dx, dy=dy}) end

lastItem = nil

function dispatchMouseEvent(event)
    for i, v in ipairs(activeUIElements) do
        if v.hittest(event.x, event.y) then
            v:dispatch(event)
            if event.type == "mousemoved" and lastItem ~= v then
                if lastItem ~= nil then
                    lastItem:dispatch({x=event.x, y=event.y, type="mouseexit"})
                end
                v:dispatch({x=event.x, y=event.y, type="mouseenter"})
                lastItem = v
            end
        elseif event.type == "mousemoved" and v == lastItem and lastItem ~= nil then
            lastItem:dispatch({x=event.x, y=event.y, type="mouseexit"})
            lastItem = nil
        end

    end
end
