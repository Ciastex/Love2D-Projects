InputManager = Object:extend()

function InputManager:new()
    self.bindings = { }
end

function InputManager:update(dt)
    for i, binding in ipairs(self.bindings) do
        if binding:isPressed() then            
            if binding.waitingFor and binding.waitingFor:isPressed() then
                goto continue
            end
            
            if binding.oneShot then
                if binding.wasPressedLastTime == true then
                    goto continue
                else
                    binding.wasPressedLastTime = true
                    binding:callback()
                end                
            else               
                binding:callback()
            end
        else
            if binding.wasPressedLastTime then
                binding.wasPressedLastTime = false
            end
        end
        ::continue::
    end
end

function InputManager:existsMoreComplexThan(keyBinding)
    for i, binding in ipairs(self.bindings) do
        if binding:hasAnotherBindingsKeys(keyBinding) then return true, binding end
    end
    
    return false
end

function InputManager:isMostComplex(keyBinding)
    local result = false
    local lessComplex = nil
    
    for i, binding in ipairs(self.bindings) do
        if keyBinding:hasAnotherBindingsKeys(binding) then 
            result = true
            lessComplex = binding
        end
    end
    
    return result, lessComplex
end

function InputManager:createKeyBinding(keys, callback, oneShot)
    local binding = KeyBinding(keys, callback, oneShot)
    
    local isMostComplex, lessComplex = self:isMostComplex(binding)
    
    if isMostComplex then
        lessComplex:setWaitingFor(binding)
    else
       local exists, complex = self:existsMoreComplexThan(binding) 
       
        if exists and not binding.waitingFor then
            binding:setWaitingFor(complex)
        end
    end

    table.insert(self.bindings, binding)
end