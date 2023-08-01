--/Services
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")

--/Modules
local Rendering = {}
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)

--/Variables
local MobSpawn = game.ReplicatedStorage.Remotes.Misc.MobSpawn
local MobAnimation = game.ReplicatedStorage.Remotes.Misc.MobAnimation
local MobFolder = game.ReplicatedStorage.Assets.Mobs

local Mobs = {}

--/Functions
local function CreateMob(Data)
	local ClassName = string.split(Data.Name,"_")[1]
	local Mob = MobFolder:FindFirstChild(ClassName) 
	if not Mob then warn(ClassName.." does not exist.") return end 
	
	--/TODO: Make the torso not part of the model and name it after the name of the mob so they can find the torso with a "findfirstchild" search
	
	Mob = Mob:Clone()
	
	for i,v in pairs(Mob:GetChildren()) do
		v.Parent = Data.Model
	end
	Mob:Destroy()
	
	for i,v in pairs(Data.Model:GetChildren()) do
		if v:IsA("BasePart") then 
			v.CollisionGroup = "NoCollision"
		end
	end
	
	
	--Mob:Clone().Parent = Data.Model
	
	Data.Model.HumanoidRootPart.CFrame = Data.Torso.CFrame --*CFrame.new(0,0,8)
	Data.Moving = false 
	G.playAnim(Data.Model.Humanoid,"Mobs","NPCIdle")
	
	local Humanoid = Data.Model.Humanoid
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	--Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
	--Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
	
	Mobs[#Mobs+1] = Data
end

local function DeleteMob(Name)
	local Mob,Iteration
	for i,v in pairs(Mobs) do 
		if v.Name == Name then 
			Mob = Mobs[i]
			Iteration = i
		end
	end
	
	for i,v in pairs(Mob.Model:GetChildren()) do
		if v.Name ~= "PseudoTorso" then 
			v:Destroy()
		end
	end
	Mobs[Iteration] = nil
end

--/Events 
MobSpawn.OnClientEvent:Connect(function(Action,Data)
	if Action == "Spawn" then
		CreateMob(Data)
	elseif Action == "Death" then
		DeleteMob(Data)
	end
end)

MobAnimation.OnClientEvent:Connect(function(MobChosen,FolderName,AnimationName)
	for i,v in pairs(Mobs) do
		if v.Name == MobChosen then 
			G.playAnim(v.Model.Humanoid,FolderName,AnimationName)
		end
	end
end)

coroutine.wrap(function()
	while true do 
		for Index,Mob in pairs(Mobs) do
			if Mob.Model:GetAttribute("Walking") then 
				if not Mob.Moving then 
					local anim = G.getAnim(Mob.Model.Humanoid,"NPCIdle") 
					if anim then anim:Stop() end
					
					G.playAnim(Mob.Model.Humanoid,"Mobs","NPCMovement")
					Mob.Moving = true 
				end
			else
				if Mob.Moving then 
					local anim = G.getAnim(Mob.Model.Humanoid,"NPCMovement")
					if anim then anim:Stop() end
					
					G.playAnim(Mob.Model.Humanoid,"Mobs","NPCIdle")
					Mob.Moving = false
				end
			end
			
			--[[
			if Mob.LastCFrame ~= Mob.Torso.CFrame then
				if not Mob.Moving then 
					G.playAnim(Mob.Model.Humanoid,"NPCMovement")
					Mob.Moving = true 
				end
			else
				if Mob.Moving then 
					local anim = G.getAnim(Mob.Model.Humanoid,"NPCMovement")
					if anim then anim:Stop() end
					Mob.Moving = false
				end
			end
			Mob.LastCFrame = Mob.Torso.CFrame
			]]
			
			Mob.Model.HumanoidRootPart.CFrame = Mob.Model.HumanoidRootPart.CFrame:Lerp(Mob.Torso.CFrame,.25)
			
			
			
		end
		RunService.Heartbeat:wait()
	end
end)()


return Rendering
