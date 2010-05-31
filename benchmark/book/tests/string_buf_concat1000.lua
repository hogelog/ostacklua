local count, n = ...
print("<string concatenation test> count = ", count)

local start = os.clock()

local text
local buf
local tinsert = table.insert
local tostring = tostring
local tconcat = table.concat

for i=1,count do
	buf = {}
	for i=0, n do
		table.insert(buf, "XYZ")
	end
	text = table.concat(buf)
end
print(text)

local elapsed = os.clock() - start
print(string.format("clock = %f", elapsed))
return elapsed
