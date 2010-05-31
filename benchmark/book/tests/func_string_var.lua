local count = ...
print("<local function string param test> count = ", count)

local function func1(x)
  return "RETURN"
end

local start = os.clock()
local res 

local x = 0
for i=1,count do
  x = x + 1
  res = func1("CALLFUNC")
end

local elapsed = os.clock() - start
print(string.format("clock = %f  x = %d", elapsed, x))
return elapsed
