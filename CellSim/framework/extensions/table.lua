function table.reverse(t)
    if not t then return end

    local rev = {}
    local count = #t

    for i, v in ipairs(t) do
        rev[count + 1 - i] = v
    end

    return rev
end

function table.filter(t, func)
    if not func or not t then return end 

    local res = { }

    for k, v in pairs(t) do
        if func(k, v) then
            res[k] = v
        end
    end

    return res
end

function table.map(t, func)
    if not func or not t then return end

    local res = { }
    for k, v in pairs(t) do
        local fk, fv = func(k, v)
        res[fk] = fv
    end

    return res
end

function table.first(t, func)
    if not func or not t then return end

    for k, v in pairs(t) do
        if func(k, v) then return t[k] end
    end
end

function table.count(t, func)
    if not func or not t then return end

    local i = 0
    for k, v in pairs(t) do
        if func(k, v) then i = i + 1 end
    end

    return i
end

function table.keyOf(t, val)
    for k, v in pairs(t) do
        if v == val then return k end
    end
end

function table.includes(t, val)
    for k, v in pairs(t) do
        if v == val then return true end
    end
    
    return false
end

function table.swap(t, i1, i2)
    if t[i1] and t[i2] then
        local tmp = t[i2]
        t[i2] = t[i1]
        t[i1] = tmp
    end
end

function table.foreach(t, func)
    if not func or not t then return end

    for k, v in pairs(t) do
        func(k, v)
    end
end