--//Services
local Players = game:GetService("Players")

--/Modules
local module = {}
local logiaModule = require(script.Logia)
local Cooldowns = require(script.Parent.Parent.Handlers.CooldownHandler)
local Quests = require(script.Parent.Parent.Handlers.QuestHandler)
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)

--/Variables
local playerVariables = {}
local damageRemote = game.ReplicatedStorage.Remotes.Misc.DamageIndicator
local MobData = require(script.Parent.Parent.Systems.Mobs.Information)

local World = game.Workspace:WaitForChild("World")
local Visual = World.Visual

function module.damageSNG(p, target, damage, moveUsed)
	--if target:FindFirstChild("Humanoid").Health <= 0 or target then return end
	if not target then
		return
	end
	if target:FindFirstChild("PseudoTorso") and target:GetAttribute("Health") <= 0 then
		return
	elseif target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid").Health <= 0 then
		return
	end

	--/Safezone Check
	if target.States and target.States:GetAttribute("Safezone") then
		return
	end

	--/Ally Check
	if p.Allies and p.Allies:GetAttribute(target.Name) then
		return
	end

	--/Logia Check
	local usedLogia = logiaModule.checkLogia(p, target, moveUsed)
	if usedLogia then
		return true
	end

	--/Damage
	if target:FindFirstChild("PseudoTorso") then
		Cooldowns.addCooldown(target, nil, "Attacked", 0.25)
		target:SetAttribute("Health", target:GetAttribute("Health") - damage)
	else
		target:FindFirstChild("Humanoid"):TakeDamage(damage)
	end

	damageRemote:FireAllClients(
		(target:FindFirstChild("PseudoTorso") and target.PseudoTorso.CFrame or target.HumanoidRootPart.CFrame),
		damage
	)
	if not (typeof(p) == "Instance") then
		return
	end

	--/On Death
	local TargetHealth
	if target:FindFirstChild("PseudoTorso") then
		TargetHealth = target:GetAttribute("Health")
	else
		TargetHealth = target.Humanoid.Health
	end
	if TargetHealth <= 0 then
		--/Quest stuff
		Quests.IncrementQuest(p, target)
		--/Bounty Gain
		if Players:FindFirstChild(p.Name) then
			local increase
			local Name = string.split(target.Name, "_")[1]
			if MobData[Name] then
				local bounty = p.leaderstats["Bounty/Respect"]
				increase = MobData[Name].Data.Bounty
				bounty.Value += increase
			elseif Players:FindFirstChild(Name) then
				--/Must be a player
				local bounty = p.leaderstats["Bounty/Respect"]
				increase = Players:FindFirstChild(Name).leaderstats["Bounty/Respect"].Value / 2
				bounty.Value += increase
				G.Notify(
					Players:FindFirstChild(Name),
					string.format("<b>Lost<font color = 'rgb(255, 46, 46)'>%d</font> bounty.</b>", increase),
					2
				)
			end

			--[[
			if increase then
				G.Notify(p,string.format("<b>Gained<font color = 'rgb(255, 46, 46)'>%d</font> bounty.</b>",increase),2)
			end
			]]
		end
	end

	--/Combo Counter
	local states = p.Character.States
	if playerVariables[p.Name] then
		if os.clock() - playerVariables[p.Name].lastCombo < 1.5 then
			states:SetAttribute("ComboCounter", states:GetAttribute("ComboCounter") + 1)
		else
			states:SetAttribute("ComboCounter", 0)
			wait()
			states:SetAttribute("ComboCounter", 1)
		end
	else
		states:SetAttribute("ComboCounter", 1)
		playerVariables[p.Name] = { lastCombo = nil }
	end
	playerVariables[p.Name].lastCombo = os.clock()
end

function module.getGTP(p, size, cframe, singular)
	local hitlist = {}
	local Character = typeof(p) == "Instance" and p.Character or p.Model
	local HumanoidRootPart = typeof(p) == "Instance" and Character.HumanoidRootPart or Character.PseudoTorso
	local closestRange = 200
	local part = Instance.new("Part")
	part.Size = size
	part.Transparency = 1
	part.CFrame = cframe
	part.CanCollide = false
	part.Anchored = true
	part.Parent = Visual
	local conn = part.Touched:connect(function() end)

	local results = part:GetTouchingParts()
	conn:Disconnect()
	for _, v in pairs(results) do
		if
			v.Parent
			and v.Parent ~= Character
			and (v.Parent:FindFirstChild("Humanoid") or v.Parent:FindFirstChild("PseudoTorso"))
		then
			if not singular then
				if not table.find(hitlist, v.Parent) then
					hitlist[#hitlist + 1] = v.Parent
				end
			else
				if typeof(hitlist) ~= "Instance" then
					local AttackedHumanoidRootPart = v.Parent:FindFirstChild("PseudoTorso") and v.Parent.PseudoTorso
						or v.Parent.HumanoidRootPart
					if (AttackedHumanoidRootPart.Position - HumanoidRootPart.Position).magnitude < closestRange then
						hitlist = v.Parent
						closestRange = (AttackedHumanoidRootPart.Position - HumanoidRootPart.Position).magnitude
					end
				end
			end
		end
	end

	part:Destroy()
	if (typeof(hitlist) == "table") and #hitlist <= 0 then
		hitlist = nil
	end
	return hitlist
end

function module.getAOE(c, pos, range)
	local peoplefound = {}

	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v ~= c then
			local HumanoidRootPart

			if v:FindFirstChild("PseudoTorso") then
				HumanoidRootPart = v.PseudoTorso
			elseif v:FindFirstChild("HumanoidRootPart") then
				HumanoidRootPart = v.HumanoidRootPart
			end

			if HumanoidRootPart and (HumanoidRootPart.Position - pos).magnitude <= range then
				if not table.find(peoplefound, v) then
					table.insert(peoplefound, v)
				end
			end
		end
	end

	--[[
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v ~= c and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position-pos).magnitude <= range then
			if not table.find(peoplefound,v) then
				table.insert(peoplefound,v)
			end
		end
	end
	]]

	return peoplefound
end

return module
