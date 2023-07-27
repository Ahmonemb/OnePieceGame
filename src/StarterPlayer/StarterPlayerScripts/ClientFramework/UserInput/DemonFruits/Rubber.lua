--/Services
local userInputService = game:GetService("UserInputService")
local collectionService = game:GetService("CollectionService")

--/Modules
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)

--/Variables
local attackRemote = G.descendantSearch(game.ReplicatedStorage.Remotes.DemonFruits,script.Name)


local module = {
	["MouseButton1"] = {
		["Release"] = function(p)
			attackRemote:FireServer("TestMastery")
		end,
	},
	["Z"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns

			if cooldowns:GetAttribute("RubberPistol") then return end
			collectionService:AddTag(c,"Aim")
			G.Aim(p,.3)

			local anim = G.playAnim(c.Humanoid,"Rubber","RubberPistol",true)
			anim.TimePosition = 0.5 
			anim:AdjustSpeed(0)

		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns

			if cooldowns:GetAttribute("RubberPistol") then return end
			collectionService:RemoveTag(c,"Aim")

			local anim = G.getAnim(c.Humanoid,"RubberPistol")
			anim:AdjustSpeed(1)

			attackRemote:FireServer("Move1")
		end,
	},
	["X"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns

			if cooldowns:GetAttribute("RubberBazooka") then return end
			collectionService:AddTag(c,"Aim")
			G.Aim(p,.3)

			local anim = G.playAnim(c.Humanoid,"Rubber","RubberBazooka",true)
			anim.TimePosition = 0.25
			anim:AdjustSpeed(0)

		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns

			if cooldowns:GetAttribute("RubberBazooka") then return end
			collectionService:RemoveTag(c,"Aim")

			local anim = G.getAnim(c.Humanoid,"RubberBazooka")
			anim:AdjustSpeed(1)

			attackRemote:FireServer("Move2")
		end,
	},	
	["C"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns

			if cooldowns:GetAttribute("RubberAxe") then return end

			local anim = G.playAnim(c.Humanoid,"Rubber","RubberAxe",true)
			anim.TimePosition = 0.1
			anim:AdjustSpeed(0)

		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns

			if cooldowns:GetAttribute("RubberAxe") then return end

			local anim = G.getAnim(c.Humanoid,"RubberAxe")
			anim:AdjustSpeed(1)

			attackRemote:FireServer("Move3")
		end,
	},		
	["V"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns

			if cooldowns:GetAttribute("RubberGatling") then return end
			collectionService:AddTag(c,"Aim")
			G.Aim(p,.3)

			local anim = G.playAnim(c.Humanoid,"Rubber","RubberGatling",true)
			anim.TimePosition = 0.1
			anim:AdjustSpeed(0)

		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns

			if cooldowns:GetAttribute("RubberGatling") then return end
			collectionService:RemoveTag(c,"Aim")

			local anim = G.getAnim(c.Humanoid,"RubberGatling")
			anim:AdjustSpeed(1)

			attackRemote:FireServer("Move4")
		end,	
	}	
}

return module