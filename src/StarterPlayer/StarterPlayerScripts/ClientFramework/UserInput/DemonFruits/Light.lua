--/Services
local userInputService = game:GetService("UserInputService")
local collectionService = game:GetService("CollectionService")
local attackData = require(game.ReplicatedStorage.Modules.Manager.AttackData)

--/Modules
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)

--/Variables
local attackRemote = G.descendantSearch(game.ReplicatedStorage.Remotes.DemonFruits,script.Name)
local MAX_COMBO = 4
local COMBO_TIME_WINDOW = 0.8
local COMBO_CD = 0.25
local stage = 1

local module = {
	["Idle"] = function(p)
		local c = p.Character
		local stateChanged = true

		attackRemote:FireServer("LightSword")
		local anim = G.playAnim(c.Humanoid,"Light","Idle",true)
		while c:FindFirstChild(script.Name) do
			if c.Humanoid.FloorMaterial ~= Enum.Material.Air then
				if c.Humanoid.MoveDirection.magnitude > 0 then
					if stateChanged then
						anim:Stop()
						stateChanged = false
					end
				else
					if not stateChanged then
						anim:Play()
						stateChanged = true
					end
				end
			else
				anim:Stop()
				stateChanged = false
			end
			wait()
		end
		attackRemote:FireServer("LightSword")
		anim:Stop()
	end;
	
	["MouseButton1"] = {
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local states = c.States
			local staminaData = attackData.getData("Light","Melee")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			if cooldowns:GetAttribute("Melee") then return end
			if (os.clock()-states:GetAttribute("MeleeClicked")) > COMBO_TIME_WINDOW or stage >= MAX_COMBO then
				stage = 1
			else
				stage += 1
			end

			G.playAnim(c.Humanoid,"OneSwordStyle","Combo"..stage)
			task.wait(0.15)
			attackRemote:FireServer("Melee")
		end,
	};
	
	["Z"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Light","LightKick")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			if cooldowns:GetAttribute("LightKick") then return end
			collectionService:AddTag(c,"Aim")
			G.Aim(p,.3)

			local anim = G.playAnim(c.Humanoid,"Light","LightKick",true)
			anim.TimePosition = 0.1 
			anim:AdjustSpeed(0)
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Light","LightKick")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			if cooldowns:GetAttribute("LightKick") then return end
			collectionService:RemoveTag(c,"Aim")

			local anim = G.getAnim(c.Humanoid,"LightKick")
			anim:AdjustSpeed(1)

			attackRemote:FireServer("Move1")
		end,
	};
	
	["X"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Light","LightMirror")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			if cooldowns:GetAttribute("LightMirror") then return end
			collectionService:AddTag(c,"Aim")
			G.Aim(p,.3)

			local anim = G.playAnim(c.Humanoid,"Light","LightMirror",true)
			anim.TimePosition = 0.1
			anim:AdjustSpeed(0)
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Light","LightMirror")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			if cooldowns:GetAttribute("LightMirror") then return end
			collectionService:RemoveTag(c,"Aim")

			local anim = G.getAnim(c.Humanoid,"LightMirror")
			anim:AdjustSpeed(1)

			attackRemote:FireServer("Move2")
		end,
	};
	
	["C"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Light","LightFlight")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			if cooldowns:GetAttribute("LightFlight") then return end

			G.playAnim(c.Humanoid,"Light","LightFlight")

			attackRemote:FireServer("Move3", true)
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Light","LightFlight")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			G.stopAnim(c.Humanoid,"LightFlight")

			attackRemote:FireServer("Move3", "Release")
		end,
	},
	
	["V"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Light","LightJewels")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			if cooldowns:GetAttribute("LightJewels") then return end
			collectionService:AddTag(c,"Aim")
			G.Aim(p,.3)

			local anim = G.playAnim(c.Humanoid,"Light","LightJewels",true)
			anim.TimePosition = 0.5
			anim:AdjustSpeed(0)
			
			attackRemote:FireServer("JewelsHold")
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Light","LightJewels")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			
			collectionService:RemoveTag(c,"Aim")

			local anim = G.getAnim(c.Humanoid,"LightJewels")
			anim:AdjustSpeed(1)

			attackRemote:FireServer("Move4")
		end,

	}	
}

return module