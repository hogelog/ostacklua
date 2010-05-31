local count = ...
print("<multiple test (local)> count = ", count)

local start = os.clock()
local x = 0
local y = 0

local mul = 1.1
for i=1,count do
  x = x + 1
  y = y * mul -- 測定対象（ローカル変数）
end

local elapsed = os.clock() - start
print(string.format("clock = %f  x = %d y = %d", elapsed, x, y))
return elapsed
