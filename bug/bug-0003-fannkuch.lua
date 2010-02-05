local function fannkuch(n)
  local p, q, s, odd, check, maxflips = {}, {}, {}, true, 0, 0
  for i=1,n do
    p[i] = i
    q[i] = i
    s[i] = i
  end
  repeat
    -- Print max. 30 permutations.
    if check < 30 then
      if not p[n] then
        -- Catch n = 0, 1, 2.
        return maxflips
      end
      -- io.write(unpack({1,2,3,4}))
      -- io.write(": ")
      io.write(unpack(p))
      io.write("\n")
      check = check + 1
    end
    -- Copy and flip.
    local q1 = p[1]                                     -- Cache 1st element.
    -- Avoid useless work.
    if p[n] ~= n and q1 ~= 1 then
      for i=2,n do
        -- Work on a copy.
        q[i] = p[i]
      end
      -- Flip ...
      for flips=1,1000000 do
        local qq = q[q1]
        -- ... until 1st element is 1.
        if qq == 1 then
          -- New maximum?
          if flips > maxflips then
            maxflips = flips
          end
          break
        end
        q[q1] = q1
        if q1 >= 4 then
          local i, j = 2, q1 - 1
          repeat
            q[i], q[j] = q[j], q[i]
            i = i + 1
            j = j - 1
          until i >= j
        end
        q1 = qq
      end
    end
    -- Permute.
    if odd then
      -- Rotate 1<-2.
      p[2], p[1] = p[1], p[2]
      odd = false
    else
      -- Rotate 1<-2 and 1<-2<-3.
      p[2], p[3] = p[3], p[2]
      odd = true
      for i=3,n do
        local sx = s[i]
        if sx ~= 1 then
          s[i] = sx-1
          break
        end
        if i == n then
          -- Out of permutations.
          return maxflips
        end
        s[i] = i
        -- Rotate 1<-...<-i+1.
        local t = p[1]
        for j=1,i do
          p[j] = p[j+1]
        end
        p[i+1] = t
      end
    end
  until false
end

-- local n = 6
local n = tonumber(arg and arg[1]) or 10
io.write("Pfannkuchen(", n, ") = ", fannkuch(n), "\n")
