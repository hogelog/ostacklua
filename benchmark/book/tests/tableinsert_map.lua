local count = ...
print("<table insert (map part) test> count = ", count)

-- 連想配列テーブルの場合
-- インデックス１０万からなら連想配列になるだろう。たぶん。
local t = {}
t[1] = 1 -- 配列部分

-- 以下は連想配列部分になるはず
local n = 1000 -- 要素数
for i=100001,100000+n do
	t[i] = i
end

local x = 100000
local y = 0
local start = os.clock()
for i=1,count do
  x = x + 1
  if x > 101000 then
    x = 100001
  end
  y = y + 1
  t[x] = i
end

local elapsed = os.clock() - start
print(string.format("clock = %f  x = %d y = %d", elapsed, x, y))
return elapsed
