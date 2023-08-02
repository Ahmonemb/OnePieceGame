local player = game.Players.LocalPlayer
local Char = player.Character
local Hum = Char:WaitForChild("Humanoid")

local UIS = game:GetService("UserInputService")

local Button = "LeftShift"

local Running = false

local WKeyDown = false
local AKeyDown = false
local SKeyDown = false
local DKeyDown = false

local NoKeyDown = true

local Speed = 25

local Camera = workspace.CurrentCamera

local Stuns = require(game.ReplicatedStorage:WaitForChild("Combat"):WaitForChild("Stuns"))

local function Run()
	Running = true
	local RunAnim = Hum:LoadAnimation(script:WaitForChild("Sprint"))
	RunAnim:Play()

	Hum.WalkSpeed = Speed

	local Val = Instance.new("BoolValue")
	Val.Name = "Running"
	Val.Parent = Char

	local goal = {}
	goal.FieldOfView = 80
	local info = TweenInfo.new(0.5)
	local tween = game:GetService("TweenService"):Create(Camera, info, goal)
	tween:Play()
end

local function Stop()
	Running = false
	local AnimTracks = Hum:GetPlayingAnimationTracks()

	for _, v in pairs(AnimTracks) do
		if v.Name == "Sprint" then
			v:Stop()
		end
	end

	for _, v in pairs(Char:GetChildren()) do
		if v.Name == "Running" then
			v:Destroy()
		end
	end

	local goal = {}
	goal.FieldOfView = 70
	local info = TweenInfo.new(1)
	local tween = game:GetService("TweenService"):Create(Camera, info, goal)
	tween:Play()
end

UIS.InputBegan:Connect(function(input, istyping)
	for _, v in pairs(Stuns) do
		if game.Players.LocalPlayer.Character:FindFirstChild(v) then
			return
		end
	end

	if istyping then
		return
	end

	if input.KeyCode == Enum.KeyCode[Button] and NoKeyDown == false and Running == false then
		Run()
	end
end)

UIS.InputEnded:Connect(function(input, istyping)
	if istyping then
		return
	end
	if input.KeyCode == Enum.KeyCode[Button] and Running == true then
		Stop()
	end
end)

local RunService = game:GetService("RunService")

RunService.Heartbeat:Connect(function()
	if UIS:IsKeyDown(Enum.KeyCode.W) then
		WKeyDown = true
	else
		WKeyDown = false
	end
	if UIS:IsKeyDown(Enum.KeyCode.A) then
		AKeyDown = true
	else
		AKeyDown = false
	end
	if UIS:IsKeyDown(Enum.KeyCode.S) then
		SKeyDown = true
	else
		SKeyDown = false
	end
	if UIS:IsKeyDown(Enum.KeyCode.D) then
		DKeyDown = true
	else
		DKeyDown = false
	end
	if WKeyDown == false and AKeyDown == false and SKeyDown == false and DKeyDown == false then
		NoKeyDown = true
		if Running == true then
			Stop()
		end
	else
		NoKeyDown = false
	end

	for _, v in pairs(Stuns) do
		if v ~= "Dashing" then
			if game.Players.LocalPlayer.Character:FindFirstChild(v) then
				Stop()
			end
		end
	end
	if Char:FindFirstChild("Blocking") then
		Stop()
	end
end)
