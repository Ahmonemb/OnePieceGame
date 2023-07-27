local Values = require(game.ReplicatedStorage:WaitForChild("Combat"):WaitForChild("Values"))
script.Parent.OnServerEvent:Connect(function(plr,Action)
	local Char = plr.Character
	local Hum = Char:WaitForChild("Humanoid")
	if Action == "Start" then
		Values:CreateValue("BoolValue",Char,"Blocking",false,math.huge)
		Values:CreateValue("BoolValue",Char,"PB",false,.1)
		Values:CreateValue("IntValue",Char,"BlockHealth",100,math.huge)
		
		local BlockAnim = Hum:LoadAnimation(script:WaitForChild("BlockAnim"))
		BlockAnim:Play()
	end
	
	if Action == "Stop" then
		for i,v in pairs(Char:GetChildren()) do
			if v.Name == "Blocking" then
				v:Destroy()
			end
			
			if v.Name == "BlockHealth" then
				v:Destroy()
			end
			
		end
		
		local AnimTracks = Hum:GetPlayingAnimationTracks()
		for i,v in pairs(AnimTracks) do
			if v.Name == "BlockAnim" then
				v:Stop()
			end
		end
	end
end)
