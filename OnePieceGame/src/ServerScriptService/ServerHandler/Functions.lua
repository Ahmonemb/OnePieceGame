local Functions = {
	["FireMove"] = function(Player, ...)
		local Data, MoveName, Moveset = unpack(...)
		if not Player.Character:GetAttribute("Stunned") then
			local Skill
			local Success, Fail = pcall(function()
				Skill = require(script.Parent.Moves[Moveset])[MoveName](Player, Data)
			end)
			if not Success then warn(Fail) end
			return Skill
		end
	end,
	["FireClientWithDistance"] = function(Args, ...)
		for i, P in pairs(game.Players:GetChildren()) do
			local CharModel = P.Character
			if (Args.Origin - CharModel.HumanoidRootPart.Position).Magnitude <= Args.Distance then
				Args.Remote:FireClient(game.Players:GetPlayerFromCharacter(CharModel), ...)
			end
		end
	end,
	
}

return Functions
