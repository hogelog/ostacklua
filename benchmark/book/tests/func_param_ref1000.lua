local count, n = ...
print("<function return test> count = ", count)

local start = os.clock()

local function f(t,x) -- �e�[�u���͊O����������ŗ^����
  t[1] = x
end

local result = {}
for i=1,count do
	f(result,10) -- �֐����ĂԂƃe�[�u���̒��g���ω����邪�A�e�[�u���͍쐬����Ȃ�
end

local elapsed = os.clock() - start
print(string.format("clock = %f", elapsed))
return elapsed
