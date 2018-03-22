SoundManager = Object:extend()

function SoundManager:new(directory)
    self.directory = directory
    self.sources = { }
end

function SoundManager:loadSound(identifier, filename)
    self.sources[identifier] = love.audio.newSource(self.directory..filename, "static")
end

function SoundManager:playSound(identifier)
    coroutine.run(
        function()
            self.sources[identifier]:play()
        end
    )
end