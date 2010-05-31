local count,n = ...
print("<string concatenation test> count = ", count)

local start = os.clock()

local text = nil

for i=1,count do
	text = ""
	for i=0, n do
		text = text .. "XYZ"
	end

end
print(text)

local elapsed = os.clock() - start
print(string.format("clock = %f", elapsed))
return elapsed
