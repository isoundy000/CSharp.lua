require("strict")

package.path = package.path .. ";../../../CSharp.lua/Coresystem.lua/?.lua"
package.path = package.path .. ";../?.lua"

package.path = package.path .. ";CSharp.lua/Coresystem.lua/?.lua"
package.path = package.path .. ";test/BridgeNetTests/?.lua;"

local now = 0
local timeoutQueue

local conf = {
  setTimeout = function (f, delay)
    if not timeoutQueue then
      timeoutQueue = System.TimeoutQueue()
    end
    return timeoutQueue:Add(now, delay, f)
  end,
  clearTimeout = function (t)
    timeoutQueue:Erase(t)
  end
}
require("All")("", conf)          -- coresystem.lua/All.lua

local modules = {
  "BridgeAttributes",
  "BridgeTestNUnit",
  "ClientTestHelper",
  "Batch1",
  "Tests"
}

for i = 1, #modules do
  local name = modules[i]
  require(name .. "/out/manifest")(name .. "/out")
end

local main = System.Reflection.Assembly.GetEntryAssembly().getEntryPoint()
main:Invoke()

while true do
  local nextExpiration = timeoutQueue:getNextExpiration()
  if nextExpiration ~= timeoutQueue.MaxExpiration then
    now = nextExpiration
    timeoutQueue:RunLoop(now)
  else
    break
  end
end
