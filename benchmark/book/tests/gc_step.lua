local count = ...
print("<GC empty test> count = ", count)

local start = os.clock()
local collectgarbage = collectgarbage

local x = 0
local res
local cycles = 0
for i=1,count do
  x = x + 1
  local res = collectgarbage("step")
  if res == true then
    cycles = cycles + 1
  end
end

local elapsed = os.clock() - start
print(string.format("clock = %f  x = %d GC-cycles = %d", elapsed, x, cycles))
return elapsed