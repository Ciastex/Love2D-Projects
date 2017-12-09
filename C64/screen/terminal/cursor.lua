Object = require("libs.object")

Cursor = Object:extend()

local ticks = 0

function Cursor:new(base_x, base_y, width, height, color, blink_interval)
    self.base_x = base_x
    self.base_y = base_y
    self.width = width
    self.height = height
    self.color = color
    self.blink_interval = blink_interval
    
    self.current_x = 0
    self.current_y = 0
end

function Cursor:update(dt)
    ticks = ticks + (1000 * dt)
    
    if ticks >= self.blink_interval then
        ticks = 0
        
        if self.color.a > 0 then
            self.color.a = 0
        else
            self.color.a = 200
        end
    end
end

function Cursor:draw()
    love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
    
    local target_x = (self.base_x * self.width) + (self.current_x * self.width)
    local target_y = (self.base_y * self.height) + (self.current_y * self.height) - 1
    love.graphics.rectangle("fill", target_x, target_y, self.width, self.height)
end

function Cursor:setXY(x, y)
    self.current_x = x
    self.current_y = y
end