--/Services
local players = game:GetService("Players")

--/Modules
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)
local attackData = require(game.ReplicatedStorage.Modules.Manager.AttackData)
local dataStore = require(script.Parent.Parent.Parent.Systems.Datastore)
local module = {}

--/Variables

--/TODO: Check if they have a logia
function module.checkLogia(p,target, moveUsed)
	local demonFruit = players:GetPlayerFromCharacter(target) and dataStore.GetData(players:GetPlayerFromCharacter(target),"DemonFruit") or target.Data:GetAttribute("DemonFruit")
	if demonFruit == "" then return nil end
	
	local logia = attackData.getData(demonFruit,"Logia")
	local physical = attackData.getData(moveUsed[1],moveUsed[2])
	
	physical = physical and physical.physical or nil
	logia = logia and logia.value or nil
	
	local logiaRemote = game.ReplicatedStorage.Remotes.DemonFruits[demonFruit]
	
	if logia and physical then
		local Character = p:IsA("Player") and p.Character or p.Model
		if Character.States:GetAttribute("BusoActive") then
			return nil
		end
		
		logiaRemote:FireAllClients({Function = "Logia", Target = target})
		return true
	else
		return nil
	end
end


return module
