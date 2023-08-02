local module = {}

function module:CreateValue(Value, Parent, Name, Amount, Time)
	local NewValue = Instance.new(Value)
	NewValue.Name = Name
	NewValue.Value = Amount
	NewValue.Parent = Parent
	game.Debris:AddItem(NewValue, Time)
end

return module
