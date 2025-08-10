local GameState = require("src.states.gamestate")

local Splash = {}

function Splash:enter()
    self.timer = 0
    self.duration = 3
    self.fade_in = 1
    self.fade_out = 1
    self.alpha = 0

    -- Loads simple font (built-in)
    self.font_large = love.graphics.newFont(48)
    self.font_small = love.graphics.newFont(24)

    -- Developer info
    self.dev_name = "zyrridian"
    self.dev_title = "Presents"
end

function Splash:update(dt)
    self.timer = self.timer + dt

    -- Fade in
    if self.timer < self.fade_in then
        self.alpha = self.timer / self.fade_in
        -- Delay (3 seconds)
    elseif self.timer < self.duration - self.fade_out then
        self.alpha = 1
        -- Fade out
    elseif self.timer < self.duration then
        local fade_time = self.timer - (self.duration - self.fade_out)
        self.alpha = 1 - (fade_time / self.fade_out)
    else
        local Menu = require('src.states.menu')
        GameState.switch(Menu)
    end
end

function Splash:draw()
    -- Clear the screen
    love.graphics.clear(0.05, 0.05, 0.1, 1)
    love.graphics.setColor(1, 1, 1, self.alpha)

    -- Draw dev name
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    love.graphics.setFont(self.font_large)
    love.graphics.printf(self.dev_name, 0, height / 2 - 50, width, "center")
    love.graphics.setFont(self.font_small)
    love.graphics.printf(self.dev_title, 0, height / 2 + 10, width, "center")

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function Splash:keypressed(key)
    if key == "space" or key == "return" then
        local Menu = require('src.states.menu')
        GameState.switch(Menu)
    end
end

return Splash
