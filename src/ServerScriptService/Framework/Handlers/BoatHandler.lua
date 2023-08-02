--/Services

--/Modules
local module = {}
local Conversations = require(game.ReplicatedStorage.Modules.Manager.Dialogue.Conversations)
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)

--/Variables
local Remote = game.ReplicatedStorage.Remotes.Functions.BoatSpawn
local Boats = workspace.World.Boats
local BoatStorage = game.ReplicatedStorage.Assets.Boats

local function BoatFunctionality(Boat, Data)
	local VehicleSeat = Boat:FindFirstChild("VehicleSeat")
	local Reverse = false
	local Speed = 0
	local MaxSpeed = Data.MaxSpeed
	local Acceleration = Data.Acceleration
	local TurnSpeed = Data.TurnSpeed

	local BV = Boat.PrimaryPart.BodyVelocity
	local BG = Boat.PrimaryPart.BodyGyro

	while Boat.Parent == Boats do
		wait()
		if VehicleSeat.Throttle == 1 then
			Reverse = false
			if Speed < MaxSpeed then
				Speed = Speed + Acceleration
			end
			BV.Velocity = VehicleSeat.CFrame.lookVector * Speed
		elseif VehicleSeat.Throttle == 0 then
			if not Reverse then
				if Speed <= MaxSpeed and Speed >= 0 then
					Speed = Speed - Acceleration * 2
				else
					Speed = 0
				end
			else
				if Speed < 0 then
					Speed = Speed + Acceleration
				end
			end
			BV.Velocity = VehicleSeat.CFrame.lookVector * Speed
		elseif VehicleSeat.Throttle == -1 then
			Reverse = true
			if Speed <= MaxSpeed and Speed >= -(MaxSpeed / 4) then
				Speed = Speed - Acceleration
			end
			BV.Velocity = VehicleSeat.CFrame.lookVector * Speed
		end
		--Steering
		if VehicleSeat.Steer == 1 then
			BG.CFrame = BG.CFrame * CFrame.Angles(0, -TurnSpeed, 0)
		elseif VehicleSeat.Steer == -1 then
			BG.CFrame = BG.CFrame * CFrame.Angles(0, TurnSpeed, 0)
		end
	end
end

--/TODO: Spawn the player's boat
local function SpawnBoat(Player, BoatType, NPC)
	local Data = Conversations.GetConvo("Cyke").Details[BoatType]
	local BoatCoordinate = Data.Coordinate
	local SpawnArea = NPC.HumanoidRootPart.CFrame * BoatCoordinate

	local Boat = BoatStorage:FindFirstChild(BoatType):Clone()
	Boat:SetPrimaryPartCFrame(SpawnArea)
	Boat.Name = Player.Name .. "'s Boat"

	local ray = G.rayCast(SpawnArea.Position, Vector3.new(0, -50, 0), { Boat, Player.Character, NPC })
	local BP = script.BodyPosition:Clone()
	BP.Position = ray.Position + Vector3.new(0, Boat.PrimaryPart.Size.Y / 2, 0) or SpawnArea
	BP.Parent = Boat.PrimaryPart

	local BG = script.BodyGyro:Clone()
	BG.CFrame = Boat.PrimaryPart.CFrame -- CFrame.new(Boat.PrimaryPart.Position,NPC.PrimaryPart.CFrame*CFrame.new(0,0,100).Position)
	BG.Parent = Boat.PrimaryPart

	local BV = script.BodyVelocity:Clone()
	BV.Velocity = Vector3.new()
	BV.Parent = Boat.PrimaryPart
	Boat.Parent = Boats

	coroutine.wrap(function()
		BoatFunctionality(Boat, Data, Boat.VehicleSeat)
	end)()
end

local function DeleteBoat(Player)
	local PlayerBoat = Boats:FindFirstChild(Player.Name .. "'s Boat")
	if PlayerBoat then
		PlayerBoat:Destroy()
	end
end

Remote.OnServerInvoke = function(Player, BoatType, NPC)
	local Data = Player.Character.Data
	local Beli = Data:GetAttribute("Beli")

	local Price = Conversations.GetConvo("Cyke").Details[BoatType].Price

	if Beli >= Price then
		DeleteBoat(Player)
		SpawnBoat(Player, BoatType, NPC)
		return true
	else
		return false
	end
end

return module
