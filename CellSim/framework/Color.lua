Color = Object:extend()

function Color:new(r, g, b, a)
    self.r = r
    self.g = g
    self.b = b
    self.a = a or 255

    local mt = getmetatable(self)
    mt.__eq = function(o1, o2) 
        if not o1 or not o2 then return false end
        return o1.r == o2.r and o1.g == o2.g and o1.b == o2.b and o1.a == o2.a
    end
    setmetatable(self, mt)
end

function Color:toRGBA()
    return { r = self.r, g = self.g, b = self.b, a = self.a }
end

function Color:toRGBA2()
    return { self.r, self.g, self.b, self.a }
end

function Color:loveCompat()
    return self.r, self.g, self.b, self.a
end

function Color:clone()
   return Color(self.r, self.g, self.b, self.a) 
end

-- 0 <= h <= 360; 0 <= s <= 1; <- same for v
function Color.fromHSV(h, s, v)
    local c = s * v
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c

    local color = Color(0, 0, 0)
    if h >= 0 and h < 60 then
        color.r = c
        color.g = x
        color.b = 0
    elseif h >= 60 and h < 120 then
        color.r = x
        color.g = c
        color.b = 0
    elseif h >= 120 and h < 180 then
        color.r = 0
        color.g = c
        color.b = x
    elseif h >= 180 and h < 240 then
        color.r = 0
        color.g = x
        color.b = c
    elseif h >= 240 and h < 300 then
        color.r = x
        color.g = 0
        color.b = c
    elseif h >= 300 and h < 360 then
        color.r = c
        color.g = 0
        color.b = x
    end
    
    return color
end