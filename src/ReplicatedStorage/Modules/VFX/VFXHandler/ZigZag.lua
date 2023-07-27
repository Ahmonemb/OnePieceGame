return function(Data)
	
	--[[ Setpath Properties ]]--
	local AllCoordinates = {}
	
	local Amount = Data.Amount
	local Distance = Data.Distance
	local Offset = Data.Offset or 1
	
	local OffsetRange = Distance/Amount

	local StartPosition = Data.StartPosition
	local EndPosition = Data.EndPosition
	local Visualize = Data.Visualize

	for i = 1,Amount do
		OffsetRange *= -1
		local Coordinate = StartPosition * CFrame.new(OffsetRange * Offset, 0, math.abs(OffsetRange * i) * -1)
		table.insert(AllCoordinates, i, Coordinate)
		
		if Visualize then
			local Target = script.Target:Clone()
			Target.CFrame = Coordinate
			Target.Parent = workspace	
		end
	end
	return AllCoordinates
end
