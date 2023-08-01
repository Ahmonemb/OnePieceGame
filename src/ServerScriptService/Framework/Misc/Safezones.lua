--/Services

--/Modules
local module = {}
local Zones = require(game.ReplicatedStorage.Modules.Misc.Zone)

--/Variables
local Safezones = {}

-- local function InSafeZone(Character, Zone)
-- 	local TouchingParts = Zone:GetTouchingParts()
-- 	for i, v in pairs(TouchingParts) do
-- 		if v.Parent == Character then
-- 			return true
-- 		end
-- 	end
-- end

local function LoadSafezones()
	for i, v in pairs(workspace.World.Safezones:GetChildren()) do
		Safezones[i] = Zones.new(v)

		Safezones[i].playerEntered:Connect(function(Player)
			local Character = Player.Character
			Character.States:SetAttribute("Safezone", true)
			Player.PlayerGui.HUD.Safezone.Visible = true
			--G.Notify(Player,"<b><font color = 'rgb(85, 255, 127)'>Entered Safezone</font></b>",2.2)
		end)

		Safezones[i].playerExited:Connect(function(Player)
			local Character = Player.Character
			if not Character:FindFirstChild("States") then
				return
			end
			Character.States:SetAttribute("Safezone", false)
			Player.PlayerGui.HUD.Safezone.Visible = false
			--G.Notify(Player,"<b><font color = 'rgb(255, 46, 46)'>Left Safezone</font></b>",2.2)
		end)
	end
end

LoadSafezones()

return module
