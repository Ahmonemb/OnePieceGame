local PhysicsService = game:GetService("PhysicsService")

local module = {}

local playerCollisionGroupName = "NoCollision"
PhysicsService:RegisterCollisionGroup(playerCollisionGroupName)
PhysicsService:CollisionGroupSetCollidable(playerCollisionGroupName, playerCollisionGroupName, false)

local previousCollisionGroups = {}

local function setCollisionGroup(object)
	if object:IsA("BasePart") then
		previousCollisionGroups[object] = object.CollisionGroupId
		object.CollisionGroup = playerCollisionGroupName
	end
end

local function setCollisionGroupRecursive(object)
	setCollisionGroup(object)

	for _, child in ipairs(object:GetChildren()) do
		setCollisionGroupRecursive(child)
	end
end

local function resetCollisionGroup(object)
	local previousCollisionGroupId = previousCollisionGroups[object]
	if not previousCollisionGroupId then
		return
	end

	local previousCollisionGroupName = object.CollisionGroup
	if not previousCollisionGroupName then
		return
	end

	object.CollisionGroup = previousCollisionGroupName
	previousCollisionGroups[object] = nil
end

local function onCharacterAdded(character)
	setCollisionGroupRecursive(character)

	character.DescendantAdded:Connect(setCollisionGroup)
	character.DescendantRemoving:Connect(resetCollisionGroup)
end

for _, object in pairs(workspace:GetDescendants()) do
	if object:FindFirstChild("HumanoidRootPart") then
		onCharacterAdded(object)
	end
end
workspace.DescendantAdded:Connect(function(object)
	if object:FindFirstChild("HumanoidRootPart") then
		onCharacterAdded(object)
	end
end)

return module
