local GameState = require('src.states.gamestate')
local Splash = require('src.states.splash')
local Menu = require('src.states.menu')

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())
    GameState.switch(Menu)
end

function love.update(dt)
    GameState.update(dt)
end

function love.draw()
    GameState.draw()
end

function love.keypressed(key)
    GameState.keypressed(key)
end
