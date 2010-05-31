local count = ...
print("<add test (global)> count = ", count)

local start = os.clock()
local x = 0
y = 0

for i=1,count do
  x = x + 1
  y = y + 1 -- 測定対象（グローバル変数）
end

local elapsed = os.clock() - start
print(string.format("clock = %f  x = %d y = %d", elapsed, x, y))
return elapsed
