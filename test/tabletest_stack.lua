size = 80000000
t = table.create(size, 0)
for i = 1, size do
  t[i] = i
end
--for i = 1, size do
--  print("\tt["..i.."]: "..t[i])
--end
print("t#size: "..table.maxn(t))