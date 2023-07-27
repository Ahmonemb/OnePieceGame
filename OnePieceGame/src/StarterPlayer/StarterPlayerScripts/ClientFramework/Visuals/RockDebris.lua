--//Services
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")

--//Modules
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)
local module = {}

local World = game.Workspace:WaitForChild("World")
local Visual = World.Visual

--/Methods
function module.Crater(data)
	local model = Instance.new("Model",Visual)
	
	for i = 1,data.points do
		local angle = ((2*math.pi)/data.points)*i
		local x, z = math.cos(angle)*data.radius, math.sin(angle)*data.radius
		local determinedPosition = data.position + Vector3.new(x,0,z)
		local randomSize = math.random(1,4)
		local moving = data.movement
		
		local part = Instance.new("Part")
		part.Orientation = Vector3.new(math.random(360),math.random(360),math.random(360))
		part.Anchored = true part.CanCollide = false
		part.Size = Vector3.new(data.size,data.size,data.size) + Vector3.new(randomSize,randomSize,randomSize)
		
		if moving then
			part.Position = data.position
			tweenService:Create(part,TweenInfo.new(data.speed,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Position = determinedPosition}):Play()
			coroutine.wrap(function() wait(data.speed) moving = false end)()
			coroutine.wrap(function()
				while moving do
					local ray = G.rayCast(determinedPosition+Vector3.new(0,data.size/2,0),Vector3.new(0,-10,0),data.blacklist)
					if ray then
						part.Material = ray.Instance.Material
						part.Color = ray.Instance.Color
					end
					runService.Stepped:wait()
				end
			end)()
		else
			local ray = G.rayCast(determinedPosition+Vector3.new(0,data.size/2,0),Vector3.new(0,-10,0),data.blacklist)
			if ray then
				part.Material = ray.Instance.Material
				part.Color = ray.Instance.Color
				part.Position = ray.Position
				part.Parent = model
			end
		end
		
	end
	
	coroutine.wrap(function()
		wait((data.speed or 0) + (data.yield or 0))
		
		for i,v in pairs(model:GetChildren()) do
			tweenService:Create(v,TweenInfo.new(data.clearSpeed,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{Size = Vector3.new(0,0,0)}):Play()
			game.Debris:AddItem(v,data.clearSpeed)
			if data.domino then
				wait(data.clearSpeed)
			end
		end
		wait(data.clearSpeed)
		model:Destroy()
	end)()
end


return module
