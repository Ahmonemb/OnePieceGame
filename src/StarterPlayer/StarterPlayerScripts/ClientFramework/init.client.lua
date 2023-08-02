--/Services
local tweenService = game:GetService("TweenService")

--// Wunbo Variables
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets
local World = game.Workspace:WaitForChild("World")
local Visual = World.Visual
local Remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes").Misc.Stamina

--/Initializers
for _, v in pairs(script:GetDescendants()) do
	if v:IsA("ModuleScript") then
		require(v)
	end
end

--/Remotes
local damageIndicator = game.ReplicatedStorage.Remotes.Misc.DamageIndicator

--/Camera Shake
_G.CamShake = require(game.ReplicatedStorage.Modules.Misc.CameraShaker).new(
	Enum.RenderPriority.Camera.Value,
	function(shakeCFrame)
		workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * shakeCFrame
	end
)
_G.CamShake:Start()

Remote:FireServer()

--/Damage Indicator
damageIndicator.OnClientEvent:connect(function(cframe, text)
	--/Create
	local billboard = Assets.VFX.Misc.damageBillboard:Clone()
	billboard.CFrame = cframe
	billboard.HP.holder.text.Text = text
	billboard.HP.holder.layer.Text = text
	local bounds = math.random(3, 6)
	local speed = 0.5

	--/Tween
	local position = billboard.CFrame
		* CFrame.new(math.random(-bounds, bounds), -3, math.random(-bounds, bounds)).Position
	local goal = {}
	goal.Position = position
	local tweenInfo = TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = tweenService:Create(billboard, tweenInfo, goal)
	tween:Play()
	local goal1 = {}
	goal1.Size = UDim2.new(0, 0, 0, 0)
	local tweenInfo1 = TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween1 = tweenService:Create(billboard.HP.holder, tweenInfo1, goal1)
	tween1:Play()
	billboard.Parent = Visual
	game.Debris:AddItem(billboard, speed)
end)
