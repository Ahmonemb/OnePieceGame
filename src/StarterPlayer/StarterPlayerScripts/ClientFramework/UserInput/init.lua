--/Services
local players = game:GetService("Players")
local userInputService = game:GetService("UserInputService")
local collectionService = game:GetService("CollectionService")

--/Variables
local p = players.LocalPlayer
local c = p.Character or p.CharacterAdded:wait()
local currTool

local mouse = p:GetMouse()
mouse.TargetFilter = workspace.World.Visual
local currentAction = false

--/Modules
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)
local module = {}
local keyBinds = {}
for _, v in pairs(script:GetDescendants()) do
	if v:IsA("ModuleScript") then
		keyBinds[v.Name] = require(v)
	end
end

--/Remotes
local getMouse = game.ReplicatedStorage.Remotes.Functions.GetMouse
local clientRemote = game.ReplicatedStorage.Remotes.Misc.ClientRemote
local RemovePlayerTag = game.ReplicatedStorage.Remotes.Misc.RemovePlayerTag

--/Events
getMouse.OnClientInvoke = function()
	return mouse.Hit.Position
end

local function UIEvents()
	c.ChildAdded:Connect(function(child)
		if child:IsA("Tool") and keyBinds[child.Name] then
			local masteryCard = p.PlayerGui.Mastery[child.Name]
			if masteryCard then
				masteryCard.Visible = true
				masteryCard:TweenPosition(
					UDim2.new(masteryCard.Position.X.Scale, 0, masteryCard.OpenedPosition.Value, 0),
					"Out",
					"Quad",
					0.1
				)
			end

			if keyBinds[child.Name]["Idle"] then
				keyBinds[child.Name]["Idle"](p)
			end
		end
	end)

	c.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") and keyBinds[child.Name] then
			local masteryCard = p.PlayerGui.Mastery[child.Name]
			if masteryCard then
				masteryCard:TweenPosition(UDim2.new(masteryCard.Position.X.Scale, 0, 1.2, 0), "In", "Quad", 0.1)
				coroutine.wrap(function()
					task.wait(0.5)
					masteryCard.Visible = false
				end)()
			end
		end
	end)
end
UIEvents()

userInputService.InputBegan:Connect(function(input, typing)
	if typing then
		return
	end

	if c.Humanoid.Health <= 0 then
		c = p.Character
		UIEvents()
		return
	end

	if keyBinds.Movement[input.KeyCode.Name] then
		keyBinds.Movement[input.KeyCode.Name](p)
		return
	elseif keyBinds.Haki[input.KeyCode.Name] then
		keyBinds.Haki[input.KeyCode.Name](p)
		return
	end

	local toolEquipped = (c:FindFirstChildOfClass("Tool") and c:FindFirstChildOfClass("Tool").Name) or nil
	if
		not toolEquipped
		or c.States:GetAttribute("KeyHeld") ~= ""
		or table.find(keyBinds.BlacklistedKeys, input.KeyCode.Name)
	then
		return
	end

	local moveCheck = keyBinds[toolEquipped][input.KeyCode.Name] or keyBinds[toolEquipped][input.UserInputType.Name]
	if not moveCheck then
		return
	end
	c.States:SetAttribute(
		"KeyHeld",
		(input.KeyCode.Name ~= "Unknown" and input.KeyCode.Name or input.UserInputType.Name)
	)
	currentAction = true
	currTool = toolEquipped
	moveCheck = moveCheck["Held"] and moveCheck["Held"](p)
	currentAction = false

	--/TODO: If player presses the Q fast, it forcefully yields if needed
	if c.States:GetAttribute("KeyHeld") == "" then
		moveCheck = keyBinds[toolEquipped][input.KeyCode.Name] or keyBinds[toolEquipped][input.UserInputType.Name]
		moveCheck = moveCheck["Release"] and moveCheck["Release"](p)
		task.wait()
		c.States:SetAttribute("KeyHeld", "")
	end
end)

userInputService.InputEnded:Connect(function(input, typing)
	if
		typing
		or not currTool
		or c.States:GetAttribute("KeyHeld") ~= (input.KeyCode.Name ~= "Unknown" and input.KeyCode.Name or input.UserInputType.Name)
		or table.find(keyBinds.BlacklistedKeys, input.KeyCode.Name)
	then
		return
	end

	if not currentAction then
		local moveCheck = keyBinds[currTool][input.KeyCode.Name] or keyBinds[currTool][input.UserInputType.Name]
		moveCheck = moveCheck["Release"] and moveCheck["Release"](p)
	end
	currTool = nil
	task.wait()
	c.States:SetAttribute("KeyHeld", "")
end)

clientRemote.OnClientEvent:Connect(function(action, info)
	if action == "stopAnim" then
		local anim = G.getAnim(c.Humanoid, info)
		anim:Stop()
	end
end)

RemovePlayerTag.OnClientEvent:Connect(function(action1, skillName, moduleName)
	local attackRemote = G.descendantSearch(game.ReplicatedStorage.Remotes.DemonFruits, moduleName)

	collectionService:RemoveTag(c, action1)
	print(collectionService:HasTag(c, "Aim"))
	c.HumanoidRootPart:FindFirstChild("BodyGyro"):Destroy()
	c.HumanoidRootPart:FindFirstChild("BodyPosition"):Destroy()
	c.States:SetAttribute("KeyHeld", "")
	local anim = G.getAnim(c.Humanoid, skillName)
	if anim then
		anim:AdjustSpeed(1)
	end
	attackRemote:FireServer("Move4")
end)

return module
