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
			local staminaData = attackData.getData("Gravity","GravityPush")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			if cooldowns:GetAttribute("GravityPush") then return end
			collectionService:AddTag(c,"Aim")
			G.Aim(p,.3)

			local anim = G.playAnim(c.Humanoid,"Gravity","GravityPush",true)
			anim.TimePosition = 0.5 
			anim:AdjustSpeed(0)
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Gravity","GravityPush")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			if cooldowns:GetAttribute("GravityPush") then return end
			collectionService:RemoveTag(c,"Aim")

			local anim = G.getAnim(c.Humanoid,"GravityPush")
			anim:AdjustSpeed(1.5)

			attackRemote:FireServer("Move1")
		end,
	};
	
	["X"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Gravity","InfiniteGravity")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end
			
			if cooldowns:GetAttribute("InfiniteGravity") then return end
			local anim = G.playAnim(c.Humanoid,"Gravity","InfiniteGravity", true)
			anim.TimePosition = 0.1
			anim:AdjustSpeed(0)
			
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Gravity","InfiniteGravity")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end
			
			if cooldowns:GetAttribute("InfiniteGravity") then return end
			local anim = G.getAnim(c.Humanoid,"InfiniteGravity")
			anim:AdjustSpeed(1)
			
			attackRemote:FireServer("Move2")
		end,
	};	

	["C"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Gravity","GravityFlight")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			if cooldowns:GetAttribute("GravityFlight") then return end

			G.playAnim(c.Humanoid,"Gravity","GravityFlight")

			attackRemote:FireServer("Move3", true)
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Gravity","GravityFlight")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			G.stopAnim(c.Humanoid,"GravityFlight")

			attackRemote:FireServer("Move3", "Release")
		end,
	},

	
	["V"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Gravity","Meteor")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			if cooldowns:GetAttribute("Meteor") then return end

			local anim = G.playAnim(c.Humanoid,"Gravity","Meteor",true)
			anim.TimePosition = 0.1
			anim:AdjustSpeed(0)
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Gravity","Meteor")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			local anim = G.getAnim(c.Humanoid,"Meteor")
			anim:AdjustSpeed(1)

			attackRemote:FireServer("Move4")
		end,
	};
}

return module