local count = ...
count = count or 10000000
print("<if test (string)> count = ", count)

local start = os.clock()
local x = 0
local y = 0

local t = {}
local strings = {"FIRST", "SECOND", "THIRD"}

for i=1,1000 do
  t[i] = strings[i % 3 + 1]
end

local z
for i=1,count do
  x = x + 1
  z = t[i % 1000]
  if z == "FIRST" then
    y = y + 1
  end
end

local elapsed = os.clock() - start
print(string.format("clock = %f  x = %d y = %d", elapsed, x, y))
return elapsed
