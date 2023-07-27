local Inputs = {}

Inputs.InputTable = {}

function Inputs.CheckInput(Player, Input)
	return Inputs.InputTable[Player][Input]
end

return Inputs
