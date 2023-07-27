local module = {}

module.Block = function(Char,Health,Animation,ParryTime)
	local ParVal = Instance.new("BoolValue",Char)
	ParVal.Name = "Parry"
	game.Debris:AddItem(ParVal,ParryTime)
	
	Char:WaitForChild("Humanoid"):LoadAnimation(Animation):Play()
	
	local BlockVal = Instance.new("NumberValue",Char)
	BlockVal.Name = "Blocking"
	BlockVal.Value = Health
	
	delay(2,function()
		BlockVal:Destroy()
		print("Destroyed")
	end)
end

module.UnBlock = function(Char,AnimName)
	for i,v in pairs(Char:GetChildren()) do
		if v.Name == "Blocking" then
			v:Destroy()
		end
	end
	
	local Tracks = Char:WaitForChild("Humanoid"):GetPlayingAnimationTracks()
	
	for i,v in pairs(Tracks) do
		if v.Name == AnimName then
			v:Stop()
		end
	end
	
	
	
	
end

return module
