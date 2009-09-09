--a = {}
size = 10000000
t = {}
for i = 1, size do
  t[i] = i
end
for i = 1, size do
  print("\tt["..i.."]: "..t[i])
end
print("t#size: "..table.maxn(t))
