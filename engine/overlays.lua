require("helpers")

activeUIElements = {}

function drawCenteredText(x, y, w, h, text)
    local font = love.graphics.getFont()
    local tw = font:getWidth(text)
    local th = font:getHeight()
    love.graphics.print(text, x + w / 2, y + h / 2, 0, 1, 1, tw / 2, th / 2)
end

UIElement = {
    new = function(self, obj)
        obj = obj or {}
        setmetatable(obj, self)
        self.__index = self
        return obj
    end,
    init = function(self)
        self.x = self.x or 0
        self.y = self.y or 0
        self.w = self.w or 0
        self.h = self.h or 0

        self.dispatchTable = {}
        self.hittest = self.hittest or function(mx, my) return false end

        table.insert(activeUIElements, self)
    end,
    spawn = function(self, obj)
        obj = self:new(obj)
        obj:init()
        return obj
    end,
    draw = function()
    end,

    -- events
    dispatch = function(self, event)
        for i, v in ipairs(self.dispatchTable) do
            if v.type == event.type then v.handle(event) end
        end
    end,
    addEventListener = function(self, type, handle)
        table.insert(self.dispatchTable, { type = type, handle = handle })
    end,
}

UIButton = UIElement:new()
function UIButton:init()
    UIElement.init(self)
    self.colorR = self.colorR or 0.8
    self.colorG = self.colorG or 0.0
    self.colorB = self.colorB or 0.8
    self.colorA = self.colorA or 1.0

    self.hoverColorR = self.hoverColorR or 1.0
    self.hoverColorG = self.hoverColorG or 0.0
    self.hoverColorB = self.hoverColorB or 1.0
    self.hoverColorA = self.hoverColorA or 1.0

    self.disabledColorR = self.disabledColorR or 0.8
    self.disabledColorG = self.disabledColorG or 0.8
    self.disabledColorB = self.disabledColorB or 0.8
    self.disabledColorA = self.disabledColorA or 1.0

    self.textColorR = self.textColorR or 1.0
    self.textColorG = self.textColorG or 1.0
    self.textColorB = self.textColorB or 1.0
    self.textColorA = self.textColorA or 1.0

    self.enabled = self.enabled or true

    self.text = self.text or "Button"
    self.hovering = false

    self.hittest = function(mx, my)
        return self.x < mx and self.y < my and mx < self.x + self.w and my < self.y + self.h
    end

    self:addEventListener(
        "mouseenter",
        function(event)
            self.hovering = true
        end
    )

    self:addEventListener(
        "mouseexit",
        function(event)
            self.hovering = false
        end
    )

    self:addEventListener(
        "mousepressed",
        function(event)
            if self.enabled then self.onClick() end
        end
    )
end
function UIButton:draw()
    UIElement:draw()
    if not self.enabled then
        love.graphics.setColor(self.disabledColorR, self.disabledColorG, self.disabledColorB, self.disabledColorA)
    elseif self.hovering then
        love.graphics.setColor(self.hoverColorR, self.hoverColorG, self.hoverColorB, self.hoverColorA)
    else
        love.graphics.setColor(self.colorR, self.colorG, self.colorB, self.colorA)
    end
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    love.graphics.setColor(self.textColorR, self.textColorG, self.textColorB, self.textColorA)
    drawCenteredText(self.x, self.y, self.w, self.h, self.text)
    love.graphics.reset()
end

UISeed = UIElement:new()
function UISeed:init()
    UIElement.init(self)
    self.type = self.type or 1 -- types are 1, 2, ...
    self.x = self.x or 0
    self.y = self.y or 0
    self.r = self.r or 32

    self.onMoved = self.onMoved or function(x, y)
        local str = string.format("Moved to %d, %d", x, y)
        print(str)
    end

    self.hovering = false
    self.grabbed = false
    self.isInCentre = false

    self.hittest = function(mx, my) return (self.x - mx)^2 + (self.y - my)^2 < self.r^2 end

    self:addEventListener(
        "mouseenter",
        function(event) self.hovering = true end
    )

    self:addEventListener(
        "mouseexit",
        function(event)
            self.hovering = false
            self.grabbed = false
        end
    )

    self:addEventListener(
        "mousepressed",
        function(event) self.grabbed = true end
    )

    self:addEventListener(
        "mousereleased",
        function(event) self.grabbed = false end
    )

    self:addEventListener(
        "mousemoved",
        function(event)
            if self.grabbed then
                self.x = self.x + event.dx
                self.y = self.y + event.dy
                self.onMoved(self.x, self.y)
            end
        end
    )
end
function UISeed:draw()
    UIElement:draw()
    if self.hovering then
        love.graphics.setColor(1, 1, 1, 1)
    elseif self.type == 1 then
        love.graphics.setColor(1, 0, 0, 1)
    elseif self.type == 2 then
        love.graphics.setColor(0, 1, 0, 1)
    elseif self.type == 3 then
        love.graphics.setColor(0, 0, 1, 1)
    end

    love.graphics.circle("fill", self.x, self.y, self.r)
    love.graphics.reset()
end

UIInventory = UIElement:new()
function UIInventory:init()
    UIElement.init(self)
    self.radius = self.radius or 256
    self.innerRadius = self.innerRadius or 128
    self.seeds = self.seeds or {1, 2, 1, 2, 1}

    self.mergeResult = function()
        local getCountOfType = function(type)
            return reduce(
                self.seeds,
                0,
                function(acc, value)
                    if value.isInCentre and value.type == type then
                        return acc + 1
                    end
                    return acc
                end
            )
        end

        local countType1 = getCountOfType(1)
        local countType2 = getCountOfType(2)
        local countType3 = getCountOfType(3)

        print("=============================")
        print(countType1)
        print(countType2)
        print(countType3)
        print("=============================")

        if countType1 == 1 and countType2 == 1 and countType3 == 0 then
            return 3
        end
        return nil
    end

    self.mergeButton = UIButton:spawn({
        x = love.graphics.getWidth() / 2 - 32,
        y = love.graphics.getHeight() / 2 - 32 - self.innerRadius,
        w = 64,
        h = 24,
        text = "Merge",
        colorR = 0.5,
        colorG = 0.5,
        colorB = 0.5,
        hoverColorR = 0.6,
        hoverColorG = 0.6,
        hoverColorB = 0.6,
        enabled = false,
        onClick = function()
            -- take whatever's in the middle and remove it.
            local result = self.mergeResult()

            local uiElementIndicesToRemove = {}
            local seedIndicesToRemove = {}
            for i, v in ipairs(self.seeds) do
                if v.isInCentre then
                    -- garbage collector?
                    local uiElementIndex = nil
                    for j, w in ipairs(activeUIElements) do
                        if w == self.seeds[i] then uiElementIndex = j end
                    end
                    if uiElementIndex ~= nil then
                        table.insert(uiElementIndicesToRemove, uiElementIndex)
                        table.insert(seedIndicesToRemove, i)
                    else print ("could not remove seed") end
                end
            end

            table.sort(uiElementIndicesToRemove, function(a, b) return a > b end)
            table.sort(seedIndicesToRemove, function(a, b) return a > b end)
            for _, index in ipairs(uiElementIndicesToRemove) do
                table.remove(activeUIElements, index)
            end
            for _, index in ipairs(seedIndicesToRemove) do
                table.remove(self.seeds, index)
            end

            -- then add a seed corresponding to result of mergeResult, re-initialize everything
            for i, v in ipairs(self.seeds) do
                local angle = 2 * i * 3.1419265 / (#self.seeds + 1)
                v.x = love.graphics.getWidth() / 2 + self.radius * math.sin(angle)
                v.y = love.graphics.getHeight() / 2 + self.radius * math.cos(angle)
                v.onMoved = function(x, y)
                    local prev = self.seeds[i].isInCentre 
                    if (x - love.graphics.getWidth() / 2)^2 + (y - love.graphics.getHeight() / 2)^2 < self.innerRadius^2 then 
                        self.seeds[i].isInCentre = true
                    else
                        self.seeds[i].isInCentre = false
                    end

                    if prev ~= self.seeds[i].isInCentre then
                        self.mergeButton.enabled = self.mergeResult() ~= nil
                    end
                end
            end

            local addIndex = #self.seeds + 1
            self.seeds[addIndex] = UISeed:spawn({
                x = love.graphics.getWidth() / 2 + self.radius * math.sin(2 * 3.14159265),
                y = love.graphics.getHeight() / 2 + self.radius * math.cos(2 * 3.14159265),
                type = result,
                onMoved = function(x, y)
                    local prev = self.seeds[addIndex].isInCentre
                    if (x - love.graphics.getWidth() / 2)^2 + (y - love.graphics.getHeight() / 2)^2 < self.innerRadius^2 then 
                        self.seeds[addIndex].isInCentre = true
                    else
                        self.seeds[addIndex].isInCentre = false
                    end

                    if prev ~= self.seeds[addIndex].isInCentre then
                        self.mergeButton.enabled = self.mergeResult() ~= nil
                    end
                end,
            })

        end
    })

    for i, v in ipairs(self.seeds) do
        local angle = 2 * i * 3.1419265 / #self.seeds
        self.seeds[i] = UISeed:spawn({
            x = love.graphics.getWidth() / 2 + self.radius * math.sin(angle),
            y = love.graphics.getHeight() / 2 + self.radius * math.cos(angle),
            type = v,
            onMoved = function(x, y)
                local prev = self.seeds[i].isInCentre 
                if (x - love.graphics.getWidth() / 2)^2 + (y - love.graphics.getHeight() / 2)^2 < self.innerRadius^2 then 
                    self.seeds[i].isInCentre = true
                else
                    self.seeds[i].isInCentre = false
                end

                if prev ~= self.seeds[i].isInCentre then
                    self.mergeButton.enabled = self.mergeResult() ~= nil
                end
            end,
        })
    end

end
function UIInventory:draw()
    UIElement:draw()
    local numInCauldron = reduce(self.seeds, 0, function(acc, value) return acc + (value.isInCentre and 1 or 0) end)
    love.graphics.setColor(0.2, 0.2 * numInCauldron, 0.2, 0.2)
    love.graphics.circle("fill", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, self.innerRadius)
    for i, v in ipairs(self.seeds) do
        v:draw()
    end
    love.graphics.reset()
end

UIHealthBar = UIElement:new()
function UIHealthBar:init()
    UIElement.init(self)
    self.x = self.x or 32
    self.y = self.y or 32
    self.w = self.w or 128
    self.h = self.h or 32

    self.health = self.health or 40
    self.maxHealth = self.maxHealth or 100
end
function UIHealthBar:draw()
    UIElement.draw()

    local healthPct = self.health / self.maxHealth
    local healthText = string.format("%d / %d", self.health, self.maxHealth)

    love.graphics.setColor(0.2, 0.2, 0.2, 1.0)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h) -- background
    if healthPct > 0.4 then
        love.graphics.setColor(0.2, 0.8, 0.3, 1.0)
    elseif healthPct > 0.1 then
        love.graphics.setColor(0.8, 0.7, 0.2, 1.0)
    else
        love.graphics.setColor(0.8, 0.2, 0.1, 1.0)
    end
    love.graphics.rectangle("fill", self.x, self.y, self.w * healthPct, self.h) -- foreground
    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h) -- outline
    drawCenteredText(self.x, self.y, self.w, self.h, healthText)
    love.graphics.reset()
end

--[[Button1 = UIButton:spawn({
    x=100, y=100, w=100, h=100,
    onClick=function()
        print("click motherfucker")
    end
})]]

--Inventory1 = UIInventory:spawn({seeds = {1,2,1,2,1}})
HealthBar = UIHealthBar:spawn({x=32, y=32, w=128, h=32})
