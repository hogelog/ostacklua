local gc_pause = 130
local gc_stepmul = 400
local gc_step_n = 1

local static_data_count = 500 -- 静的なデータの量
local dynamic_data_count = 500 -- 毎ループ作成される動的なデータの量

print("setpause:", gc_pause)
print("setstepmul:", gc_stepmul)
print("gc_step_n:", gc_step_n)
print("static_data_count:", static_data_count)
print("dynamic_data_count:", dynamic_data_count)

collectgarbage("setpause", gc_pause)
collectgarbage("setstepmul", gc_stepmul)
collectgarbage("stop")

-- show total memory size
function show_gccount()
	local gccount = collectgarbage("count") * 1024
	print("collectgarbage(\"count\") * 1024 = "..gccount.." bytes")
	return gccount
end

print("=====================================")
show_gccount()

print(">>>>>>>>> create static data ")

-- static data
local t = {}
for i=1,static_data_count do
	table.insert(t, {i})
end

local prev_mem = show_gccount()
print(">>>>>>>>> GC step ")

local gc_start_j = 1
for j=1,50 do
	-- create garbage 
	for i=1,dynamic_data_count do
		local x = {i}
	end
	-- exec GC step
	local res = collectgarbage("step", gc_step_n)
	local mem = collectgarbage("count")*1024
	collectgarbage("stop")
	print("step : ",j, mem, "bytes   diff:", mem-prev_mem, "bytes" )
	prev_mem = mem
	if res then
	  print("cycle end. step count:",j - gc_start_j+1 )
	  gc_start_j = j
	end
end

show_gccount()
collectgarbage("collect")
show_gccount()
print("=====================================")