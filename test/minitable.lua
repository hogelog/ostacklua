function test(i)
  local t = {10, 20, 30}
  return t[1] + t[2] + t[3]
end
size = 1000000
sum = 0
for i = 1, size do
  sum = sum + test(i)
end
print(sum)
