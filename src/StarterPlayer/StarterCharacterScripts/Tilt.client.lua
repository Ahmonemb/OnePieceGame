--|| Services ||--
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local runService = game:GetService("RunService")

--|| Variables ||--
local Player = Players.LocalPlayer
local Character = script.Parent
local HumanoidRootPart = Character.HumanoidRootPart
local Torso = Character.Torso

local RootJoint = HumanoidRootPart.RootJoint
local LeftHipJoint = Torso["Left Hip"]
local RightHipJoint = Torso["Right Hip"]

local function Lerp(a, b, c)
	return a + (b - a) * c
end

local Force = nil
local Direction = nil
local Value1 = 0
local Value2 = 0
local multiplier = 4

local RootJointC0 = RootJoint.C0
local LeftHipJointC0 = LeftHipJoint.C0
local RightHipJointC0 = RightHipJoint.C0

RunService.RenderStepped:Connect(function()
	Force = HumanoidRootPart.Velocity * Vector3.new(1,0,1)
	if Force.Magnitude > 2 then
		Direction = Force.Unit    
		Value1 = HumanoidRootPart.CFrame.RightVector:Dot(Direction) * 1.25
		Value2 = HumanoidRootPart.CFrame.LookVector:Dot(Direction) * 1.25
	else
		Value1 = 0
		Value2 = 0
	end

	RootJoint.C0 = RootJoint.C0:Lerp(RootJointC0 * CFrame.Angles(math.rad(Value2 * multiplier), math.rad(-Value1 * multiplier), 0), 0.2)
	LeftHipJoint.C0 = LeftHipJoint.C0:Lerp(LeftHipJointC0 * CFrame.Angles(math.rad(Value1 * multiplier), 0, 0), 0.2)
	RightHipJoint.C0 = RightHipJoint.C0:Lerp(RightHipJointC0 * CFrame.Angles(math.rad(-Value1 * multiplier), 0, 0), 0.2)
end)