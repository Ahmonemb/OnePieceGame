--/Services

--/Modules
local cooldownHandler = require(script.Parent.Parent.Handlers.CooldownHandler)
local frameWork = script.Parent.Parent
local staminaHandler = require(frameWork.Handlers.StaminaHandler)

local module = {}

--/Variables
local attackRemote = game.ReplicatedStorage.Remotes.Misc[script.Name]

--/TODO: Jump on air
function module.Geppo(p)
	local c = p.Character
	local cooldowns = c.Cooldowns

	if cooldowns:GetAttribute("Geppo") then
		return
	end
	cooldownHandler.addCooldown(c, "Movement", "Geppo")
	staminaHandler.checkStamina(c, "Movement", "Geppo")

	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1, 1, 1) * 1e5
	bv.Velocity = c.HumanoidRootPart.CFrame.upVector * 50
	bv.Parent = c.HumanoidRootPart
	game.Debris:AddItem(bv, 0.25)

	attackRemote:FireAllClients("Geppo", c)
end

function module.Dash(p)
	local c = p.Character

	c.Humanoid.AutoRotate = false
	local direction = c.Humanoid.MoveDirection == Vector3.new(0, 0, 0) and c.HumanoidRootPart.CFrame.lookVector * 1
		or c.Humanoid.MoveDirection
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e6, 100, 1e6)
	bv.Velocity = CFrame.new(c.HumanoidRootPart.CFrame.Position, direction + c.HumanoidRootPart.CFrame.Position).lookVector
		* 60 --c.HumanoidRootPart.CFrame.upVector*50
	bv.Parent = c.HumanoidRootPart
	game.Debris:AddItem(bv, 0.25)
end

--/Events
attackRemote.OnServerEvent:connect(function(p, action, info)
	if module[action] then
		module[action](p, info)
	end
end)

return module
