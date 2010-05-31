local count = ...
print("<string concatenation test> count = ", count)

local start = os.clock()
local x = 0
local y = 0

for i=1,count do
  x = x + 1
  y = "ABC" .. i
end

local elapsed = os.clock() - start
print(string.format("clock = %f  x = %d", elapsed, x))
return elapsed
