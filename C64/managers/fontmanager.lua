Object = require("libs.object")
FontManager = Object:extend()

function FontManager:new(directory)
    self.directory = directory
    
    self.font_metadata = { }
    self.fonts = { }
end

function FontManager:loadFont(identifier, filename, size)
    self.fonts[identifier] = love.graphics.newFont(self.directory..filename, size)
    
    self.font_metadata[identifier] = { 
        fullpath = self.directory..filename,
        size = size
    }
end

function FontManager:resizeFont(identifier, new_size)
    self.fonts[identifier] = love.graphics.newFont(self.font_metadata, new_size)
    self.font_metadata[identifier].size = new_size
end

function FontManager:get(identifier)
    return self.fonts[identifier]
end