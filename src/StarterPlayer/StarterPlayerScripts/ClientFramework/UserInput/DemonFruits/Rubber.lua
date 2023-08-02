--/Services
local collectionService = game:GetService("CollectionService")
local attackData = require(game.ReplicatedStorage.Modules.Manager.AttackData)

--/Modules
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)

--/Variables
local attackRemote = G.descendantSearch(game.ReplicatedStorage.Remotes.DemonFruits, script.Name)

local module = {
	["MouseButton1"] = {
		["Release"] = function()
			attackRemote:FireServer("TestMastery")
		end,
	},
	["Z"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Rubber", "RubberPistol")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then
				return
			end

			if cooldowns:GetAttribute("RubberPistol") then
				return
			end
			collectionService:AddTag(c, "Aim")
			G.Aim(p, 0.3)

			local anim = G.playAnim(c.Humanoid, "Rubber", "RubberPistol", true)
			anim.TimePosition = 0.5
			anim:AdjustSpeed(0)
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Rubber", "RubberPistol")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then
				return
			end

			if cooldowns:GetAttribute("RubberPistol") then
				return
			end
			collectionService:RemoveTag(c, "Aim")

			local anim = G.getAnim(c.Humanoid, "RubberPistol")
			if anim then
				anim:AdjustSpeed(1)
			end

			attackRemote:FireServer("Move1")
		end,
	},
	["X"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Rubber", "RubberBazooka")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then
				return
			end

			if cooldowns:GetAttribute("RubberBazooka") then
				return
			end
			collectionService:AddTag(c, "Aim")
			G.Aim(p, 0.3)

			local anim = G.playAnim(c.Humanoid, "Rubber", "RubberBazooka", true)
			anim.TimePosition = 0.25
			anim:AdjustSpeed(0)
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Rubber", "RubberBazooka")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then
				return
			end

			if cooldowns:GetAttribute("RubberBazooka") then
				return
			end
			collectionService:RemoveTag(c, "Aim")

			local anim = G.getAnim(c.Humanoid, "RubberBazooka")
			if anim then
				anim:AdjustSpeed(1)
			end

			attackRemote:FireServer("Move2")
		end,
	},
	["C"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Rubber", "RubberAxeStamp")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then
				return
			end

			if cooldowns:GetAttribute("RubberAxeStamp") then
				return
			end

			local anim = G.playAnim(c.Humanoid, "Rubber", "RubberAxeStamp", true)
			anim.TimePosition = 0.1
			anim:AdjustSpeed(0)
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Rubber", "RubberAxeStamp")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then
				return
			end

			if cooldowns:GetAttribute("RubberAxeStamp") then
				return
			end

			local anim = G.getAnim(c.Humanoid, "RubberAxeStamp")
			if anim then
				anim:AdjustSpeed(1)
			end

			attackRemote:FireServer("Move3")
		end,
	},
	["V"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Rubber", "RubberGattling")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then
				return
			end

			if cooldowns:GetAttribute("RubberGattling") then
				return
			end
			collectionService:AddTag(c, "Aim")
			G.Aim(p, 0.3)

			local anim = G.playAnim(c.Humanoid, "Rubber", "RubberGattling", true)
			anim.TimePosition = 0.1
			anim:AdjustSpeed(0)
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local staminaData = attackData.getData("Rubber", "RubberGattling")

			if staminaData.Stamina > c.States:GetAttribute("Stamina") then
				return
			end

			if cooldowns:GetAttribute("RubberGattling") then
				return
			end
			collectionService:RemoveTag(c, "Aim")

			local anim = G.getAnim(c.Humanoid, "RubberGattling")
			if anim then
				anim:AdjustSpeed(1)
			end
			attackRemote:FireServer("Move4")
		end,
	},
}

return module
