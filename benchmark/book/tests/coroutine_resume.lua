local count = ...
print("<coroutine resume test> count = ", count)

local yield = coroutine.yield

local function func1(x)
  while true do
    x = yield(x + 1)
  end
end

local start = os.clock()

local cocreate = coroutine.create
local resume = coroutine.resume
local co = cocreate(func1)

local x = 0
local res
for i=1,count do
  --x = x + 1
  res, x = resume(co, x)
end

local elapsed = os.clock() - start
print(string.format("clock = %f  x = %d", elapsed, x))
return elapsed
