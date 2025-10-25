local anim8 = require('src.libraries.anim8.anim8')

local Player = {}
Player.__index = Player

function Player.new(x, y, tileSize)
    local self = setmetatable({}, Player)

    self.tileSize = tileSize or 16
    self.tileX = x or 1
    self.tileY = y or 1

    self.x = (self.tileX - 1) * self.tileSize
    self.y = (self.tileY - 1) * self.tileSize
    self.speed = 60 -- or 120

    self.targetX = self.x
    self.targetY = self.y

    self.width = self.tileSize
    self.height = self.tileSize

    self.direction = "down"
    self.moving = false
    self.movingTime = 0

    self:setupAnimations()
    return self
end

function Player:setupAnimations()
    local spritePath = "assets/images/sparky_sheet.png"
    self.spriteSheet = love.graphics.newImage(spritePath)

    local g = anim8.newGrid(16, 16, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

    self.animations = {
        right = anim8.newAnimation(g('1-3', 1), 0.1),
        left = anim8.newAnimation(g('1-3', 2), 0.1),
        down = anim8.newAnimation(g('1-3', 1), 0.1), -- temp reuse
        up = anim8.newAnimation(g('1-3', 2), 0.1), -- temp reuse

        idle_right = anim8.newAnimation(g(1, 1), 0.1),
        idle_left = anim8.newAnimation(g(1, 2), 0.1),
        idle_down = anim8.newAnimation(g(1, 1), 0.1),
        idle_up = anim8.newAnimation(g(1, 2), 0.1)
    }

    self.currentAnimation = self.animations["idle_" .. self.direction]
end

function Player:moveTo(tileX, tileY, game)
    local canMove = true

    -- Use the game's collision checking method
    -- if game.canMoveTo then
    --     canMove = game:canMoveTo(tileX, tileY)
    -- else
    -- Fallback boundary check
    -- if tileX < 1 or tileX > game.mapWidth or tileY < 1 or tileY > game.mapHeight then
    --     canMove = false
    -- end
    -- end

    if canMove then
        self.tileX = tileX
        self.tileY = tileY
        self.targetX = (self.tileX - 1) * self.tileSize
        self.targetY = (self.tileY - 1) * self.tileSize
        self.moving = true
        self.movingTime = 0

        -- Play walk sound
        if game.playWalkSound then
            game:playWalkSound()
        end
    end

    return canMove
end

function Player:move(dx, dy, game)
    if dx > 0 then
        self.direction = "right"
    elseif dx < 0 then
        self.direction = "left"
    elseif dy > 0 then
        self.direction = "down"
    elseif dy < 0 then
        self.direction = "up"
    end
    return self:moveTo(self.tileX + dx, self.tileY + dy, game)
end

function Player:handleInput(dt, game)
    local moved = false

    -- Only allow new movement input if the player has reached their target position
    if math.abs(self.x - self.targetX) < 1 and math.abs(self.y - self.targetY) < 1 then
        self.x = self.targetX
        self.y = self.targetY
        self.moving = false

        if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
            moved = self:move(0, -1, game)
        elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then
            moved = self:move(0, 1, game)
        elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
            moved = self:move(-1, 0, game)
        elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
            moved = self:move(1, 0, game)
        end
    end

    -- Smooth movement toward target position
    if self.x < self.targetX then
        self.x = math.min(self.x + self.speed * dt, self.targetX)
    elseif self.x > self.targetX then
        self.x = math.max(self.x - self.speed * dt, self.targetX)
    end

    if self.y < self.targetY then
        self.y = math.min(self.y + self.speed * dt, self.targetY)
    elseif self.y > self.targetY then
        self.y = math.max(self.y - self.speed * dt, self.targetY)
    end

    -- Update movement animation
    if self.moving then
        self.movingTime = self.movingTime + dt
        local anim = self.animations[self.direction]
        if anim then
            anim:update(dt)
            self.currentAnimation = anim
        end
    else
        -- Update idle animation
        local idleAnim = self.animations["idle_" .. self.direction]
        if idleAnim then
            idleAnim:update(dt)
            self.currentAnimation = idleAnim
        end
    end

    return moved
end

function Player:update(dt, tilemap)
    self:handleInput(dt, tilemap)
end

function Player:draw()
    local x = self.x
    local y = self.y

    local yOffset = 0
    if self.moving then
        yOffset = math.sin(self.movingTime * 15) * 1
    end

    -- simple shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.ellipse("fill", x + self.width / 2, y + self.height - 2, self.width * 0.5, self.height * 0.15)
    love.graphics.setColor(1, 1, 1)

    self.currentAnimation:draw(self.spriteSheet, x, y - yOffset)
end

return Player
