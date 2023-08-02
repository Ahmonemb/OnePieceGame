--/Services

--/Modules
local cooldownHandler = require(script.Parent.Parent.Handlers.CooldownHandler)
local module = {}

--/Variables
local attackRemote = game.ReplicatedStorage.Remotes.Misc[script.Name]

--/TODO: Cover arms with armour
function module.Buso(p)
	local c = p.Character
	local cooldowns = c.Cooldowns
	local states = c.States

	if cooldowns:GetAttribute("Buso") then
		return
	end
	cooldownHandler.addCooldown(c, "Buso")

	if not states:GetAttribute("BusoActive") then
		states:SetAttribute("BusoActive", true)
		require(game.StarterPlayer.StarterPlayerScripts.ClientFramework.Visuals.HakiVFX).Buso({ c, true })
		--attackRemote:FireAllClients("Buso",{c,true})
	else
		states:SetAttribute("BusoActive", false)
		require(game.StarterPlayer.StarterPlayerScripts.ClientFramework.Visuals.HakiVFX).Buso({ c, false })
		--attackRemote:FireAllClients("Buso",{c,false})
	end
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
