local GameState = require('src.states.gamestate')

local Menu = {}

function Menu:enter()
    self.font_title = love.graphics.newFont(64)
    self.font_menu = love.graphics.newFont(32)
    self.font_small = love.graphics.newFont(18)
    
    self.title = "TITLE"
    self.options = {"Start Game", "Settings", "Exit"}
    self.selected = 1
    
    -- Background color
    self.bg_color = {0, 0, 0, 0}
    -- self.bg_color = {0.1, 0.1, 0.2, 1}
    
    -- Menu animation
    self.time = 0
    self.pulse = 0
end

function Menu:update(dt)
    self.time = self.time + dt
    self.pulse = math.sin(self.time * 3) * 0.3 + 0.7
end

function Menu:draw()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    -- Background
    love.graphics.clear(self.bg_color)
    
    -- Title
    love.graphics.setColor(1, 1, 0.8, 1)
    love.graphics.setFont(self.font_title)
    love.graphics.printf(self.title, 0, height/4, width, "center")
    
    -- Menu options
    love.graphics.setFont(self.font_menu)
    local start_y = height/2
    
    for i, option in ipairs(self.options) do
        local y = start_y + (i-1) * 60
        
        -- Highlight selected option
        if i == self.selected then
            love.graphics.setColor(1, 1, 1, self.pulse)
            love.graphics.printf("> " .. option .. " <", 0, y, width, "center")
        else
            love.graphics.setColor(0.7, 0.7, 0.7, 1)
            love.graphics.printf(option, 0, y, width, "center")
        end
    end
    
    -- Instructions
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.setFont(self.font_small)
    love.graphics.printf("Use UP/DOWN arrows and ENTER to select", 0, height - 60, width, "center")
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function Menu:keypressed(key)
    if key == "up" then
        self.selected = self.selected - 1
        if self.selected < 1 then
            self.selected = #self.options
        end
    elseif key == "down" then
        self.selected = self.selected + 1
        if self.selected > #self.options then
            self.selected = 1
        end
    elseif key == "return" or key == "space" then
        if self.selected == 1 then
            -- Start Game
            print("Starting game...")
        elseif self.selected == 2 then
            -- Settings
            print("Settings not implemented yet")
        elseif self.selected == 3 then
            -- Exit
            love.event.quit()
        end
    end
end

return Menu