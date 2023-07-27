--/Services
local userInputService = game:GetService("UserInputService")
local collectionService = game:GetService("CollectionService")

--/Modules
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)

--/Variables
local attackRemote = G.descendantSearch(game.ReplicatedStorage.Remotes.DemonFruits,script.Name)

local module = {
	["Z"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns

			if cooldowns:GetAttribute("BombBooger") then return end
			collectionService:AddTag(c,"Aim")
			G.Aim(p,.3)

			local anim = G.playAnim(c.Humanoid,"Bomb","BombBooger",true)
			anim.TimePosition = 0.15 
			anim:AdjustSpeed(0)
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns

			if cooldowns:GetAttribute("BombBooger") then return end
			collectionService:RemoveTag(c,"Aim")

			local anim = G.getAnim(c.Humanoid,"BombBooger")
			anim:AdjustSpeed(1)

			attackRemote:FireServer("Move1")
		end,
	};
	
	["X"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			
			local anim = G.playAnim(c.Humanoid,"Bomb","BombLandmine",true)
			anim:AdjustSpeed(2)
			
			attackRemote:FireServer("Plant")
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns

			attackRemote:FireServer("Move2")
		end,
	};
	
	["C"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns

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

			if cooldowns:GetAttribute("SelfDetonation") then return end
			collectionService:AddTag(c,"Aim")
			G.Aim(p,.3)

			local anim = G.playAnim(c.Humanoid,"Bomb","SelfDetonation",true)
			anim.TimePosition = 0.35 
			anim:AdjustSpeed(0)
			
			attackRemote:FireServer("ChargeUp")
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns

			if cooldowns:GetAttribute("SelfDetonation") then return end
			collectionService:RemoveTag(c,"Aim")

			local anim = G.getAnim(c.Humanoid,"SelfDetonation")
			anim:AdjustSpeed(1.25)

			attackRemote:FireServer("Move4")
		end,

	}	
}

return module