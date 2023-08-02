--/Services
local collectionService = game:GetService("CollectionService")
local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")

--/Modules
local hitDetection = require(game.ReplicatedStorage.Modules.Misc.HitDetection)
local module = {}

--/Variables
local attackRemote = game.ReplicatedStorage.Remotes.DemonFruits[string.split(script.Name, "VFX")[1]]
local effectFolder = game.ReplicatedStorage.Assets.VFX.DemonFruits[string.split(script.Name, "VFX")[1]]

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
local SoundManager = require(Modules.Manager.SoundManager)

local FireAttachment = script.ParticleAttatchments["FireAttachment"]
local SparkAttachment = script.ParticleAttatchments["SparkAttachment"]

function module.Logia(Info)
	local storage = effectFolder
	local speed = 0.2

	local c = Info.Target

	for _, v in pairs(c:GetChildren()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			tweenService:Create(v, TweenInfo.new(speed), { Transparency = 1 }):Play()
			local particle = storage.logiaEffect:Clone()
			particle.Parent = v
			particle:Emit(25)
			game.Debris:AddItem(particle, 1)
			coroutine.wrap(function()
				wait(speed)
				tweenService:Create(v, TweenInfo.new(speed), { Transparency = 0 }):Play()
			end)()
		elseif v:IsA("Accessory") then
			tweenService:Create(v.Handle, TweenInfo.new(speed), { Transparency = 1 }):Play()
			coroutine.wrap(function()
				wait(speed)
				tweenService:Create(v.Handle, TweenInfo.new(speed), { Transparency = 0 }):Play()
			end)()
		end
	end
end

function module.Move1(Data)
	local Character = Data.Character
	local projectileCFrame = Data.projectileCFrame
	local projectileData = Data.projectileData
	local hitSomething = false

	--// throw projectile
	local Projectile = VFXEffects.Part.Block:Clone()
	Projectile.Size = Vector3.new(0, 0, 0)
	Projectile.CanCollide = true
	Projectile.Anchored = false
	Projectile.CFrame = projectileCFrame
	Projectile.Parent = Visual

	for _ = 1, 2 do
		local FireAtt = FireAttachment:Clone()
		local Fire = FireAtt.Fire
		Fire.Drag = -5
		Fire.Lifetime = NumberRange.new(0.25, 0.35)
		Fire.Speed = NumberRange.new(100)
		Fire.LockedToPart = false
		Fire.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 12), NumberSequenceKeypoint.new(1, 0) })
		Fire.Enabled = true
		FireAtt.Parent = Projectile
	end
	-- sparkz
	local SparkAtt = SparkAttachment:Clone()
	local Spark = SparkAtt.Spark
	Spark.Color = ColorSequence.new(Color3.fromRGB(255, 85, 0))
	Spark.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 3), NumberSequenceKeypoint.new(1, 0) })
	Spark.Drag = -5
	Spark.Lifetime = NumberRange.new(0.35, 0.5)
	Spark.Speed = NumberRange.new(75)
	Spark.Enabled = true
	SparkAtt.Parent = Projectile

	local tween = TweenService:Create(
		Projectile,
		TweenInfo.new(projectileData.Lifetime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{ ["CFrame"] = Projectile.CFrame * CFrame.new(0, 0, -projectileData.Velocity * projectileData.Lifetime) }
	)
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
			Debris:AddItem(Projectile, 0.5)

			--// Explosion Effect
			local Explosion = VFXEffects.Model.Explosion:Clone()
			Explosion.Parent = Visual
			Debris:AddItem(Explosion, 3)

			SoundManager:Play(Explosion.Main, "FlameExplosion", { Volume = 2 })

			--// increase
			local i = math.random(-50, 50)
			for _, v in ipairs(Explosion:GetChildren()) do
				v.CFrame = Projectile.CFrame
				local tween1 =
					TweenService:Create(v, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						["CFrame"] = v.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(270) * i, 0, 0),
						["Size"] = Vector3.new(0, 0, 0),
					})
				tween1:Play()
				tween1:Destroy()
			end

			--// PointLight
			local PointLight = Instance.new("PointLight")
			PointLight.Color = Color3.fromRGB(255, 85, 0)
			PointLight.Range = 100
			PointLight.Brightness = 2
			PointLight.Parent = Explosion.Main

			local LightTween = TweenService:Create(
				PointLight,
				TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ ["Range"] = 0, ["Brightness"] = 0 }
			)
			LightTween:Play()
			LightTween:Destroy()

			--[[ Crater on Ground ]]
			--
			VFXHandler.Crater({
				Cframe = Projectile.CFrame, -- Position
				Amount = 25, -- How manay rocks
				Iteration = 15, -- Expand
				Max = 2, -- Length upwards
				FirstDuration = 0.25, -- Rock tween outward start duration
				RocksLength = 2, -- How long the rocks stay for
			})
			--[[ Fire P00rticle XD ]]
			--
			local Fire = VFXEffects.Particle.ParticleAttatchments.Fire:Clone()
			local Attachment = Instance.new("Attachment")
			Fire.Fire.Parent = Attachment
			Attachment.Parent = Explosion.Main
			Fire:Destroy()

			Attachment.Fire.Speed = NumberRange.new(60, 90)
			Attachment.Fire.Drag = 5

			Attachment.Fire.Lifetime = NumberRange.new(0.75, 1)
			Attachment.Fire.Size =
				NumberSequence.new({ NumberSequenceKeypoint.new(0, 15), NumberSequenceKeypoint.new(1, 0) })
			Attachment.Fire.Acceleration = Vector3.new(0, 0, 0)
			Attachment.Fire.Rate = 200

			coroutine.wrap(function()
				Attachment.Fire.Enabled = true
				for _ = 1, 2 do
					Attachment.Fire:Emit(50)
					wait(0.1)
				end
				Attachment.Fire.Enabled = false
				Debris:AddItem(Attachment, 1)

				--[[ Stars xD ]]
				--
				local Stars = VFXEffects.Particle.ParticleAttatchments.Stars:Clone()
				Stars.Stars.Color = ColorSequence.new(Color3.fromRGB(255, 85, 0))
				Stars.Stars.Size =
					NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.5), NumberSequenceKeypoint.new(1, 0) })
				Stars.Stars.Drag = 5
				Stars.Stars.Rate = 100
				Stars.Stars.Acceleration = Vector3.new(0, -50, 0)
				Stars.Stars.Lifetime = NumberRange.new(1, 1.5)
				Stars.Stars.Speed = NumberRange.new(75, 100)
				Stars.Parent = Explosion.Main

				Stars.Stars:Emit(50)
				Debris:AddItem(Stars, 1.5)

				--[[ Rocks xD ]]
				--
				local Rocks = VFXEffects.Particle.ParticleAttatchments.Rocks:Clone()
				Rocks.Rocks.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, math.random(5, 10) / 15),
					NumberSequenceKeypoint.new(1, 0),
				})
				Rocks.Rocks.Drag = 5
				Rocks.Rocks.Rate = 100
				Rocks.Rocks.Acceleration = Vector3.new(0, -100, 0)
				Rocks.Rocks.Lifetime = NumberRange.new(1, 1.5)
				Rocks.Rocks.Speed = NumberRange.new(75, 100)
				Rocks.Parent = Explosion.Main
				Rocks.Rocks:Emit(50)
				Debris:AddItem(Rocks, 2)

				--// shockwave particle
				local Shockwave = VFXEffects.Particle.ParticleAttatchments.Shockwave:Clone()
				Shockwave.Shockwave.Size =
					NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 50) })
				Shockwave.Shockwave.Parent = Attachment
				Attachment.Shockwave:Emit(2)

				--// Ball Effect
				local Ball = VFXEffects.Part.Ball:Clone()
				Ball.Color = Color3.fromRGB(255, 85, 127)
				Ball.Material = Enum.Material.ForceField
				Ball.Transparency = 0
				Ball.Size = Vector3.new(5, 5, 5)
				Ball.CFrame = Projectile.CFrame
				Ball.Parent = Visual

				local tween1 = TweenService:Create(
					Ball,
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ ["Transparency"] = 1, ["Size"] = Ball.Size * 7 }
				)
				tween1:Play()
				tween1:Destroy()
				Debris:AddItem(Ball, 0.2)

				--[[ Flying Debris Rock ]]
				--
				VFXHandler.FlyingRocks({
					i = 2, -- first loop
					j = 5, -- nested loop
					Offset = 10, -- radius from starting pos
					Origin = Projectile.Position, -- where to start
					Filter = { Character, Live, Visual }, -- filter raycast
					Size = Vector2.new(1, 3), -- size range random from 1,3
					AxisRange = 80, -- velocity X and Z ranges from (-AxisRange,AxisRange)
					Height = Vector2.new(50, 60), -- velocity Y ranges from X,Y
					Percent = 0.65, -- velocity * percent of nested loop
					Duration = 2, -- duration of the debris rock
					IterationDelay = 0, -- delay between each i loop
				})

				for _ = 1, 5 do
					--[[ Wunbo Orbies ]]
					--
					VFXHandler.WunboOrbies({
						j = 2, -- j (first loop)
						i = 2, -- i (second loop)
						StartPos = Projectile.Position, -- where the orbies originate
						Duration = 0.15, -- how long orbies last
						Width = 5, -- width (x,y) sizes
						Length = 20, -- length (z) size
						Color1 = Color3.fromRGB(255, 255, 255), -- color of half of the orbies, color2 is the other half
						Color2 = Color3.fromRGB(255, 85, 0), -- color of half of the orbies, color2 is the other half
						Distance = CFrame.new(0, 0, math.random(40, 70)), -- how far the orbies travel
					})
					wait()
				end
			end)()
			--//
		end
	end)()

	wait(projectileData.Lifetime)

	if Projectile and not hitSomething then
		tween:Pause()
		Projectile.Anchored = true
		Debris:AddItem(Projectile, 0.5)
	end
end

function module.Move2(Data)
	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")

	SoundManager:Play(Root, "FlameCharge", { Volume = 2 })

	local Projectile = VFXEffects.Part.Block:Clone()
	Projectile.Size = Vector3.new(0, 0, 0)
	Projectile.Shape = "Ball"
	Projectile.CanCollide = false
	Projectile.Anchored = true
	Projectile.BrickColor = BrickColor.new("Cork")
	Projectile.Material = Enum.Material.Neon
	Projectile.Transparency = 1
	Projectile.Position = Root.Position
	Projectile.Parent = Visual
	Debris:AddItem(Projectile, 4)

	local FireAtt = FireAttachment:Clone()
	local Fire = FireAtt.Fire
	Fire.Drag = 5
	Fire.Lifetime = NumberRange.new(0.75)
	Fire.Speed = NumberRange.new(200)
	Fire.Rate = 500
	Fire.SpreadAngle = Vector2.new(0, 180)
	Fire.LockedToPart = false
	Fire.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 8), NumberSequenceKeypoint.new(1, 0) })
	Fire.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
	Fire.Enabled = true
	Fire.EmissionDirection = "Back"
	local Fire2 = Fire:Clone()
	Fire2.Parent = FireAtt
	FireAtt.Parent = Projectile

	-- spinners and above fire
	local FirePillarAtt = FireAttachment:Clone()
	local FirePillar = FirePillarAtt.Fire
	FirePillar.Drag = -2
	FirePillar.Lifetime = NumberRange.new(0.35, 0.5)
	FirePillar.Acceleration = Vector3.new(0, 1000, 0)
	FirePillar.Speed = NumberRange.new(100)
	FirePillar.Rate = 1000
	FirePillar.LockedToPart = false
	FirePillar.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 15), NumberSequenceKeypoint.new(1, 0) })
	FirePillar.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
	FirePillar.Enabled = true
	FirePillar.Parent = FirePillarAtt
	FirePillarAtt.Parent = Projectile

	-- sparkz
	local SparkAtt = SparkAttachment:Clone()
	local Spark = SparkAtt.Spark
	Spark.Color = ColorSequence.new(Color3.fromRGB(255, 85, 0))
	Spark.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 15), NumberSequenceKeypoint.new(1, 0) })
	Spark.Drag = -1
	Spark.Lifetime = NumberRange.new(0.35, 0.5)
	Spark.Speed = NumberRange.new(180)
	Spark.Enabled = false
	SparkAtt.Parent = Projectile

	-- end
	for _ = 1, 5 do
		Fire:Emit(250)
		Spark:Emit(75)

		for j = 1, 5 do
			--
			local CenterAtt = Instance.new("Attachment")
			CenterAtt.Parent = Projectile

			local StartPos = Root.Position
			local EndPos = (
				Vector3.new(
					math.sin(360 * j) * math.random(-80, 80),
					math.tan(90 * j) * math.random(10, 100),
					math.cos(360 * j) * math.random(-80, 80)
				) + StartPos
			)

			local SegmentAtt = Instance.new("Attachment")
			SegmentAtt.WorldPosition = EndPos
			SegmentAtt.Parent = Projectile

			local Beam = VFXEffects.Beam.AirBeam:Clone()
			Beam.Color = ColorSequence.new(Color3.fromRGB(255, 85, 0))
			Beam.Attachment0 = CenterAtt
			Beam.Attachment1 = SegmentAtt
			--Beam.Enabled = true
			Beam.Parent = CenterAtt
			coroutine.wrap(function()
				for i, v in pairs(CenterAtt:GetChildren()) do
					if v:IsA("Beam") then
						v.Width0 = 75
						v.Width1 = 100
						v.Enabled = true
						local Tween = TweenService:Create(
							v,
							TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false),
							{
								["CurveSize0"] = math.random(-25, 25) * i,
								["CurveSize1"] = math.random(-100, 100) * i,
								["Width0"] = 0,
							}
						)
						Tween:Play()
						Tween:Destroy()

						local Tween2 = TweenService:Create(
							v,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false),
							{ ["Width1"] = 0 }
						)
						Tween2:Play()
						Tween2:Destroy()
					end
				end
			end)()
			--

			--[[ Flying Debris Rock ]]
			--
			VFXHandler.FlyingRocks({
				i = 1, -- first loop
				j = 1, -- nested loop
				Offset = 10, -- radius from starting pos
				Origin = Projectile.Position, -- where to start
				Filter = { Character, Live, Visual }, -- filter raycast
				Size = Vector2.new(1, 3), -- size range random from 1,3
				AxisRange = 90, -- velocity X and Z ranges from (-AxisRange,AxisRange)
				Height = Vector2.new(80, 100), -- velocity Y ranges from X,Y
				Percent = 2, -- velocity * percent of nested loop
				Duration = 2, -- duration of the debris rock
				IterationDelay = 0, -- delay between each i loop
			})
		end
		task.wait(0.35)
	end
	Fire.Enabled = false
	Fire2.Enabled = false
	FirePillar.Enabled = false
	Fire:Emit(100)
end

function module.Move3(Data)
	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")

	local mouse = players:GetPlayerFromCharacter(Character):GetMouse()

	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1, 1, 1) * 1e12
	bv.Velocity = Root.CFrame.lookVector * 125
	bv.Parent = Root

	local bg = Instance.new("BodyGyro")
	bg.MaxTorque = Vector3.new(1, 1, 1) * 1e12
	bg.P = 5000000
	bg.Parent = Root

	--/Sound
	--local sound = G.getSound("fireFlight",1):Clone()
	--sound.Parent = Root
	--sound:Play()

	while collectionService:HasTag(Character, "FireFlight") do
		bv.Velocity = Root.CFrame.lookVector * 50
		bg.CFrame = CFrame.new(Root.Position, mouse.Hit.Position)
		task.wait()
	end
	--sound:Destroy()

	bg:Destroy()
	bv:Destroy()
	print("destroyed")
end

function module.Move4(Data)
	local Character = Data.Character
	local projectileCFrame = Data.projectileCFrame
	local projectileData = Data.projectileData
	local hitSomething = false

	local Projectile = script.MeraBall:Clone()
	Projectile.CFrame = projectileCFrame
	Projectile.Parent = Visual

	local tween = TweenService:Create(
		Projectile,
		TweenInfo.new(projectileData.Lifetime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{ ["CFrame"] = Projectile.CFrame * CFrame.new(0, 0, -projectileData.Velocity * projectileData.Lifetime) }
	)
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
			Projectile.Fire.Enabled = false
			Projectile.Transparency = 1
			Debris:AddItem(Projectile, 2)

			SoundManager:Play(Projectile, "FlameExplosion", { Volume = 0.5 })

			--[[ Flying Debris Rock ]]
			--
			VFXHandler.FlyingRocks({
				i = 1, -- first loop
				j = 3, -- nested loop
				Offset = 10, -- radius from starting pos
				Origin = Projectile.Position, -- where to start
				Filter = { Character, Live, Visual }, -- filter raycast
				Size = Vector2.new(1, 3), -- size range random from 1,3
				AxisRange = 50, -- velocity X and Z ranges from (-AxisRange,AxisRange)
				Height = Vector2.new(50, 60), -- velocity Y ranges from X,Y
				Percent = 0.35, -- velocity * percent of nested loop
				Duration = 2, -- duration of the debris rock
				IterationDelay = 0, -- delay between each i loop
			})

			--[[ Crater on Ground ]]
			--
			VFXHandler.Crater({
				Cframe = CFrame.new(Projectile.Position), -- Position
				Amount = 10, -- How manay rocks
				Iteration = 10, -- Expand
				Max = 2, -- Length upwards
				FirstDuration = 0.25, -- Rock tween outward start duration
				RocksLength = 1, -- How long the rocks stay for
			})

			--[[ Wunbo Orbies ]]
			--
			VFXHandler.WunboOrbies({
				j = 2, -- j (first loop)
				i = 4, -- i (second loop)
				StartPos = Projectile.Position, -- where the orbies originate
				Duration = 0.15, -- how long orbies last
				Width = 2, -- width (x,y) sizes
				Length = 10, -- length (z) size
				Color1 = Color3.fromRGB(255, 255, 255), -- color of half of the orbies, color2 is the other half
				Color2 = Color3.fromRGB(255, 85, 0), -- color of half of the orbies, color2 is the other half
				Distance = CFrame.new(0, 0, 50), -- how far the orbies travel
			})

			--[[ Fire P00rticle XD ]]
			--
			local Fire = VFXEffects.Particle.ParticleAttatchments.Fire:Clone()
			local Attachment = Instance.new("Attachment")
			Fire.Fire.Parent = Attachment
			Attachment.Parent = Projectile
			Fire:Destroy()

			Attachment.Fire.Speed = NumberRange.new(60, 90)
			Attachment.Fire.Drag = 5

			Attachment.Fire.Lifetime = NumberRange.new(0.75, 1)
			Attachment.Fire.Size =
				NumberSequence.new({ NumberSequenceKeypoint.new(0, 7), NumberSequenceKeypoint.new(1, 0) })
			Attachment.Fire.Acceleration = Vector3.new(0, 0, 0)
			Attachment.Fire.Rate = 200

			Attachment.Fire.Enabled = true
			for _ = 1, 2 do
				Attachment.Fire:Emit(50)
				wait(0.1)
			end
			Attachment.Fire.Enabled = false
			Debris:AddItem(Attachment, 1)

			--[[ Stars xD ]]
			--
			local Stars = VFXEffects.Particle.ParticleAttatchments.Stars:Clone()
			Stars.Stars.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
			Stars.Stars.Size =
				NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.5), NumberSequenceKeypoint.new(1, 0) })
			Stars.Stars.Drag = 5
			Stars.Stars.Rate = 100
			Stars.Stars.Acceleration = Vector3.new(0, -100, 0)
			Stars.Stars.Lifetime = NumberRange.new(1, 1.5)
			Stars.Stars.Speed = NumberRange.new(75, 100)
			Stars.Parent = Projectile

			Stars.Stars:Emit(50)
			Debris:AddItem(Stars, 1.5)

			--[[ Rocks xD ]]
			--
			local Rocks = VFXEffects.Particle.ParticleAttatchments.Rocks:Clone()
			Rocks.Rocks.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, math.random(5, 10) / 10),
				NumberSequenceKeypoint.new(1, 0),
			})
			Rocks.Rocks.Drag = 5
			Rocks.Rocks.Rate = 100
			Rocks.Rocks.Acceleration = Vector3.new(0, -100, 0)
			Rocks.Rocks.Lifetime = NumberRange.new(1, 1.5)
			Rocks.Rocks.Speed = NumberRange.new(75, 100)
			Rocks.Parent = Projectile
			Rocks.Rocks:Emit(100)
			Debris:AddItem(Rocks, 2)

			--// shockwave particle
			local Shockwave = VFXEffects.Particle.ParticleAttatchments.Shockwave:Clone()
			Shockwave.Shockwave.Size =
				NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 50) })
			Shockwave.Shockwave.Parent = Attachment
			Attachment.Shockwave:Emit(1)

			local CrashSmoke = VFXEffects.Particle.Smoke:Clone()
			CrashSmoke.Parent = Visual
			CrashSmoke.CanCollide = false
			CrashSmoke.Position = Projectile.Position
			CrashSmoke.Smoke.Size =
				NumberSequence.new({ NumberSequenceKeypoint.new(0, 5), NumberSequenceKeypoint.new(1, 10) })
			CrashSmoke.Size = Vector3.new(20, 0, 20)
			CrashSmoke.Smoke:Emit(50)
			CrashSmoke.Anchored = true

			task.delay(1, function()
				CrashSmoke.Smoke.Enabled = false
			end)
			Debris:AddItem(CrashSmoke, 3)
		end
	end)()

	wait(projectileData.Lifetime)

	if Projectile and not hitSomething then
		tween:Pause()
		Projectile.Anchored = true
		Debris:AddItem(Projectile, 0.5)
	end
end

attackRemote.OnClientEvent:Connect(function(info)
	local action = info.Function
	if module[action] then
		module[action](info)
	end
end)

return module
