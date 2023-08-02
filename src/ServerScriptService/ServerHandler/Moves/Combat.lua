local Functions = require(script.Parent.Parent.Functions)

local Combat = {
	["Skill"] = function(...)
		local Data = (...)
		print(Data)
	end,

	["M1"] = function(Player)
		print("Reached Server")
		local Character = Player.Character
		Functions.FireClientWithDistance({
			Origin = Character.HumanoidRootPart.Position,
			Distance = 125,
			Remote = game.ReplicatedStorage.Remotes.Effects,
		}, { "M1", { Params = nil } })
	end,
}

return Combat
