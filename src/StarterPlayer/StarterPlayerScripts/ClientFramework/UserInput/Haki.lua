--/Services
local userInputService = game:GetService("UserInputService")
local collectionService = game:GetService("CollectionService")

--/Modules
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)

--/Variables
local attackRemote = G.descendantSearch(game.ReplicatedStorage.Remotes.Misc,script.Name)
local lastSpace, debounce = os.clock(), false

local module = {
	["T"] = function(p)
		local c = p.Character
		local cooldowns = c.Cooldowns

		if cooldowns:GetAttribute("Buso") then return end
		attackRemote:FireServer("Buso")
	end,
	
}

return module