--/Services
local userInputService = game:GetService("UserInputService")
local collectionService = game:GetService("CollectionService")
local attackData = require(game.ReplicatedStorage.Modules.Manager.AttackData)

--/Modules
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)

--/Variables
local attackRemote = G.descendantSearch(game.ReplicatedStorage.Remotes.DemonFruits,script.Name)

local module = {
	["Z"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Flame","FireFist")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end
			if cooldowns:GetAttribute("FireFist") then return end
			collectionService:AddTag(c,"Aim")
			G.Aim(p,.3)

			local anim = G.playAnim(c.Humanoid,"Flame","FireFist",true)
			anim.TimePosition = 0.5 
			anim:AdjustSpeed(0)
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Flame","FireFist")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end
			if cooldowns:GetAttribute("FireFist") then return end
			collectionService:RemoveTag(c,"Aim")

			local anim = G.getAnim(c.Humanoid,"FireFist")
			anim:AdjustSpeed(1.5)

			attackRemote:FireServer("Move1")
		end,
	};
	
	["X"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Flame","FirePillar")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			if cooldowns:GetAttribute("FirePillar") then return end

			local anim = G.playAnim(c.Humanoid,"Flame","FirePillar", true)
			
			anim.TimePosition = 0.1
			anim:AdjustSpeed(0)
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Flame","FirePillar")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			if cooldowns:GetAttribute("FirePillar") then return end

			local anim = G.getAnim(c.Humanoid,"FirePillar")
			anim:AdjustSpeed(0.5)

			attackRemote:FireServer("Move2")
		end,
	};
	
	["C"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Flame","FireFlight")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			if cooldowns:GetAttribute("FireFlight") then return end

			G.playAnim(c.Humanoid,"Flame","FireFlight")

			attackRemote:FireServer("Move3", true)
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Flame","FireFlight")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			G.stopAnim(c.Humanoid,"FireFlight")
			
			attackRemote:FireServer("Move3", "Release")
		end,
	},

	["V"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Flame","FireFlies")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			if cooldowns:GetAttribute("FireFlies") then return end
			collectionService:AddTag(c,"Aim")
			G.Aim(p,.3)

			local anim = G.playAnim(c.Humanoid,"Flame","FireFlies",true)
			anim.TimePosition = 0.35 
			anim:AdjustSpeed(0)

			attackRemote:FireServer("FireFlyHold")
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Flame","FireFlies")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end
			collectionService:RemoveTag(c,"Aim")

			local anim = G.getAnim(c.Humanoid,"FireFlies")
			if anim then
				anim:AdjustSpeed(1)
			end

			attackRemote:FireServer("Move4")
		end,

	}	
}

return module