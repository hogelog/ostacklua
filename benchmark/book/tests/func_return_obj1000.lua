local count, n = ...
print("<function return test> count = ", count)

local start = os.clock()

local function f(x)
  return {x}
end

for i=1,count do
	local result = f(10) -- ŠÖ”‚ğŒÄ‚Ô‚½‚Ñ‚Éƒe[ƒuƒ‹‚ªì‚ç‚ê‚é
end

local elapsed = os.clock() - start
print(string.format("clock = %f", elapsed))
return elapsed
