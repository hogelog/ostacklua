local count, garbage_count = ...
count = count or 10000
garbage_count = garbage_count or 10000

print(string.format("<GC collect test with %d flat tables> count = %d garbage = %d", 
	garbage_count, count, garbage_count))

local t = {}
for i=0,garbage_count do
	t[math.random(1,100000)] = {i}
end

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
