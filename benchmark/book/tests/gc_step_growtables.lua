local count, garbage_count, grow_count = ...
count = count or 10000
garbage_count = garbage_count or 10000
grow_count = grow_count or 1000

print(string.format("<GC step test with %d linked tables, growing garbage by %d per loop> count = %d garbage = %d", 
	garbage_count, grow_count, count, garbage_count))

local t = {}

local current = t
for i=0,garbage_count do
	local new_t  = {i}
	current[math.random(100000)] = new_t
	current = new_t -- Ç«ÇÒÇ«ÇÒê[Ç≠ÉäÉìÉNÇµÇƒÇ¢Ç≠
end

local read_p = t

local start = os.clock()
local collectgarbage = collectgarbage

local t2 = {}
local current2 = t2

local x = 0
local res
local random = math.random
local cycles = 0
local mod = math.mod
for i=1,count do
  x = x + 1
  for j=1,grow_count do
    local new_t  = {i}
    current2[random(100000)] = new_t
    current2 = new_t
  end
  local res = collectgarbage("step")
  if res == true then
    cycles = cycles + 1
  end
  if mod(i,100) == 0 then
  	collectgarbage("collect")
  end
end

local elapsed = os.clock() - start
print(string.format("clock = %f  x = %d GC-cycles = %d", elapsed, x, cycles))
return elapsed
