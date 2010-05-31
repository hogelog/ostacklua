local count = ...
print("<coroutine (wrap) resume test> count = ", count)

local yield = coroutine.yield

local function func1(x)
  while true do
    x = yield(x + 1)
  end
end

local start = os.clock()

local cowrap = coroutine.wrap
local resume = coroutine.resume
local co_func = cowrap(func1)

local x = 0
local res
for i=1,count do
  --x = x + 1
  x = co_func(x)
end

local elapsed = os.clock() - start
print(string.format("clock = %f  x = %d", elapsed, x))
return elapsed
