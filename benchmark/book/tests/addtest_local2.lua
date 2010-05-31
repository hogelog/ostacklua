local count = ...
print("<add test2 (local)> count = ", count)

local start = os.clock()
local x = 0
local y = 0
local add = 1
for i=1,count do
  x = x + 1
  y = y + add -- 測定対象（ローカル変数）
end

local elapsed = os.clock() - start
print(string.format("clock = %f  x = %d y = %d", elapsed, x, y))
return elapsed
