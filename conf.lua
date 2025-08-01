function love.conf(t)
    t.title = "RPG Demo"
    t.author = "zyrridian"
    t.version = "11.5"
    t.console = true

    t.window.title = "RPG Demo"
    t.window.icon = nil
    t.window.width = 1024
    t.window.height = 768
    t.window.borderless = false
    t.window.resizable = false
    t.window.minwidth = 1024
    t.window.minheight = 768
    t.window.fullscreen = false
    t.window.fullscreentype = "desktop"
    t.window.vsync = 1
    t.window.msaa = 0
    t.window.highdpi = false

    t.audio.mic = false
    t.audio.mixwithsystem = true
end