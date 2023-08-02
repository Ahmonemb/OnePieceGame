--/Services

--/Modules
local module = {}
local Datastore = require(script.Parent.Parent.Parent.Systems.Datastore)

--/Variables
local EquipData = require(script.EquipData)
local Races = {
	{ Name = "Human", Chance = 75 },
	{
		Name = "Mink",
		Chance = 80,
		Variants = {
			{ Name = "Reindeer", Chance = 50 },
			{ Name = "Rabbit", Chance = 100 },
		},
	},
	{
		Name = "Fishman",
		Chance = 90,
		Variants = {
			{ Name = "Octopus", Chance = 50 },
			{ Name = "Octopus", Chance = 100 },
		},
	},
	{
		Name = "Skypian",
		Chance = 100,
		Variants = {
			{ Name = "Normal", Chance = 80 },
			{ Name = "Fallen", Chance = 100 },
		},
	},
}

--/TODO: Spin for Race
local function SpinRace(Player)
	local Data = Player.Character.Data

	local Randomize = Random.new():NextInteger(1, 100)
	local RaceSpun = ""

	--/Race Spinning
	for i = 1, #Races do
		RaceSpun = Races[i]
		local PreviousChance = Races[i - 1] and Races[i - 1].Chance or 0
		if Randomize <= RaceSpun.Chance and Randomize > PreviousChance then
			RaceSpun = RaceSpun.Name
			break
		end
	end

	Data:SetAttribute("Race", RaceSpun)
	--print(Randomize,RaceSpun)
	return RaceSpun
end

--/TODO: Spin for Racial Variant
local function SpinVariant(Player)
	local Data = Player.Character.Data
	local Race = Data:GetAttribute("Race")

	local Randomize = Random.new():NextInteger(1, 100)
	local Variant

	for i = 1, #Races do
		if Races[i].Name == Race then
			Race = Races[i]
			break
		end
	end

	if not Race.Variants then
		return
	end

	--/Variant Spinning
	for i = 1, #Race.Variants do
		Variant = Race.Variants[i]
		local PreviousChance = Races[i - 1] and Races[i - 1].Chance or 0
		if Randomize <= Variant.Chance and Randomize > PreviousChance then
			Variant = Variant.Name
			break
		end
	end

	if typeof(Variant) == "table" then
		Variant = Variant.Name
	end
	--/Random Accessory Type
	print(Randomize, Race.Name, Variant)
	local NumAccessories = #game.ReplicatedStorage.Assets.RacialFeatures[Race.Name][Variant]:GetChildren()

	Data:SetAttribute("RaceAccessory", Random.new():NextInteger(1, NumAccessories))
	Data:SetAttribute("Variant", Variant)

	return Variant
end

function module.LoadRace(Player)
	task.wait(1)
	local Race = Datastore.GetData(Player, "Race")
	local Variant = Datastore.GetData(Player, "Variant")

	if Race == "" then
		Race = SpinRace(Player)
	end

	if Variant == "" then
		Variant = SpinVariant(Player)
	end

	if Race == "Human" then
		return
	end
	--[[
	Race = SpinRace(Player) 
	if Race == "Human" then return end
	Variant = SpinVariant(Player)
	]]

	--/Equip Accessories
	local AccessoryNum = Player.Character.Data:GetAttribute("RaceAccessory")
	local AccessoryData = EquipData[Race][Variant][AccessoryNum]

	--Main Feature
	if typeof(AccessoryData[1]) == "table" then --Double Parts
		for i = 1, #AccessoryData do
			local Data = AccessoryData[i]
			local Accessory = game.ReplicatedStorage.Assets.RacialFeatures[Race][Variant][AccessoryNum]:Clone()
			Accessory.CFrame = Player.Character:FindFirstChild(Data.BodyPart).CFrame * Data.CFrame
			local Weld = Instance.new("Weld")
			Weld.Part0 = Accessory
			Weld.C0 = Weld.Part0.CFrame:inverse()
			Weld.Part1 = Player.Character:FindFirstChild(Data.BodyPart)
			Weld.C1 = Weld.Part1.CFrame:inverse()
			Weld.Parent = Accessory
			Accessory.Name = "RacialAccessory" .. i
			Accessory.Parent = Player.Character
		end
	else
		local Accessory = game.ReplicatedStorage.Assets.RacialFeatures[Race][Variant][AccessoryNum]:Clone()
		Accessory.CFrame = Player.Character:FindFirstChild(AccessoryData.BodyPart).CFrame * AccessoryData.CFrame
		local Weld = Instance.new("Weld")
		Weld.Part0 = Accessory
		Weld.C0 = Weld.Part0.CFrame:Inverse()
		Weld.Part1 = Player.Character:FindFirstChild(AccessoryData.BodyPart)
		Weld.C1 = Weld.Part1.CFrame:Inverse()
		Weld.Parent = Accessory
		Accessory.Name = "RacialAccessory"
		Accessory.Parent = Player.Character
	end

	--Side Feature
	AccessoryData = EquipData[Race][Variant]["Side"]

	if AccessoryData then
		local Side = game.ReplicatedStorage.Assets.RacialFeatures[Race][Variant]["SideFeature"]:Clone()
		Side.CFrame = Player.Character:FindFirstChild(AccessoryData.BodyPart).CFrame * AccessoryData.CFrame
		local Weld = Instance.new("Weld")
		Weld.Part0 = Side
		Weld.C0 = Weld.Part0.CFrame:Inverse()
		Weld.Part1 = Player.Character:FindFirstChild(AccessoryData.BodyPart)
		Weld.C1 = Weld.Part1.CFrame:Inverse()
		Weld.Parent = Side
		Side.Name = "SideFeatureAccessory"
		Side.Parent = Player.Character
	end
end

--/TODO: To get racial passives
--function module.GetPassive(Player) end

return module
