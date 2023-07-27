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
local module = {}

--/Variables
local attackRemote = game.ReplicatedStorage.Remotes.FightingStyles[script.Name]
local clientRemote = game.ReplicatedStorage.Remotes.Misc.ClientRemote
local getMouse = game.ReplicatedStorage.Remotes.Functions.GetMouse
local count = {}

--// Modules
local Modules = ReplicatedStorage.Modules
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
	
	local skillData = attackData.getData(script.Name,skillName)
	local damage = skillData.baseDamage + c.Data:GetAttribute("Strength")
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
	
	
	local target = damageModule.getGTP(p,Vector3.new(5,5,5),HumanoidRootpart.CFrame*CFrame.new(0,0,-1),true)
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

--/Events
attackRemote.OnServerEvent:connect(function(p,action,info)
	if module[action] then
		module[action](p,info)
	end
end)


return module
