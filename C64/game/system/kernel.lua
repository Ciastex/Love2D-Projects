Object = require("libs.object")
Kernel = Object:extend()

require("game.system.bootsequence")
require("screen.terminal.console")
require("screen.color")

function Kernel:load()
    self.display_shader = love.graphics.newShader("resources/shaders/crt.fs")
    self.display_canvas = love.graphics.newCanvas()
end

function Kernel:new()
    self:load()
    self.console = Console(Color(0,255,0), Color(0,0,0), 0, 0, 16, function(string) self:handleCommand(string) end)

    coroutine.run(
        function()
            self.bootsequence = BootSequence(self.console, 
                function()
                    self.console:setfg(127, 127, 127, 255)
                    coroutine.run(
                        function()
                            self.console:puts("> ")
                        end
                    )
                end
            )
        end
    )
end

function Kernel:update(dt)
    self.console:update(dt)
end

function Kernel:draw()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setCanvas(self.display_canvas)
    self.console:draw()
    love.graphics.setCanvas()

    love.graphics.setShader(self.display_shader)
    love.graphics.draw(self.display_canvas)
    love.graphics.setShader()
end

function Kernel:keypressed(key, scancode, isrepeat)
    self.console:keypressed(key, scancode, isrepeat)
end

function Kernel:keyreleased(key)
    self.console:keyreleased(key)
end

function Kernel:textinput(text)
    self.console:textinput(text)
end

function Kernel:handleCommand(string)
    coroutine.run(
        function()
            if string == "DEBUG" then
                self.console.dialogs.guru:show("LOW-LEVEL SYSTEM ROUTINE ACTIVE\nUNSUPPORTED!", 3000)
                coroutine.waitForSignal(coroutine.signals.DIALOG_HIDDEN)
            end
            self.console:puts("> ")
        end
    )
end