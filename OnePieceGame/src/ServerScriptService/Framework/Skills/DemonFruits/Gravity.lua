--/Services
local collectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--/Modules
local frameWork = script.Parent.Parent.Parent
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)
local cooldownHandler = require(frameWork.Handlers.CooldownHandler)
local stateHandler = require(frameWork.Handlers.StateHandler)
local attackData = require(game.ReplicatedStorage.Modules.Manager.AttackData)
local damageModule = require(frameWork.Misc.Damage)
local dataStore = require(frameWork.Systems.Datastore)
local bezierCurve = require(game.ReplicatedStorage.Modules.Misc.BezierCurves)
local hitDetection = require(game.ReplicatedStorage.Modules.Misc.HitDetection)
local module = {}

--/Variables
local attackRemote = game.ReplicatedStorage.Remotes.DemonFruits[script.Name]
local clientRemote = game.ReplicatedStorage.Remotes.Misc.ClientRemote
local CameraRemote = game.ReplicatedStorage.Remotes.Misc.CameraRemote
local getMouse = game.ReplicatedStorage.Remotes.Functions.GetMouse

--// Modules
local Modules = ReplicatedStorage.Modules
local SharedFunctions = require(Modules.SharedFunctions)

--// Wunbo Variables
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Modules = ReplicatedStorage.Modules
local Debris = require(Modules.Misc.Debris)
local VFXHandler = require(Modules.VFX.VFXHandler)
local Assets = ReplicatedStorage.Assets
local VFXEffects = Assets.VFXEffects
local World = game.Workspace:WaitForChild("World")
local Visual = World.Visual
local Live = World.Live
local SharedFunctions = require(Modules.SharedFunctions)


--/TODO: MOVE DESCRIPTION
function module.Move1(p)
	local c = p.Character
	local cooldowns = c.Cooldowns
	local states = c.States
	local mousePos = getMouse:InvokeClient(p)

	local skillName = "Gravity Push"

	local skillData = attackData.getData(script.Name,skillName)
	local damage = skillData.baseDamage + dataStore.GetData(p, "Fruit")
	
	if cooldowns:GetAttribute(skillName) then return end
	cooldownHandler.addCooldown(c,skillName)

	SharedFunctions:FireAllDistanceClients(c, script.Name, 200, {Character = c, Function = "Move1"})
	local RootStartCFrame = c.HumanoidRootPart.CFrame
	
	--/Damage
	for j = 1,5 do
		local hitPoint = (RootStartCFrame * CFrame.new(0,0,-j * 5)).Position
		if hitPoint then

			CameraRemote:FireClient(p, "CameraShake", {FirstText = 4, SecondText = 6})

			local targets = damageModule.getAOE(c,hitPoint,20)
			for i = 1,#targets do
				local target = targets[i]

				damageModule.damageSNG(p,target,damage,{script.Name,skillName})
				SharedFunctions:FireAllDistanceClients(c, script.Name, 200, {Target = target, Character = c, Function = "TargetPush"})
			end
		end
	end
	
end

--/TODO: MOVE DESCRIPTION
function module.Move2(p)
	local c = p.Character
	local cooldowns = c.Cooldowns
	local states = c.States
	local mousePos = getMouse:InvokeClient(p)

	local skillName = "Infinite Gravity"

	local skillData = attackData.getData(script.Name,skillName)
	local damage = skillData.baseDamage + dataStore.GetData(p, "Fruit")
	
	if cooldowns:GetAttribute(skillName) then return end
	cooldownHandler.addCooldown(c,skillName)

	SharedFunctions:FireAllDistanceClients(c, script.Name, 200, {Character = c, Function = "Move2"})
	SharedFunctions:FireAllDistanceClients(c, script.Name, 30, {Character = c, Function = "Screen"})
	
	SharedFunctions:BodyPosition(c.HumanoidRootPart, 200, 25, Vector3.new(1e5,1e5,1e5), c.HumanoidRootPart.Position, 1)
	--/Damage
	for _ = 1,10 do
		local hitPoint = c.HumanoidRootPart.Position
		if hitPoint then

			CameraRemote:FireClient(p, "CameraShake", {FirstText = 2, SecondText = 2})

			local targets = damageModule.getAOE(c,hitPoint,30)
			for i = 1,#targets do
				local target = targets[i]
				damageModule.damageSNG(p,target,damage,{script.Name,skillName})
				if target:FindFirstChild("HumanoidRootPart") then
					SharedFunctions:BodyPosition(target.HumanoidRootPart, 200, 25, Vector3.new(1e5,1e5,1e5), target.HumanoidRootPart.Position, 1)
				end	
			end
		end
		wait(0.1)
	end
end

--/TODO: MOVE DESCRIPTION
function module.Move3(p, chargeUp)
	local c = p.Character
	local cooldowns = c.Cooldowns
	local states = c.States
	local mousePos = getMouse:InvokeClient(p)

	local skillName = "Move3"

	if cooldowns:GetAttribute(skillName) then return end
	cooldownHandler.addCooldown(c,skillName)

	if chargeUp then
		collectionService:AddTag(c,"GravityFlight")
		
		local flatrock = VFXEffects.Mesh.flatrock:Clone()
		local RayData = RaycastParams.new()
		RayData.FilterDescendantsInstances = {c, Live, Visual} or Visual
		RayData.FilterType = Enum.RaycastFilterType.Blacklist
		RayData.IgnoreWater = true
		local ray = game.Workspace:Raycast(c.HumanoidRootPart.Position, c.HumanoidRootPart.Position - Vector3.new(0,10,0), RayData)
		if ray then

			local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
			if partHit then
				flatrock.Material = partHit.Material
				flatrock.Color = partHit.Color
			end
		end	
		
		local weld = Instance.new("Weld")
		flatrock.CFrame = c.HumanoidRootPart.CFrame * CFrame.new(0, -5.5, 0)

		weld.Part0 = c.HumanoidRootPart
		weld.C0 = c.HumanoidRootPart.CFrame:inverse()
		weld.Part1 = flatrock                            
		weld.C1 = flatrock.CFrame:inverse()
		flatrock.Massless = true
		weld.Parent = flatrock
		flatrock.Parent = c

		SharedFunctions:FireAllDistanceClients(c, script.Name, 1000, {States = states, Character = c, Function = "Move3"})
		return
	end
	
	for _,v in ipairs(c:GetChildren()) do
		if v.Name == "flatrock" then
			v:Destroy()
		end
	end
	collectionService:RemoveTag(c,"GravityFlight")
end

--/TODO: MOVE DESCRIPTION
function module.Move4(p)
	local c = p.Character
	local cooldowns = c.Cooldowns
	local states = c.States
	local mousePos = getMouse:InvokeClient(p)

	local skillName = "Meteor"

	local skillData = attackData.getData(script.Name,skillName)
	local damage = skillData.baseDamage + dataStore.GetData(p, "Fruit")
	
	if cooldowns:GetAttribute(skillName) then return end
	cooldownHandler.addCooldown(c,skillName)
	
	local Offset = 100
	if math.random(1,2) == 1 then
		Offset *= -1
	end
	local MeteorStartPos = c.HumanoidRootPart.CFrame*CFrame.new(Offset,100,Offset).Position
	local projectileCFrame = CFrame.lookAt(MeteorStartPos, mousePos)
	
	local points = hitDetection:GetPoints(projectileCFrame,5,5)
	local projectileData = {
		Points = points,
		Direction = projectileCFrame.lookVector,
		Velocity = 200,
		Iterations = 50,
		Lifetime = 5,
		Visualize = false,
		Ignore = {c,Visual},
	}

	SharedFunctions:FireAllDistanceClients(c, script.Name, 200, {projectileCFrame = projectileCFrame, projectileData = projectileData, Character = c, Function = "Move4"})
	local hitPoint = hitDetection:ProjectileActive(projectileData)

	--/Damage
	if hitPoint then

		CameraRemote:FireClient(p, "CameraShake", {FirstText = 4, SecondText = 6})

		local targets = damageModule.getAOE(c,hitPoint,50)
		for i = 1,#targets do
			local target = targets[i]

			damageModule.damageSNG(p,target,damage,{script.Name,skillName})
		end
	end
end

--/Events
attackRemote.OnServerEvent:connect(function(p,action,info)
	if module[action] then
		module[action](p,info)
	end
end)


return module
