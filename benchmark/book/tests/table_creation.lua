local count = ...
print("<table creation test> count = ", count)

local start = os.clock()
local x = 0
local y

local div = 1.1
for i=1,count do
  x = x + 1
  y = {i}
end

local elapsed = os.clock() - start
print(string.format("clock = %f  x = %d", elapsed, x))
return elapsed
