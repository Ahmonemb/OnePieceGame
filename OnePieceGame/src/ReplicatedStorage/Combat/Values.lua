
local module = {}

function module:CreateValue(Value,Parent,Name,Amount,Time)
	local NewValue = Instance.new(Value,Parent)
	NewValue.Name = Name
	NewValue.Value = Amount
	game.Debris:AddItem(NewValue,Time)
end

return module
