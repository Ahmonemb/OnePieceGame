--/Services

--/Modules
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)

--/Variables
local attackRemote = G.descendantSearch(game.ReplicatedStorage.Remotes.FightingStyles, script.Name)
local stage = 1

local MAX_COMBO = 4
local COMBO_TIME_WINDOW = 0.8

local module = {
	["Idle"] = function(p)
		local c = p.Character
		local stateChanged = true

		local anim = G.playAnim(c.Humanoid, "Combat", "Idle", true)
		while c:FindFirstChild(script.Name) do
			local ray = G.rayCast(c.HumanoidRootPart.Position, Vector3.new(0, -5, 0), { c })
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

			if cooldowns:GetAttribute("Melee") then
				return
			end
			if (os.clock() - states:GetAttribute("MeleeClicked")) > COMBO_TIME_WINDOW or stage >= MAX_COMBO then
				stage = 1
			else
				stage += 1
			end

			G.playAnim(c.Humanoid, "Combat", "Combo" .. stage)
			wait(0.15)
			attackRemote:FireServer("Melee")
		end,
	},
}

return module
