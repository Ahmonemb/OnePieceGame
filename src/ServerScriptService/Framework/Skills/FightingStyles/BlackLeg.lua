--/Services
local tweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--/Modules
local cooldownHandler = require(script.Parent.Parent.Parent.Handlers.CooldownHandler)
local attackData = require(game.ReplicatedStorage.Modules.Manager.AttackData)
local damageModule = require(script.Parent.Parent.Parent.Misc.Damage)
local dataStore = require(script.Parent.Parent.Parent.Systems.Datastore)
local module = {}

--/Variables
local attackRemote = game.ReplicatedStorage.Remotes.FightingStyles[script.Name]
local CameraRemote = game.ReplicatedStorage.Remotes.Misc.CameraRemote
local getMouse = game.ReplicatedStorage.Remotes.Functions.GetMouse
local count = {}

--// Modules

--// Wunbo Variables
local Modules = ReplicatedStorage.Modules
local Debris = require(Modules.Misc.Debris)
local World = game.Workspace:WaitForChild("World")
local Visual = World.Visual
local Live = World.Live
local SharedFunctions = require(Modules.SharedFunctions)

local MAX_COMBO = 4
local COMBO_TIME_WINDOW = 0.8
local COMBO_CD = 0.25
--/TODO: Simple melee combat

function module.Melee(p)
	local c = typeof(p) == "Instance" and p.Character or p.Model
	local cooldowns = c.Cooldowns
	local states = c.States

	local skillName = "Melee"

	local skillData = attackData.getData(script.Name, skillName)
	local damage = skillData.baseDamage + dataStore.GetData(p, "Strength")
	local knockback = false

	local HumanoidRootpart = typeof(p) == "Instance" and c.HumanoidRootPart or p.Torso

	if cooldowns:GetAttribute(skillName) then
		return
	end

	cooldownHandler.addCooldown(c, script.Name, skillName, COMBO_CD)

	if not count[p.Name] then
		count[p.Name] = 1
	end

	--SharedFunctions:FireAllDistanceClients(c, script.Name, 25, {CurrentCombo = count[p.Name], Character = c, Function = "CombatSwing"})

	if (os.clock() - states:GetAttribute("MeleeClicked")) > COMBO_TIME_WINDOW or count[p.Name] >= MAX_COMBO then
		if count[p.Name] >= MAX_COMBO then
			damage += math.random(5)
			knockback = true
		end
		count[p.Name] = 1
	else
		count[p.Name] += 1
	end

	local target = damageModule.getGTP(p, Vector3.new(5, 5, 5), HumanoidRootpart.CFrame * CFrame.new(0, 0, -2.5), true)
	if target then
		if target:FindFirstChild("PseudoTorso") then
			if target:GetAttribute("Health") <= 0 then
				return
			end
		else
			if target.Humanoid.Health <= 0 then
				return
			end
		end

		local logiaCheck = damageModule.damageSNG(p, target, damage, { script.Name, skillName })
		if not logiaCheck then
			SharedFunctions:FireAllDistanceClients(
				c,
				script.Name,
				25,
				{ Target = target, Character = c, Function = "CombatHit" }
			)
			if knockback then
				if target:FindFirstChild("PseudoTorso") then
					tweenService
						:Create(
							target.PseudoTorso,
							TweenInfo.new(0.6),
							{ Position = (c.HumanoidRootPart.CFrame * CFrame.new(0, 0, -50)).Position }
						)
						:Play()
				end
				SharedFunctions:FireAllDistanceClients(
					c,
					script.Name,
					25,
					{ Target = target, Character = c, Function = "Knockback" }
				)
			end
		end
	end

	states:SetAttribute("MeleeClicked", os.clock())
end

--/TODO: MOVE DESCRIPTION
function module.Move1(p)
	local c = p.Character
	local cooldowns = c.Cooldowns

	local skillName = "Collier"

	local skillData = attackData.getData(script.Name, skillName)
	local damage = skillData.baseDamage + dataStore.GetData(p, "Strength")

	if cooldowns:GetAttribute(skillName) then
		return
	end
	cooldownHandler.addCooldown(c, skillName)

	SharedFunctions:FireAllDistanceClients(c, script.Name, 200, { Character = c, Function = "Move1" })

	--/Damage
	local hitPoint = c.HumanoidRootPart.Position
	if hitPoint then
		CameraRemote:FireClient(p, "CameraShake", { FirstText = 4, SecondText = 6 })

		local targets = damageModule.getAOE(c, hitPoint, 20)
		for i = 1, #targets do
			local target = targets[i]

			damageModule.damageSNG(p, target, damage, { script.Name, skillName })
		end
	end
end

--/TODO: MOVE DESCRIPTION
function module.Move2(p)
	local c = p.Character
	local cooldowns = c.Cooldowns

	local skillName = "Concassé"

	local skillData = attackData.getData(script.Name, skillName)
	local damage = skillData.baseDamage + dataStore.GetData(p, "Strength")

	if cooldowns:GetAttribute(skillName) then
		return
	end
	cooldownHandler.addCooldown(c, skillName)

	for _, v in ipairs(c.HumanoidRootPart:GetDescendants()) do
		if v:IsA("BodyGyro") or v:IsA("BodyPosition") then
			v:Destroy()
		end
	end

	local BodyPosition = Instance.new("BodyPosition")
	BodyPosition.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	BodyPosition.P = 200
	BodyPosition.D = 25
	BodyPosition.Position = (c.HumanoidRootPart.CFrame * CFrame.new(0, 25, -25)).Position
	BodyPosition.Parent = c.HumanoidRootPart
	Debris:AddItem(BodyPosition, 0.35)
	wait(0.25)

	local BodyPosition1 = Instance.new("BodyPosition")
	BodyPosition1.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	BodyPosition1.P = 200
	BodyPosition1.D = 25
	BodyPosition1.Position = (c.HumanoidRootPart.CFrame * CFrame.new(0, -100, -50)).Position
	BodyPosition1.Parent = c.HumanoidRootPart
	Debris:AddItem(BodyPosition1, 0.25)

	local MAX_MAG = 4
	local SKILL_TIME_ELAPSED = 5

	local oldTime = os.clock()
	while true do
		game:GetService("RunService").Heartbeat:Wait()
		--[[ Raycast ]]
		--
		local StartPosition = c.HumanoidRootPart.Position
		local EndPosition = (c.HumanoidRootPart.CFrame.UpVector * -10)

		local newClock = os.clock()
		if newClock - oldTime >= SKILL_TIME_ELAPSED then
			break
		end

		local RayData = RaycastParams.new()
		RayData.FilterDescendantsInstances = { c, Live, Visual } or Visual
		RayData.FilterType = Enum.RaycastFilterType.Exclude
		RayData.IgnoreWater = true

		local ray = workspace:Raycast(StartPosition, EndPosition, RayData)

		if ray then
			local partHit, pos = ray.Instance or nil, ray.Position or nil
			if partHit then
				--[[ Check if a landing spot is found, otherwise, return false to do a normal landing. ]]
				--
				if (c.HumanoidRootPart.Position - pos).Magnitude < MAX_MAG then
					break
				end
			end
		end
	end
	SharedFunctions:FireAllDistanceClients(c, script.Name, 200, { Character = c, Function = "Move2" })

	--/Damage
	local hitPoint = c.HumanoidRootPart.Position
	if hitPoint then
		CameraRemote:FireClient(p, "CameraShake", { FirstText = 4, SecondText = 6 })

		local targets = damageModule.getAOE(c, hitPoint, 25)
		for i = 1, #targets do
			local target = targets[i]

			damageModule.damageSNG(p, target, damage, { script.Name, skillName })
		end
	end
end

--/TODO: MOVE DESCRIPTION
function module.Move3(p)
	local c = p.Character
	local cooldowns = c.Cooldowns

	local skillName = "Party Table Kick Course"

	local skillData = attackData.getData(script.Name, skillName)
	local damage = skillData.baseDamage + dataStore.GetData(p, "Strength")

	if cooldowns:GetAttribute(skillName) then
		return
	end
	cooldownHandler.addCooldown(c, skillName)

	SharedFunctions:FireAllDistanceClients(c, script.Name, 200, { Character = c, Function = "Move3" })

	for _ = 1, 6 do
		--/Damage
		local hitPoint = c.HumanoidRootPart.Position
		if hitPoint then
			local targets = damageModule.getAOE(c, hitPoint, 10)
			for i = 1, #targets do
				local target = targets[i]

				damageModule.damageSNG(p, target, damage, { script.Name, skillName })
			end
		end
		wait(0.1)
	end
end

--/TODO: MOVE DESCRIPTION
function module.Move4(p)
	local c = p.Character
	local cooldowns = c.Cooldowns

	local skillName = "Mouton Shot"

	local skillData = attackData.getData(script.Name, skillName)
	local damage = skillData.baseDamage + dataStore.GetData(p, "Strength")

	if cooldowns:GetAttribute(skillName) then
		return
	end
	cooldownHandler.addCooldown(c, skillName)

	SharedFunctions:FireAllDistanceClients(c, script.Name, 200, { Character = c, Function = "Move4" })

	local RootStartCFrame = c.HumanoidRootPart.CFrame

	--/Damage
	CameraRemote:FireClient(p, "CameraShake", { FirstText = 4, SecondText = 6 })
	for j = 1, 5 do
		local hitPoint = (RootStartCFrame * CFrame.new(0, 0, -j * 3)).Position
		if hitPoint then
			local targets = damageModule.getAOE(c, hitPoint, 20)
			for i = 1, #targets do
				local target = targets[i]

				damageModule.damageSNG(p, target, damage, { script.Name, skillName })
			end
		end
	end
end

--/Events
attackRemote.OnServerEvent:connect(function(p, action, info)
	if module[action] then
		module[action](p, info)
	end
end)

return module
