require("libs.coroutine")
require("libs.signals")

require("libs.extensions.string")

require("managers.soundmanager")
require("managers.fontmanager")

require("game.system.kernel")

_G.managers = { 
    sound = SoundManager("resources/sounds/"),
    font = FontManager("resources/fonts/")
}

function loadSounds()
    _G.managers.sound:loadSound("input", "input.wav")
    _G.managers.sound:loadSound("dialog_blink", "dialog_blink.wav")
    _G.managers.sound:loadSound("dialog_blink2", "dialog_blink2.wav")

    _G.managers.sound:loadSound("error", "error.wav")
end

function loadFonts()
    _G.managers.font:loadFont("terminal", "c64.ttf", 16)
    _G.managers.font:loadFont("countdown",  "c64.ttf", 36)
end

function love.load()
    -- if arg[#arg] == "-debug" then require("mobdebug").start() end
    loadSounds()
    loadFonts()

    love.keyboard.setKeyRepeat(true)
    
    kernel = Kernel()
end

function love.update(dt)
    coroutine._wakeUpWaitingThreads(dt)
    kernel:update(dt)
end

function love.keypressed(key, scancode, isrepeat)
    kernel:keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key)
    kernel:keyreleased(key)
end

function love.textinput(text)
    kernel:textinput(text)
end

function love.draw()
    kernel:draw()
end