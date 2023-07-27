--/Services
local runService = game:GetService("RunService")

--/Modules
local module = {}
local G = require(script.Parent.Parent.GlobalFunctions)

function module:GetPoints(CF,x,y)
	local hSizex, hSizey = 4,4
	local splitx, splity = 1 + math.floor(x/hSizex), 1 + math.floor(y/hSizey)
	local studPerPointX = x / splitx
	local studPerPointY = y / splity
	--> A table and starting cframe
	local startCFrame = CF * CFrame.new(-x/2 -studPerPointX/2 ,-y/2 -studPerPointY/2,0)
	local points = {CF}
	for x = 1, splitx do
		for y = 1, splity do
			points[#points + 1] = startCFrame * CFrame.new(studPerPointX*x, studPerPointY*y,0)
		end
	end
	return points
end


function module:ProjectileActive(data)
	--[[
	TODO: Example Usage
	
		module:ProjectileActive({
			Points = {} --Array of CFrames from module:GetPoints()
			Direction = Vector3.new() -- Direction
			Velocity = 10 -- Velocity of Projectile
			Lifetime = 1 --The duration of the projectile
			Iterations = 1 --The amount of segments in the movement TODO: The larger the number, the smoother the movement
			Visualize = true --Visualizes the movement
			Ignore = {} -- Table of things for the raycast to ignore
	]]
	
	--/Data
	local points = data.Points
	local direction = data.Direction
	local velocity = data.Velocity
	local lifeTime = data.Lifetime
	local iterations = data.Iterations
	local visualize = data.Visualize
	local breakOnHit = data.BreakOnHit or true
	local ignore = data.Ignore or {}
	
	local start = os.clock()
	local impactPosition
	
	local lastCast
	local interception = false
	local castInterval = lifeTime/iterations
	while (os.clock()-start) < lifeTime and ((breakOnHit and not interception) or not breakOnHit) do
		local delta = lastCast and (os.clock()-lastCast) or castInterval
		if not lastCast or delta >= castInterval then
			local distance = velocity * delta 
			lastCast = os.clock()
			for i,point in next, points do
				local startPos = point.Position
				local endPos = point.Position + direction * distance 
				local result = G.mystCast(startPos,endPos,ignore)
				if visualize then
					G.mystVisualize(startPos,endPos)
				end
				
				if result then
					interception = true
					impactPosition = result.Position
				end
				points[i] = CFrame.new(endPos)
			end
		end
		runService.Stepped:wait()
	end
	
	return impactPosition
end

function module:CastProjectileHitbox(Data)

	--[[
	Example Call
	
		
		HitboxService:CastProjectileHitbox({ -- Everything is required
			Points = {}, -- Array Of CFrames
			Direction = Vector3.new(), -- Direction
			Velocity = 10, -- Velocity Of Projectile
			Lifetime = 1, -- Total Duration 
			Iterations = 1, -- Amount of times it's splitted,
			Visualize = true, -- Visualizes the hitbox using RayService
			Function = function(RaycastResult) -- Callback

			end,
			Ignore = {} -- Array Of Objects To be Ignored
		})


	]]

	--| Data
	local Points = Data.Points
	local Direction = Data.Direction 
	local Velocity = Data.Velocity 
	local Lifetime = Data.Lifetime 
	local Iterations = Data.Iterations 
	local Visualize = Data.Visualize
	local BreakOnHit = Data.BreakOnHit == true and true or Data.BreakOnHit == false and false or Data.BreakOnHit == nil and true;

	local Function = Data.Function or function()
		warn("There was no function provided for projectile hitbox")
	end
	local Ignore = Data.Ignore or {}

	local Start = os.clock()
	
	coroutine.resume(coroutine.create(function()
		local LastCast = nil
		local Interception = false
		local CastInterval = Lifetime / Iterations
		while os.clock() - Start < Lifetime and ((BreakOnHit and not Interception) or not BreakOnHit) do
			local Delta = LastCast and os.clock() - LastCast or CastInterval
			if not LastCast or Delta >= CastInterval then
				local Distance = Velocity * Delta
				LastCast = os.clock()
				for Index, Point in next, Points do
					local StartPosition = Point.Position
					local EndPosition = Point.Position + Direction * Distance
					local Result = G.Cast(StartPosition,EndPosition,Ignore)
					if Visualize then
						G.Visualize(StartPosition,EndPosition)
					end

					if Result then
						Interception = true
						Function(Result)
						if BreakOnHit then
							break
						end
					end
					Points[Index] = CFrame.new(EndPosition)
				end
			end
			game:GetService("RunService").Stepped:Wait()
		end
	end))
end

return module
