
local function func1(x)
  return x + 1
end

local sqrt = math.sqrt


local x = 0
local count = arg[1]
print("count = ", count)
local start = os.clock()

for i=1,count do
  x = sqrt(x)+1
end

print("clock = ", os.clock() - start)
print("x = ", x)
