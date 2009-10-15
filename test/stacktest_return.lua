function h()
  i = 0
  function g()
    local a, b, c, d
    function f()
      local t = {10, 20}
      local v = {1000, 2000}
      local u = {100, 200}
      print("t: ", t)
      print("v: ", v)
      print("u: ", u)
      return t, u
    end
    i = i + 1
    a, b = f()
    print("a: ", a)
    print("b: ", b)
    if i == 1 then
      print("a:", a, a[1])
      return a
    else
      print("b: ", b, b[1])
      return b
    end
  end
  local a
  a = g()
  print(a, a[1])
  a = g()
  print(a, a[1])
end
h()
h()
