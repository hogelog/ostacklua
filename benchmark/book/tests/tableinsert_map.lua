local count = ...
print("<table insert (map part) test> count = ", count)

-- �A�z�z��e�[�u���̏ꍇ
-- �C���f�b�N�X�P�O������Ȃ�A�z�z��ɂȂ邾�낤�B���Ԃ�B
local t = {}
t[1] = 1 -- �z�񕔕�

-- �ȉ��͘A�z�z�񕔕��ɂȂ�͂�
local n = 1000 -- �v�f��
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
