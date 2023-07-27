--/Services
local collectionService = game:GetService("CollectionService")
local tweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--/Modules
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)
local cooldownHandler = require(script.Parent.Parent.Parent.Handlers.CooldownHandler)
local stateHandler = require(script.Parent.Parent.Parent.Handlers.StateHandler)
local attackData = require(game.ReplicatedStorage.Modules.Manager.AttackData)
local damageModule = require(script.Parent.Parent.Parent.Misc.Damage)
local dataStore = require(script.Parent.Parent.Parent.Systems.Datastore)
local hitDetection = require(game.ReplicatedStorage.Modules.Misc.HitDetection)
local module = {}

--/Variables
local attackRemote = game.ReplicatedStorage.Remotes.FightingStyles[script.Name]
local clientRemote = game.ReplicatedStorage.Remotes.Misc.ClientRemote
local getMouse = game.ReplicatedStorage.Remotes.Functions.GetMouse
local CameraRemote = game.ReplicatedStorage.Remotes.Misc.CameraRemote
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
local SoundManager = require(Modules.Manager.SoundManager)

local MAX_COMBO = 4
local COMBO_TIME_WINDOW = 0.8
local COMBO_CD = 0.25

--/TODO: Light Sword
function module.OneSwordStyle(p)
	local c = p.Character
	require(game.StarterPlayer.StarterPlayerScripts.ClientFramework.Visuals.FightingStyles.OneSwordStyleVFX).OneSwordStyle({Character = c})
	--SharedFunctions:FireAllDistanceClients(c, script.Name, 1000, {Character = c, Function = "OneSwordStyle"})
end

--/TODO: Simple melee combat

function module.Melee(p)
	local c = typeof(p) == "Instance" and p.Character or p.Model
	local cooldowns = c.Cooldowns
	local states = c.States
	
	local skillName = "Melee"

	local skillData = attackData.getData(script.Name,skillName)
	local damage = skillData.baseDamage + dataStore.GetData(p, "Weapon")
	
	local knockback = false
	
	local HumanoidRootpart = typeof(p) == "Instance" and c.HumanoidRootPart or p.Torso
	
	if cooldowns:GetAttribute(skillName) then return end
	
	cooldownHandler.addCooldown(c,script.Name, skillName,COMBO_CD)
	
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
					tweenService:Create(target.PseudoTorso,TweenInfo.new(.6),{Position = (c.HumanoidRootPart.CFrame * CFrame.new(0,0,-50)).Position}):Play()
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

	local skillName = "36 Caliber Phoenix"

	local skillData = attackData.getData(script.Name,skillName)
	local damage = skillData.baseDamage + dataStore.GetData(p, "Weapon")

	if cooldowns:GetAttribute(skillName) then return end
	cooldownHandler.addCooldown(c,skillName)

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

		local targets = damageModule.getAOE(c,hitPoint,20)
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

	local skillName = "Rapid Slashes"

	local skillData = attackData.getData(script.Name,skillName)
	local damage = skillData.baseDamage + dataStore.GetData(p, "Weapon")
	
	if cooldowns:GetAttribute(skillName) then return end
	cooldownHandler.addCooldown(c,skillName)

	SharedFunctions:FireAllDistanceClients(c, script.Name, 200, {Character = c, Function = "Move2"})
	
	for _ = 1, 6 do
		local hitPoint = (c.HumanoidRootPart.CFrame * CFrame.new(0,0,-2)).Position

		--/Damage
		if hitPoint then

			CameraRemote:FireClient(p, "CameraShake", {FirstText = 4, SecondText = 6})

			local targets = damageModule.getAOE(c,hitPoint,10)
			for i = 1,#targets do
				local target = targets[i]

				damageModule.damageSNG(p,target,damage,{script.Name,skillName})
			end
		end
		wait(0.1)
	end
end

--/TODO: MOVE DESCRIPTION
function module.Move3(p)
	local c = p.Character
	local cooldowns = c.Cooldowns
	local states = c.States
	local mousePos = getMouse:InvokeClient(p)

	local skillName = "Lion's Song"

	local skillData = attackData.getData(script.Name,skillName)
	local damage = skillData.baseDamage + dataStore.GetData(p, "Weapon")
	
	if cooldowns:GetAttribute(skillName) then return end
	cooldownHandler.addCooldown(c,skillName)
	
	for _, v in ipairs(c.HumanoidRootPart:GetDescendants()) do
		if v:IsA("BodyGyro") or v:IsA("BodyPosition") then
			v:Destroy()
		end
	end
	
	local Root = c.HumanoidRootPart
	
	local MAX_DISTANCE = 50
	local BodyPosition = Instance.new("BodyPosition")
	BodyPosition.Position = (Root.CFrame * CFrame.new(0,0,-MAX_DISTANCE)).Position
	BodyPosition.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	BodyPosition.P = 200;
	BodyPosition.D = 25;
	BodyPosition.Parent = Root

	Debris:AddItem(BodyPosition,1)

	SharedFunctions:FireAllDistanceClients(c, script.Name, 200, {Character = c, Function = "Move3"})
	SharedFunctions:FireAllDistanceClients(c, script.Name, 10, {Character = c, Function = "Screen"})
	
	for _ = 1, 5 do
		local hitPoint = (c.HumanoidRootPart.CFrame * CFrame.new(0,0,-2)).Position

		--/Damage
		if hitPoint then

			CameraRemote:FireClient(p, "CameraShake", {FirstText = 4, SecondText = 6})

			local targets = damageModule.getAOE(c,hitPoint,10)
			for i = 1,#targets do
				local target = targets[i]

				damageModule.damageSNG(p,target,damage,{script.Name,skillName})
			end
		end
		wait(0.05)
	end
end

--/Events
attackRemote.OnServerEvent:connect(function(p,action,info)
	if module[action] then
		module[action](p,info)
	end
end)


return module
