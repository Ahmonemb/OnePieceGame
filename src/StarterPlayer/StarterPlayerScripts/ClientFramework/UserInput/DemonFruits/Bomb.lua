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
			local staminaData = attackData.getData("Bomb","NoseCannon")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			if cooldowns:GetAttribute("NoseCannon") then return end
			collectionService:AddTag(c,"Aim")
			G.Aim(p,.3)

			local anim = G.playAnim(c.Humanoid,"Bomb","NoseCannon",true)
			anim.TimePosition = 0.15 
			anim:AdjustSpeed(0)
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Bomb","NoseCannon")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			if cooldowns:GetAttribute("NoseCannon") then return end
			collectionService:RemoveTag(c,"Aim")

			local anim = G.getAnim(c.Humanoid,"NoseCannon")
			anim:AdjustSpeed(1)

			attackRemote:FireServer("Move1")
		end,
	};
	
	["X"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Bomb","Landmine")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end
			
			if cooldowns:GetAttribute("Landmine") then return end
			collectionService:RemoveTag(c,"Aim")
			local anim = G.playAnim(c.Humanoid,"Bomb","Landmine",true)
			anim:AdjustSpeed(2)
			
			attackRemote:FireServer("Plant")
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Bomb","Landmine")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			if cooldowns:GetAttribute("Landmine") then return end
			collectionService:RemoveTag(c,"Aim")

			attackRemote:FireServer("Move2")
		end,
	};
	
	["C"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Bomb","BombLeap")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			if cooldowns:GetAttribute("BombLeap") then return end
			collectionService:AddTag(c,"Aim")
			G.Aim(p,.3)

			local anim = G.playAnim(c.Humanoid,"Bomb","BombLeap",true)
			anim.TimePosition = 0.15 
			anim:AdjustSpeed(0)
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Bomb","BombLeap")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			if cooldowns:GetAttribute("BombLeap") then return end
			collectionService:RemoveTag(c,"Aim")

			local anim = G.getAnim(c.Humanoid,"BombLeap")
			anim:AdjustSpeed(1)

			attackRemote:FireServer("Move3")
		end,
	};

	
	["V"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Bomb","SelfDetonate")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			if cooldowns:GetAttribute("SelfDetonate") then return end
			collectionService:AddTag(c,"Aim")
			G.Aim(p,.3)

			local anim = G.playAnim(c.Humanoid,"Bomb","SelfDetonate",true)
			anim.TimePosition = 0.35 
			anim:AdjustSpeed(0)
			
			attackRemote:FireServer("ChargeUp")
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Bomb","SelfDetonate")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then return end

			if cooldowns:GetAttribute("SelfDetonate") then return end
			collectionService:RemoveTag(c,"Aim")

			local anim = G.getAnim(c.Humanoid,"SelfDetonate")
			anim:AdjustSpeed(1.25)

			attackRemote:FireServer("Move4")
		end,

	}	
}

return module