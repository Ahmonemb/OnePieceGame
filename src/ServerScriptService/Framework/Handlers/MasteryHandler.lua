--/Services
local Players = game:GetService("Players")

--/Modules
local module = {}
local Datastore = require(script.Parent.Parent.Systems.Datastore)

--/Variables
local Remote = game.ReplicatedStorage.Remotes.Misc.Mastery
local Invites = {}


--/TODO: Load mastery onto the folder
function module.LoadMastery(Player)
	task.wait(1)
	local MasteryData = Datastore.GetData(Player,"Mastery")
	Remote:FireClient(Player,MasteryData,"Load")
end

--/TODO: Add a new mastery to data
function module.AddMastery(Player,Name)
	local MasteryData = Datastore.GetData(Player,"Mastery")
	MasteryData[Name] = {Level = 1, Experience = 0, MaxExperience = 50}
end

--/TODO: Update mastery to the client
function module.UpdateMastery(Player)
	local MasteryData = Datastore.GetData(Player,"Mastery")
	Remote:FireClient(Player,MasteryData,"Update")
end

--//SERVER METHODS\\--
function module.MasteryLevelUp(Player,Ability)
	local MasteryData = Datastore.GetData(Player,"Mastery")
	if MasteryData[Ability] then 
		local Mastery = MasteryData[Ability]
		if Mastery.Experience >= Mastery.MaxExperience then
			local Difference = Mastery.Experience-Mastery.MaxExperience
			Mastery.Level += 1 
			Mastery.Experience = Difference 
			Mastery.MaxExperience += 50
			module.MasteryLevelUp(Player,Ability)
		end
	end
end

--/TODO: Get mastery 
function module.GetMastery(Player,Ability)
	local MasteryData = Datastore.GetData(Player,"Mastery")
	return MasteryData[Ability] or warn(Ability.." does not exist in mastery.")
end

--/TODO: Set mastery 
function module.IncreaseMastery(Player,Ability,Amount)
	local MasteryData = Datastore.GetData(Player,"Mastery")
	if MasteryData[Ability] then 
		local Mastery = MasteryData[Ability]
		Mastery.Experience += Amount 
		module.MasteryLevelUp(Player,Ability)
		module.UpdateMastery(Player)
	end
end

--/Events
Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function(Character)
		module.LoadMastery(Player)
	end)
end)

Remote.OnServerEvent:connect(function(p,action,...)
	if module[action] then
		module[action](p,...)
	end
end)


return module
