
IMAGE_WIDTH = 256
IMAGE_HEIGHT = 256
NSUBSAMPLES = 2
NAO_SAMPLES = 8

math.randomseed(100)

-- vec

function vec(ix, iy, iz)
	return {ix, iy, iz}
end

function vadd(a, b)
	return {a[1] + b[1], a[2] + b[2], a[3] + b[3]}
end

function vsub(a, b)
	return {a[1] - b[1], a[2] - b[2], a[3] - b[3]}
end

function vcross(a, b)
	return {a[2] * b[3] - a[3] * b[2],
				a[3] * b[1] - a[1] * b[3],
				a[1] * b[2] - a[2] * b[1]}
end

function vdot(a, b)
	return (a[1] * b[1] + a[2] * b[2] + a[3] * b[3])
end

function vlength(a)
	return math.sqrt(a[1] * a[1] + a[2] * a[2] + a[3] * a[3])
end

function vnormalize(a)
	local len = vlength(a)
	local v = {a[1], a[2], a[3]}
	
	if ( math.abs(len) > 1.0e-17 ) then
		v[1] = v[1] / len;
		v[2] = v[2] / len;
		v[3] = v[3] / len;
	end
	
	return v;
end

function vprint(vname, a)
	print( string.format("%s=(%f,%f,%f)", vname, a[1], a[2], a[3]) )
end

--[[
v1 = vec(1.0, 2.0, 3.0)
vprint("v1", v1)
print( string.format("length(v1)=%f", vlength(v1)) )
vprint("normalize(v1)", vnormalize(v1) )

v2 = vec(1.0, 0.0, 0.0)
v3 = vec(0.0, 1.0, 0.0)
vprint("cross", vcross(v2, v3))
]]


-- Sphere
function Sphere(icenter, iradius)
	return {center = icenter, radius = iradius}
end

function Sphere_intersect(sphere, ray, isect)
	local rs = vsub(ray[1], sphere[1])
	local B = vdot(rs, ray[2])
	local C = vdot(rs, rs) - (sphere[2] * sphere[2])
	local D = B * B - C
	
	if( D > 0.0 ) then
		local t = -B - math.sqrt(D)
		
		if ( (t > 0.0) and (t < isect[1]) ) then
			isect[1] = t
			isect[2] = true
			isect[3] = {ray[1][1] + ray[2][1] * t,
							ray[1][2] + ray[2][2] * t,
							ray[1][3] + ray[2][3] * t}
			
			local n = vsub( isect[3], sphere[1] )
			isect[4] = vnormalize(n)
		end
	end
end
--[[
function Plane(ip, inorm)
	return {p = ip, n = inorm}
end
--]]

function Plane_intersect(aplane, ray, isect)
	local d = -vdot(aplane[1], aplane[2])
	local v = vdot(ray[2], aplane[2])
	
	if (math.abs(v) < 1.0e-17) then
		return;	--no hit
	end
	
	local t = -(vdot(ray[1], aplane[2]) + d) / v
	
	if ((t > 0.0) and (t < isect[1])) then
		isect[2] = true
		isect[1] = t
		isect[4] = aplane[2]
		isect[3] = {ray[1][1] + ray[2][1] * t,
						    ray[1][2] + ray[2][2] * t,
						    ray[1][3] + ray[2][3] * t}
	end
end
--[[
function Ray(iorg, idir)
	return {org = iorg, dir = idir}
end
--]]
function Isect()
	return {1000000.0, false, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0} }
	--return {t = 1000000.0, hit = false, p = vec(0.0, 0.0, 0.0), n = vec(0.0, 0.0, 0.0) }
end


function clamp(f)
	local i = f * 255.5
	if i > 255.0 then
		i = 255.0
	elseif i < 0.0 then
		i = 0.0
	end
	
	return math.floor(i + 0.5) -- round is not defined
end

function orthoBasis( basis, n )
	basis[3] = {n[1], n[2], n[3]}
	basis[2] = {0.0, 0.0, 0.0}
	
	if ((n[1] < 0.6) and (n[1] > -0.6)) then
		basis[2][1] = 1.0
	elseif ((n[2] < 0.6) and (n[2] > -0.6)) then
		basis[2][2] = 1.0
	elseif ((n[3] < 0.6) and (n[3] > -0.6)) then
		basis[2][3] = 1.0
	else
		basis[2][1] = 1.0
	end
	
	basis[1] = vcross(basis[2], basis[3])
	basis[1] = vnormalize(basis[1])
	
	basis[2] = vcross(basis[3], basis[1])
	basis[2] = vnormalize(basis[2])
end


-- ==========

function init_scene()
	spheres = {{{-2.0, 0.0, -3.5}, 0.5},
	           {{-0.5, 0.0, -3.0}, 0.5},
	           {{1.0, 0.0, -2.2}, 0.5}}
	plane = {{0.0, -0.5, 0.0}, {0.0, 1.0, 0.0}}
end


function ambient_occlusion( isect )
	local basis = {}
	orthoBasis( basis, isect[4] )
	
	local ntheta = NAO_SAMPLES
	local nphi   = NAO_SAMPLES
	local eps    = 0.0001
	local occlusion = 0.0
	
	local p = {isect[3][1] + eps * isect[4][1],
					isect[3][2] + eps * isect[4][2],
					isect[3][3] + eps * isect[4][3]}
	
	for j = 0, nphi -1 do
		for i = 0, ntheta -1 do
			local r = math.random()
			local phi = 2.0 * math.pi * math.random()
			
			local x = math.cos(phi) * math.sqrt(1.0 - r)
			local y = math.sin(phi) * math.sqrt(1.0 - r)
			local z = math.sqrt(r)
			
			-- local to global
			local rx = x * basis[1][1] + y * basis[2][1] + z * basis[3][1]
			local ry = x * basis[1][2] + y * basis[2][2] + z * basis[3][2]
			local rz = x * basis[1][3] + y * basis[2][3] + z * basis[3][3]
			
			local raydir = {rx, ry, rz}
			local ray = {p, raydir}
			
			local occIsect = Isect()
			Sphere_intersect( spheres[1], ray, occIsect )
			Sphere_intersect( spheres[2], ray, occIsect )
			Sphere_intersect( spheres[3], ray, occIsect )
			Plane_intersect( plane, ray, occIsect )
			
			if occIsect[2] then
				occlusion = occlusion + 1.0
			end
			
		end
	end
	
	occlusion = (ntheta * nphi - occlusion) / (ntheta * nphi)
	
	return {occlusion, occlusion, occlusion}
end

function render(buffer, w, h, nsubsamples)
	local cnt = 0;
	
	for y = 0, h - 1 do
		for x = 0, w - 1 do
			local rad = {0.0, 0.0, 0.0}
			
			-- subsampling
			for v = 0, nsubsamples - 1 do
				for u = 0, nsubsamples - 1 do
					cnt = cnt + 1
					local px = (x + (u / nsubsamples) - (w / 2.0)) / (w / 2.0)
					local py = -(y + (v / nsubsamples) - (h / 2.0)) / (h / 2.0)
					
					local eye = vnormalize({px, py, -1.0})
					local ray = {{0.0, 0.0, 0.0}, eye}
					
					isect = Isect()
					Sphere_intersect( spheres[1], ray, isect )
					Sphere_intersect( spheres[2], ray, isect )
					Sphere_intersect( spheres[3], ray, isect )
					Plane_intersect( plane, ray, isect )
					
					if isect[2] then
						local col = ambient_occlusion(isect)
						
						rad[1] = rad[1] + col[1]
						rad[2] = rad[2] + col[2]
						rad[3] = rad[3] + col[3]
					end
					--[[
					rad[1] = rad[1] + isect.n[1] * 0.5 + 0.5
					rad[2] = rad[2] + isect.n[2] * 0.5 + 0.5
					rad[3] = rad[3] + isect.n[3] * 0.5 + 0.5
					]]
				end
			end
			-- end sub sample
			
			local r = rad[1] / (nsubsamples * nsubsamples)
			local g = rad[2] / (nsubsamples * nsubsamples)
			local b = rad[3] / (nsubsamples * nsubsamples)
			
			buffer[x + y * w] = string.char( clamp(r), clamp(g), clamp(b) )
		end -- x
	end -- y
	-- end per pixel
end

function saveppm( fname, w, h, buffer )
	local f = io.open( fname, "w" )
	f:write("P6\n")
	f:write( string.format("%d %d\n", w, h) )
	f:write("255\n")
	for i = 0, w * h -1 do
		f:write( buffer[i] )
	end
	f:close()
end

-- =====

print("--- aobench ---")

startTime = os.time()

image = table.create(IMAGE_WIDTH * IMAGE_HEIGHT - 1, 0)

print("init scene")
init_scene()

print("render start")
render(image, IMAGE_WIDTH, IMAGE_HEIGHT, NSUBSAMPLES)

renderEndTime = os.time()

print(string.format("save ppm"))
saveppm( "ao.ppm", IMAGE_WIDTH, IMAGE_HEIGHT, image )

finalTime = os.time()

print( "time to render end", os.difftime(renderEndTime, startTime) )
print( "total time", os.difftime(finalTime, startTime) )

print("--- done ---")
