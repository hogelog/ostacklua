
-- �ƥ��Ȥ�¹Ԥ��ơ��ƥ�������ʬ��®�٤��¬���롣

local COUNT_1_OKU = 100000000 -- ������
local COUNT_1000_MAN = 10000000 -- ��������
local COUNT_100_MAN = 1000000 -- ɴ����
local COUNT_10_MAN = 100000 -- ������
local COUNT_1_MAN = 10000 -- ������
local COUNT_1000 = 1000 -- ���
local COUNT_100 = 100 -- ɴ��

local lua_cmd = (arg and arg[1]) or "lua"

-- �١����ƥ��ȤˤĤ��Ƥϡ����θ�Υƥ��Ȥ���١����ƥ��Ȥλ��֤򺹤�������Ĵ�٤ޤ���

-- �Ĥ� ifʸ��ʸ�����Ȥ�����

local tests = {
	---- �ƥ���̾���ƥ��ȥե�����̾��������ȡ�������١����ƥ��ȥե饰���ƥ��Ȥ��Ϥ��ɲð���
	--{"ifʸ�ʥ١����ƥ��ȡ�",	"iftest_base.lua", 		COUNT_1000_MAN, 3, true },
	--{"ifʸ�ʿ��͡�",	"iftest_number.lua", 		COUNT_1000_MAN, 3, false },
	--{"ifʸ��ʸ�����",	"iftest_string.lua", 		COUNT_1000_MAN, 3, false },

	--{"�ؿ��ơ��֥��֤�",	"func_return_obj1000.lua", 		COUNT_1000_MAN, 3, false },
	--{"�ؿ���ե�����Ϥ�",	"func_param_ref1000.lua", 		COUNT_1000_MAN, 3, false },

	--{"ʸ����Ϣ��10000x100",	"string_concat1000.lua", 		COUNT_100, 3, false, "10000" },
	--{"ʸ����Хåե�Ϣ��10000x100",	"string_buf_concat1000.lua", 		COUNT_100, 3, false, "10000" },

	--{"ʸ����Ϣ��1000x1000",	"string_concat1000.lua", 		COUNT_1000, 3, false, "1000" },
	--{"ʸ����Хåե�Ϣ��1000x1000",	"string_buf_concat1000.lua", 		COUNT_1000, 3, false, "1000" },

	--{"�롼�סܲû��ʥ١����ƥ��ȡ�",	"looptest.lua", 		COUNT_1000_MAN, 3, true },

	--{"�ؿ��ƤӽФ���ʸ���������", 		"func_string_var.lua", 	COUNT_1000_MAN, 3, false },
	--{"ʸ����Ϣ��",	"string_concat.lua", 		COUNT_100_MAN, 3, false },
	--{"�û��ʥ������ѿ���¨�͡�",	"addtest_local.lua", 		COUNT_1_OKU, 3, false },
	--{"�û��ʥ������ѿ�Ʊ�Ρ�",	"addtest_local2.lua", 		COUNT_1_OKU, 3, false },
	--{"�ݤ����ʥ������ѿ�Ʊ�Ρ�",	"multest_local.lua", 		COUNT_1_OKU, 3, false },
	--{"��껻�ʥ������ѿ�Ʊ�Ρ�",	"divtest_local.lua", 		COUNT_1_OKU, 3, false },
	--{"�û��ʥ����Х��ѿ���",	"addtest_global.lua", 		COUNT_1000_MAN, 3, false },
	--{"�����Х�ؿ��ƤӽФ�", 			"functest_global.lua", 	COUNT_1000_MAN, 3, false },
	--{"������ؿ��ƤӽФ�", 			"functest_local.lua", 	COUNT_1000_MAN, 3, false },
	--{"pcall�ˤ��ؿ��ƤӽФ�", 			"functest_pcall.lua", 	COUNT_1000_MAN, 3, false },
	--{"ʸ���󥳥�ѥ���",	"loadstring.lua", 		COUNT_100_MAN, 3, false },
	--{"�ؿ�����",	"func_creation.lua", 		COUNT_1000_MAN, 3, false },
	--{"�ơ��֥����",	"table_creation.lua", 		COUNT_1000_MAN, 3, false },

	--{"�ơ��֥륤��ǥå����ʥ١����ƥ��ȡ�",	"tableindex_base.lua", 		COUNT_1000_MAN, 3, true },
	--{"�ơ��֥����󥤥�ǥå���",	"tableindex_array.lua", 		COUNT_1000_MAN, 3, false },
	--{"�ơ��֥�Ϣ�����󥤥�ǥå���",	"tableindex_map.lua", 		COUNT_1000_MAN, 3, false },
	--{"�ơ��֥����󥻥å�",	"tableinsert_array.lua", 		COUNT_1000_MAN, 3, false },
	--{"�ơ��֥�Ϣ�����󥻥å�",	"tableinsert_map.lua", 		COUNT_1000_MAN, 3, false },

	--{"���롼�������", 			"coroutine_create.lua", 	COUNT_100_MAN, 3, false },
	--{"���롼����resume", 			"coroutine_resume.lua", 	COUNT_1000_MAN, 3, false },
	--{"���롼����(wrap)����", 			"coroutine_wrap_create.lua", 	COUNT_100_MAN, 3, false },
	--{"���롼����(wrap)resume", 			"coroutine_wrap_resume.lua", 	COUNT_1000_MAN, 3, false },

	--{"GC collect�ʥǡ����ʤ���", 			"gc_collect_empty.lua", 	COUNT_10_MAN, 3, false },
	--{"GC collect��1000�ơ��֥��", 			"gc_collect_flattables.lua", 	COUNT_1000, 3, false, "1000" },
	--{"GC collect��1000��󥯥ơ��֥��", 			"gc_collect_linktables.lua", 	COUNT_1000, 3, false, "1000" },
	----{"GC collect��10000�ơ��֥��", 			"gc_collect_flattables.lua", 	COUNT_1000, 3, false, "10000" },
	----{"GC collect��10000��󥯥ơ��֥��", 			"gc_collect_linktables.lua", 	COUNT_1000, 3, false, "10000" },

	{"GC step", 			"gc_step.lua", 	COUNT_10_MAN, 3, false },
	--{"GC step��10000�ե�åȥơ��֥��100�Ĥ������á�", 	"gc_step_growtables.lua", 	COUNT_1_MAN, 3, false, "10000 100" },
	{"GC step��10000�ե�åȥơ��֥��1000�Ĥ������á�", 	"gc_step_growtables.lua", 	COUNT_1000, 3, false, "10000 1000" },
	--{"GC step��1000�ե�åȥơ��֥��1000�Ĥ������á�", 	"gc_step_growtables.lua", 	COUNT_1000, 3, false, "1000 1000" },
	{"GC step��1000000�ե�åȥơ��֥��1000�Ĥ������á�", 	"gc_step_growtables.lua", 	COUNT_1000, 3, false, "1000000 1000" },
	{"GC step��100000�ե�åȥơ��֥��1000�Ĥ������á�", 	"gc_step_growtables.lua", 	COUNT_1000, 3, false, "100000 1000" },

}

-- �ե�����˽񤤤Ƥ�����ͤ��������
function get_test_clock_time()
	-- ����ÿ�������
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

-- �ƥƥ��Ȥ�¹�
for i,v in ipairs(tests) do
	local name, file, testcount, loop, is_base_test, arg = unpack(v)
	print(string.format("\n�����ƥ��ȡ�%s�� �ե�����:%s �������:%d �ƥ��Ȳ��:%d\n", unpack(v)))
	local elapsed_sum = 0
	for i=1, loop do
		-- OS��ͳ�ǥƥ��ȼ¹�
		local a,b,c = os.execute(lua_cmd .. " test_sub.lua "..file.." "..testcount.." "..(arg or ""))
		-- ����ÿ���ե������ͳ�Ǽ���
		local elapsed = get_test_clock_time()
		print("elapsed: ", elapsed)
		elapsed_sum = elapsed_sum + elapsed
	end
	
	local elapsed_avg = elapsed_sum / loop
	print(string.format("�ƥ��ȼ¹Ի���ʿ��: %.3f�� (%d��)", elapsed_avg, testcount))
	local time1 = elapsed_avg / testcount -- ����λ�Ԥˤ��������

	-- �١����ƥ��Ȥˤ����ä����֤�Ф��Ƥ�����
	-- ��Υƥ��ȤǤϥ١����ƥ��Ȥλ��֤������ɽ����
	if is_base_test then
		base_time = time1
	end
	
	print(string.format("����λ�Ԥˤ��������: %fms", time1 * 1000))
	local diff_time = time1 - base_time
	if is_base_test then
		diff_time = time1
		base_name = name
	else
		print(string.format("�١����ƥ���(%s)����κ�ʬ      : %fms - %fms = %fms", 
			base_name, time1 * 1000, base_time * 1000, diff_time * 1000))
	end
	print(string.format("1ms������μ¹Բ���˴��� : %.1f�� ", (0.001 / diff_time)))

end

