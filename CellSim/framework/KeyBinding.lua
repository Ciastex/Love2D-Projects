KeyBinding = Object:extend()

function KeyBinding:new(keys, callback, oneShot)
    self.keys = keys
    self.callback = callback
    self.oneShot = oneShot
    self.wasPressedLastTime = false
    self.waitingFor = nil
end

function KeyBinding:setWaitingFor(keyBinding)
    self.waitingFor = keyBinding 
end

function KeyBinding:isPressed()
    local result = true

    for i = 1, #self.keys do
        if not love.keyboard.isDown(self.keys[i]) then
            result = false
            break
        end
    end

    return result
end

function KeyBinding:hasKey(key)
    return table.includes(self.keys, key)
end

function KeyBinding:hasAnotherBindingsKeys(otherBinding)
    for k, v in pairs(otherBinding.keys) do
        if not self:hasKey(v) then return false end
    end

    return true
end