local count = ...
print("<function pcall test> count = ", count)

local function func1(x)
  return x + 1
end

local start = os.clock()

local x = 0
local res
local pcall = pcall

for i=1,count do
  res, x = pcall(func1, x)
end

local elapsed = os.clock() - start
print(string.format("clock = %f  x = %d", elapsed, x))
return elapsed
