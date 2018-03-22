Body = Object:extend()

function Body:new(width, height, scale)
    self.width = width
    self.height = height
    self.scale = scale or 2
    
    self.xpos = (love.graphics.getWidth() / 2) - (self.width * self.scale / 2)
    self.ypos = (love.graphics.getHeight() / 2) - (self.height * self.scale / 2)

    self.space = { }
    for y = 1, self.height do
        self.space[y] = { }
        for x = 1, self.width do
            self.space[y][x] = 0
        end
    end
    
    self.canvas = love.graphics.newCanvas(self.width * self.scale, self.height * self.scale)
end

function Body:createCell(x, y)
    local cell = Cell(self, x, y)
    cell.dna[1] = "A"
    self:setCell(x, y, cell)
end

function Body:setCell(x, y, cell)
    if x > self.width or x <= 0 then return end
    if y > self.height or y <= 0 then return end
    
    self.space[y][x] = cell
end

function Body:update(dt)
    for y = 1, self.height do
        for x = 1, self.width do
            if type(self.space[y][x]) ~= "number" and self.space[y][x].update and type(self.space[y][x].update) == "function" then
                self.space[y][x]:update(dt)
            end
        end
    end
end

function Body:isEmpty(x, y)
    return x <= self.width and x > 0 and y <= self.height and y > 0 and self.space[y][x] == 0
end

function Body:draw()
    love.graphics.clear(0, 0, 0)

    self:drawFrame()
    self:drawCells()
end

function Body:drawCells()
    love.graphics.setCanvas(self.canvas)
    for y = 1, self.height do
        for x = 1, self.width do
            if type(self.space[y][x]) ~= "number" and self.space[y][x].draw and type(self.space[y][x].draw) == "function" then
                self.space[y][x]:draw()
            end
        end
    end
    love.graphics.setCanvas()
    
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.canvas, self.xpos, self.ypos)
end

function Body:removeCell(x, y)
    self.space[y][x] = 0
end

function Body:drawFrame()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setLineWidth(1)
    love.graphics.setLineStyle("rough")
    love.graphics.rectangle("line", (self.xpos) + self.scale - 1, (self.ypos) + self.scale - 2, (self.width * self.scale) - self.scale + 3, (self.height * self.scale) - self.scale + 3)
end