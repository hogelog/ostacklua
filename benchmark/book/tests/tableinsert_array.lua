local count = ...
print("<table insert (array part) test> count = ", count)

-- 配列テーブルの場合
local t = {}
local n = 1000 -- 要素数
for i=1,n do
	t[i] = i
end

local x = 0
local y = 0
local start = os.clock()

for i=1,count do
  x = x + 1
  if x > 1000 then
    x = 1
  end
  y = y + 1
  t[x] = i
end

local elapsed = os.clock() - start
print(string.format("clock = %f  x = %d y = %d", elapsed, x, y))
return elapsed
