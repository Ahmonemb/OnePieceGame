local player = game.Players.LocalPlayer
local char = player.Character
local Hum = char:WaitForChild("Humanoid")

local DashTime = .3
local Force = 40000
local Power = 50

local CD = .5
local DashDB = false

local CurrentWalkSpeed = 16
local RunningWalkSpeed = 25

local RunS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Stuns = require(game.ReplicatedStorage:WaitForChild("Combat"):WaitForChild("Stuns"))
local Values = require(game.ReplicatedStorage:WaitForChild("Combat"):WaitForChild("Values"))

local WKeyDown = false
local AKeyDown = false
local SKeyDown = false
local DKeyDown = false

local NoKeyDown = true

local function Dirt()
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = {char}
		raycastParams.IgnoreWater = true
		
		local RayOrigin = char.HumanoidRootPart.Position
		local RayDirection = Vector3.new(0,-1,0) * 10
		local NewRay = workspace:Raycast(RayOrigin,RayDirection,raycastParams)
		
		if NewRay then
			local Dirt = script:WaitForChild("Dirt"):Clone()
			Dirt.Parent = workspace
			Dirt.Position = NewRay.Position
			print(NewRay.Instance.Name)
			local trueColor = NewRay.Instance.Color
			Dirt:WaitForChild("Attachment"):WaitForChild("Smoke").Color = ColorSequence.new{			
				ColorSequenceKeypoint.new(0,trueColor),
				ColorSequenceKeypoint.new(1,trueColor),				
			}
			Dirt:WaitForChild("Attachment"):WaitForChild("Smoke"):Emit(30)
			game.Debris:AddItem(Dirt,1.1)
			end
			end

function DashFoward()
	local Dash = Hum:LoadAnimation(script:WaitForChild("ForwardDash"))
	local BV = Instance.new("BodyVelocity",char.Torso)
	BV.MaxForce = Vector3.new(Force,0,Force)
	BV.Velocity = char.HumanoidRootPart.CFrame.lookVector * Power
	game.Debris:AddItem(BV,DashTime)
	Dash:Play()
	Dash:AdjustSpeed(1.5)
	
	


	Dirt()
	Hum.WalkSpeed = 0
	local direction = coroutine.wrap(function()
		local Runservice = RunS.Stepped:Connect(function()
			BV.Velocity = char.HumanoidRootPart.CFrame.lookVector * Power
		end)
		
		wait(DashTime)
		Runservice:disconnect()
		if char:FindFirstChild("Running") then
			Hum.WalkSpeed = RunningWalkSpeed
		else
			Hum.WalkSpeed = CurrentWalkSpeed
			end
	end)()
end

function DashBack()
	local Dash = Hum:LoadAnimation(script:WaitForChild("BackwardDash"))
	local BV = Instance.new("BodyVelocity",char.Torso)
	BV.MaxForce = Vector3.new(Force,0,Force)
	BV.Velocity = char.HumanoidRootPart.CFrame.lookVector * -Power
	game.Debris:AddItem(BV,DashTime)
	Dash:Play()
	Dash:AdjustSpeed(1.5)


	Dirt()
	Hum.WalkSpeed = 0
	local direction = coroutine.wrap(function()
		local Runservice = RunS.Stepped:Connect(function()
			BV.Velocity = char.HumanoidRootPart.CFrame.lookVector * -Power
		end)
		wait(DashTime)
		Runservice:disconnect()
		if char:FindFirstChild("Running") then
			Hum.WalkSpeed = RunningWalkSpeed
		else
			Hum.WalkSpeed = CurrentWalkSpeed
		end
	end)()
end

function DashLeft()
	local Dash = Hum:LoadAnimation(script:WaitForChild("LeftDash"))
	local BV = Instance.new("BodyVelocity",char.Torso)
	BV.MaxForce = Vector3.new(Force,0,Force)
	BV.Velocity = char.HumanoidRootPart.CFrame.RightVector * -Power
	game.Debris:AddItem(BV,DashTime)
	Dash:Play()
	Dash:AdjustSpeed(1.5)

	Dirt()
	Hum.WalkSpeed = 0

	local direction = coroutine.wrap(function()
		local Runservice = RunS.Stepped:Connect(function()
			BV.Velocity = char.HumanoidRootPart.CFrame.RightVector * -Power
		end)
		wait(DashTime)
		Runservice:disconnect()
		if char:FindFirstChild("Running") then
			Hum.WalkSpeed = RunningWalkSpeed
		else
			Hum.WalkSpeed = CurrentWalkSpeed
		end
	end)()
end

function DashRight()
	local Dash = Hum:LoadAnimation(script:WaitForChild("RightDash"))
	local BV = Instance.new("BodyVelocity",char.Torso)
	BV.MaxForce = Vector3.new(Force,0,Force)
	BV.Velocity = char.HumanoidRootPart.CFrame.RightVector * Power
	game.Debris:AddItem(BV,DashTime)
	Dash:Play()
	Dash:AdjustSpeed(1.5)

	Dirt()
	Hum.WalkSpeed = 0

	local direction = coroutine.wrap(function()
		local Runservice = RunS.Stepped:Connect(function()
			BV.Velocity = char.HumanoidRootPart.CFrame.RightVector * Power
		end)
		wait(DashTime)
		Runservice:disconnect()
		if char:FindFirstChild("Running") then
			Hum.WalkSpeed = RunningWalkSpeed
		else
			Hum.WalkSpeed = CurrentWalkSpeed
		end
	end)()
end

UIS.InputBegan:Connect(function(input,istyping)
	
	for i,v in pairs(Stuns) do
		if game.Players.LocalPlayer.Character:FindFirstChild(v) then return end	
	end
	
	if game.Players.LocalPlayer.Character:FindFirstChild("Blocking") then return end
	
	if game.Players.LocalPlayer.Character:GetAttribute("InAir") == true then return end
	
	if istyping then return end
	
	if input.KeyCode == Enum.KeyCode.Q and DashDB == false then
		DashDB = true
		delay(CD,function()
			wait(0.5)
			DashDB = false
		end)
		
		Values:CreateValue("BoolValue",player.Character,"Dashing",false,.3)
		
		local DashSound = script:WaitForChild("DashSound"):Clone()
		DashSound.Parent = char:WaitForChild("HumanoidRootPart")
		DashSound:Play()
		game.Debris:AddItem(DashSound,1)
		
		if UIS.MouseBehavior == Enum.MouseBehavior.LockCenter then
		if NoKeyDown == true or WKeyDown == true then
				DashFoward()
				return
		end
		if AKeyDown == true then
				DashLeft()
				return
		end
		if SKeyDown == true then
				DashBack()
				return
		end
		if DKeyDown == true then
				DashRight()
				return
		end
		else
			DashFoward()
			return
		end
		end
end)


RunS.Heartbeat:Connect(function()
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
	else
		NoKeyDown = false
	end
end)
