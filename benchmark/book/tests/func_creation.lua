local count = ...
print("<function creation test> count = ", count)

local start = os.clock()
local x = 0
local y

local div = 1.1
for i=1,count do
  x = x + 1
  y = function(a) a = a + 1 end
end

local elapsed = os.clock() - start
print(string.format("clock = %f  x = %d", elapsed, x))
return elapsed
