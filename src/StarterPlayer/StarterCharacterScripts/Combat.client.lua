local Player = game.Players.LocalPlayer

local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local Animations = RS:WaitForChild("Assets").Animations.FightingStyles.Combat

local HitboxSettings = require(RS:WaitForChild("Replicated").HitboxSettings1)
local Server = RS:WaitForChild("Remotes").ServerCombat

local HS = HitboxSettings.new(Player, Vector3.new(6, 7, 6))
HS.Damage = 3
HS.LastCooldownTime = 1
HS.Animation1 = Animations:WaitForChild("A1")
HS.Animation2 = Animations:WaitForChild("A2")
HS.Animation3 = Animations:WaitForChild("A3")
HS.Animation4 = Animations:WaitForChild("A4")
HS.Animation5 = Animations:WaitForChild("A5")

UIS.InputBegan:Connect(function(input, istyping)
	if istyping then
		return
	end

	if
		input.UserInputType == Enum.UserInputType.MouseButton1
		and Player.Character:GetAttribute("Attacking") == false
		and Player.Character:GetAttribute("Stunned") == false
	then
		HS:Attack()
	end
end)

game:GetService("RunService").Heartbeat:Connect(function()
	if UIS:IsKeyDown(Enum.KeyCode.Space) then
		HS.SpaceHold = true
	else
		HS.SpaceHold = false
	end
end)

Server.OnClientEvent:Connect(function(Action)
	if Action == "PB" then
		local camera = workspace.CurrentCamera
		local CC = script:WaitForChild("ColorCorrection"):Clone()
		CC.Parent = camera
		game.Debris:AddItem(CC, 3)

		local goal = {}
		goal.TintColor = Color3.fromRGB(139, 128, 255)
		goal.Brightness = 1
		local info = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 2, true, 0)
		local tween = game:GetService("TweenService"):Create(CC, info, goal)
		tween:Play()

		local Blur = script:WaitForChild("Blur"):Clone()
		Blur.Parent = camera
		game.Debris:AddItem(Blur, 3)

		local goal1 = {}
		goal1.Size = 100
		local info1 = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 2, true, 0)
		local tween1 = game:GetService("TweenService"):Create(Blur, info1, goal1)
		tween1:Play()
	end
end)
