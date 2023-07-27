local player = game.Players.LocalPlayer
local Char = script.Parent or player.CharacterAdded:Wait()

local camera = workspace.CurrentCamera
local Mouse = player:GetMouse()

local CameraShaker = require(game:GetService('ReplicatedStorage'):WaitForChild("Replicated"):WaitForChild("CameraShaker"))

local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
	camera.CFrame = camera.CFrame * shakeCf
end)

camShake:Start()

local RunService = game:GetService("RunService")

local UIS = game:GetService("UserInputService")

Char.ChildAdded:Connect(function(item)
	if item.Name == "LowShake" then
		camShake:Shake(CameraShaker.Presets.ExtremeWind)
	end

	if item.Name == "BigShake" then
		camShake:Shake(CameraShaker.Presets.BigExplosion)
	end

end)
