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
local getMouse = game.ReplicatedStorage.Remotes.Functions.GetMouse
local count = {}

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
local MAX_COMBO = 4
local COMBO_TIME_WINDOW = 0.8
local COMBO_CD = 0.25
local CameraRemote = game.ReplicatedStorage.Remotes.Misc.CameraRemote


--/TODO: Light Sword
function module.LightSword(p)
	local c = p.Character
	require(game.StarterPlayer.StarterPlayerScripts.ClientFramework.Visuals.DemonFruits.LightVFX).LightSword(c)
end

--/TODO: Light Melee
function module.Melee(p)
	local c = typeof(p) == "Instance" and p.Character or p.Model
	local cooldowns = c.Cooldowns
	local states = c.States

	local skillName = "Melee"

	local skillData = attackData.getData(script.Name,skillName)
	local damage = skillData.baseDamage + dataStore.GetData(p, "Strength")
	local knockback = false

	local HumanoidRootpart = typeof(p) == "Instance" and c.HumanoidRootPart or p.Torso

	if cooldowns:GetAttribute(skillName) then return end

	cooldownHandler.addCooldown(c,script.Name, skillName,COMBO_CD)
	staminaHandler.checkStamina(c,"Light",skillName)

	if not count[p.Name] then
		count[p.Name] = 1
	end

	--SharedFunctions:FireAllDistanceClients(c, script.Name, 25, {CurrentCombo = count[p.Name], Character = c, Function = "CombatSwing"})

	if (os.clock()-states:GetAttribute("MeleeClicked")) > COMBO_TIME_WINDOW or count[p.Name] >= MAX_COMBO then
		if count[p.Name] >= MAX_COMBO then
			damage += math.random(5)
			knockback = true
		end
		count[p.Name] = 1
	else
		count[p.Name] += 1
	end


	local target = damageModule.getGTP(p,Vector3.new(5,5,5),HumanoidRootpart.CFrame*CFrame.new(0,0,-2.5),true)
	if target then
		if target:FindFirstChild("PseudoTorso") then 
			if target:GetAttribute("Health") <= 0 then return end 
		else
			if target.Humanoid.Health <= 0 then return end
		end

		local logiaCheck = damageModule.damageSNG(p,target,damage,{script.Name,skillName})
		if not logiaCheck then
			SharedFunctions:FireAllDistanceClients(c, script.Name, 25, {Target = target, Character = c, Function = "CombatHit"})
			if knockback then
				if target:FindFirstChild("PseudoTorso") then 
					TweenService:Create(target.PseudoTorso,TweenInfo.new(.6),{Position = (c.HumanoidRootPart.CFrame * CFrame.new(0,0,-50)).Position}):Play()
				end
				SharedFunctions:FireAllDistanceClients(c, script.Name, 25, {Target = target, Character = c, Function = "Knockback"})
			end
		end
	end

	states:SetAttribute("MeleeClicked",os.clock())
end

--/TODO: MOVE DESCRIPTION
function module.Move1(p)
	local c = p.Character
	local cooldowns = c.Cooldowns
	local states = c.States
	local mousePos = getMouse:InvokeClient(p)
	
	local skillName = "LightKick"

	local skillData = attackData.getData(script.Name,skillName)
	local damage = skillData.baseDamage + dataStore.GetData(p, "Fruit")
	
	if cooldowns:GetAttribute(skillName) then return end
	cooldownHandler.addCooldown(c,"Light",skillName)
	staminaHandler.checkStamina(c,"Light",skillName)


	local projectileCFrame = CFrame.lookAt(c.HumanoidRootPart.CFrame*CFrame.new(0,0,-1).Position, mousePos)
	local points = hitDetection:GetPoints(projectileCFrame,5,5)
	local projectileData = {
		Points = points,
		Direction = projectileCFrame.lookVector,
		Velocity = 1000,
		Iterations = 50,
		Lifetime = 2,
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

	local skillName = "LightMirror"

	local skillData = attackData.getData(script.Name,skillName)
	local damage = skillData.baseDamage + dataStore.GetData(p, "Fruit")
	
	if cooldowns:GetAttribute(skillName) then return end
	cooldownHandler.addCooldown(c,"Light",skillName)
	staminaHandler.checkStamina(c,"Light",skillName)
	
	--[[ Raycast ]]--
	local Root = c.HumanoidRootPart
	local StartPosition = (Root.Position)
	local EndPosition = (mousePos - StartPosition).Unit * 500

	local RayData = RaycastParams.new()
	RayData.FilterDescendantsInstances = {c, Live, Visual} or Visual
	RayData.FilterType = Enum.RaycastFilterType.Blacklist
	RayData.IgnoreWater = true

	local ray = workspace:Raycast(StartPosition, EndPosition, RayData)
	if ray then

		local partHit, pos, normVector = ray.Instance, ray.Position, ray.Normal
		
		local Magnitude = (StartPosition - pos).Magnitude
		
		SharedFunctions:FireAllDistanceClients(c, script.Name, 200, {Magnitude = Magnitude, pos = pos, Character = c, Function = "CastMirrors"})
		Root.Anchored = true
		wait(1.5)
		Root.Anchored = false
		local projectileCFrame = CFrame.lookAt(pos + Vector3.new(0,5,0), (pos - Vector3.new(0,1,0)))
		local points = hitDetection:GetPoints(projectileCFrame,5,5)
		local projectileData = {
			Points = points,
			Direction = projectileCFrame.lookVector,
			Velocity = 500,
			Iterations = 50,
			Lifetime = 2,
			Visualize = false,
			Ignore = {c,Visual},
		}

		SharedFunctions:FireAllDistanceClients(c, script.Name, 200, {Shockwave = true, projectileCFrame = projectileCFrame, projectileData = projectileData, Character = c, Function = "Move1"})
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
end

--/TODO: MOVE DESCRIPTION
function module.Move3(p, chargeUp)
	local c = p.Character
	local cooldowns = c.Cooldowns
	local states = c.States
	local mousePos = getMouse:InvokeClient(p)

	local skillName = "LightFlight"

	if chargeUp ~= "Release" then
		if cooldowns:GetAttribute(skillName) then return end
		cooldownHandler.addCooldown(c,"Light",skillName)
		staminaHandler.checkStamina(c,"Light",skillName)
	end

	if chargeUp and chargeUp ~= "Release" then
		collectionService:AddTag(c,"LightFlight")
		
		
		for _,v in ipairs(script.ParticleAttachment:GetChildren()) do
			local Particle = v:Clone()
			Particle:Emit(10)
			Particle.Enabled = true
			Particle.Parent = c.Torso.WaistCenterAttachment
		end
		
		for _, v in ipairs(c:GetDescendants()) do
			if (v.Name ~= "HumanoidRootPart") and (v:IsA("MeshPart") or v:IsA("BasePart")) then
				v.Transparency = 1
			end
		end
		
		SharedFunctions:FireAllDistanceClients(c, script.Name, 1000, {States = states, Character = c, Function = "Move3"})
		return
	end
	if collectionService:HasTag(c, "LightFlight") then
		for _,v in ipairs(c.Torso.WaistCenterAttachment:GetChildren()) do
			if v.Name == "Rays" or v.Name == "Spark" or v.Name == "Star" or v.Name == "Wave" then
				v.Enabled = false
				v:Emit(2)
				v:Destroy()
			end
		end

		for _, v in ipairs(c:GetDescendants()) do
			if (v.Name ~= "HumanoidRootPart") and (v:IsA("MeshPart") or v:IsA("BasePart")) then
				v.Transparency = 0
			end
		end
		collectionService:RemoveTag(c,"LightFlight")
	end
end

--/TODO: MOVE DESCRIPTION
function module.Move4(p)
	local c = p.Character
	local cooldowns = c.Cooldowns
	local states = c.States
	local mousePos = getMouse:InvokeClient(p)

	local skillName = "LightJewels"

	local _ = (c.HumanoidRootPart:FindFirstChild("PikaJewelsHold") and c.HumanoidRootPart:FindFirstChild("PikaJewelsHold"):Destroy())
	--local skillData = attackData.getData(script.Name,skillName)
	--local damage = skillData.baseDamage + dataStore.Get(p,"Fruit")
	if cooldowns:GetAttribute(skillName) then return end
	cooldownHandler.addCooldown(c,"Light",skillName)
	staminaHandler.checkStamina(c,"Light",skillName)


	--SharedFunctions:FireAllDistanceClients(c, script.Name, 100, {Character = c, Function = "Move4"})
end

--/TODO: MOVE DESCRIPTION
function module.JewelsHold(p)
	local c = p.Character
	local cooldowns = c.Cooldowns
	local states = c.States

	local skillName = "LightJewels"

	local skillData = attackData.getData(script.Name,skillName)
	local damage = skillData.baseDamage + dataStore.GetData(p, "Fruit")
	
	
	if cooldowns:GetAttribute(skillName) then return end
	cooldownHandler.addCooldown(c,"Light",skillName)
	staminaHandler.checkStamina(c,"Light",skillName)
	
	local Val = Instance.new("BoolValue")
	Val.Name = "PikaJewelsHold"
	Val.Parent = c.HumanoidRootPart
	
	while c.HumanoidRootPart:FindFirstChild("PikaJewelsHold") do
		spawn(function()
			local mousePos = getMouse:InvokeClient(p)
			local projectileCFrame = CFrame.lookAt(c.HumanoidRootPart.CFrame*CFrame.new(0,0,-1).Position, mousePos + Vector3.new(math.random(-5,5),0,math.random(-5,5)))
			local points = hitDetection:GetPoints(projectileCFrame,5,5)
			local projectileData = {
				Points = points,
				Direction = projectileCFrame.lookVector,
				Velocity = 500,
				Iterations = 50,
				Lifetime = 2,
				Visualize = false,
				Ignore = {c,Visual},
			}

			SharedFunctions:FireAllDistanceClients(c, script.Name, 200, {projectileCFrame = projectileCFrame, projectileData = projectileData, Character = c, Function = "Move4"})
			local hitPoint = hitDetection:ProjectileActive(projectileData)

			--/Damage
			if hitPoint then
				local targets = damageModule.getAOE(c,hitPoint,10)
				for i = 1,#targets do
					local target = targets[i]

					damageModule.damageSNG(p,target,damage,{script.Name,skillName})
				end
			end
		end)
		wait(0.1)
	end	
end

--/Events
attackRemote.OnServerEvent:connect(function(p,action,info)
	if module[action] then
		module[action](p,info)
	end
end)


return module
