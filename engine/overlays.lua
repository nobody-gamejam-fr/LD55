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
        self.onClick = self.onClick or function() end
        self.mouseHover = false
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
    handleMousePosition = function(self, x, y)
        if self.x < x and x < self.x + self.w and self.y < y and y < self.y + self.h then self.mouseHover = true
        else self.mouseHover = false
        end
    end,

    handleMouseDown = function(self)
        if self.mouseHover then self:onClick() end
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

    self.textColorR = self.textColorR or 1.0
    self.textColorG = self.textColorG or 1.0
    self.textColorB = self.textColorB or 1.0
    self.textColorA = self.textColorA or 1.0

    self.text = self.text or "Button"
end
function UIButton:draw()
    UIElement.draw()
    if self.mouseHover then
        love.graphics.setColor(self.hoverColorR, self.hoverColorG, self.hoverColorB, self.hoverColorA)
    else
        love.graphics.setColor(self.colorR, self.colorG, self.colorB, self.colorA)
    end
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    love.graphics.setColor(self.textColorR, self.textColorG, self.textColorB, self.textColorA)
    drawCenteredText(self.x, self.y, self.w, self.h, self.text)
    love.graphics.reset()
end

Button1 = UIButton:spawn({
    x=100, y=100, w=100, h=100,
    onClick=function()
        print("click motherfucker")
    end
})
