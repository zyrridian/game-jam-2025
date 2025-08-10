local GameState = require('src.states.gamestate')
local sti = require('src.libraries.sti')
local Player = require('src.maps.player')

local Game = {}

function Game:enter()
    self.font = love.graphics.newFont(16)

    -- Camera settings (TODO: Use lib)
    self.cameraZoom = 3.0
    self.viewportWidth = love.graphics.getWidth() / self.cameraZoom
    self.viewportHeight = love.graphics.getHeight() / self.cameraZoom

    -- Load map
    self.map = sti("src/maps/stage1.lua")
    self.mapWidth = self.map.width
    self.mapHeight = self.map.height
    self.tileWidth = self.map.tilewidth
    self.tileHeight = self.map.tileheight

    -- Spawn player
    self.player = Player.new(5, 5, self.tileWidth)
    self:updateCamera()
    self.showDebugInfo = true

    -- Initialize keyboard state tracking
    love.keyboard.keysPressed = {}

    -- Load and play background music
    self:loadAudio()
    self:playBackgroundMusic()
end

function Game:loadAudio()
    self.backgroundMusic = love.audio.newSource("assets/music/bgm_robot.ogg", "stream")
    self.walkSound = love.audio.newSource("assets/sfx/sfx_walk.wav", "static")

    self.backgroundMusic:setLooping(true)
    self.backgroundMusic:setVolume(0.5)

    self.walkSound:setVolume(0.4)
end

function Game:playBackgroundMusic()
    love.audio.play(self.backgroundMusic)
end

function Game:stopBackgroundMusic()
    if self.backgroundMusic:isPlaying() then
        love.audio.stop(self.backgroundMusic)
    end
end

function Game:playWalkSound()
    -- Stop and restart walk sound for playback
    self.walkSound:stop()

    -- Add some annoying pitch variation
    local pitch = 0.9 + math.random() * 0.2 -- pitch between 0.9-1.1
    self.walkSound:setPitch(pitch)

    love.audio.play(self.walkSound)
end

function Game:updateCamera()
    -- Center the camera on the player
    local viewportWidth = self.viewportWidth
    local viewportHeight = self.viewportHeight
    local camX = self.player.x - viewportWidth / 2 + self.player.width / 2
    local camY = self.player.y - viewportHeight / 2 + self.player.height / 2
    local mapPixelWidth = self.mapWidth * self.tileWidth
    local mapPixelHeight = self.mapHeight * self.tileHeight

    camX = math.max(0, math.min(camX, mapPixelWidth - viewportWidth))
    camY = math.max(0, math.min(camY, mapPixelHeight - viewportHeight))

    self.camX = camX
    self.camY = camY
end

function Game:update(dt)
    self.player:update(dt, self)
    self:updateCamera()
    self.map:update(dt)

    -- Toggle debug info
    if love.keyboard.keysPressed["f1"] then
        self.showDebugInfo = not self.showDebugInfo
    end
end

function Game:draw()
    love.graphics.clear(0.1, 0.1, 0.1)
    love.graphics.push()
    love.graphics.scale(self.cameraZoom, self.cameraZoom)
    love.graphics.push()
    love.graphics.translate(-self.camX, -self.camY)

    self.map:draw()
    self.player:draw(0, 0)

    love.graphics.pop() -- Reset camera translation
    love.graphics.pop() -- Reset zoom scaling

    -- Draw UI elements 
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.font)
    love.graphics.printf("Use WASD or arrow keys to move", 10, 10, love.graphics.getWidth() - 20, "right")
    love.graphics.printf("Press ESC to return to menu", 10, 30, love.graphics.getWidth() - 20, "right")

    -- Draw debug info
    if self.showDebugInfo then
        local info = {"Player: " .. self.player.tileX .. ", " .. self.player.tileY}

        table.insert(info, string.format("Camera: %d, %d (zoom: %.1fx)", math.floor(self.camX), math.floor(self.camY),
            self.cameraZoom))

        table.insert(info,
            string.format("Map: %dx%d tiles (%dx%d px)", self.mapWidth, self.mapHeight, self.mapWidth * self.tileWidth,
                self.mapHeight * self.tileHeight))

        table.insert(info, "FPS: " .. love.timer.getFPS())

        for i, text in ipairs(info) do
            love.graphics.printf(text, 10, 10 + (i - 1) * 20, love.graphics.getWidth() - 20, "left")
        end
    end
end

function Game:keypressed(key)
    if key == "escape" then
        self:stopBackgroundMusic()
        local Menu = require('src.states.menu')
        GameState.switch(Menu)
    elseif key == "=" or key == "+" then
        -- Increase zoom
        self.cameraZoom = math.min(self.cameraZoom + 0.5, 6.0)
        self.viewportWidth = love.graphics.getWidth() / self.cameraZoom
        self.viewportHeight = love.graphics.getHeight() / self.cameraZoom
        self:updateCamera()
    elseif key == "-" or key == "_" then
        -- Decrease zoom
        self.cameraZoom = math.max(self.cameraZoom - 0.5, 1.0)
        self.viewportWidth = love.graphics.getWidth() / self.cameraZoom
        self.viewportHeight = love.graphics.getHeight() / self.cameraZoom
        self:updateCamera()
    end
end

-- Collision checking method for the player
function Game:canMoveTo(tileX, tileY)
    -- Check map boundaries
    if tileX < 1 or tileX > self.mapWidth or tileY < 1 or tileY > self.mapHeight then
        return false
    end

    -- Get the tile data from the map
    local layer = self.map.layers[1]
    if layer and layer.data then
        local index = (tileY - 1) * self.mapWidth + tileX
        local tileId = layer.data[index]

        -- Define which tiles are walkable
        local walkableTiles = {5} -- Add more tile IDs as needed

        for _, walkableId in ipairs(walkableTiles) do
            if tileId == walkableId then
                return true
            end
        end

        return false
    end

    return true
end

function Game:exit()
    self:stopBackgroundMusic()
end

return Game
