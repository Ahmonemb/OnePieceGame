local RS = game:GetService("ReplicatedStorage")

local ServerRemote = RS.Remotes.Server

local Inputs = require(script.Inputs)
local Functions = require(script.Functions)

game.Players.PlayerAdded:Connect(function(Player)
	Inputs.InputTable[Player] = {}
	Player.CharacterAdded:Connect(function(Character)
		Character:SetAttribute("Stunned", false)
		Character:SetAttribute("Attacking", false)
		Character:SetAttribute("InAir", false)
		Character:SetAttribute("Dashing", false)
	end)
end)

ServerRemote.OnServerInvoke = function(Player, Action, Input, Params)
	if Action == "InputBegan" then
		print("pressed")
		Inputs.InputTable[Player][Input] = true
	elseif Action == "InputEnded" then
		print("stopped")
		Inputs.InputTable[Player][Input] = nil
	elseif Action == "Skill" then
		if Player.Character:GetAttribute("Stunned") == false and Player.Character:GetAttribute("Attacking") == false then
			local Move = Functions.FireMove(Player, Params)
			return Move
		end
	end
end
