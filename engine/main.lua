require("world")
require("characters")
require("collisions")
require("overlays")
require("menus.main_menu")

gameState = "menu"

function love.load() -- game init
    mainMenuSetListeners(
        function()
            gameState = "game"
            for _, v in pairs(menuElements) do v.visible = false end
        end
    )

    player = Player:spawn()
    player:moveTo(math.floor(love.graphics.getWidth()/2), math.floor(love.graphics.getHeight()/2))

    love.graphics.setBackgroundColor(6/255,21/255,24/255)
    love.graphics.setNewFont(12)

    mapBounds = {  -- in fractions of screen size so resizing is less of a pain
            y = {min = 0, max = 1}, x = {min = nil, max = nil},
            scrollY = {min = nil, max = nil}, scrollX = {min = 0.2, max = 0.8}
        }
end

function love.update(dt) -- dt in seconds
    if gameState == "menu" then menuUpdate(dt)
    elseif gameState == "game" then gameUpdate(dt)
    end
end

function menuUpdate(dt) end

function gameUpdate(dt)
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
    if gameState == "menu" then drawMenu()
    elseif gameState == "game" then drawGame()
    end
end

function drawMenu() 
    for _, v in ipairs(activeUIElements) do
        v:drawImpl()
    end
end

function drawGame()
    drawWorld()
    for _, v in ipairs(activeChars) do
        v:draw()
    end
    for _, v in ipairs(activeUIElements) do
        v:drawImpl()
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
