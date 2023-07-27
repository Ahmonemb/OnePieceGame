--/Services
local userInputService = game:GetService("UserInputService")
local collectionService = game:GetService("CollectionService")

--/Modules
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)

--/Variables
local attackRemote = G.descendantSearch(game.ReplicatedStorage.Remotes.FightingStyles,script.Name)
local stage = 1


local MAX_COMBO = 4
local COMBO_TIME_WINDOW = 0.8
local COMBO_CD = 0.25

local module = {
	["Idle"] = function(p)
		local c = p.Character
		local stateChanged = true

		local anim = G.playAnim(c.Humanoid,"Combat","Idle",true)
		while c:FindFirstChild(script.Name) do
			local ray = G.rayCast(c.HumanoidRootPart.Position,Vector3.new(0,-5,0),{c})
			if ray then
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
		anim:Stop()
	end,
	["MouseButton1"] = {
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns
			local states = c.States

			if cooldowns:GetAttribute("Melee") then return end
			if (os.clock()-states:GetAttribute("MeleeClicked")) > COMBO_TIME_WINDOW or stage >= MAX_COMBO then
				stage = 1
			else
				stage += 1
			end

			G.playAnim(c.Humanoid,"Combat","Combo"..stage)
			wait(0.15)
			attackRemote:FireServer("Melee")
		end,
	};
	
	["Z"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns

			if cooldowns:GetAttribute("Collier") then return end
			collectionService:AddTag(c,"Aim")
			G.Aim(p,.3)

			local anim = G.playAnim(c.Humanoid,"BlackLeg","Collier",true)
			anim.TimePosition = 0.15 
			anim:AdjustSpeed(0)
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns

			if cooldowns:GetAttribute("Collier") then return end
			collectionService:RemoveTag(c,"Aim")

			local anim = G.getAnim(c.Humanoid,"Collier")
			anim:AdjustSpeed(1)

			attackRemote:FireServer("Move1")
		end,
	};
	
	["X"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns

			if cooldowns:GetAttribute("Concasse") then return end
			collectionService:AddTag(c,"Aim")
			G.Aim(p,.3)

			local anim = G.playAnim(c.Humanoid,"BlackLeg","Concasse",true)
			anim.TimePosition = 0.05
			anim:AdjustSpeed(0)
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns

			if cooldowns:GetAttribute("Concasse") then return end
			collectionService:RemoveTag(c,"Aim")

			local anim = G.getAnim(c.Humanoid,"Concasse")
			anim:AdjustSpeed(1)
			
			for _, v in ipairs(c.HumanoidRootPart:GetDescendants()) do
				if v:IsA("BodyGyro") or v:IsA("BodyPosition") then
					v:Destroy()
				end
			end

			attackRemote:FireServer("Move2")
		end,
	};
	["C"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns

			if cooldowns:GetAttribute("PartyTable") then return end
			collectionService:AddTag(c,"Aim")
			G.Aim(p,.3)

			local anim = G.playAnim(c.Humanoid,"BlackLeg","PartyTable",true)
			anim.TimePosition = 0.15 
			anim:AdjustSpeed(0)
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns

			if cooldowns:GetAttribute("PartyTable") then return end
			collectionService:RemoveTag(c,"Aim")

			local anim = G.getAnim(c.Humanoid,"PartyTable")
			anim:AdjustSpeed(1)

			attackRemote:FireServer("Move3")
		end,
	};
	
	["V"] = {
		["Held"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns

			if cooldowns:GetAttribute("Collier") then return end
			collectionService:AddTag(c,"Aim")
			G.Aim(p,.3)

			local anim = G.playAnim(c.Humanoid,"BlackLeg","Collier",true)
			anim.TimePosition = 0.15 
			anim:AdjustSpeed(0)
		end,
		["Release"] = function(p)
			local c = p.Character
			local cooldowns = c.Cooldowns

			if cooldowns:GetAttribute("Collier") then return end
			collectionService:RemoveTag(c,"Aim")

			local anim = G.getAnim(c.Humanoid,"Collier")
			anim:AdjustSpeed(1)

			attackRemote:FireServer("Move4")
		end,
	};
	
}

return module