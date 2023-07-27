local module = {}

function module.quadBezier(t, p0, p1, p2)
	return (1 - t)^2 * p0 + 2 * (1 - t) * t * p1 + t^2 * p2
end

function module.cubicBezier(t, p0, p1, p2, p3)
	return (1 - t)^3*p0 + 3*(1 - t)^2*t*p1 + 3*(1 - t)*t^2*p2 + t^3*p3
end

function module.getCoords(type,amount,...)
	local args = {...}
	local coords = {}
	
	local point1 = args[1]
	local point2 = args[2]
	local point3 = args[3]
	local point4 = args[4]
	
	
	if type == "quad" then
		for i = 1,(amount or 10) do
			coords[i] = module.quadBezier(i/(amount or 10),point1,point2,point3)
		end
	else
		for i = 1,(amount or 10) do
			coords[i] = module.cubicBezier(i/(amount or 10),point1,point2,point3,point4)
		end
	end
	return coords
end


return module
