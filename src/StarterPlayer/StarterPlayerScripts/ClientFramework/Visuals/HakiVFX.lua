--/Services
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")

--/Modules
local attackData = require(game.ReplicatedStorage.Modules.Manager.AttackData)
local module = {}

--/Variables
local attackRemote = game.ReplicatedStorage.Remotes.Misc[string.split(script.Name, "VFX")[1]]
local effectFolder = game.ReplicatedStorage.Assets.VFX.Misc[string.split(script.Name, "VFX")[1]]

function module.Buso(info)
	local c = info[1]
	local activate = info[2]
	local storage = effectFolder.Buso
	local weapons = c.Weapons:GetChildren()

	if activate then
		local weldInfo = attackData.getData("Haki", "Buso").welds
		local hands = storage.hands:Clone()

		for _, v in pairs(hands:GetChildren()) do
			if c:FindFirstChild(v.Name) then
				local bodyPart = c:FindFirstChild(v.Name)
				local weld = Instance.new("Weld")
				weld.Part0 = v
				weld.C0 = CFrame.new(unpack(weldInfo[v.Name][1]))
				weld.Part1 = bodyPart
				weld.C1 = CFrame.new(unpack(weldInfo[v.Name][2]))
				weld.Parent = v
				tweenService
					:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transparency = 0 })
					:Play()
				coroutine.wrap(function()
					task.wait(0.1)
					tweenService
						:Create(
							v,
							TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{ Color = Color3.fromRGB(0, 0, 0) }
						)
						:Play()
				end)()
				v.Name = "Buso"
				v.Parent = c
			end
		end

		for _, v in pairs(weapons) do
			if v:IsA("Model") ~= true then
				v.Material = "Glass"
				tweenService:Create(v, TweenInfo.new(0.1), { Color = Color3.fromRGB(0, 0, 0) }):Play()
			end
		end
	else
		for _, v in pairs(c:GetChildren()) do
			if v.Name == "Buso" then
				tweenService
					:Create(
						v,
						TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ Transparency = 1 }
					)
					:Play()
				game.Debris:AddItem(v, 0.6)
			end
		end

		for _, v in pairs(weapons) do
			if v:IsA("Model") ~= true then
				v.Material = v:GetAttribute("OGMaterial")
				tweenService:Create(v, TweenInfo.new(0.1), { Color = v:GetAttribute("OGColor") }):Play()
			end
		end
	end
end

if runService:IsClient() then
	attackRemote.OnClientEvent:connect(function(action, info)
		if module[action] then
			module[action](info)
		end
	end)
end

return module
