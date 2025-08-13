local GameState = require('src.states.gamestate')
local sti = require('src.libraries.sti')
local Player = require('src.players.player')
local Camera = require('src.libraries.hump.camera')

local Game = {}

function Game:enter()
    self.font = love.graphics.newFont(16)

    self.camera = Camera()
    self.cameraZoom = 1.0
    self.scale = 4.0
    self.camera:zoom(self.cameraZoom)

    -- Load map
    self.map = sti("src/maps/stage1.lua")
    self.mapWidth = self.map.width
    self.mapHeight = self.map.height
    self.tileWidth = self.map.tilewidth
    self.tileHeight = self.map.tileheight
    -- self.mapPixelWidth = self.mapWidth * self.tileWidth * self.scale
    -- self.mapPixelHeight = self.mapHeight * self.tileHeight * self.scale

    -- Spawn player
    self.player = Player.new(5, 5, self.tileWidth)
    self:updateCamera()

    self.showDebugInfo = true

    -- Initialize keyboard state tracking
    love.keyboard.keysPressed = {}

    -- Load and play background music
    self:loadAudio()

    -- Add music delay
    self.musicDelay = 0.5
    self.musicTimer = 0
    self.musicStarted = false
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
    self.walkSound:stop()
    local pitch = 0.9 + math.random() * 0.2
    self.walkSound:setPitch(pitch)
    love.audio.play(self.walkSound)
end

function Game:updateCamera()
    local playerCenterX = self.player.x + self.player.width / 2
    local playerCenterY = self.player.y + self.player.height / 2
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local halfScreenWidth = screenWidth / (2 * self.scale)
    local halfScreenHeight = screenHeight / (2 * self.scale)
    local mapPixelWidth = self.mapWidth * self.tileWidth
    local mapPixelHeight = self.mapHeight * self.tileHeight
    local camX = playerCenterX
    local camY = playerCenterY

    if mapPixelWidth > screenWidth / self.scale then
        camX = math.max(halfScreenWidth, math.min(camX, mapPixelWidth - halfScreenWidth))
    else
        camX = mapPixelWidth / 2
    end

    if mapPixelHeight > screenHeight / self.scale then
        camY = math.max(halfScreenHeight, math.min(camY, mapPixelHeight - halfScreenHeight))
    else
        camY = mapPixelHeight / 2
    end

    self.camera:lookAt(camX, camY)
end

function Game:update(dt)
    self.player:update(dt, self)
    self:updateCamera()
    self.map:update(dt)

    -- Music delay
    if not self.musicStarted then
        self.musicTimer = self.musicTimer + dt
        if self.musicTimer >= self.musicDelay then
            self:playBackgroundMusic()
            self.musicStarted = true
        end
    end

    -- Toggle debug info
    if love.keyboard.keysPressed["f1"] then
        self.showDebugInfo = not self.showDebugInfo
    end
end

function Game:draw()
    love.graphics.clear(0.1, 0.1, 0.1)
    self.camera:attach()
    love.graphics.push()
    love.graphics.scale(self.scale, self.scale)
    self.map:draw(0, 0, self.scale, self.scale)
    self.player:draw()
    love.graphics.pop()
    self.camera:detach()

    -- Draw UI elements 
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.font)
    love.graphics.printf("Use WASD or arrow keys to move", 10, 10, love.graphics.getWidth() - 20, "right")
    love.graphics.printf("Press ESC to return to menu", 10, 30, love.graphics.getWidth() - 20, "right")
    love.graphics.printf("Use +/- to zoom", 10, 50, love.graphics.getWidth() - 20, "right")
    love.graphics.printf("Press F1 to toggle debug info", 10, 70, love.graphics.getWidth() - 20, "right")

    -- Draw debug info
    if self.showDebugInfo then
        local camX, camY = self.camera:position()
        local info = {"Player Tile: " .. self.player.tileX .. ", " .. self.player.tileY,
                      string.format("Player Pixel: %.1f, %.1f", self.player.x, self.player.y),
                      string.format("Camera: %.1f, %.1f (scale: %.1fx)", camX, camY, self.scale),
                      string.format("Map: %dx%d tiles (%dx%d px)", self.mapWidth, self.mapHeight,
            self.mapWidth * self.tileWidth, self.mapHeight * self.tileHeight), "FPS: " .. love.timer.getFPS()}

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
        -- Increase scale
        self.scale = math.min(self.scale + 0.5, 6.0)
        self:updateCamera()
    elseif key == "-" or key == "_" then
        -- Decrease scale
        self.scale = math.max(self.scale - 0.5, 1.0)
        self:updateCamera()
    end
end

-- COLLISION SYSTEM COMMENTED OUT - ALL TILES ARE NOW WALKABLE
--[[
-- Collision checking method for the player
function Game:canMoveTo(tileX, tileY)
    -- Check map boundaries
    if tileX < 1 or tileX > self.mapWidth or tileY < 1 or tileY > self.mapHeight then
        return false
    end

    local layer = self.map.layers[1]
    if layer and layer.data then
        local index = (tileY - 1) * self.mapWidth + tileX
        local tileId = layer.data[index]

        local walkableTiles = {5}

        for _, walkableId in ipairs(walkableTiles) do
            if tileId == walkableId then
                return true
            end
        end

        return false
    end

    return true
end
--]]

-- Temporary allows movement to all tiles within map boundaries
function Game:canMoveTo(tileX, tileY)
    if tileX < 1 or tileX > self.mapWidth or tileY < 1 or tileY > self.mapHeight then
        return false
    end
    return true
end

function Game:exit()
    self:stopBackgroundMusic()
end

return Game
