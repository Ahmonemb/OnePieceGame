local CameraShaker = require(game.ReplicatedStorage.Replicated.CameraShaker)
local Camera = workspace.CurrentCamera
local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
	Camera.CFrame = Camera.CFrame * shakeCFrame
end)

camShake:Start()

local Camera = {
	["BeamCameraShake"] = function()
		local c = CameraShaker.CameraShakeInstance.new(1, 3.5, 2, 10)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		c.PositionInfluence = Vector3.new(1, 1, 4)
		local shakeInstance = camShake:ShakeSustain(c)
		task.wait(2)
		shakeInstance:StartFadeOut(1)
	end,
}

return Camera
