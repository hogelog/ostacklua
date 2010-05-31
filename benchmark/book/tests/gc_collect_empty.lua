local count = ...
print("<GC empty test> count = ", count)

local start = os.clock()
local collectgarbage = collectgarbage

local x = 0
local res
for i=1,count do
  x = x + 1
  collectgarbage("collect")
end

local elapsed = os.clock() - start
print(string.format("clock = %f  x = %d", elapsed, x))
return elapsed
