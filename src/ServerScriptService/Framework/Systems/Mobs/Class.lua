--/Services
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")

--/Modules
local Information = require(script.Parent.Information)
local GlobalFunctions = require(game.ReplicatedStorage.Modules.GlobalFunctions)
local StateHandler = require(script.Parent.Parent.Parent.Handlers.StateHandler)
local MobClass = {}
MobClass.__index = MobClass
--/Remotes 
local MobAnimationRemote = game.ReplicatedStorage.Remotes.Misc.MobAnimation
local MobSpawn = game.ReplicatedStorage.Remotes.Misc.MobSpawn

--/Variables
local MAX_COMBO = 4
local COMBO_TIME_WINDOW = 0.8

--/TODO: Create a new mob
function MobClass.new(Type,Count)
	local Mob = {} 
	local MobData = Information[Type]
	setmetatable(Mob,MobClass)

	Mob.Name = string.format("%s_%d",Type,Count)
	--[[Creating the Model and Torso]]--
	local Model = Instance.new("Model")
	Model.Name = Mob.Name 

	local Torso = Instance.new("Part")
	Torso.Transparency = 1 Torso.CanCollide = false
	Torso.Name = "PseudoTorso" Torso.Anchored = false 
	Torso.Massless = false
	Torso.Size = Vector3.new(2,2,1) 
	Torso.Position = GlobalFunctions.rayCast(MobData.SpawnArea,Vector3.new(0,-30,0),{Model}).Position+Vector3.new(math.random(-25,25),2.9,math.random(-25,25)) --MobData.SpawnArea+Vector3.new(math.random(-25,25),0,math.random(-25,25))
	Torso.Parent = Model 
	Model.Parent = workspace.World.Live


	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1,1,1)*1e5
	bv.Velocity = Vector3.new(0,0,0)
	bv.Parent = Torso

	local bg = Instance.new("BodyGyro")
	bg.MaxTorque = Vector3.new(1,1,1)*1e7
	bg.P = 1e5
	bg.Parent = Torso

	Mob.Model = Model 
	Mob.Torso = Torso 

	--[[Mob Data Variables]]--
	Mob.MaxHealth = MobData.MaxHealth
	Mob.Health = Mob.MaxHealth
	Mob.Damage = MobData.Damage
	Mob.Data = MobData.Data

	Mob.Target = nil
	Mob.FollowRange = MobData.FollowRange 
	Mob.CombatRange = MobData.CombatRange
	Mob.WalkSpeed = MobData.WalkSpeed
	Mob.RespawnTime = MobData.RespawnTime


	Mob.ComboStage = 1

	--[[Attribute Folders]]--
	local folder = Instance.new("Folder")
	folder.Name = "Cooldowns"
	folder.Parent = Mob.Model 

	local folder = Instance.new("Folder")
	folder.Name = "States"
	folder.Parent = Mob.Model 

	local folder = Instance.new("Folder")
	folder.Name = "Data"
	folder.Parent = Mob.Model 

	for i,v in pairs(MobData.Data) do 
		folder:SetAttribute(i,v)
	end

	StateHandler:CreateProfile(Mob.Model)

	Mob.Model:SetAttribute("Health",Mob.Health)

	local Header = game.ReplicatedStorage.Assets.Header:Clone()
	Header.CharacterName.Text = Type
	Header.Level.Text = string.format("LVL. %d",Mob.Data.Level)
	Header.Health.Value.Text = string.format("HEALTH: %d/%d",Mob.Health,Mob.MaxHealth)
	Header.Parent = Torso

	Mob.Model:GetAttributeChangedSignal("Health"):Connect(function()
		local Value = Mob.Model:GetAttribute("Health")
		Mob.Health = Value
		if Mob.Health <= 0 then
			Header.Enabled = false
		else
			Header.Enabled = true
			Header.Health.Value.Text = string.format("HEALTH: %d/%d",Mob.Health,Mob.MaxHealth)
			Header.Health.Bar:TweenSize(UDim2.new((Mob.Health/Mob.MaxHealth),0,1,0),"Out","Quad",.6)
		end
	end)

	return Mob
end

--/TODO: Find nearest dude
local function FindNearestPlayer(self)
	for _,v in pairs(workspace:GetChildren()) do
		if Players:GetPlayerFromCharacter(v) and (v.HumanoidRootPart.Position-self.Torso.Position).magnitude <= self.FollowRange then 
			self.Target = v
		end
	end
end

--/TODO: Make the mob attack
function MobClass:Attack()
	local CombatModule = require(script.Parent.Parent.Parent.Skills.FightingStyles[self.Data.FightingStyle])
	if CombatModule then 
		local Cooldowns = self.Model.Cooldowns
		local States = self.Model.States

		if Cooldowns:GetAttribute("Melee") then return end
		if self.Model.Cooldowns:FindFirstChild("Attacked") then return end
		
		if (os.clock()-States:GetAttribute("MeleeClicked")) > COMBO_TIME_WINDOW or self.ComboStage >= MAX_COMBO then
			self.ComboStage = 1
		else
			self.ComboStage += 1
		end

		local Player = GlobalFunctions.GetNearestPlayer(self.Torso.Position,self.CombatRange)
		if Player then
			MobAnimationRemote:FireClient(Player,self.Name,"Combat","Combo"..self.ComboStage)
		end
		task.wait(0.15)
		CombatModule.Melee(self)
	end
end

--/TODO: Make the mob respawn
function MobClass:Respawn() 
	if self.Health <= 0 then 
		self.Torso:SetAttribute("Dead",true)
		MobSpawn:FireAllClients("Death",self.Name)

		wait(self.RespawnTime) 

		--/Reset Values
		self.Health = self.MaxHealth
		self.Target = nil
		self.Model:SetAttribute("Health",self.Health)


		--/Respawn and start moving
		self.Torso:SetAttribute("Dead",nil)
		self:Movement()
		MobSpawn:FireAllClients("Spawn",self)
	end
end


--/TODO: Make the MobClass follow
function MobClass:Movement()
	--print(self)

	coroutine.wrap(function()
		while self.Health > 0 do
			if not self.Target then
				FindNearestPlayer(self)
			end

			if self.Target and self.Target.Humanoid.Health > 0 then
				local Distance = (self.Target.HumanoidRootPart.Position-self.Torso.Position).magnitude 
				if Distance <= self.FollowRange then 

					local HipHeight = GlobalFunctions.rayCast(self.Torso.Position,Vector3.new(0,-4.5,0),{self.Target,self.Model})

					if HipHeight and not self.Model.Cooldowns:FindFirstChild("Attacked") and not self.Model.States:FindFirstChild("Lerping") then 
						
						local Position = HipHeight.Position+Vector3.new(0,2.9,0)
						local TargetPosition = self.Target.HumanoidRootPart.Position 
						local TargetCFrame = CFrame.new(Position,Vector3.new(TargetPosition.X,Position.Y,TargetPosition.Z))
						
						self.Torso.CFrame = self.Torso.CFrame:Lerp(TargetCFrame,0.19000005722046)
						self.Torso.BodyGyro.CFrame = TargetCFrame
						self.Torso.BodyVelocity.Velocity = TargetCFrame.LookVector*self.WalkSpeed

						self.Model:SetAttribute("Walking",true)
					else
						if self.Model.Cooldowns:FindFirstChild("Attacked") and self.Target.States.Combo.Value < 5 and not self.Model.States:FindFirstChild("M1KB") then
							print("m1")
							self.Torso.BodyVelocity.Velocity = self.Target.HumanoidRootPart.CFrame.LookVector * 7 
							self.Model:SetAttribute("Walking",nil)
							task.wait()
						elseif self.Model.Cooldowns:FindFirstChild("Attacked") and self.Target.States.Combo.Value == 5 then
							print("knockback")
							self.Torso.BodyVelocity.Velocity = self.Target.HumanoidRootPart.CFrame.LookVector * 40 
							self.Model:SetAttribute("Walking",nil)
							task.wait()
						elseif self.Model.Cooldowns:FindFirstChild("Attacked") and self.Target.States.Combo.Value == 6 and not self.Model.States:FindFirstChild("SendUp") then
							print("sendup")
							local SendUp = Instance.new("BoolValue", self.Model.States)
							SendUp.Name = "SendUp"
							SendUp.Parent = self.Model.States
							
							self.Torso.BodyVelocity.Velocity = self.Target.HumanoidRootPart.CFrame.UpVector * 33
							task.delay(.4, function()
								self.Torso.BodyVelocity.Velocity = Vector3.new()
							end)
							task.delay(.5,function()
								local BP = Instance.new("BodyPosition",self.Torso)
								BP.Position = self.Torso.Position
								BP.MaxForce = Vector3.new(200000,200000,200000)
								BP.P = 400
								BP.Name = "HoldBP"
								task.delay(3, function()
									BP:Destroy()
								end)
								print("holding")
							end)
							
							task.wait(3.53255529981)
							self.Model:SetAttribute("Walking",nil)
							SendUp:Destroy()
						elseif self.Model.States:FindFirstChild("Lerping") and self.Target.States.Combo.Value == 7 then
							if self.Torso:FindFirstChild("HoldBP") then
								self.Torso:FindFirstChild("HoldBP"):Destroy()
							end
							print("5")
							self.Torso.BodyVelocity.Velocity = Vector3.new(0,0,0)
							self.Model:SetAttribute("Walking",nil)
						else
							print("6")
							self.Torso.BodyVelocity.Velocity = Vector3.new(0,-30,0)
							self.Model:SetAttribute("Walking",nil)
						end
					end


					--/TODO: Combat Prox Check 
					if Distance <= self.CombatRange and not self.Model.Cooldowns:FindFirstChild("Attacked") then
						self.Torso.BodyVelocity.Velocity = Vector3.new()
						self.Model:SetAttribute("Walking",nil)
						self:Attack()
					end

				else 
					self.Target = nil 
					self.Torso.BodyVelocity.Velocity = Vector3.new()
					self.Model:SetAttribute("Walking",nil)
					
				end
			else
				self.Target = nil
				self.Torso.BodyVelocity.Velocity = Vector3.new()
				self.Model:SetAttribute("Walking",nil)
				
			end
			task.wait()
		end
		self.Torso.BodyVelocity.Velocity = Vector3.new()
		self.Model:SetAttribute("Walking",nil)
		self:Respawn()
	end)()
end

return MobClass
