local Player = game.Players.LocalPlayer
local Character = script.Parent

local UserInputService = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")

local Server = RS.Remotes.Server
local EffectEvent = RS.Remotes.Effects

local Cooldown = require(RS.Replicated.Cooldown)
local Skillsets = require(RS.Replicated.SkillSets)
local VFX = require(script:WaitForChild("FX"))

local AvailableSets = {
	"Movement",
	"Combat",
	"TestSkillSet",
}

local InputBegan = coroutine.create(function()
	UserInputService.InputBegan:Connect(function(UserInput, GPE)
		if GPE then
			return
		end
		local Skill, Info, Input = nil, nil, nil
		if UserInput.UserInputType == Enum.UserInputType.MouseButton1 then
			Input = "M1"
			if
				Cooldown:CheckCooldown("M1", Player) == false
				and Character:GetAttribute("Stunned") == false
				and Character:GetAttribute("Attacking") == false
			then
				Info = { Data = "Test" }
			end
		else
			Input = UserInput.KeyCode.Name
			Info = { Data = "Test" }
		end

		for _, v in pairs(AvailableSets) do
			if Skillsets[v] then
				if Skillsets[v][Input] then
					Skill = Skillsets[v][Input]
				end
			end
		end
		if Skill then
			if
				Cooldown:CheckCooldown(Skill.Name, Player) == false
				and Character:GetAttribute("Stunned") == false
				and Character:GetAttribute("Attacking") == false
				and Character:GetAttribute("InAir") == false
			then
				Server:InvokeServer("InputBegan", UserInput.KeyCode.Name)
				Character:SetAttribute("Attacking", true)
				if Info then
					print("Fire Skill")
					Cooldown:AddCooldown(Skill.Name, Skill.Cooldown, Player)
				end
				Character:SetAttribute("Attacking", false)
			end
		end
	end)
end)

local InputEnded = coroutine.create(function()
	UserInputService.InputEnded:Connect(function(Input, GPE)
		if GPE then
			return
		end
		if Character:GetAttribute("Attacking") == true then
			Server:InvokeServer("InputEnded", Input.KeyCode.Name)
		end
	end)
end)

coroutine.resume(InputBegan)
coroutine.resume(InputEnded)

EffectEvent.OnClientEvent:Connect(function(...)
	local FXName, Params = unpack(...)
	print(FXName, Params)
	VFX[FXName](Player, Params)
end)
