function string:split(pat)
    local t = { } 
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = self:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t,cap)
        end
        last_end = e+1
        s, e, cap = self:find(fpat, last_end)
    end
    if last_end <= #self then
        cap = self:sub(last_end)
        table.insert(t, cap)
    end
    return t
end

function string:startsWith(what)
    return self:sub(1, self:len(what)) == what
end

function string:endsWith(what)
    return what == "" or self:match(what.."$")
end

function string:firstToUpper()
    return self:gsub("%a", string.upper, 1) 
end

function string:trim()
    return (self:gsub("^%s*(.-)%s*$", "%1")) 
end

function string:isAsciiChar()
    return self:len() == 1 and self:byte(1,1) <= 255
end

function string:occurences(char)
    local occs = { }
    local ct = 0
    
    for i = 1, #self do
        if self:sub(i, i) == char then
            ct = ct + 1
            table.insert(occs, i)
        end
    end
    
    return ct, occs
end

function string.makeTable(as_string, ...)
    local args = { ... }
    if args.length == 0 then return end

    function pad(string, length)
        local str = string
        while #str < length do
            str = str .. " "
        end

        return str
    end

    function maxStringLength(table)
        local max = 0

        for _,v in ipairs(table) do
            if max < #v then max = #v end
        end

        return max
    end

    function maxTableLength()
        local max = 0

        for _,v in ipairs(args) do
            if max < #v then max = #v end
        end

        return max
    end

    local padded = { }
    for _,v in ipairs(args) do
        local tbl = { }
        tbl.entries = { }
        tbl.max = 0

        for _,str in ipairs(v) do
            if #str > tbl.max then tbl.max = #str end
        end

        for _,str in ipairs(v) do
            if #str ~= tbl.max then
                table.insert(tbl.entries, pad(str, tbl.max))
            else
                table.insert(tbl.entries, str)
            end
        end
        table.insert(padded, tbl)
    end

    local finalOutput = ""
    if not as_string then finalOutput = { } end

    local maxTbl = maxTableLength()

    if as_string then
        for i = 1, maxTbl do
            for _,arr in ipairs(padded) do
                if arr.entries[i] then
                    finalOutput = finalOutput .. arr.entries[i] .. " "
                else
                    finalOutput = finalOutput .. pad("", arr.max) .. " "
                end
            end
            finalOutput = finalOutput .. "\n"
        end
    else
        for i = 1, maxTbl do
            local strv = ""
            for _,arr in ipairs(padded) do
                if arr.entries[i] then
                    strv = strv .. arr.entries[i] .. " "
                else
                    strv = strv .. pad("", arr.max)
                end
            end
            table.insert(finalOutput, strv)
        end
    end

    return finalOutput
end