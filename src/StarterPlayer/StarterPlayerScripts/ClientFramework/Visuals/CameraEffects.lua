local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage.Modules
local CameraShaker = require(Modules.Misc.CameraShaker)
local CurrentCamera = workspace.CurrentCamera
local CameraRemote = ReplicatedStorage.Remotes.Misc.CameraRemote

local CameraShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
	CurrentCamera.CFrame = CurrentCamera.CFrame * shakeCFrame
end)

local CameraEffects = {

	CameraShake = function(Data)
		local Type = Data.Type
		local Time = Data.Time

		if not Type then
			CameraShake:Start()
			CameraShake:ShakeOnce(Data.FirstText, Data.SecondText, Data.ThirdText or 0, Data.FourthText or 1.5)
		elseif Type == "Loop" then
			for _ = 1, Data.Amount do
				CameraShake:Start()
				CameraShake:ShakeOnce(Data.FirstText, Data.SecondText, Data.ThirdText or 0, Data.FourthText or 1.5)
				wait(Time)
			end
		end
	end,
}

CameraRemote.OnClientEvent:connect(function(Task, Data)
	local action = Task
	if CameraEffects[action] then
		CameraEffects[action](Data)
	end
end)

return CameraEffects
