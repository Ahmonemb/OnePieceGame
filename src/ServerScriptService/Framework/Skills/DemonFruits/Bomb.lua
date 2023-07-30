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
local staminaHandler = require(frameWork.Handlers.StaminaHandler)
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

	local skillName = "NoseCannon"

	local skillData = attackData.getData(script.Name,skillName)
	local damage = skillData.baseDamage + dataStore.GetData(p, "Fruit")
	
	if cooldowns:GetAttribute(skillName) then return end
	cooldownHandler.addCooldown(c,"Bomb",skillName)
	staminaHandler.checkStamina(c,"Bomb",skillName)

	local projectileCFrame = CFrame.lookAt(c.HumanoidRootPart.CFrame*CFrame.new(0,0,-1).Position, mousePos)
	local points = hitDetection:GetPoints(projectileCFrame,5,5)
	local projectileData = {
		Points = points,
		Direction = projectileCFrame.lookVector,
		Velocity = 500,
		Iterations = 50,
		Lifetime = 0.5,
		Visualize = false,
		Ignore = {c,Visual},
	}
	
	SharedFunctions:FireAllDistanceClients(c, script.Name, 200, {projectileCFrame = projectileCFrame, projectileData = projectileData, Character = c, Function = "Move1"})
	local hitPoint = hitDetection:ProjectileActive(projectileData)

	--/Damage
	if hitPoint then
		
		CameraRemote:FireClient(p, "CameraShake", {FirstText = 4, SecondText = 6})
		
		local targets = damageModule.getAOE(c,hitPoint,30)
		for i = 1,#targets do
			local target = targets[i]
			
			damageModule.damageSNG(p,target,damage,{script.Name,skillName})
		end
	end
end

--/TODO: MOVE DESCRIPTION
function module.Move2(p)
	local c = p.Character
	local cooldowns = c.Cooldowns
	local states = c.States
	local mousePos = getMouse:InvokeClient(p)

	local skillName = "Landmine"

	local skillData = attackData.getData(script.Name,skillName)
	local damage = skillData.baseDamage + dataStore.GetData(p, "Fruit")
	
	if cooldowns:GetAttribute(skillName) then return end
	cooldownHandler.addCooldown(c,"Bomb",skillName)
	staminaHandler.checkStamina(c,"Bomb",skillName)


	local Val = c:FindFirstChild("ExplosionPlant") or warn('does not exist')
	local PlantCFrame = Val.Value	
	Val:Destroy()
	
	CameraRemote:FireClient(p, "CameraShake", {FirstText = 3, SecondText = 9})

	SharedFunctions:FireAllDistanceClients(c, script.Name, 200, {PlantCFrame = PlantCFrame, Character = c, Function = "Move2"})
	
	--/Damage
	local hitPoint = PlantCFrame.Position
	if hitPoint then

		CameraRemote:FireClient(p, "CameraShake", {FirstText = 4, SecondText = 6})

		local targets = damageModule.getAOE(c,hitPoint,20)
		for i = 1,#targets do
			local target = targets[i]

			damageModule.damageSNG(p,target,damage,{script.Name,skillName})
		end
	end
end

--/TODO: MOVE DESCRIPTION
function module.Move3(p)
	local c = p.Character
	local cooldowns = c.Cooldowns
	local states = c.States
	local mousePos = getMouse:InvokeClient(p)

	local skillName = "BombLeap"

	--local skillData = attackData.getData(script.Name,skillName)
	--local damage = skillData.baseDamage + dataStore.Get(p,"Fruit")
	if cooldowns:GetAttribute(skillName) then return end
	cooldownHandler.addCooldown(c,"Bomb",skillName)
	staminaHandler.checkStamina(c,"Bomb",skillName)

	SharedFunctions:FireAllDistanceClients(c, script.Name, 200, {Character = c, Function = "Move3"})
end

--/TODO: MOVE DESCRIPTION
function module.Move4(p)
	local c = p.Character
	local cooldowns = c.Cooldowns
	local states = c.States
	local mousePos = getMouse:InvokeClient(p)

	local _ = (c.HumanoidRootPart:FindFirstChild("ExplosionCharge") and c.HumanoidRootPart:FindFirstChild("ExplosionCharge"):Destroy())
	

	local skillName = "SelfDetonate"

	local skillData = attackData.getData(script.Name,skillName)
	local damage = skillData.baseDamage + dataStore.GetData(p, "Fruit")
	
	if cooldowns:GetAttribute(skillName) then return end
	cooldownHandler.addCooldown(c,"Bomb",skillName)
	staminaHandler.checkStamina(c,"Bomb",skillName)

	
	CameraRemote:FireClient(p, "CameraShake", {FirstText = 6, SecondText = 9})
	
	SharedFunctions:FireAllDistanceClients(c, script.Name, 100, {Character = c, Function = "Move4"})
	
	--/Damage
	local hitPoint = c.HumanoidRootPart.Position
	if hitPoint then

		CameraRemote:FireClient(p, "CameraShake", {FirstText = 4, SecondText = 6})

		local targets = damageModule.getAOE(c,hitPoint,60)
		for i = 1,#targets do
			local target = targets[i]

			damageModule.damageSNG(p,target,damage,{script.Name,skillName})
		end
	end
end

--/TODO: MOVE DESCRIPTION
function module.ChargeUp(p)
	local c = p.Character
	local cooldowns = c.Cooldowns
	local states = c.States
	local mousePos = getMouse:InvokeClient(p)

	local Val = Instance.new("BoolValue")
	Val.Name = "ExplosionCharge"
	Val.Parent = c.HumanoidRootPart

	SharedFunctions:FireAllDistanceClients(c, script.Name, 500, {Character = c, Function = "ChargeUp"})
end

--/TODO: MOVE DESCRIPTION
function module.Plant(p)
	local c = p.Character
	local cooldowns = c.Cooldowns
	local states = c.States
	local mousePos = getMouse:InvokeClient(p)
	
	local PlantCFrame = c.HumanoidRootPart.CFrame
	
	--// Raycast Plant Position
	local StartPosition = c.HumanoidRootPart.Position
	local EndPosition = CFrame.new(StartPosition).UpVector * -100

	local RayData = RaycastParams.new()
	RayData.FilterDescendantsInstances = {c, Live, Visual} or Visual
	RayData.FilterType = Enum.RaycastFilterType.Exclude
	RayData.IgnoreWater = true

	local ray = game.Workspace:Raycast(StartPosition, EndPosition, RayData)
	if ray then

		local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
		if partHit then
			PlantCFrame = CFrame.new(pos)
		end
	end	
	
	local Val = Instance.new("CFrameValue")
	Val.Name = "ExplosionPlant"
	Val.Value = PlantCFrame
	Val.Parent = c

	SharedFunctions:FireAllDistanceClients(c, script.Name, 500, {PlantCFrame = PlantCFrame, Character = c, Function = "Plant"})
end

--/Events
attackRemote.OnServerEvent:connect(function(p,action,info)
	if module[action] then
		module[action](p,info)
	end
end)


return module
