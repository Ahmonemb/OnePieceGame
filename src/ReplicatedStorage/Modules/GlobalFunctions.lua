--/Services
local collectionService = game:GetService("CollectionService")
local runService = game:GetService("RunService")
local Players = game:GetService("Players")

local World = game.Workspace:WaitForChild("World")
local Visual = World.Visual

local module = {}

function module.descendantSearch(place, name)
	for _, v in pairs(place:GetDescendants()) do
		if v.Name == name then
			return v
		end
	end
end

function module.getNearestCharacters(position, range)
	local characters = {}

	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") then
			if (v.HumanoidRootPart.Position - position).magnitude <= range then
				characters[#characters + 1] = v
			end
		end
	end
	return characters
end

function module.GetNearestPlayer(position, range)
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and Players:GetPlayerFromCharacter(v) then
			if (v.HumanoidRootPart.Position - position).magnitude <= range then
				return Players:GetPlayerFromCharacter(v)
			end
		end
	end
end

function module.DeepCopy(table)
	local newTable = {}
	for i, v in next, table do
		if type(v) == "table" then
			newTable[i] = module.deepCopy(v)
		else
			newTable[i] = v
		end
	end

	return newTable
end

function module.playAnim(humanoid, folderName, name, sendBack)
	local anim
	for _, v in pairs(game.ReplicatedStorage.Assets.Animations:GetDescendants()) do
		if v.Name == folderName then
			anim = humanoid:LoadAnimation(v:FindFirstChild(name))
			break
		end
	end

	if not anim then
		warn(folderName .. "|" .. name .. " does not exist.")
		return
	end

	anim:Play()
	if sendBack then
		return anim
	end
end

function module.getAnim(humanoid, name)
	for _, v in pairs(humanoid:GetPlayingAnimationTracks()) do
		if v.Name == name then
			return v
		end
	end
end

function module.stopAnim(humanoid, name)
	for _, v in pairs(humanoid:GetPlayingAnimationTracks()) do
		if v.Name == name then
			v:Stop()
		end
	end
end

function module.wait(TIME)
	TIME = TIME or 1 / 60
	local SECOND = os.clock()
	while os.clock() - SECOND < TIME do
		runService.Stepped:Wait()
	end
end

function module.rayCast(origin, direction, list)
	table.insert(list, Visual)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = list

	return workspace:Raycast(origin, direction, raycastParams)
end

local function ConvertToVector(CF)
	return typeof(CF) == "CFrame" and CF.Position or CF
end

function module.mystCast(Orgin, Goal, Data, FilterType)
	local StartPosition = ConvertToVector(Orgin)
	local EndPosition = ConvertToVector(Goal)
	local Difference = EndPosition - StartPosition
	local Direction = Difference.Unit
	local Distance = Difference.Magnitude

	local RayData = RaycastParams.new()
	RayData.FilterDescendantsInstances = Data or { Visual }
	RayData.FilterType = FilterType or Enum.RaycastFilterType.Exclude
	--RayData.IgnoreWater = IgnoreWater or true
	--RayData.CollisionGroup = CollisionGroup or "MystSub"

	local result = workspace:Raycast(StartPosition, Direction * Distance, RayData)
	return result
end

function module.visualizeRay(origin, goal, time, color)
	local part = Instance.new("Part")
	part.Material = Enum.Material.Neon
	part.Size = Vector3.new(0.2, 0.2, (goal - origin).magnitude)
	part.CFrame = CFrame.new(origin, goal) * CFrame.new(0, 0, -(goal - origin).magnitude / 2)
	part.Anchored = true
	part.CanCollide = false
	part.Color = color or Color3.fromRGB(255, 46, 46)
	part.Parent = Visual
	game.Debris:AddItem(part, time or 5)
	return part
end

function module.mystVisualize(Orgin, Goal, Color)
	local StartPosition = ConvertToVector(Orgin)
	local EndPosition = ConvertToVector(Goal)
	local Distance = (EndPosition - StartPosition).Magnitude

	local Beam = Instance.new("Part")
	Beam.Anchored = true
	Beam.Color = Color or Color3.fromRGB(255, 255, 255)
	Beam.Locked = true
	Beam.CanCollide = false
	Beam.Size = Vector3.new(0.1, 0.1, Distance)
	Beam.CFrame = CFrame.new(StartPosition, EndPosition) * CFrame.new(0, 0, -Distance / 2)
	Beam.Parent = Visual or game.Workspace
	game.Debris:AddItem(Beam, 4)
end

function module.getSound(name, volume)
	for _, v in pairs(game.ReplicatedStorage.Sounds:GetDescendants()) do
		if v.Name == name then
			local sound = v:Clone()
			sound.Volume = volume or sound.Volume
			return sound
		end
	end
end

function module.Aim(p, delay, torque, position)
	local mouse = p:GetMouse()
	local c = p.Character

	local bp = Instance.new("BodyPosition")
	bp.MaxForce = Vector3.new(1, 1, 1) * 1e7
	bp.P = (position and bp.P or 1e6)
	bp.Position = (position or c.HumanoidRootPart.Position)
	bp.Parent = c.HumanoidRootPart

	local bg = Instance.new("BodyGyro")
	bg.MaxTorque = (torque or Vector3.new(1, 1, 1)) * 1e7
	bg.P = 500000
	bg.Parent = (collectionService:HasTag(c, "Aim") and c.HumanoidRootPart) or nil

	coroutine.wrap(function()
		if collectionService:HasTag(c, "Aim") then
			while collectionService:HasTag(c, "Aim") do
				bg.CFrame = CFrame.new(bp.Position, mouse.hit.p)
				task.wait()
			end
		elseif collectionService:HasTag(c, "NoAim") then
			while collectionService:HasTag(c, "NoAim") do
				task.wait()
			end
		end

		task.wait(delay or 0)
		bg:Destroy()
		bp:Destroy()
	end)()
end

function module.Notify(p, text, duration)
	if p and p:IsA("Player") then
		local text1 = text or "<b>Couldn't get the text.</b>"
		local duration1 = duration or 4
		local UI = p.PlayerGui:FindFirstChild("HUD"):FindFirstChild("Notifications")
		if UI then
			local textLabel = Instance.new("TextLabel")
			textLabel.Size = UDim2.new(0.415, 0, 0.15, 0)
			textLabel.Position = UDim2.new(0.3, 0, -1.5, 0)
			textLabel.BackgroundTransparency = 1
			textLabel.Font = Enum.Font.GothamMedium
			textLabel.RichText = true
			textLabel.TextScaled = true
			textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			textLabel.Text = text1
			local gradient = Instance.new("UIGradient")
			gradient.Rotation = 90
			gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(223, 223, 223))
			gradient.Parent = textLabel
			local value = Instance.new("NumberValue")
			value.Name = "duration"
			value.Value = duration1
			value.Parent = textLabel
			textLabel.Parent = UI
		end
	end
end
return module
