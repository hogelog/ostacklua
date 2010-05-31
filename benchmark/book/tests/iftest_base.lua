local count = ...
count = count or 10000000
print("<if test (base test)> count = ", count)

local start = os.clock()
local x = 0
local y = 0

local t = {}
for i=1,1000 do
  t[i] = i % 3
end

local z
for i=1,count do
  x = x + 1
  z = t[i % 1000]
end

local elapsed = os.clock() - start
print(string.format("clock = %f  x = %d y = %d", elapsed, x, y))
return elapsed
