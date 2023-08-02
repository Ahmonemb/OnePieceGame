--/Services
local tweenService = game:GetService("TweenService")

--/Modules
local module = {}

--/Variables
local attackRemote = game.ReplicatedStorage.Remotes.Misc[string.split(script.Name, "VFX")[1]]
local effectFolder = game.ReplicatedStorage.Assets.VFX.Misc[string.split(script.Name, "VFX")[1]]

local World = game.Workspace:WaitForChild("World")
local Visual = World.Visual

function module.Geppo(c)
	local storage = effectFolder.Geppo

	--/Smoke
	local sizeRange = 3
	for _ = 1, 4 do
		local size = math.random(sizeRange, sizeRange * 2.4)
		local smoke = storage.smoke:Clone()
		smoke.Color = Color3.fromRGB(203, 203, 203)
		smoke.CFrame = c.HumanoidRootPart.CFrame
			* CFrame.new(0, -1.6, 0)
			* CFrame.Angles(math.random(360), math.random(360), math.random(360))
		smoke.Size = Vector3.new(size, size, size)
		tweenService
			:Create(smoke, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1,
				Size = Vector3.new(0, 0, 0),
				CFrame = smoke.CFrame
					* CFrame.new(math.random(-5, 5), math.random(-4, 0), math.random(-5, 5))
					* CFrame.Angles(math.random(360), math.random(360), math.random(360)),
			})
			:Play()
		smoke.Parent = Visual
		game.Debris:AddItem(smoke, 0.35)
	end

	--/Ring
	local ring = storage.ring:Clone()
	ring.CFrame = c.HumanoidRootPart.CFrame
	ring.Size = Vector3.new(0, 0, 0)
	ring.Transparency = 0.5
	ring.Color = Color3.fromRGB(203, 203, 203)
	tweenService
		:Create(
			ring,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{ Transparency = 1, CFrame = ring.CFrame * CFrame.new(0, -1, 0), Size = Vector3.new(15, 0.4, 15) }
		)
		:Play()
	ring.Parent = Visual
	game.Debris:AddItem(ring, 0.5)
end

attackRemote.OnClientEvent:connect(function(action, info)
	if module[action] then
		module[action](info)
	end
end)

return module
