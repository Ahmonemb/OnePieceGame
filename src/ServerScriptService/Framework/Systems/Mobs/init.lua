--/Services
local collectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

--/Modules
local Information = require(script.Information)
local Class = require(script.Class)
local Mobs = {}

--/Variables
local MobSpawn = game.ReplicatedStorage.Remotes.Misc.MobSpawn
_G.Mobs = {}


function LoadMobs()
	for MobType,MobInfo in pairs(Information) do
		for i = 1,MobInfo.Amount do
			local MobData = Class.new(MobType,#_G.Mobs)
			MobData:Movement()
			MobSpawn:FireAllClients("Spawn",MobData)
			_G.Mobs[#_G.Mobs+1] = MobData
		end
	end
end

local function RenderMobs(Player)
	for i,v in pairs(_G.Mobs) do
		MobSpawn:FireClient(Player,"Spawn",v)
	end
end

LoadMobs()


Players.PlayerAdded:Connect(function(Player)
	RenderMobs(Player)
end)


return Mobs
