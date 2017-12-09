Object = require("libs.object")
GuruMeditiationDialog = Object:extend()

local ticks = 0
local total_ticks = 0

function GuruMeditiationDialog:new(console, padding, border_thickness, text, hide_after)
    self.console = console
    self.padding = padding
    
    self.text = love.graphics.newText(console.font, text)

    self.width = ((padding.x) * console.font_width) + (self.text:getWidth())
    self.height = ((padding.y) * console.font_height) + (self.text:getHeight())

    self.border_thickness = border_thickness or console.font_width
    self.active = true

    self.color = console.fg:toRGBA()
    self.textcolor = console.fg:toRGBA()
    self.textcolor.a = 0

    self.base_x = (love.graphics.getWidth() / 2) - (self.width / 2)
    self.base_y = (love.graphics.getHeight() / 2) - (self.height / 2)

    self.hide_after = hide_after
end

function GuruMeditiationDialog:draw()
    if not self.active then return end

    love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
    love.graphics.rectangle("fill", self.base_x, self.base_y, self.width, self.height)
    love.graphics.setColor(self.console.curbg.r, self.console.curbg.g, self.console.curbg.b, self.console.curbg.a)
    love.graphics.rectangle("fill", self.base_x + (self.border_thickness * self.console.font_width), self.base_y + (self.border_thickness * self.console.font_height), self.width - (self.border_thickness * 2 * self.console.font_width), self.height - (self.border_thickness * 2 * self.console.font_height))


    love.graphics.setColor(self.textcolor.r, self.textcolor.g, self.textcolor.b, self.textcolor.a)
    love.graphics.draw(
        self.text,
        self.base_x + (self.width / 2) - (self.text:getWidth() / 2),
        self.base_y + (self.height / 2) - (self.text:getHeight() / 2)
    )
end

function GuruMeditiationDialog:update(dt)
    if not self.active then return end

    ticks = ticks + (1000 * dt)
    total_ticks = total_ticks + (1000 * dt)

    if ticks >= 500 then
        ticks = 0

        if self.textcolor.a > 0 then
            self.textcolor.a = 0
        else
            self.textcolor.a = 255
            _G.managers.sound:playSound("dialog_blink2")
        end
    end

    if total_ticks > self.hide_after then
        self.active = false
        coroutine.signal(coroutine.signals.DIALOG_HIDDEN)
    end
end

function GuruMeditiationDialog:show(text, hide_after, color, textcolor)
    self.text = love.graphics.newText(self.console.font, text)
    
    self.width = ((2 + self.padding.x) * self.console.font_width) + (self.text:getWidth())
    self.height = ((2 + self.padding.y) * self.console.font_height) + (self.text:getHeight())
    self.base_x = (love.graphics.getWidth() / 2) - (self.width / 2)
    self.base_y = (love.graphics.getHeight() / 2) - (self.height / 2)
    self.color = color or self.color
    self.textcolor = textcolor or self.textcolor
    self.textcolor.a = 0
    self.hide_after = hide_after

    total_ticks = 0
    self.active = true
end