local a = {1, 2}
for j = 1, 1 do
  local b = {10}
  a[1] = b
end
for j = 1, 1 do
  local c = {100}
  a[2] = c
end
assert(a[1][1]==10)
assert(a[2][1]==100)
