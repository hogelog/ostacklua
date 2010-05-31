
-- テストを実行して、各コード部分の速度を計測する。

local COUNT_1_OKU = 100000000 -- １億回
local COUNT_1000_MAN = 10000000 -- １千万回
local COUNT_100_MAN = 1000000 -- 百万回
local COUNT_10_MAN = 100000 -- 十万回
local COUNT_1_MAN = 10000 -- １万回
local COUNT_1000 = 1000 -- 千回
local COUNT_100 = 100 -- 百回

local lua_cmd = (arg and arg[1]) or "lua"

-- ベーステストについては、その後のテストからベーステストの時間を差し引いて調べます。

-- 残り if文、文字列を使うこと

local tests = {
	---- テスト名、テストファイル名、カウント、回数、ベーステストフラグ、テストに渡す追加引数
	--{"if文（ベーステスト）",	"iftest_base.lua", 		COUNT_1000_MAN, 3, true },
	--{"if文（数値）",	"iftest_number.lua", 		COUNT_1000_MAN, 3, false },
	--{"if文（文字列）",	"iftest_string.lua", 		COUNT_1000_MAN, 3, false },

	--{"関数テーブル返し",	"func_return_obj1000.lua", 		COUNT_1000_MAN, 3, false },
	--{"関数リファレンス渡し",	"func_param_ref1000.lua", 		COUNT_1000_MAN, 3, false },

	--{"文字列連結10000x100",	"string_concat1000.lua", 		COUNT_100, 3, false, "10000" },
	--{"文字列バッファ連結10000x100",	"string_buf_concat1000.lua", 		COUNT_100, 3, false, "10000" },

	--{"文字列連結1000x1000",	"string_concat1000.lua", 		COUNT_1000, 3, false, "1000" },
	--{"文字列バッファ連結1000x1000",	"string_buf_concat1000.lua", 		COUNT_1000, 3, false, "1000" },

	--{"ループ＋加算（ベーステスト）",	"looptest.lua", 		COUNT_1000_MAN, 3, true },

	--{"関数呼び出し（文字列引数）", 		"func_string_var.lua", 	COUNT_1000_MAN, 3, false },
	--{"文字列連結",	"string_concat.lua", 		COUNT_100_MAN, 3, false },
	--{"加算（ローカル変数と即値）",	"addtest_local.lua", 		COUNT_1_OKU, 3, false },
	--{"加算（ローカル変数同士）",	"addtest_local2.lua", 		COUNT_1_OKU, 3, false },
	--{"掛け算（ローカル変数同士）",	"multest_local.lua", 		COUNT_1_OKU, 3, false },
	--{"割り算（ローカル変数同士）",	"divtest_local.lua", 		COUNT_1_OKU, 3, false },
	--{"加算（グローバル変数）",	"addtest_global.lua", 		COUNT_1000_MAN, 3, false },
	--{"グローバル関数呼び出し", 			"functest_global.lua", 	COUNT_1000_MAN, 3, false },
	--{"ローカル関数呼び出し", 			"functest_local.lua", 	COUNT_1000_MAN, 3, false },
	--{"pcallによる関数呼び出し", 			"functest_pcall.lua", 	COUNT_1000_MAN, 3, false },
	--{"文字列コンパイル",	"loadstring.lua", 		COUNT_100_MAN, 3, false },
	--{"関数作成",	"func_creation.lua", 		COUNT_1000_MAN, 3, false },
	--{"テーブル作成",	"table_creation.lua", 		COUNT_1000_MAN, 3, false },

	--{"テーブルインデックス（ベーステスト）",	"tableindex_base.lua", 		COUNT_1000_MAN, 3, true },
	--{"テーブル配列インデックス",	"tableindex_array.lua", 		COUNT_1000_MAN, 3, false },
	--{"テーブル連想配列インデックス",	"tableindex_map.lua", 		COUNT_1000_MAN, 3, false },
	--{"テーブル配列セット",	"tableinsert_array.lua", 		COUNT_1000_MAN, 3, false },
	--{"テーブル連想配列セット",	"tableinsert_map.lua", 		COUNT_1000_MAN, 3, false },

	--{"コルーチン作成", 			"coroutine_create.lua", 	COUNT_100_MAN, 3, false },
	--{"コルーチンresume", 			"coroutine_resume.lua", 	COUNT_1000_MAN, 3, false },
	--{"コルーチン(wrap)作成", 			"coroutine_wrap_create.lua", 	COUNT_100_MAN, 3, false },
	--{"コルーチン(wrap)resume", 			"coroutine_wrap_resume.lua", 	COUNT_1000_MAN, 3, false },

	--{"GC collect（データなし）", 			"gc_collect_empty.lua", 	COUNT_10_MAN, 3, false },
	--{"GC collect（1000テーブル）", 			"gc_collect_flattables.lua", 	COUNT_1000, 3, false, "1000" },
	--{"GC collect（1000リンクテーブル）", 			"gc_collect_linktables.lua", 	COUNT_1000, 3, false, "1000" },
	----{"GC collect（10000テーブル）", 			"gc_collect_flattables.lua", 	COUNT_1000, 3, false, "10000" },
	----{"GC collect（10000リンクテーブル）", 			"gc_collect_linktables.lua", 	COUNT_1000, 3, false, "10000" },

	{"GC step", 			"gc_step.lua", 	COUNT_10_MAN, 3, false },
	--{"GC step（10000フラットテーブル＋100個ずつ増加）", 	"gc_step_growtables.lua", 	COUNT_1_MAN, 3, false, "10000 100" },
	{"GC step（10000フラットテーブル＋1000個ずつ増加）", 	"gc_step_growtables.lua", 	COUNT_1000, 3, false, "10000 1000" },
	--{"GC step（1000フラットテーブル＋1000個ずつ増加）", 	"gc_step_growtables.lua", 	COUNT_1000, 3, false, "1000 1000" },
	{"GC step（1000000フラットテーブル＋1000個ずつ増加）", 	"gc_step_growtables.lua", 	COUNT_1000, 3, false, "1000000 1000" },
	{"GC step（100000フラットテーブル＋1000個ずつ増加）", 	"gc_step_growtables.lua", 	COUNT_1000, 3, false, "100000 1000" },

}

-- ファイルに書いてある数値を取得する
function get_test_clock_time()
	-- 結果秒数を得る
	local fd, err = io.open("result.tmp")
	if not fd then
		error("test.lua : result.tmp can't opened! : "..err)
	end
	local elapsed = fd:read("*n")
	fd:close()
	return elapsed
end

local base_time = 0
local base_name = ""

-- 各テストを実行
for i,v in ipairs(tests) do
	local name, file, testcount, loop, is_base_test, arg = unpack(v)
	print(string.format("\n○　テスト「%s」 ファイル:%s カウント:%d テスト回数:%d\n", unpack(v)))
	local elapsed_sum = 0
	for i=1, loop do
		-- OS経由でテスト実行
		local a,b,c = os.execute(lua_cmd .. " test_sub.lua "..file.." "..testcount.." "..(arg or ""))
		-- 結果秒数をファイル経由で取得
		local elapsed = get_test_clock_time()
		print("elapsed: ", elapsed)
		elapsed_sum = elapsed_sum + elapsed
	end
	
	local elapsed_avg = elapsed_sum / loop
	print(string.format("テスト実行時間平均: %.3f秒 (%d回)", elapsed_avg, testcount))
	local time1 = elapsed_avg / testcount -- １回の試行にかかる時間

	-- ベーステストにかかった時間を覚えておく。
	-- 後のテストではベーステストの時間を引いて表示。
	if is_base_test then
		base_time = time1
	end
	
	print(string.format("１回の試行にかかる時間: %fms", time1 * 1000))
	local diff_time = time1 - base_time
	if is_base_test then
		diff_time = time1
		base_name = name
	else
		print(string.format("ベーステスト(%s)からの差分      : %fms - %fms = %fms", 
			base_name, time1 * 1000, base_time * 1000, diff_time * 1000))
	end
	print(string.format("1msあたりの実行回数に換算 : %.1f回 ", (0.001 / diff_time)))

end

