local count, n = ...
print("<function return test> count = ", count)

local start = os.clock()

local function f(t,x) -- テーブルは外部から引数で与える
  t[1] = x
end

local result = {}
for i=1,count do
	f(result,10) -- 関数を呼ぶとテーブルの中身が変化するが、テーブルは作成されない
end

local elapsed = os.clock() - start
print(string.format("clock = %f", elapsed))
return elapsed
