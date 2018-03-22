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
        size = size,
        is_bitmap = false
    }
end

function FontManager:loadBitmapFont(identifier, filename, glyphs, lineHeight, spacing)
    self.fonts[identifier] = love.graphics.newImageFont(self.directory..filename, glyphs, spacing)
    
    self.font_metadata[identifier] = {
        fullpath = self.directory..filename,
        size = "BITMAP",
        is_bitmap = true
    }
end

function FontManager:resizeFont(identifier, new_size)
    if not self.fonts[identifier] then return end
    if self.font_metadata[identifier].is_bitmap then return end
    
    self.fonts[identifier] = love.graphics.newFont(self.font_metadata[identifier].fullpath, new_size)
    self.font_metadata[identifier].size = new_size
end

function FontManager:get(identifier)
    return self.fonts[identifier]
end