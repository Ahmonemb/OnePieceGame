--/Services
local collectionService = game:GetService("CollectionService")
local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")

--/Modules
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)
local rockDebris = require(script.Parent.Parent.RockDebris)
local bezierCurve = require(game.ReplicatedStorage.Modules.Misc.BezierCurves)
local hitDetection = require(game.ReplicatedStorage.Modules.Misc.HitDetection)
local module = {}

--/Variables
local attackRemote = game.ReplicatedStorage.Remotes.DemonFruits[string.split(script.Name,"VFX")[1]]
local effectFolder = game.ReplicatedStorage.Assets.VFX.DemonFruits[string.split(script.Name,"VFX")[1]]


--// Wunbo Variables
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Modules = ReplicatedStorage.Modules
local Debris = require(Modules.Misc.Debris)
local VFXHandler = require(Modules.VFX.VFXHandler)
local Assets = ReplicatedStorage.Assets
local VFXEffects = Assets.VFXEffects
local World = game.Workspace:WaitForChild("World")
local Visual = World.Visual
local Live = World.Live
local SharedFunctions = require(Modules.SharedFunctions)
local SoundManager = require(Modules.Manager.SoundManager)

function module.Logia(c)
	local storage = effectFolder
	local speed = .2

	for i,v in pairs(c:GetChildren()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			tweenService:Create(v,TweenInfo.new(speed),{Transparency = 1}):Play()
			local particle = storage.logiaEffect:Clone()
			particle.Parent = v
			particle:Emit(17)
			game.Debris:AddItem(particle,1)
			coroutine.wrap(function()
				wait(speed)
				tweenService:Create(v,TweenInfo.new(speed),{Transparency = 0}):Play()
			end)()
		elseif v:IsA("Accessory") then
			tweenService:Create(v.Handle,TweenInfo.new(speed),{Transparency = 1}):Play()
			coroutine.wrap(function()
				wait(speed)
				tweenService:Create(v.Handle,TweenInfo.new(speed),{Transparency = 0}):Play()
			end)()
		end
	end
end

function module.LightSword(c)
	local equippedWeapons = c.Weapons
	local storage = effectFolder
	local states = c.States

	if not equippedWeapons:GetAttribute("LightSword") then
		equippedWeapons:SetAttribute("LightSword",true)

		local sword = storage.lightSword:Clone()
		sword.Transparency = 1
		local motor = Instance.new("Motor6D")
		motor.Part0 = c["Right Arm"]
		motor.C0 = CFrame.new(0.108703613, -0.976646423, -2.54676628, 0, 0, -1, 1, 0, 0, 0, -1, 0)
		motor.Part1 = sword
		motor.C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		motor.Parent = sword
		tweenService:Create(sword,TweenInfo.new(.1),{Transparency = 0}):Play()
		sword:SetAttribute("OGMaterial",sword.Material.Name)
		sword:SetAttribute("OGColor",sword.Color)
		sword.Parent = equippedWeapons

		coroutine.wrap(function()
			wait(.1)
			if states:GetAttribute("BusoActive") then
				sword.Material = "Glass"
				tweenService:Create(sword,TweenInfo.new(.1),{Color = Color3.fromRGB(0,0,0)}):Play()
			end
		end)()
	else
		equippedWeapons:SetAttribute("LightSword",nil)

		local sword = equippedWeapons:FindFirstChild("lightSword")
		tweenService:Create(sword,TweenInfo.new(.1),{Transparency = 1}):Play()
		game.Debris:AddItem(sword,.1)
	end
end

function module.CastMirrors(Data)

	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")
	
	local pos = Data.pos
	local Magnitude = Data.Magnitude
	
	--// Zig Zag Coordinates
	local StartPos = Root.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(22.5),0,0)

	local Distance = Magnitude
	local AllCoordinates = VFXHandler.ZigZag({
		Amount = math.ceil(Magnitude/10);
		Distance = Distance;
		StartPosition = StartPos;
		EndPosition = StartPos * CFrame.new(0,Distance,0);
		Offset = 2;
		Visualize = false;
	});
	
	local AllMirriors = {}
	for i = 1, #AllCoordinates do
		local Coordinate = AllCoordinates[i]
		local NextCoordinate = AllCoordinates[i+1]
		if Coordinate and NextCoordinate then
			local Distance = (Coordinate.Position - NextCoordinate.Position).Magnitude 

			local GoalCFrame = CFrame.new(Coordinate.Position, NextCoordinate.Position) * CFrame.new(0,0,-Distance/2) * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0)
			local GoalSize = Vector3.new(Distance, 1, 1)

			local Target = VFXEffects.Part.Block:Clone()        
			Target.Size = Vector3.new(1, 1, 1)
			Target.Material = "Neon"
			Target.Color = Color3.fromRGB(255, 255, 127)
			Target.Transparency = 0
			Target.Anchored = true
			Target.CFrame = Coordinate
			Target.Parent = Visual

			local tween = TweenService:Create(Target, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = GoalCFrame, ["Size"] = GoalSize})
			tween:Play()
			tween:Destroy()
			
			local Mirror = script.Mirror:Clone()
			Mirror.CFrame = CFrame.new(Coordinate.Position, NextCoordinate.Position) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)
			Mirror.Parent = Visual
			
			table.insert(AllMirriors, Mirror)
			table.insert(AllMirriors, Target)
		end	

		wait()
	end
	Root.CFrame = AllCoordinates[#AllCoordinates]
	for _, v in ipairs(AllMirriors) do
		local tween = TweenService:Create(v, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Size"] = Vector3.new(0,0,0)})
		tween:Play()
		tween:Destroy()
		Debris:AddItem(v, 0.15)
		wait(0.05)
	end
end;

function module.Move1(Data)

	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")
	local projectileCFrame = Data.projectileCFrame
	local projectileData = Data.projectileData
	local hitSomething = false

	local Projectile = script.PikaBall:Clone()
	Projectile.CFrame = projectileCFrame
	Projectile.Parent = Visual

	local tween = TweenService:Create(Projectile, TweenInfo.new(projectileData.Lifetime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["CFrame"] = Projectile.CFrame * CFrame.new(0,0, -projectileData.Velocity * projectileData.Lifetime)})
	tween:Play()
	tween:Destroy()

	Debris:AddItem(Projectile, projectileData.Lifetime)

	coroutine.wrap(function()
		local hitPoint = hitDetection:ProjectileActive(projectileData)

		if hitPoint then
			hitSomething = true
			--// hit something effects go here
			tween:Pause()
			Projectile.Anchored = true
			Projectile.Transparency = 1
			Debris:AddItem(Projectile, 3)
			
			if Data.Shockwave then
				SoundManager:Play(Root, "pikaExplosion", {Volume = 2, TimePosition = 8.5})
				local shock = VFXEffects.Mesh.upwardShock:Clone()
				shock.CFrame = CFrame.new(Projectile.Position) * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0)
				shock.Color = Color3.fromRGB(255, 255, 127)
				shock.Size = Vector3.new(0,0,0)
				local tween = TweenService:Create(shock,TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size = Vector3.new(75,105,75), CFrame = shock.CFrame*CFrame.new(0,35,0)*CFrame.Angles(0,math.pi/2,0)})
				tween:Play()
				tween:Destroy()
				coroutine.wrap(function()
					wait(.2)
					local tween = TweenService:Create(shock,TweenInfo.new(.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size = Vector3.new(0,80,0), Color = Color3.fromRGB(255, 255, 255)})
					tween:Play()
					tween:Destroy()
					game.Debris:AddItem(shock,.2)
				end)()
				shock.Parent = Visual
			else
				SoundManager:Play(Root, "pikaExplosion", {Volume = 1, TimePosition = 8.5})
			end
			--[[ Flying Debris Rock ]]--
			VFXHandler.FlyingRocks({
				i = 2; -- first loop
				j = 5; -- nested loop
				Offset = 10; -- radius from starting pos
				Origin = Projectile.Position; -- where to start
				Filter = {Character, Visual, Projectile}; -- filter raycast
				Size = Vector2.new(1,3); -- size range random from 1,3 
				AxisRange = 80; -- velocity X and Z ranges from (-AxisRange,AxisRange)
				Height = Vector2.new(50,60); -- velocity Y ranges from X,Y
				Percent = 0.5; -- velocity * percent of nested loop
				Duration = 2; -- duration of the debris rock
				IterationDelay = 0; -- delay between each i loop
			})

			--[[ Crater on Ground ]]--
			VFXHandler.Crater({
				Cframe = CFrame.new(Projectile.Position), -- Position
				Amount = 25, -- How manay rocks
				Iteration = 25, -- Expand
				Max = 2, -- Length upwards
				FirstDuration = .25, -- Rock tween outward start duration
				RocksLength = 2 -- How long the rocks stay for
			})
			--//
			local Block = VFXEffects.Part.Block:Clone()
			Block.Anchored = true
			Block.Size = Vector3.new(0,0,0)
			Block.CanCollide = false
			Block.Anchored = true
			Block.CFrame = Projectile.CFrame	
			Block.Parent = Visual
			Debris:AddItem(Block, 1.5)

			local StarParticle = script.ParticleAttachment.StarAttachment:Clone()
			local RaysParticle = script.ParticleAttachment.RaysAttachment:Clone()
			local SparkParticle = script.ParticleAttachment.SparkAttachment:Clone()
			local WaveParticle = script.ParticleAttachment.WaveAttachment:Clone()
			local RockParticle = script.ParticleAttachment.RockAttachment:Clone()

			StarParticle.Star.Lifetime = NumberRange.new(.35)
			StarParticle.Star.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 60), NumberSequenceKeypoint.new(1, 80)}
			StarParticle.Star.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}
			StarParticle.Parent = Block

			RaysParticle.Rays.Lifetime = NumberRange.new(.5)
			RaysParticle.Rays.Color = ColorSequence.new(Color3.fromRGB(255, 255, 127))
			RaysParticle.Rays.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 100), NumberSequenceKeypoint.new(1, 0)}
			RaysParticle.Parent = Block

			SparkParticle.Spark.Lifetime = NumberRange.new(0.25, 0.35)
			SparkParticle.Spark.Speed = NumberRange.new(300)
			SparkParticle.Spark.Drag = -2
			SparkParticle.Spark.Color = ColorSequence.new(Color3.fromRGB(255, 255, 127))
			SparkParticle.Spark.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 7), NumberSequenceKeypoint.new(1, 0)}
			SparkParticle.Parent = Block

			WaveParticle.Wave.Lifetime = NumberRange.new(.5)
			WaveParticle.Wave.Color = ColorSequence.new(Color3.fromRGB(255, 255, 127))
			WaveParticle.Wave.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 80)}
			WaveParticle.Parent = Block

			RockParticle.Rock.Lifetime = NumberRange.new(1)
			RockParticle.Rock.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 2), NumberSequenceKeypoint.new(1, 0)}
			RockParticle.Rock.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0)}
			RockParticle.Rock.Acceleration = Vector3.new(0,0,0)
			RockParticle.Rock.SpreadAngle = Vector2.new(-90,90)
			RockParticle.Rock.Drag = 5
			RockParticle.Rock.ZOffset = -1
			RockParticle.Rock.Speed = NumberRange.new(200)	
			RockParticle.Parent = Block		

			StarParticle.Star:Emit(5)
			RaysParticle.Rays:Emit(25)
			SparkParticle.Spark:Emit(100)
			RockParticle.Rock:Emit(50)
			WaveParticle.Wave:Emit(1)	

			--[[ Wunbo Orbies ]]--
			VFXHandler.WunboOrbies({
				j = 4; -- j (first loop)
				i = 6; -- i (second loop)
				StartPos = Projectile.Position; -- where the orbies originate
				Duration = 0.15; -- how long orbies last
				Width = 5; -- width (x,y) sizes
				Length = 20; -- length (z) size
				Color1 = Color3.fromRGB(255, 255, 255); -- color of half of the orbies, color2 is the other half
				Color2 = Color3.fromRGB(255, 255, 127); -- color of half of the orbies, color2 is the other half
				Distance = CFrame.new(0,0,80); -- how far the orbies travel
			})

			local CrashSmoke = VFXEffects.Particle.Smoke:Clone()
			CrashSmoke.Parent = Projectile
			CrashSmoke.CanCollide = false
			CrashSmoke.Position = Projectile.Position
			CrashSmoke.Smoke.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 20), NumberSequenceKeypoint.new(1, 20)}
			CrashSmoke.Size = Vector3.new(50,0,50)
			CrashSmoke.Smoke:Emit(250)
			CrashSmoke.Anchored = true

			delay(1,function()
				CrashSmoke.Smoke.Enabled = false 
			end)
			Debris:AddItem(CrashSmoke,3)		


		end
	end)()

	wait(projectileData.Lifetime)

	if Projectile and not hitSomething then

		tween:Pause()
		Projectile.Anchored = true
		Debris:AddItem(Projectile, 0.5)
	end
end

function module.Move3(Data)
	
	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")
	
	local states = Data.States
	local mouse = players:GetPlayerFromCharacter(Character):GetMouse()

	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1,1,1)*1e12
	bv.Velocity = Root.CFrame.lookVector*125
	bv.Parent = Root

	local bg = Instance.new("BodyGyro")
	bg.MaxTorque = Vector3.new(1,1,1)*1e12
	bg.P = 5000000
	bg.Parent = Root

	--/Sound
	--local sound = G.getSound("fireFlight",1):Clone()
	--sound.Parent = Root
	--sound:Play()

	while collectionService:HasTag(Character,"LightFlight") do
		bv.Velocity = Root.CFrame.lookVector*90
		bg.CFrame = CFrame.new(Root.Position, mouse.Hit.Position)
		wait()
	end
	--sound:Destroy()
	bg:Destroy() 
	bv:Destroy()
end

function module.Move4(Data)

	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")
	local projectileCFrame = Data.projectileCFrame
	local projectileData = Data.projectileData
	local hitSomething = false

	local Projectile = script.PikaBall:Clone()
	Projectile.CFrame = projectileCFrame
	Projectile.Parent = Visual

	local tween = TweenService:Create(Projectile, TweenInfo.new(projectileData.Lifetime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["CFrame"] = Projectile.CFrame * CFrame.new(0,0, -projectileData.Velocity * projectileData.Lifetime)})
	tween:Play()
	tween:Destroy()

	Debris:AddItem(Projectile, projectileData.Lifetime)

	coroutine.wrap(function()
		local hitPoint = hitDetection:ProjectileActive(projectileData)

		if hitPoint then
			hitSomething = true
			--// hit something effects go here
			
			SoundManager:Play(Projectile, "pikaExplosion", {Volume = 0.5, TimePosition = 8.5})
			
			tween:Pause()
			Projectile.Anchored = true
			Projectile.Transparency = 1
			Debris:AddItem(Projectile, 1)
			--[[ Flying Debris Rock ]]--
			VFXHandler.FlyingRocks({
				i = 1; -- first loop
				j = 3; -- nested loop
				Offset = 10; -- radius from starting pos
				Origin = Projectile.Position; -- where to start
				Filter = {Character, Live, Visual}; -- filter raycast
				Size = Vector2.new(1,3); -- size range random from 1,3 
				AxisRange = 50; -- velocity X and Z ranges from (-AxisRange,AxisRange)
				Height = Vector2.new(50,60); -- velocity Y ranges from X,Y
				Percent = 0.35; -- velocity * percent of nested loop
				Duration = 2; -- duration of the debris rock
				IterationDelay = 0; -- delay between each i loop
			})

			--[[ Crater on Ground ]]--
			VFXHandler.Crater({
				Cframe = CFrame.new(Projectile.Position), -- Position
				Amount = 10, -- How manay rocks
				Iteration = 10, -- Expand
				Max = 2, -- Length upwards
				FirstDuration = .25, -- Rock tween outward start duration
				RocksLength = 1 -- How long the rocks stay for
			})
			--//
			local Block = VFXEffects.Part.Block:Clone()
			Block.Anchored = true
			Block.Size = Vector3.new(0,0,0)
			Block.CanCollide = false
			Block.Anchored = true
			Block.CFrame = Projectile.CFrame	
			Block.Parent = Visual
			Debris:AddItem(Block, 1.5)

			local StarParticle = script.ParticleAttachment.StarAttachment:Clone()
			local RaysParticle = script.ParticleAttachment.RaysAttachment:Clone()
			local SparkParticle = script.ParticleAttachment.SparkAttachment:Clone()
			local WaveParticle = script.ParticleAttachment.WaveAttachment:Clone()
			local RockParticle = script.ParticleAttachment.RockAttachment:Clone()

			StarParticle.Star.Lifetime = NumberRange.new(.15)
			StarParticle.Star.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 30), NumberSequenceKeypoint.new(1, 40)}
			StarParticle.Star.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}
			StarParticle.Parent = Block

			RaysParticle.Rays.Lifetime = NumberRange.new(.5)
			RaysParticle.Rays.Color = ColorSequence.new(Color3.fromRGB(255, 255, 127))
			RaysParticle.Rays.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 40), NumberSequenceKeypoint.new(1, 0)}
			RaysParticle.Parent = Block

			SparkParticle.Spark.Lifetime = NumberRange.new(0.5, 0.75)
			SparkParticle.Spark.Speed = NumberRange.new(100)
			SparkParticle.Spark.Drag = -2
			SparkParticle.Spark.Color = ColorSequence.new(Color3.fromRGB(255, 255, 127))
			SparkParticle.Spark.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 2), NumberSequenceKeypoint.new(1, 0)}
			SparkParticle.Parent = Block

			WaveParticle.Wave.Lifetime = NumberRange.new(.5)
			WaveParticle.Wave.Color = ColorSequence.new(Color3.fromRGB(255, 255, 127))
			WaveParticle.Wave.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 40)}
			WaveParticle.Parent = Block

			RockParticle.Rock.Lifetime = NumberRange.new(1)
			RockParticle.Rock.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}
			RockParticle.Rock.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0)}
			RockParticle.Rock.Acceleration = Vector3.new(0,0,0)
			RockParticle.Rock.SpreadAngle = Vector2.new(-90,90)
			RockParticle.Rock.Drag = 5
			RockParticle.Rock.ZOffset = -1
			RockParticle.Rock.Speed = NumberRange.new(100)	
			RockParticle.Parent = Block		

			StarParticle.Star:Emit(5)
			RaysParticle.Rays:Emit(25)
			SparkParticle.Spark:Emit(50)
			RockParticle.Rock:Emit(15)
			WaveParticle.Wave:Emit(1)	

			--[[ Wunbo Orbies ]]--
			VFXHandler.WunboOrbies({
				j = 2; -- j (first loop)
				i = 4; -- i (second loop)
				StartPos = Projectile.Position; -- where the orbies originate
				Duration = 0.15; -- how long orbies last
				Width = 2; -- width (x,y) sizes
				Length = 10; -- length (z) size
				Color1 = Color3.fromRGB(255, 255, 255); -- color of half of the orbies, color2 is the other half
				Color2 = Color3.fromRGB(255, 255, 127); -- color of half of the orbies, color2 is the other half
				Distance = CFrame.new(0,0,50); -- how far the orbies travel
			})

			local CrashSmoke = VFXEffects.Particle.Smoke:Clone()
			CrashSmoke.Parent = Visual
			CrashSmoke.CanCollide = false
			CrashSmoke.Position = Projectile.Position
			CrashSmoke.Smoke.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 5), NumberSequenceKeypoint.new(1, 10)}
			CrashSmoke.Size = Vector3.new(20,0,20)
			CrashSmoke.Smoke:Emit(50)
			CrashSmoke.Anchored = true

			delay(1,function()
				CrashSmoke.Smoke.Enabled = false 
			end)
			Debris:AddItem(CrashSmoke,3)				
		end
	end)()

	wait(projectileData.Lifetime)

	if Projectile and not hitSomething then

		tween:Pause()
		Projectile.Anchored = true
		Debris:AddItem(Projectile, 0.5)
	end
end


if game:GetService("RunService"):IsClient() then 
	attackRemote.OnClientEvent:Connect(function(info)
		local action = info.Function
		if module[action] then
			module[action](info)
		end
	end)
end

return module