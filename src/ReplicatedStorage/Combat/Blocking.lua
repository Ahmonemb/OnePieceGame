local module = {}

module.Block = function(Char, Health, Animation, ParryTime)
	local ParVal = Instance.new("BoolValue")
	ParVal.Name = "Parry"
	ParVal.Parent = Char
	game.Debris:AddItem(ParVal, ParryTime)

	Char:WaitForChild("Humanoid"):LoadAnimation(Animation):Play()

	local BlockVal = Instance.new("NumberValue")
	BlockVal.Name = "Blocking"
	BlockVal.Value = Health
	BlockVal.Parent = Char

	task.delay(2, function()
		BlockVal:Destroy()
		print("Destroyed")
	end)
end

module.UnBlock = function(Char, AnimName)
	for _, v in pairs(Char:GetChildren()) do
		if v.Name == "Blocking" then
			v:Destroy()
		end
	end

	local Tracks = Char:WaitForChild("Humanoid"):GetPlayingAnimationTracks()

	for _, v in pairs(Tracks) do
		if v.Name == AnimName then
			v:Stop()
		end
	end
end

return module
