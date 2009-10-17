function f(i)
  t = {i, {i+1,{i+2, x=i+3}}}
end
function g(i)
  u = {i, {i+1,{i+2, x=i+3}}}
end
f(10)
g(20)
print(t, t[2][2], t[2][2][1], t[2][2].x)
print(u, u[2][2], u[2][2][1], u[2][2].x)
