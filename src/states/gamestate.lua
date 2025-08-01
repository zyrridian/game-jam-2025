local GameState = {}

GameState.current = nil

function GameState.switch(state, ...)
    if GameState.current and GameState.current.exit then
        GameState.current:exit()
    end
    
    GameState.current = state
    
    if state.enter then
        state:enter(...)
    end
end

function GameState.update(dt)
    if GameState.current and GameState.current.update then
        GameState.current:update(dt)
    end
end

function GameState.draw()
    if GameState.current and GameState.current.draw then
        GameState.current:draw()
    end
end

function GameState.keypressed(key)
    if GameState.current and GameState.current.keypressed then
        GameState.current:keypressed(key)
    end
end

return GameState