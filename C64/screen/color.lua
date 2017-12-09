Object = require("libs.object")
Color = Object:extend()

function Color:new(r, g, b, a)
    self.r = r
    self.g = g
    self.b = b
    self.a = a or 255
end

function Color:toRGBA()
    return { r = self.r, g = self.g, b = self.b, a = self.a }
end

function Color:toRGBA2()
    return { self.r, self.g, self.b, self.a }
end