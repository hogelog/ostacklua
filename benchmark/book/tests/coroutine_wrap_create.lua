local count = ...
print("<coroutine (wrap) create test> count = ", count)

local function func1(x)
  return x + 1
end

local start = os.clock()

local cowrap = coroutine.wrap

local x = 0
local co
for i=1,count do
  x = x + 1
  co = cowrap(func1)
end

local elapsed = os.clock() - start
print(string.format("clock = %f  x = %d", elapsed, x))
return elapsed
