--/Services
local collectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--/Modules
local frameWork = script.Parent.Parent.Parent
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)
local cooldownHandler = require(frameWork.Handlers.CooldownHandler)
local staminaHandler = require(frameWork.Handlers.StaminaHandler)
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

	local skillName = "FireFist"

	local skillData = attackData.getData(script.Name,skillName)
	local damage = skillData.baseDamage + dataStore.GetData(p, "Fruit")

	if cooldowns:GetAttribute(skillName) then return end
	cooldownHandler.addCooldown(c,"Flame",skillName)
	staminaHandler.checkStamina(c,"Flame",skillName)

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

	local skillName = "FirePillar"

	local skillData = attackData.getData(script.Name,skillName)
	local damage = skillData.baseDamage + dataStore.GetData(p, "Fruit")
	
	if cooldowns:GetAttribute(skillName) then return end
	cooldownHandler.addCooldown(c,"Flame",skillName)
	staminaHandler.checkStamina(c,"Flame",skillName)

	SharedFunctions:FireAllDistanceClients(c, script.Name, 100, {Character = c, Function = "Move2"})
	
	--/Damage
	for _ = 1,10 do
		local hitPoint = c.HumanoidRootPart.Position
		if hitPoint then

			CameraRemote:FireClient(p, "CameraShake", {FirstText = 2, SecondText = 2})

			local targets = damageModule.getAOE(c,hitPoint,60)
			for i = 1,#targets do
				local target = targets[i]

				damageModule.damageSNG(p,target,damage,{script.Name,skillName})
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

	local skillName = "FireFlight"
	if chargeUp ~= "Release" then
		if cooldowns:GetAttribute(skillName) then return end
		cooldownHandler.addCooldown(c,"Flame",skillName)
		staminaHandler.checkStamina(c,"Flame",skillName)
	end

	if chargeUp and chargeUp ~= "Release" then
		collectionService:AddTag(c,"FireFlight")
		
		local charge = Assets.VFX.DemonFruits.Flame.FlameFlight.bodyFire:Clone()
		charge.Enabled = true
		charge.Parent = c.Torso.WaistCenterAttachment

		c["Left Leg"].Transparency = 1
		c["Right Leg"].Transparency = 1
		
		SharedFunctions:FireAllDistanceClients(c, script.Name, 1000, {States = states, Character = c, Function = "Move3"})
		return
	end

	if collectionService:HasTag(c, "FireFlight") then
		local charge = c.Torso.WaistCenterAttachment:FindFirstChild("bodyFire")
		charge.Enabled = false
		game.Debris:AddItem(charge,1)

		c["Left Leg"].Transparency = 0
		c["Right Leg"].Transparency = 0
		
		collectionService:RemoveTag(c,"FireFlight")
	end
	
end


--/TODO: MOVE DESCRIPTION
function module.Move4(p)
	local c = p.Character
	local cooldowns = c.Cooldowns
	local states = c.States
	local mousePos = getMouse:InvokeClient(p)

	local skillName = "FireFlies"

	local _ = (c.HumanoidRootPart:FindFirstChild("FireFlyHold") and c.HumanoidRootPart:FindFirstChild("FireFlyHold"):Destroy())
	--local skillData = attackData.getData(script.Name,skillName)
	--local damage = skillData.baseDamage + dataStore.Get(p,"Fruit")
	if cooldowns:GetAttribute(skillName) then return end
	cooldownHandler.addCooldown(c,"Flame",skillName)
	staminaHandler.checkStamina(c,"Flame",skillName)


	--SharedFunctions:FireAllDistanceClients(c, script.Name, 100, {Character = c, Function = "Move4"})
end

--/TODO: MOVE DESCRIPTION
function module.FireFlyHold(p)
	local c = p.Character
	local cooldowns = c.Cooldowns
	local states = c.States

	local skillName = "FireFlies"

	local skillData = attackData.getData(script.Name,skillName)
	local damage = skillData.baseDamage + dataStore.GetData(p, "Fruit")

	if cooldowns:GetAttribute(skillName) then return end
	cooldownHandler.addCooldown(c,"Flame",skillName)
	staminaHandler.checkStamina(c,"Flame",skillName)

	local Val = Instance.new("BoolValue")
	Val.Name = "FireFlyHold"
	Val.Parent = c.HumanoidRootPart

	while c.HumanoidRootPart:FindFirstChild("FireFlyHold") do
		task.spawn(function()
			local mousePos = getMouse:InvokeClient(p)
			local projectileCFrame = CFrame.lookAt(c.HumanoidRootPart.CFrame*CFrame.new(0,0,-1).Position, mousePos + Vector3.new(math.random(-5,5),0,math.random(-5,5)))
			local points = hitDetection:GetPoints(projectileCFrame,5,5)
			local projectileData = {
				Points = points,
				Direction = projectileCFrame.lookVector,
				Velocity = 300,
				Iterations = 50,
				Lifetime = 5,
				Visualize = false,
				Ignore = {c,Visual},
			}

			SharedFunctions:FireAllDistanceClients(c, script.Name, 200, {projectileCFrame = projectileCFrame, projectileData = projectileData, Character = c, Function = "Move4"})
			local hitPoint = hitDetection:ProjectileActive(projectileData)

			--/Damage
			if hitPoint then
				
				local targets = damageModule.getAOE(c,hitPoint,30)
				for i = 1,#targets do
					local target = targets[i]

					damageModule.damageSNG(p,target,damage,{script.Name,skillName})
				end
			end
		end)
		task.wait(0.1)
	end	
end

--/Events
attackRemote.OnServerEvent:connect(function(p,action,info)
	if module[action] then
		module[action](p,info)
	end
end)


return module
