require("overlays")

menuElements = {
    playButton = UIButton:spawn({
        x = love.graphics.getWidth() / 2 - 64,
        y = love.graphics.getHeight() / 2 - 64,
        w = 128, h = 32,
        text = "Play Game",
    }),
    secondButton = UIButton:spawn({
        x = love.graphics.getWidth() / 2 - 64,
        y = love.graphics.getHeight() / 2 - 24,
        w = 128, h = 32,
        text = "Second",
    }),
    thirdButton = UIButton:spawn({
        x = love.graphics.getWidth() / 2 - 64,
        y = love.graphics.getHeight() / 2 + 16,
        w = 128, h = 32,
        text = "Third",
    }),
    anarchy_associates_and_co_label = UILabel:spawn({
        x = 4,
        y = love.graphics.getHeight() - 32,
        w = 256, h = 32,
        text = "An Anarchy Associates & Co. Production",
        backgroundColorR = 0.0,
        backgroundColorG = 0.0,
        backgroundColorB = 0.0,
        backgroundColorA = 1.0,
    })
}

function mainMenuSetListeners(onPlayButtonClick)
    menuElements.playButton.onClick = onPlayButtonClick
end
