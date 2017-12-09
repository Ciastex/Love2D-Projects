Object = require("libs.object")
CountdownWidget = Object:extend()

require("screen.color")

function CountdownWidget:new(x, y, color, finished_callback)
    self.x = x
    self.y = y    
    self.color = color or Color(255, 255, 255, 255)
    self.finished_callback = finished_callback
    self.text = love.graphics.newText( _G.managers.font:get("countdown"), "chuj")

    self.active = false
    self.limit = 0
end

function CountdownWidget:draw()
    if not self.active then return end

    love.graphics.setColor(unpack(self.color:toRGBA2()))
    love.graphics.draw(self.text, self.x - (self.text:getWidth() / 2), self.y - (self.text:getHeight() / 2))
end

function CountdownWidget:update(dt)
    if not self.active then return end

    if self.limit > 0 then
        self.limit = self.limit - (1000 * dt)
        self.text:set(string.format("%.2f", self.limit / 1000))
    else
        self.active = false
        if self.finished_callback then 
            self.finished_callback()
            self.finished_callback = nil
        end
    end
end

function CountdownWidget:startCountdown(limit, finished_callback)
    self.limit = limit
    self.active = true

    self.finished_callback = finished_callback
end

