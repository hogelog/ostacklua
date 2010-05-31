
-- コマンド引数を処理する
local filename, count, arg1, arg2, arg3  = ...
--print(string.format("***********   test file : %s  count : %d", filename, count))

-- テストをロード
local test_func, err = loadfile("tests/"..filename)
if not test_func then
	error("load failed. : "..err)
end

collectgarbage("collect")

-- テストを実行
local elapsed = test_func(count, arg1, arg2, arg3)

-- 経過秒数をファイルに書き出す
local fd,err = io.open("result.tmp", "w")
if not fd then
	error("test_launcher : result.tmp can't open! : "..err)
end
fd:write(""..elapsed)
fd:close()

collectgarbage("collect")
