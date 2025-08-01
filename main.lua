local GameState = require('src.states.gamestate')
local Splash = require('src.states.splash')

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())
    GameState.switch(Splash)
end

function love.update(dt)
    GameState.update(dt)
end

function love.draw()
    GameState.draw()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    
    GameState.keypressed(key)
end