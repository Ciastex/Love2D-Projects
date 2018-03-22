local WAITING_ON_TIME = { }
local WAITING_ON_SIGNAL = { }
local CURRENT_TIME = 0

_coroutine_resume = coroutine.resume
function coroutine.resume(...)
	local state,result = _coroutine_resume(...)
	if not state then
		error(tostring(result), 2)
	end
	return state,result
end

function coroutine.signal(signalName)
  local threads = WAITING_ON_SIGNAL[signalName]
  if threads == nil then return end

  WAITING_ON_SIGNAL[signalName] = nil
  for _, co in ipairs(threads) do
    coroutine.resume(co)
  end
end

function coroutine.waitForSeconds(seconds)
  local co = coroutine.running()
  assert(co ~= nil, "The main thread cannot wait.")

  local wakeupTime = CURRENT_TIME + seconds
  WAITING_ON_TIME[co] = wakeupTime

  return coroutine.yield(co)
end

function coroutine.waitForSignal(signalName)
  local co = coroutine.running()
  assert(co ~= nil, "The main thread cannot wait.")

  if WAITING_ON_SIGNAL[signalStr] == nil then
    WAITING_ON_SIGNAL[signalName] = { co }
  else
    table.insert(WAITING_ON_SIGNAL[signalName], co)
  end

  return coroutine.yield()
end

function coroutine._wakeUpWaitingThreads(deltaTime)
  CURRENT_TIME = CURRENT_TIME + deltaTime
  local threadsToWake = { }
  
  for co, wakeupTime in pairs(WAITING_ON_TIME) do
    if wakeupTime < CURRENT_TIME then
      table.insert(threadsToWake, co)
    end
  end

  for _, co in ipairs(threadsToWake) do
    WAITING_ON_TIME[co] = nil
    coroutine.resume(co)
  end
end

function coroutine.run(func)
  local co = coroutine.create(func)
  return coroutine.resume(co)
end

coroutine.signals = { 
    TYPED_STRING_DONE = "typedStringDone",
    DIALOG_HIDDEN = "dialogHidden",
    APPMAN_PROGRAM_FINISHED = "appmanProgramFinished",
    APPMAN_FINISHED = "appmanFinished",
    APPMAN_APP_KILLED = "appmanAppKilled",
    SANDBOX_CODE_FINISHED = "sandboxCodeFinished"
}