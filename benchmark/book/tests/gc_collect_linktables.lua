local count, garbage_count = ...
count = count or 10000
garbage_count = garbage_count or 10000

print(string.format("<GC collect test with %d linked tables> count = %d garbage = %d", 
	garbage_count, count, garbage_count))

local t = {}

local current = t
for i=0,garbage_count do
	local new_t  = {i}
	current[math.random(100000)] = new_t
	current = new_t -- ‚Ç‚ñ‚Ç‚ñ[‚­ƒŠƒ“ƒN‚µ‚Ä‚¢‚­
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
