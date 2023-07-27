
local RunS = game:GetService("RunService")
local Blocking = false

local Player = game.Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()

local Stuns = require(game.ReplicatedStorage:WaitForChild("Combat"):WaitForChild("Stuns"))


local UIS = game:GetService("UserInputService")

Char.ChildAdded:Connect(function()
	for i,v in pairs(Stuns) do
		if v ~= "Blocking" then
			if game.Players.LocalPlayer.Character:FindFirstChild(v) then Blocking = false return end
		end
	end
end)

RunS.Heartbeat:Connect(function()
	
	for i,v in pairs(Stuns) do
		if game.Players.LocalPlayer.Character:FindFirstChild(v) then return end	
	end
	
	
	if UIS:IsKeyDown(Enum.KeyCode.F) then
		Blocking = true
		if Char:FindFirstChild("Blocking") == nil then
			script:WaitForChild("RemoteEvent"):FireServer("Start")
			end
	else
		Blocking = false
		if Char:FindFirstChild("Blocking") then
			script:WaitForChild("RemoteEvent"):FireServer("Stop")
			end
	end
end)
