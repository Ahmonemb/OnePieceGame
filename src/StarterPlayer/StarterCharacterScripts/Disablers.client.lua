local player = game.Players.LocalPlayer

local Char = player.Character

local NormalWalkSpeed = 16
local NormalJumpPower = 50

game:GetService("RunService").Heartbeat:Connect(function()
	if Char:FindFirstChild("StopStun") then
		Char:FindFirstChild("Humanoid").JumpPower = 0
		Char:FindFirstChild("Humanoid").WalkSpeed = 0
		return
	end

	if Char:FindFirstChild("Stun") then
		Char:FindFirstChild("Humanoid").JumpPower = 0
		Char:FindFirstChild("Humanoid").WalkSpeed = 3
		return
	end

	if Char:FindFirstChild("Blocking") then
		Char:FindFirstChild("Humanoid").JumpPower = 0
		Char:FindFirstChild("Humanoid").WalkSpeed = 5
	end

	if Char:FindFirstChild("NoJump") then
		Char:FindFirstChild("Humanoid").JumpPower = 0
	end

	if Char:FindFirstChild("NoJump") == nil then
		Char:WaitForChild("Humanoid").JumpPower = 50
	end

	if
		Char:FindFirstChild("StopStun") == nil
		and Char:FindFirstChild("Stun") == nil
		and Char:FindFirstChild("Running") == nil
		and Char:FindFirstChild("NoJump") == nil
		and Char:FindFirstChild("Blocking") == nil
	then
		Char:FindFirstChild("Humanoid").JumpPower = NormalJumpPower
		Char:FindFirstChild("Humanoid").WalkSpeed = NormalWalkSpeed
	end
end)
