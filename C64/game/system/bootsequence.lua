Object = require("libs.object")
BootSequence = Object:extend()

local function getFileLines(path)
  local file = io.open(path, "r")
  
  if not file then 
    error("*** FRAMEWORK: Requested file cannot be found.")
  else
    file:close()
    return io.lines(path)
  end
end

local function getBootProcedureContent()
  local parsedLines = { }

  for line in getFileLines("resources/text/bootsequence.txt") do
    if line ~= nil and line ~= "" then
      local splitLine = line:split('|')
      local parameters = splitLine[1]:split(' ')
      
      local t = { }
      t["type"] = parameters[1]
      t["time"] = tonumber(parameters[2])
      if parameters[3] and parameters[3] == "$" then
        t["newline"] = true
      else
        t["newline"] = false
      end
      table.remove(splitLine, 1)
      t["content"] = table.concat(splitLine, '|')
      t["content"] = t["content"]:upper()
      
      table.insert(parsedLines, t)
    end
  end
  
  return parsedLines
end

function BootSequence:new(console, finishCallback)
  self.console = console
  
  self.finishCallback = finishCallback or function() console:puts("> ") end
  
  if _G.isDebugMode then
    finishCallback()
    return
  end
  
  local bootProcedureLines = getBootProcedureContent()
  
  local co = coroutine.create(
    function()
      for index, line in pairs(bootProcedureLines) do
        local actualContent = ""
        
        if line["content"] == "[%MEMORY]" then
          actualContent = "64K" --tostring(kernel:getAvailableMemory())
        elseif line["content"] == "[%TIME]" then
          actualContent = os.date('%c')
        else
          actualContent = line["content"]
        end
        
        if line["type"] == "TYPED" then
          self.console:putTypedString(actualContent, line["time"])
          coroutine.waitForSignal(coroutine.signals.TYPED_STRING_DONE)
        elseif line["type"] == "WAIT" then
          self.console:puts(actualContent)
          coroutine.waitForSeconds(line["time"])
        end
        
        if line["newline"] then
          self.console:putc('\n')
        end
      end

      if not self.finishCallback then return else self.finishCallback() end
    end
  )
  coroutine.resume(co)
end