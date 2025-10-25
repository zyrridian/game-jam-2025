local GameState = require('src.states.gamestate')

local Settings = {}

function Settings:enter()
    self.font_title = love.graphics.newFont(48)
    self.font_menu = love.graphics.newFont(28)
    self.font_small = love.graphics.newFont(18)

    self.title = "SETTINGS"
    self.selected = 1

    -- Settings options
    self.options = {{
        name = "Master Volume",
        type = "slider",
        value = 0.7,
        min = 0,
        max = 1,
        step = 0.1
    }, {
        name = "Music Volume",
        type = "slider",
        value = 0.7,
        min = 0,
        max = 1,
        step = 0.1
    }, {
        name = "SFX Volume",
        type = "slider",
        value = 0.8,
        min = 0,
        max = 1,
        step = 0.1
    }, {
        name = "Fullscreen",
        type = "toggle",
        value = false
    }, {
        name = "VSync",
        type = "toggle",
        value = true
    }, {
        name = "Back",
        type = "button"
    }}

    -- Animation
    self.time = 0
    self.pulse = 0

    -- Load sounds
    self.sounds = {
        sfx_move = love.audio.newSource("assets/sfx/sfx_move.wav", "static"),
        sfx_back = love.audio.newSource("assets/sfx/sfx_back.wav", "static"),
        sfx_click = love.audio.newSource("assets/sfx/sfx_click.wav", "static")
    }

    -- Set initial volumes
    self:applyAudioSettings()
end

-- Helper function to play sound effects and to make sure they don't overlap
function Settings:playSound(sound)
    if sound then
        sound:stop()
        love.audio.play(sound)
    end
end

function Settings:update(dt)
    self.time = self.time + dt
    self.pulse = math.sin(self.time * 3) * 0.3 + 0.7
end

function Settings:draw()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    -- Background
    love.graphics.clear(0.05, 0.05, 0.1, 1)

    -- Title
    love.graphics.setColor(1, 1, 0.8, 1)
    love.graphics.setFont(self.font_title)
    love.graphics.printf(self.title, 0, height / 6, width, "center")

    -- Settings options
    love.graphics.setFont(self.font_menu)
    local start_y = height / 3

    for i, option in ipairs(self.options) do
        local y = start_y + (i - 1) * 60
        local is_selected = (i == self.selected)

        -- Set color based on selection
        if is_selected then
            love.graphics.setColor(1, 1, 1, self.pulse)
        else
            love.graphics.setColor(0.7, 0.7, 0.7, 1)
        end

        if option.type == "slider" then
            -- Draw slider
            local label = option.name .. ": " .. math.floor(option.value * 100) .. "%"
            if is_selected then
                label = "> " .. label .. " <"
            end
            love.graphics.printf(label, 0, y, width, "center")

            -- Draw slider bar
            local bar_width = 200
            local bar_height = 10
            local bar_x = width / 2 - bar_width / 2
            local bar_y = y + 35

            -- Background bar
            love.graphics.setColor(0.3, 0.3, 0.3, 1)
            love.graphics.rectangle("fill", bar_x, bar_y, bar_width, bar_height)

            -- Fill bar
            if is_selected then
                love.graphics.setColor(1, 1, 0.5, self.pulse)
            else
                love.graphics.setColor(0.8, 0.8, 0.8, 1)
            end
            love.graphics.rectangle("fill", bar_x, bar_y, bar_width * option.value, bar_height)
        elseif option.type == "toggle" then
            -- Draw toggle
            local status = option.value and "ON" or "OFF"
            local label = option.name .. ": " .. status
            if is_selected then
                label = "> " .. label .. " <"
            end
            love.graphics.printf(label, 0, y, width, "center")
        elseif option.type == "button" then
            -- Draw button
            local label = is_selected and "> " .. option.name .. " <" or option.name
            love.graphics.printf(label, 0, y, width, "center")
        end
    end

    -- Instructions
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.setFont(self.font_small)
    love.graphics.printf("Use UP/DOWN to navigate, LEFT/RIGHT to adjust, ENTER to select", 0, height - 80, width,
        "center")
    love.graphics.printf("ESC to go back", 0, height - 60, width, "center")

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function Settings:keypressed(key)
    local current_option = self.options[self.selected]

    if key == "up" then
        self.selected = self.selected - 1
        if self.selected < 1 then
            self.selected = #self.options
        end
        self:playSound(self.sounds.sfx_move)
    elseif key == "down" then
        self.selected = self.selected + 1
        if self.selected > #self.options then
            self.selected = 1
        end
        self:playSound(self.sounds.sfx_move)
    elseif key == "left" and current_option.type == "slider" then
        current_option.value = math.max(current_option.min, current_option.value - current_option.step)
        self:applyAudioSettings()
        self:playSound(self.sounds.sfx_click)
    elseif key == "right" and current_option.type == "slider" then
        current_option.value = math.min(current_option.max, current_option.value + current_option.step)
        self:applyAudioSettings()
        self:playSound(self.sounds.sfx_click)
    elseif (key == "return" or key == "space") then
        if current_option.type == "toggle" then
            current_option.value = not current_option.value
            self:applySettings()
        elseif current_option.type == "button" and current_option.name == "Back" then
            self:goBack()
        end
        self:playSound(self.sounds.sfx_click)
    elseif key == "escape" then
        self:goBack()
        self:playSound(self.sounds.sfx_back)
    end
end

function Settings:applyAudioSettings()
    -- Apply master volume
    love.audio.setVolume(self.options[1].value)

    -- Apply music volume 
    local music_volume = self.options[2].value
    -- TODO: create a global music manager
    -- MusicManager.setVolume(music_volume)

    -- Apply SFX volume to all sound effects
    local sfx_volume = self.options[3].value
    for _, sound in pairs(self.sounds) do
        sound:setVolume(sfx_volume)
    end
end

function Settings:applySettings()
    -- Apply fullscreen setting
    if self.options[4].name == "Fullscreen" then
        love.window.setFullscreen(self.options[4].value)
    end

    -- Apply VSync setting
    if self.options[5].name == "VSync" then
        love.window.setVSync(self.options[5].value and 1 or 0)
    end
end

function Settings:goBack()
    local Menu = require('src.states.menu')
    GameState.switch(Menu)
end

function Settings:exit()
    -- TODO: Save settings if needed
    self:applySettings()
end

return Settings
