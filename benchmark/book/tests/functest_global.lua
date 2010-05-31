local count = ...
print("<global function test> count = ", count)

function func1(x)
  return x + 1
end

local start = os.clock()

local x = 0
for i=1,count do
  x = func1(x)
end

local elapsed = os.clock() - start
print(string.format("clock = %f  x = %d", elapsed, x))
return elapsed
