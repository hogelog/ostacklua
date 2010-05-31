
-- �R�}���h��������������
local filename, count, arg1, arg2, arg3  = ...
--print(string.format("***********   test file : %s  count : %d", filename, count))

-- �e�X�g�����[�h
local test_func, err = loadfile("tests/"..filename)
if not test_func then
	error("load failed. : "..err)
end

collectgarbage("collect")

-- �e�X�g�����s
local elapsed = test_func(count, arg1, arg2, arg3)

-- �o�ߕb�����t�@�C���ɏ����o��
local fd,err = io.open("result.tmp", "w")
if not fd then
	error("test_launcher : result.tmp can't open! : "..err)
end
fd:write(""..elapsed)
fd:close()

collectgarbage("collect")
