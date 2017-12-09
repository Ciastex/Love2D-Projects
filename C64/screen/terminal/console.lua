require("screen.color")
require("screen.terminal.cursor")
require("screen.dialogs.guru_meditation")

Object = require("libs.object")
Console = Object:extend()

function Console:load(char_width)
    self.font = _G.managers.font:get("terminal")
    
    self.font:setFilter("nearest", "nearest", 0)
    self.font_height = self.font:getHeight('A')
    self.font_width = self.font:getWidth('A')
end

function Console:new(fg, bg, frame_cols, frame_rows, char_width, accept_input_handler)
    self:load(char_width)

    self.columns = math.ceil(love.graphics.getWidth() / self.font_width)
    self.rows = math.ceil(love.graphics.getHeight() / self.font_height)

    self.frame_cols = frame_cols
    self.frame_rows = frame_rows

    self.frame_color = fg:toRGBA()

    self.actual_columns = math.ceil(self.columns - (self.frame_cols * 2))
    self.actual_rows = math.ceil(self.rows - (self.frame_rows * 2))

    self.cursor = Cursor(frame_cols + 1, frame_rows + 1, self.font_width, self.font_height, fg:toRGBA(), 350)
    self.input_enabled = true

    self.fg = fg
    self.curfg = fg

    self.bg = bg
    self.curbg = bg

    self.char_width = char_width
    self.current_x = 0
    self.current_y = 0
    self.vgabuffer = { }
    self.visual = { }
    self.inputbuffer = ""

    self.cursor_canvas = love.graphics.newCanvas()

    self.dialogs = {}
    self.dialogs.guru = GuruMeditiationDialog(self, {x = 2, y = 2}, 1, "HACKING DETECTED", 0)
    
    self.widgets = {}
    self.widgets.countdown = CountdownWidget((self.actual_columns * self.font_width) - 100, self.font_height * 2, Color(255, 255, 0))

    for y = 1, self.actual_rows do
        self.vgabuffer[y] = { }
        for x = 1, self.actual_columns do
            self.vgabuffer[y][x] = { character = ' ', fg = self.fg }
        end
    end   

    self.accept_input_handler = accept_input_handler or (
        function(string) 
            if #string > 0 then
                coroutine.run(
                    function()
                        if string:upper() == "HELP" then
                            self:putTypedString("THERE IS NO HELP.\n\n")
                        else
                            self:putTypedString("? SYNTAX ERROR.\n\n")
                        end

                        coroutine.waitForSignal(coroutine.signals.TYPED_STRING_DONE)
                        self:putTypedString("> ")
                    end
                )
            end
        end
    )    
end

function Console.colors_equal(color1, color2)
    if not color1 or not color2 then return false end
    return (color1.r == color2.r and color1.g == color2.g and color1.b == color2.b and color1.a == color2.a)
end

function Console:updateVisual()
    self.visual = { }

    local previous_cell = self.vgabuffer[1][1]
    local segments = { }
    local segment = { s = "", fg = Color(255, 255, 255, 255) }
    for y = 1, self.actual_rows do
        for x = 1, self.actual_columns do
            if self.colors_equal(previous_cell.fg, self.vgabuffer[y][x].fg) then
                segment.s = segment.s..self.vgabuffer[y][x].character
                segment.fg = self.vgabuffer[y][x].fg

                previous_cell = self.vgabuffer[y][x]
            else
                table.insert(segments, segment)

                segment = { s = "", fg = Color(255, 255, 255, 255) }
                segment.s = segment.s..self.vgabuffer[y][x].character
                segment.fg = self.vgabuffer[y][x].fg

                previous_cell = self.vgabuffer[y][x]
            end
        end
    end

    if #segment.s > 0 then
        table.insert(segments, segment)
    end

    local total_indices = 0
    for i, v in ipairs(segments) do
        local newstring = ""
        for j = 1, #v.s do       
            total_indices = total_indices + 1

            if total_indices > self.actual_columns - 1 then
                if #newstring == 0 then
                    newstring = " " .. newstring .. v.s:sub(j,j)
                else
                    newstring = newstring .. "\n" .. v.s:sub(j,j)
                end
                total_indices = 0
            else
                newstring = newstring .. v.s:sub(j,j)
            end
        end

        if i == 1 then newstring = " "..newstring end
        v.s = newstring
    end

    for i, v in ipairs(segments) do
        table.insert(self.visual, v.fg:toRGBA2())
        table.insert(self.visual, v.s)
    end
end

function Console:update(dt)
    self:updateVisual()
    self.cursor:update(dt)

    for i, v in pairs(self.dialogs) do
        self.dialogs[i]:update(dt)
    end
    
    for i, v in pairs(self.widgets) do
        self.widgets[i]:update(dt)
    end
end

function Console:draw()   
    self:drawFrame()
    self:drawOutput()

    if self.input_enabled then
        self.cursor:draw()
    end

    for i, v in pairs(self.dialogs) do
        self.dialogs[i]:draw()
    end
    
    for i, v in pairs(self.widgets) do
        self.widgets[i]:draw()
    end
end

function Console:drawFrame()
    love.graphics.clear(self.frame_color.r, self.frame_color.g, self.frame_color.b, self.frame_color.a)
    love.graphics.setColor(self.curbg.r, self.curbg.g, self.curbg.b, self.curbg.a)
    love.graphics.rectangle(
        "fill",
        self.char_width * self.frame_cols,
        self.char_width * self.frame_rows,
        self.actual_columns * self.char_width,
        self.actual_rows * self.font_height
    )
end

function Console:drawOutput()
    love.graphics.setFont(self.font)

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print(self.visual, (self.frame_cols) * self.char_width, (self.frame_rows + 1) * self.font_height)
end

function Console:setfg(r, g, b, a)
    self.curfg = Color(r, g, b, a)

    self.cursor.color.r = r
    self.cursor.color.g = g
    self.cursor.color.b = b
end

function Console:setframecolor(r, g, b, a)
    self.frame_color = Color(r, g, b, a):toRGBA()
end

function Console:resetframecolor()
    self.frame_color = self.fg
end

function Console:setbg(r, g, b, a)
    self.curbg = Color(r, g, b, a):toRGBA()
end

function Console:resetbg()
    self.curbg = self.bg
end

function Console:resetfg()
    self.curfg = self.fg

    self.cursor.color.r = self.fg.r
    self.cursor.color.g = self.fg.g
    self.cursor.color.b = self.fg.b
end

function Console:setAllCellsToColor(r, g, b, a)
    for y = 1, self.actual_rows do
        for x = 1, self.actual_columns do
            self.vgabuffer[y][x].fg = Color(r, g, b, a)
        end
    end
end

function Console:putc(c)
    if c == "\n" then
        self.current_x = 0
        self.current_y = self.current_y + 1

        self:updateCursor()
    end

    if c == "\r" then
        self.current_x = 0
        self:updateCursor()
    end

    if (c  ~= "\n") and (c ~= "\r") then
        self.vgabuffer[self.current_y + 1][self.current_x + 1].character = c
        self.vgabuffer[self.current_y + 1][self.current_x + 1].fg = self.curfg
        self.current_x = self.current_x + 1
    end

    if self.current_x >= self.actual_columns - 2 then
        self.current_x = 0
        self.current_y = self.current_y + 1
    end

    if self.current_y >= self.actual_rows - 2 then
        self:scrollLineUp()
    end

    self:updateCursor()
end

function Console:scrollLineUp()
    for y = 2, self.actual_rows do
        for x = 1, self.actual_columns do
            self.vgabuffer[y - 1][x].character = self.vgabuffer[y][x].character
            self.vgabuffer[y - 1][x].fg = self.vgabuffer[y][x].fg
        end
    end

    for x = 1, self.actual_columns do
        self.vgabuffer[self.actual_rows - 1][x].character = ' '
        self.vgabuffer[self.actual_rows - 1][x].fg = self.curfg
    end

    self.current_x = 0
    self.current_y = self.current_y - 1
end

function Console:puts(text)
    for i = 1, #text do
        local c = text:sub(i, i)
        self:putc(c)
    end
end

function Console:putTypedString(text, interval)
    local intval = interval or 0

    coroutine.run(function()
            for i = 1, #text do
                local c = text:sub(i, i)

                self:putc(c)

                if c == '.' then
                    coroutine.waitForSeconds((intval * 5) or 0.05)
                else
                    coroutine.waitForSeconds(intval or 0)
                end
            end

            coroutine.signal(
                coroutine.signals.TYPED_STRING_DONE
            )
        end)
end

function Console:setXY(x, y)
    if x < 0 or x >= self.actual_columns - 1 then
        error("Invalid X coordinate provided for shell.")
    end

    if y < 0 or y >= self.actual_rows - 1 then
        error("Invalid Y coordinate provided for shell.")
    end

    self.current_x = math.floor(x)
    self.current_y = math.floor(y)

    self:updateCursor()
end

function Console:updateCursor()    
    self.cursor:setXY(self.current_x, self.current_y)
end

function Console:backspace()
    self.current_x = self.current_x - 1

    if self.current_x < 0 then
        self.current_x = self.actual_columns - 2 - 1
        if self.current_y - 1 >= 0 then
            self.current_y = self.current_y - 1
        else
            self.current_y = 0
            self.current_x = 0
        end
    end

    self.vgabuffer[self.current_y + 1][self.current_x + 1].character = ' '

    if #self.inputbuffer > 0 then
        self.inputbuffer = self.inputbuffer:sub(1, #self.inputbuffer - 1)
    end

    self:updateCursor()
end

function Console:acceptInput()
    self.accept_input_handler(self.inputbuffer)
    self.inputbuffer = ""
end

function Console:textinput(text)
    if not self.input_enabled then return end

    self:playKeyPressSound()

    self.inputbuffer = self.inputbuffer .. text:upper()
    self:putc(text:upper())
end

function Console:keyreleased(key)

end

function Console:keypressed(key, scancode, isrepeat)
    if not self.input_enabled then return end

    if key == "backspace" then
        self:backspace()
    end

    if key == "return" then
        self:puts("\n")
        self:acceptInput()
    end

    if key == "up" then
        if self.current_y - 1 >= 0 then
            self:setXY(self.current_x, self.current_y - 1)
            self.inputbuffer = ""
        end        
    end

    if key == "down" then
        if self.current_y + 1 < self.actual_rows - 2 then
            self:setXY(self.current_x, self.current_y + 1)
        else 
            self:scrollLineUp()
            self:setXY(self.current_x, self.actual_rows - 3)
        end
        self.inputbuffer = ""
    end

    if key == "left" then
        if self.current_x - 1 >= 0 then
            self:setXY(self.current_x - 1, self.current_y)
            self.inputbuffer = ""
        end
    end

    if key == "right" then
        if self.current_x + 1 < self.actual_columns - 2 then
            self:setXY(self.current_x + 1, self.current_y)
            self.inputbuffer = ""
        end
    end
end

function Console:playKeyPressSound()
    _G.managers.sound:playSound("input")
end
