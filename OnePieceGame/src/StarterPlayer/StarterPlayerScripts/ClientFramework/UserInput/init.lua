--/Services
local players = game:GetService("Players")
local userInputService = game:GetService("UserInputService")

--/Variables
local p = players.LocalPlayer
local c = p.Character or p.CharacterAdded:wait()
local currTool 

local mouse = p:GetMouse()
mouse.TargetFilter = workspace.World.Visual
local currentAction = false

--/Remotes
local getMouse = game.ReplicatedStorage.Remotes.Functions.GetMouse
local clientRemote = game.ReplicatedStorage.Remotes.Misc.ClientRemote

--/Modules
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)
local module = {}
local keyBinds = {}
for i,v in pairs(script:GetDescendants()) do
	if v:IsA("ModuleScript") then
		keyBinds[v.Name] = require(v)
	end
end

--/Events
getMouse.OnClientInvoke = function()
	return mouse.Hit.Position
end


local function UIEvents()
	c.ChildAdded:connect(function(child)
		if child:IsA("Tool") and keyBinds[child.Name] then
			local masteryCard = p.PlayerGui.Mastery[child.Name]
			if masteryCard then
				masteryCard.Visible = true
				masteryCard:TweenPosition(UDim2.new(masteryCard.Position.X.Scale,0,masteryCard.OpenedPosition.Value,0),"Out","Quad",.1)
			end

			if keyBinds[child.Name]["Idle"] then
				keyBinds[child.Name]["Idle"](p)
			end
		end
	end)

	c.ChildRemoved:connect(function(child)
		if child:IsA("Tool") and keyBinds[child.Name] then
			local masteryCard = p.PlayerGui.Mastery[child.Name]
			if masteryCard then
				masteryCard:TweenPosition(UDim2.new(masteryCard.Position.X.Scale,0,1.2,0),"In","Quad",.1)
				coroutine.wrap(function() wait(.5) masteryCard.Visible = false end)()
			end
		end
	end)
end
UIEvents()

userInputService.InputBegan:connect(function(input,typing)
	if typing then return end
	
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
	if not toolEquipped or c.States:GetAttribute("KeyHeld") ~= "" or table.find(keyBinds.BlacklistedKeys,input.KeyCode.Name) then return end
	
	local moveCheck = keyBinds[toolEquipped][input.KeyCode.Name] or keyBinds[toolEquipped][input.UserInputType.Name]
	if not moveCheck then return end
	c.States:SetAttribute("KeyHeld",(input.KeyCode.Name ~= "Unknown" and input.KeyCode.Name or input.UserInputType.Name))
	currentAction = true
	currTool = toolEquipped
	moveCheck = moveCheck["Held"] and moveCheck["Held"](p)
	currentAction = false
	
	--/TODO: If player presses the Q fast, it forcefully yields if needed
	if c.States:GetAttribute("KeyHeld") == "" then
		moveCheck = keyBinds[toolEquipped][input.KeyCode.Name] or keyBinds[toolEquipped][input.UserInputType.Name] 
		moveCheck = moveCheck["Release"] and moveCheck["Release"](p)
		wait()
		c.States:SetAttribute("KeyHeld","")
	end
end)


userInputService.InputEnded:connect(function(input,typing)
	if typing or not currTool or c.States:GetAttribute("KeyHeld") ~= (input.KeyCode.Name ~= "Unknown" and input.KeyCode.Name or input.UserInputType.Name) or table.find(keyBinds.BlacklistedKeys,input.KeyCode.Name) then return end
	
	if not currentAction then
		local moveCheck = keyBinds[currTool][input.KeyCode.Name] or keyBinds[currTool][input.UserInputType.Name] 
		moveCheck = moveCheck["Release"] and moveCheck["Release"](p)
	end
	currTool = nil
	wait()
	c.States:SetAttribute("KeyHeld","")
end)


clientRemote.OnClientEvent:connect(function(action,info)
	if action == "stopAnim" then
		local anim = G.getAnim(c.Humanoid,info)
		anim:Stop()
	end
end)

return module