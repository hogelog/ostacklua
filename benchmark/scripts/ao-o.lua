
IMAGE_WIDTH = 256
IMAGE_HEIGHT = 256
NSUBSAMPLES = 2
NAO_SAMPLES = 8

math.randomseed(100)

-- vec

local function vec(ix, iy, iz)
	return {x = ix, y = iy, z = iz}
end

local function vadd(a, b)
	return vec(a.x + b.x, a.y + b.y, a.z + b.z)
end

local function vsub(a, b)
	return vec(a.x - b.x, a.y - b.y, a.z - b.z)
end

local function vcross(a, b)
	return vec(	a.y * b.z - a.z * b.y,
				a.z * b.x - a.x * b.z,
				a.x * b.y - a.y * b.x )
end

local function vdot(a, b)
	return (a.x * b.x + a.y * b.y + a.z * b.z)
end

local function vlength(a)
	return math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
end

local function vnormalize(a)
	local len = vlength(a)
	local v = vec(a.x, a.y, a.z)
	
	if ( math.abs(len) > 1.0e-17 ) then
		v.x = v.x / len;
		v.y = v.y / len;
		v.z = v.z / len;
	end
	
	return v;
end

local function vprint(vname, a)
	print( string.format("%s=(%f,%f,%f)", vname, a.x, a.y, a.z) )
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
local function Sphere(icenter, iradius)
	return {center = icenter, radius = iradius}
end

local function Sphere_intersect(sphere, ray, isect)
	local rs = vsub(ray.org, sphere.center)
	local B = vdot(rs, ray.dir)
	local C = vdot(rs, rs) - (sphere.radius * sphere.radius)
	local D = B * B - C
	
	if( D > 0.0 ) then
		local t = -B - math.sqrt(D)
		
		if ( (t > 0.0) and (t < isect.t) ) then
			isect.t = t
			isect.hit = true
			isect.p = vec(	ray.org.x + ray.dir.x * t,
							ray.org.y + ray.dir.y * t,
							ray.org.z + ray.dir.z * t )
			
			local n = vsub( isect.p, sphere.center )
			isect.n = vnormalize(n)
		end
	end
end

local function Plane(ip, inorm)
	return {p = ip, n = inorm}
end

local function Plane_intersect(aplane, ray, isect)
	local d = -vdot(aplane.p, aplane.n)
	local v = vdot(ray.dir, aplane.n)
	
	if (math.abs(v) < 1.0e-17) then
		return;	--no hit
	end
	
	local t = -(vdot(ray.org, aplane.n) + d) / v
	
	if ((t > 0.0) and (t < isect.t)) then
		isect.hit = true
		isect.t = t
		isect.n = aplane.n
		isect.p = vec(	ray.org.x + ray.dir.x * t,
						ray.org.y + ray.dir.y * t,
						ray.org.z + ray.dir.z * t )
	end
end

local function Ray(iorg, idir)
	return {org = iorg, dir = idir}
end

local function Isect()
	return {t = 1000000.0, hit = false, p = vec(0.0, 0.0, 0.0), n = vec(0.0, 0.0, 0.0) }
end

local function clamp(f)
	local i = f * 255.5
	if i > 255.0 then
		i = 255.0
	elseif i < 0.0 then
		i = 0.0
	end
	
	return math.floor(i + 0.5) -- round is not defined
end

local function orthoBasis( basis, n )
	basis[2] = vec(n.x, n.y, n.z)
	basis[1] = vec(0.0, 0.0, 0.0)
	
	if ((n.x < 0.6) and (n.x > -0.6)) then
		basis[1].x = 1.0
	elseif ((n.y < 0.6) and (n.y > -0.6)) then
		basis[1].y = 1.0
	elseif ((n.z < 0.6) and (n.z > -0.6)) then
		basis[1].z = 1.0
	else
		basis[1].x = 1.0
	end
	
	basis[0] = vcross(basis[1], basis[2])
	basis[0] = vnormalize(basis[0])
	
	basis[1] = vcross(basis[2], basis[0])
	basis[1] = vnormalize(basis[1])
end


-- ==========

local function init_scene()
	spheres = {}
	spheres[0]  = Sphere(vec(-2.0, 0.0, -3.5), 0.5)
	spheres[1]  = Sphere(vec(-0.5, 0.0, -3.0), 0.5)
	spheres[2]  = Sphere(vec(1.0, 0.0, -2.2), 0.5)
	plane = Plane( vec(0.0, -0.5, 0.0), vec(0.0, 1.0, 0.0) )
end


local function ambient_occlusion( isect )
	local basis = {}
	orthoBasis( basis, isect.n )
	
	local ntheta = NAO_SAMPLES
	local nphi   = NAO_SAMPLES
	local eps    = 0.0001
	local occlusion = 0.0
	
	local p = vec(	isect.p.x + eps * isect.n.x,
					isect.p.y + eps * isect.n.y,
					isect.p.z + eps * isect.n.z )
	
	for j = 0, nphi -1 do
		for i = 0, ntheta -1 do
			local r = math.random()
			local phi = 2.0 * math.pi * math.random()
			
			local x = math.cos(phi) * math.sqrt(1.0 - r)
			local y = math.sin(phi) * math.sqrt(1.0 - r)
			local z = math.sqrt(r)
			
			-- local to global
			local rx = x * basis[0].x + y * basis[1].x + z * basis[2].x
			local ry = x * basis[0].y + y * basis[1].y + z * basis[2].y
			local rz = x * basis[0].z + y * basis[1].z + z * basis[2].z
			
			local raydir = vec(rx, ry, rz)
			local ray = Ray(p, raydir)
			
			local occIsect = Isect()
			Sphere_intersect( spheres[0], ray, occIsect )
			Sphere_intersect( spheres[1], ray, occIsect )
			Sphere_intersect( spheres[2], ray, occIsect )
			Plane_intersect( plane, ray, occIsect )
			
			if occIsect.hit then
				occlusion = occlusion + 1.0
			end
			
		end
	end
	
	occlusion = (ntheta * nphi - occlusion) / (ntheta * nphi)
	
	return vec(occlusion, occlusion, occlusion)
end

local function render(buffer, w, h, nsubsamples)
	local cnt = 0;
	
	for y = 0, h - 1 do
		for x = 0, w - 1 do
			local rad = vec(0.0, 0.0, 0.0)
			
			-- subsampling
			for v = 0, nsubsamples - 1 do
				for u = 0, nsubsamples - 1 do
					cnt = cnt + 1
					local px = (x + (u / nsubsamples) - (w / 2.0)) / (w / 2.0)
					local py = -(y + (v / nsubsamples) - (h / 2.0)) / (h / 2.0)
					
					local eye = vnormalize( vec(px, py, -1.0) )
					local ray = Ray( vec(0.0, 0.0, 0.0), eye )
					
					isect = Isect()
					Sphere_intersect( spheres[0], ray, isect )
					Sphere_intersect( spheres[1], ray, isect )
					Sphere_intersect( spheres[2], ray, isect )
					Plane_intersect( plane, ray, isect )
					
					if isect.hit then
						local col = ambient_occlusion(isect)
						
						rad.x = rad.x + col.x
						rad.y = rad.y + col.y
						rad.z = rad.z + col.z
					end
					--[[
					rad.x = rad.x + isect.n.x * 0.5 + 0.5
					rad.y = rad.y + isect.n.y * 0.5 + 0.5
					rad.z = rad.z + isect.n.z * 0.5 + 0.5
					]]
				end
			end
			-- end sub sample
			
			local r = rad.x / (nsubsamples * nsubsamples)
			local g = rad.y / (nsubsamples * nsubsamples)
			local b = rad.z / (nsubsamples * nsubsamples)
			
			buffer[x + y * w] = string.char( clamp(r), clamp(g), clamp(b) )
		end -- x
	end -- y
	-- end per pixel
end

local function saveppm( fname, w, h, buffer )
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

image = {}

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
