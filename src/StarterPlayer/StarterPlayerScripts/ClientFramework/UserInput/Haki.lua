--/Services

--/Modules
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)

--/Variables
local attackRemote = G.descendantSearch(game.ReplicatedStorage.Remotes.Misc, script.Name)

local module = {
	["T"] = function(p)
		local c = p.Character
		local cooldowns = c.Cooldowns

		if cooldowns:GetAttribute("Buso") then
			return
		end
		attackRemote:FireServer("Buso")
	end,
}

return module
