--[[ Services ]]--
local UserInput = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local PlayersService = game:GetService("Players")

--// Libraries \\--
local Debris = require(ReplicatedStorage.Modules.Misc.Debris)

--// Folders \\--
local Remotes = ReplicatedStorage.Remotes

local SharedFunctions = {}

--// References \\--
local GLOBAL_CLOCK = os.clock
local coroutine = coroutine
local coroutineresume = coroutine.resume
local coroutinecreate = coroutine.create

local Visual = workspace.World.Visual

function SharedFunctions:Weld(Part0, Part1, C0, Name)
	local weld = Instance.new("ManualWeld")
	weld.Name = Name or "Weld"
	weld.Part0 = Part0
	weld.Part1 = Part1
	weld.Parent = Part0
	weld.C0 = C0

	return weld
end
--[[ Custom Wait Function ]]--
function SharedFunctions:Wait(TIME)
	TIME = TIME or 1/60
	local SECOND = GLOBAL_CLOCK()
	while GLOBAL_CLOCK() - SECOND < TIME do
		RunService.Stepped:Wait()
	end
end
function SharedFunctions:Spawn(Func)
	local NewCO

	NewCO = coroutinecreate(function()
		NewCO = nil

		local succ, err = pcall(function()
			Func()
		end)

		if not succ then print(err) end
	end)

	coroutineresume(NewCO)
end

function SharedFunctions:Delay(Time, Func)
	local NewCO

	NewCO = coroutinecreate(function()
		NewCO = nil

		local succ, err = pcall(function()
			if Time >= 1 then
				wait(Time)
			else
				SharedFunctions:Wait(Time)
			end

			Func()
		end)

		if not succ then print(err) end
	end)

	coroutineresume(NewCO)
end

function SharedFunctions:DeepSearch(Folder, Type, InfoTable)
	local NewTable = InfoTable or {}
	Type = Type or "Animation"

	local Children = Folder:GetChildren()

	for i,Object in ipairs(Children) do
		if Object:IsA(Type) then
			NewTable[#NewTable + 1] = Object
		elseif Object:IsA("Folder") or Object:IsA("ModuleScript") then
			self:DeepSearch(Object, Type, NewTable)
		end
	end
	return NewTable
end

function SharedFunctions:FireAllDistanceClients(Character, RemoteName, Distance, Data)
	local Remote = self:DeepSearch(Remotes, "RemoteEvent")
	local HumanoidRootPart = Character:FindFirstChild("PseudoTorso") and Character.PseudoTorso  or Character.HumanoidRootPart
	for _,v in ipairs(Remote) do
		if v.Name == RemoteName then
			Remote = v
			break
		end
	end
	assert(type(Remote) == "userdata", "couldnt find remote")
	for _, v in ipairs(PlayersService:GetChildren()) do
		local Magnitude = (HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude 
		if Magnitude <= Distance then
			Remote:FireClient(v, Data)
		end
	end
end

function SharedFunctions:IsPlayer(Character)
	return PlayersService:GetPlayerFromCharacter(Character)
end

function SharedFunctions:BodyPosition(Parent, P, D, Force, Position, Duration)

	local BodyPosition = Instance.new("BodyPosition")
	BodyPosition.P = P
	BodyPosition.D = D
	BodyPosition.MaxForce = Force
	BodyPosition.Position = Position
	BodyPosition.Parent = Parent

	Debris:AddItem(BodyPosition, Duration)

	return BodyPosition
end

function SharedFunctions:BodyGyro(Parent, P, D, Torque, Position, Duration)

	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.P = P
	BodyGyro.D = D
	BodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
	BodyGyro.CFrame = Position
	BodyGyro.Parent = Parent
	
	Debris:AddItem(BodyGyro, Duration)
	
	return BodyGyro
end

function SharedFunctions:DestroyForce(Parent, Force)
	for _, v in ipairs(Parent:GetDescendants()) do
		if v:IsA(Force) then
			v:Destroy()
		end
	end
end

function SharedFunctions:GetMouse(Character)
	local Player = PlayersService:GetPlayerFromCharacter(Character)
	local Mouse = Player:GetMouse()
	Mouse.TargetFilter = Visual
	return Mouse.Hit
end

return SharedFunctions
