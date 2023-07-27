--/Services
local collectionService = game:GetService("CollectionService")
local players = game:GetService("Players")

--/Modules
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)
local stateHandler = require(script.Parent.Parent.Handlers.StateHandler)
local Datastore = require(script.Parent.Parent.Systems.Datastore)
local Inventory = require(script.Inventory)
local Races = require(script.Races)
local module = {}

--/Variables


--/Events
players.PlayerAdded:connect(function(p)
	for i,v in pairs(script:GetChildren()) do
		if v:IsA("Folder") then
			v:Clone().Parent = p
		end
	end
	
	p.CharacterAdded:connect(function(c)
		stateHandler:CreateProfile(c)
		
		Races.LoadRace(p)
		
		Inventory.LoadItem(p)
	end)
end)



return module
