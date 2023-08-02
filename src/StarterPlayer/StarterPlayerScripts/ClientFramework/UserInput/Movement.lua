--/Services
local attackData = require(game.ReplicatedStorage.Modules.Manager.AttackData)

--/Modules
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)

--/Variables
local attackRemote = G.descendantSearch(game.ReplicatedStorage.Remotes, string.split(script.Name, "Client")[1])
local lastSpace = os.clock()

local module = {
	["LeftControl"] = function(p)
		local c = p.Character
		if c.Humanoid.WalkSpeed > 16 then
			c.Humanoid.WalkSpeed = 16
		else
			c.Humanoid.WalkSpeed = 35
		end
	end,

	["Space"] = function(p)
		local c = p.Character
		local staminaData = attackData.getData("Bomb", "NoseCannon")

		if staminaData.Stamina > c.States:GetAttribute("Stamina") then
			return
		end

		if c.Humanoid.FloorMaterial == Enum.Material.Air then
			c.Cooldowns:SetAttribute("InAir", true)
		else
			c.Cooldowns:SetAttribute("InAir", nil)
		end

		if
			((os.clock() - lastSpace <= 1) and c.Cooldowns:GetAttribute("InAir"))
			and not c.Cooldowns:GetAttribute("Geppo")
		then
			attackRemote:FireServer("Geppo")
		end
		lastSpace = os.clock()
	end,
}

return module
