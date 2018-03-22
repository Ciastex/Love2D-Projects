Cell = Object:extend()

local CELL_GENOME = {"A", "C", "E", "I", "K", "M", "Z"}
local DIRECTIONS = { 
    { x = 0, y = -1}, 
    { x = 0, y = 1 },
    { x = -1, y = 0 },
    { x = 1, y = 0 }
}

function Cell:new(body, x, y)
    self.body = body or error("Must set cell's body.")
    self.color = Color(math.random(50, 255), math.random(50, 255), math.random(50, 255))
    
    self.x = x or error("Must set cell's X")
    self.y = y or error("Must set cell's Y")
    
    self.dna = { }
    self.lifeSpan = 0
    self.strength = 0
    self.antigens = { }

    self:generateRandomDNA()
    self:generateProperties()
end

function Cell:generateRandomDNA()
    for i = 1, 4 do
        self.dna[i] = CELL_GENOME[math.random(1, #CELL_GENOME)]
    end
end

function Cell:generateProperties()
    self.lifeSpan = math.random(100, 600)
    self.strength = math.random(1, 1000)
end

function Cell:mutate()
    local targetIndex = math.random(1, #self.dna)
    self.dna[targetIndex] = CELL_GENOME[math.random(1, #CELL_GENOME)]
    
    if math.random(1, 10000) > 9980 then
        self.strength = self.strength + 1
    end
    
    if math.random(1, 1000) > 999 then
        -- table.insert(self.antigens, self:generateRandomDNA())
    end
    
    self.color = Color(math.random(50, 255), math.random(50, 255), math.random(50, 255))
end

function Cell:divide()
    local d = DIRECTIONS[math.random(1, #DIRECTIONS)]
    if not self.body:isEmpty(self.x + d.x, self.y + d.y) then 
        if self.x + d.x <= 0 or self.x + d.x > self.body.width or self.y + d.y <= 0 or self.y + d.y > self.body.height then return end
        
        local cell = self.body.space[self.y + d.y][self.x + d.x]
        if not cell then return end
        
        if cell.strength >= self.strength then return end
    end
    
    local cl = self:createClone(self.x + d.x, self.y + d.y)
    if math.random(1, 10000) > 9800 then
        cl:mutate()
    end
    
    self.body:setCell(self.x + d.x, self.y + d.y, cl)
end

function Cell:createClone(x, y)
    local clone = Cell(self.body, x, y)
    
    clone.dna = { }
    for _, v in pairs(self.dna) do
        table.insert(clone.dna, v)
    end    
    clone.color = self.color
    clone.strength = self.strength

    return clone
end

function Cell:findCancerousNeighbor()
    for _, d in ipairs(DIRECTIONS) do
        if not self.body:isEmpty(self.x + d.x, self.y + d.y) then
            if self.x + d.x <= 0 or self.x + d.x > self.body.width or self.y + d.y <= 0 or self.y + d.y > self.body.height then return false end
            local cell = self.body.space[self.y + d.y][self.x + d.x]
            
            if cell and not table.includes(cell.dna, "C") then
                return true, d
            end
        end
    end
    
    return false
end

function Cell:isSurrounded()
    for _, d in ipairs(DIRECTIONS) do
        if self.body:isEmpty(self.x + d.x, self.y + d.y) then
            return false
        end
    end
    
    return true
end

function Cell:update(dt)
    if self.lifeSpan == 0 then self:die() end
    
    if table.includes(self.dna, "A") then
        if table.includes(self.dna, "I") then
            if math.random(1, 1000) > 900 then
                self:divide()
            end
            
        else
            if math.random(1, 1000) > 950 then
                self:divide()
            end
        end
    end
    
    if table.includes(self.dna, "C") then  
        if table.includes(self.dna, "K") then
            self.lifeSpan = self.lifeSpan - (20 * dt)
        else
            self.lifeSpan = self.lifeSpan - (10 * dt)
        end            
    end
    
    if table.includes(self.dna, "E") then
        if math.random(1, 1000) > 900 then
            self.lifeSpan = self.lifeSpan + math.random(20, 80)
        end
    end
    
    if table.includes(self.dna, "M") then
        local hasCancerousNeighbor, d = self:findCancerousNeighbor()
        
        if hasCancerousNeighbor then
            self.body:removeCell(self.x + d.x, self.y + d.y)
        end
    end

    if table.includes(self.dna, "Z") then
        local d = DIRECTIONS[math.random(1, #DIRECTIONS)]
        if self.x + d.x > 0 and self.x + d.x <= self.body.width and self.y + d.y > 0 and self.y + d.y < self.body.height then
            
        end
    end
end

function Cell:die()
    self.body:removeCell(self.x, self.y)
end

function Cell:draw()
    love.graphics.setColor(self.color:loveCompat())
    love.graphics.rectangle("fill", (self.x * self.body.scale), (self.y * self.body.scale), self.body.scale, self.body.scale)
end