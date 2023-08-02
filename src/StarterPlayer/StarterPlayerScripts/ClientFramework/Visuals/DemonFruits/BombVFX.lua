--/Services

--/Modules
local hitDetection = require(game.ReplicatedStorage.Modules.Misc.HitDetection)
local module = {}

--/Variables
local attackRemote = game.ReplicatedStorage.Remotes.DemonFruits[string.split(script.Name, "VFX")[1]]

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

--// hold all planted bombs
local PlantedBomb = {}
local LEAP_HEIGHT = 50

function module.ChargeUp(Data)
	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")

	SoundManager:Play(Root, "ChargeUp", { Volume = 1 })

	--// absorb parts
	--[[ Orbies come IN ]]
	--
	while Root:FindFirstChild("ExplosionCharge") do
		for i = 1, 5 do
			local RootPosition = Root.CFrame

			local originalPos = CFrame.new(
				RootPosition.Position
					+ Vector3.new(math.random(-3, 3) * 5, math.random(-3, 3) * 5, math.random(-3, 3) * 5),
				RootPosition.Position
			)
			local beam = VFXEffects.Part.Block:Clone()
			beam.Shape = "Block"
			local mesh = Instance.new("SpecialMesh")
			mesh.MeshType = "Sphere"
			mesh.Parent = beam
			local WIDTH, LENGTH = 0.5, math.random(5, 10)
			beam.Size = Vector3.new(WIDTH, WIDTH, LENGTH)
			beam.Material = Enum.Material.Neon
			if i % 2 == 0 then
				beam.Color = Color3.fromRGB(255, 85, 0)
			else
				beam.Color = Color3.fromRGB(255, 255, 255)
			end
			beam.Transparency = 0
			beam.Parent = Visual
			beam.CFrame = CFrame.new(
				originalPos.Position + Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)),
				RootPosition.Position
			)
			local tween = TweenService:Create(
				beam,
				TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ ["Size"] = beam.Size + Vector3.new(0, 0, math.random(1, 2)), ["Position"] = RootPosition.Position }
			)
			local tween2 = TweenService:Create(
				beam,
				TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{ ["Size"] = Vector3.new(0, 0, LENGTH) }
			)
			tween:Play()
			tween:Destroy()
			tween2:Play()
			tween2:Destroy()
			Debris:AddItem(beam, 0.15)
		end
		task.wait(0.1)
	end
end

function module.Plant(Data)
	local Character = Data.Character
	local PlantCFrame = Data.PlantCFrame

	local Ball = VFXEffects.Part.Ball:Clone()
	Ball.Material = Enum.Material.Neon
	Ball.Color = Color3.fromRGB(255, 255, 255)
	Ball.Size = Vector3.new(1, 1, 1)
	Ball.CFrame = PlantCFrame
	Ball.Anchored = true
	Ball.Parent = Visual

	local tween = TweenService:Create(
		Ball,
		TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 100, true, 0.25),
		{ ["Size"] = Vector3.new(3, 3, 3), ["Color"] = Color3.fromRGB(255, 85, 0) }
	)
	tween:Play()
	tween:Destroy()

	Ball.Name = Character.Name .. " - BombPlant"
	PlantedBomb[Character.Name .. " - BombPlant"] = Ball
end

function module.Move1(Data)
	local Character = Data.Character
	local projectileCFrame = Data.projectileCFrame
	local projectileData = Data.projectileData
	local hitSomething = false

	local Projectile = VFXEffects.Part.Booger:Clone()
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
			Debris:AddItem(Projectile, 2)

			SoundManager:Play(Projectile, "beamExplosion", { Volume = 1 })

			--// Explosion Effect
			local Explosion = VFXEffects.Model.Explosion:Clone()
			Explosion.Parent = Visual
			Debris:AddItem(Explosion, 3)
			local Increment = 18
			--// increase
			local i = math.random(-50, 50)
			for _, v in ipairs(Explosion:GetChildren()) do
				v.CFrame = Projectile.CFrame
				local tween1 =
					TweenService:Create(v, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						["CFrame"] = v.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(270) * i, 0, 0),
						["Size"] = v.Size + Vector3.new(Increment, Increment, Increment),
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
			coroutine.wrap(function()
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
				end)()
				Debris:AddItem(Attachment, 1)

				--[[ Stars xD ]]
				--
				local Stars = VFXEffects.Particle.ParticleAttatchments.Stars:Clone()
				Stars.Stars.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
				Stars.Stars.Size =
					NumberSequence.new({ NumberSequenceKeypoint.new(0, 2.5), NumberSequenceKeypoint.new(1, 0) })
				Stars.Stars.Drag = 5
				Stars.Stars.Rate = 100
				Stars.Stars.Acceleration = Vector3.new(0, -100, 0)
				Stars.Stars.Lifetime = NumberRange.new(1, 1.5)
				Stars.Stars.Speed = NumberRange.new(75, 100)
				Stars.Parent = Explosion.Main

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
				Rocks.Parent = Explosion.Main
				Rocks.Rocks:Emit(100)
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
			end)()

			task.wait(0.2)
			--// decrase
			for _, v in ipairs(Explosion:GetChildren()) do
				local tween1 =
					TweenService:Create(v, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						["CFrame"] = v.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(270) * i, 0, 0),
						["Size"] = Vector3.new(0, 0, 0),
					})
				tween1:Play()
				tween1:Destroy()
			end
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
	local PlantCFrame = Data.PlantCFrame

	for i, v in pairs(PlantedBomb) do
		if i == Character.Name .. " - BombPlant" then
			i = nil
			v:Destroy()
		end
	end
	--// Explosion Effect
	local Explosion = VFXEffects.Model.Explosion:Clone()
	Explosion.Parent = Visual
	Debris:AddItem(Explosion, 3)

	SoundManager:Play(Explosion.Main, "bangExplosion", { Volume = 1 })
	local Increment = 18
	--// increase
	local i = math.random(-50, 50)
	for _, v in ipairs(Explosion:GetChildren()) do
		v.CFrame = PlantCFrame
		local tween = TweenService:Create(v, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			["CFrame"] = v.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(270) * i, 0, 0),
			["Size"] = v.Size + Vector3.new(Increment, Increment, Increment),
		})
		tween:Play()
		tween:Destroy()
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
		Cframe = PlantCFrame, -- Position
		Amount = 25, -- How manay rocks
		Iteration = 15, -- Expand
		Max = 2, -- Length upwards
		FirstDuration = 0.25, -- Rock tween outward start duration
		RocksLength = 2, -- How long the rocks stay for
	})

	--[[ Fire P00rticle XD ]]
	--
	coroutine.wrap(function()
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
				task.wait(0.1)
			end
			Attachment.Fire.Enabled = false
		end)()
		Debris:AddItem(Attachment, 1)

		--[[ Stars xD ]]
		--
		local Stars = VFXEffects.Particle.ParticleAttatchments.Stars:Clone()
		Stars.Stars.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
		Stars.Stars.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 2.5), NumberSequenceKeypoint.new(1, 0) })
		Stars.Stars.Drag = 5
		Stars.Stars.Rate = 100
		Stars.Stars.Acceleration = Vector3.new(0, -100, 0)
		Stars.Stars.Lifetime = NumberRange.new(1, 1.5)
		Stars.Stars.Speed = NumberRange.new(75, 100)
		Stars.Parent = Explosion.Main

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
		Rocks.Parent = Explosion.Main
		Rocks.Rocks:Emit(100)
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
		Ball.CFrame = PlantCFrame
		Ball.Parent = Visual

		local tween = TweenService:Create(
			Ball,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ ["Transparency"] = 1, ["Size"] = Ball.Size * 7 }
		)
		tween:Play()
		tween:Destroy()
		Debris:AddItem(Ball, 0.2)

		--[[ Flying Debris Rock ]]
		--
		VFXHandler.FlyingRocks({
			i = 2, -- first loop
			j = 5, -- nested loop
			Offset = 10, -- radius from starting pos
			Origin = PlantCFrame.Position, -- where to start
			Filter = { Character, Live, Visual }, -- filter raycast
			Size = Vector2.new(1, 3), -- size range random from 1,3
			AxisRange = 80, -- velocity X and Z ranges from (-AxisRange,AxisRange)
			Height = Vector2.new(50, 60), -- velocity Y ranges from X,Y
			Percent = 0.65, -- velocity * percent of nested loop
			Duration = 2, -- duration of the debris rock
			IterationDelay = 0, -- delay between each i loop
		})
	end)()

	wait(0.2)
	--// decrase
	for _, v in ipairs(Explosion:GetChildren()) do
		local tween = TweenService:Create(v, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			["CFrame"] = v.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(270) * i, 0, 0),
			["Size"] = Vector3.new(0, 0, 0),
		})
		tween:Play()
		tween:Destroy()
	end
end

function module.Move3(Data)
	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")

	SoundManager:Play(Root, "combustionExplosion", { Volume = 1 })

	for i = 1, 2 do
		coroutine.wrap(function()
			local Offset = 3
			local Height = 3
			if i == 2 then
				Offset *= -1
			end
			local RootCFrame = Root.CFrame * CFrame.new(Offset, -Height, 0)

			--// Explosion Effect
			local Explosion = VFXEffects.Model.Explosion:Clone()
			Explosion.Main.Size = Vector3.new(1.78, 1.943, 1.701)
			Explosion.One.Size = Vector3.new(1.794, 2.085, 2.05)
			Explosion.Two.Size = Vector3.new(1.59, 1.706, 1.518)
			Explosion.Three.Size = Vector3.new(1.585, 1.704, 1.514)
			Explosion.Parent = Visual
			Debris:AddItem(Explosion, 3)

			local Increment = 10
			--// increase
			local i1 = math.random(-50, 50)
			for _, v in ipairs(Explosion:GetChildren()) do
				v.CFrame = RootCFrame
				local tween =
					TweenService:Create(v, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						["CFrame"] = v.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(270) * i1, 0, 0),
						["Size"] = v.Size + Vector3.new(Increment, Increment, Increment),
					})
				tween:Play()
				tween:Destroy()
			end

			--// PointLight
			local PointLight = Instance.new("PointLight")
			PointLight.Color = Color3.fromRGB(255, 85, 0)
			PointLight.Range = 8
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
				Cframe = RootCFrame, -- Position
				Amount = 10, -- How manay rocks
				Iteration = 4, -- Expand
				Max = 1, -- Length upwards
				FirstDuration = 0.25, -- Rock tween outward start duration
				RocksLength = 2, -- How long the rocks stay for
			})
			--[[ Stars xD ]]
			--
			local Stars = VFXEffects.Particle.ParticleAttatchments.Stars:Clone()
			Stars.Stars.Color = ColorSequence.new(Color3.fromRGB(255, 85, 0))
			Stars.Stars.Size =
				NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0) })
			Stars.Stars.Drag = 5
			Stars.Stars.Rate = 100
			Stars.Stars.Acceleration = Vector3.new(0, -5, 0)
			Stars.Stars.Lifetime = NumberRange.new(0.5, 0.75)
			Stars.Stars.Speed = NumberRange.new(20, 35)
			Stars.Parent = Explosion.Main

			Stars.Stars:Emit(25)
			Debris:AddItem(Stars, 1)

			--// Ball Effect
			local Ball = VFXEffects.Part.Ball:Clone()
			Ball.Color = Color3.fromRGB(255, 85, 127)
			Ball.Material = Enum.Material.ForceField
			Ball.Transparency = 0
			Ball.Size = Vector3.new(5, 5, 5)
			Ball.CFrame = RootCFrame
			Ball.Parent = Visual

			local tween = TweenService:Create(
				Ball,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ ["Transparency"] = 1, ["Size"] = Ball.Size * 3 }
			)
			tween:Play()
			tween:Destroy()
			Debris:AddItem(Ball, 0.2)

			wait(0.2)
			--// decrase
			for _, v in ipairs(Explosion:GetChildren()) do
				local tween1 =
					TweenService:Create(v, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						["CFrame"] = v.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(270) * i, 0, 0),
						["Size"] = Vector3.new(0, 0, 0),
					})
				tween1:Play()
				tween1:Destroy()
			end
		end)()
	end

	--// Move Body Upwards
	SharedFunctions:DestroyForce(Root, "BodyGyro")
	SharedFunctions:DestroyForce(Root, "BodyPosition")
	SharedFunctions:BodyPosition(
		Root,
		200,
		50,
		Vector3.new(1e5, 1e5, 1e5),
		(Root.CFrame * CFrame.new(0, LEAP_HEIGHT, 0)).Position,
		0.35
	)
end

function module.Move4(Data)
	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")

	SoundManager:Play(Root, "pewExplosion", { Volume = 2 })

	local Explosion = VFXEffects.Model.Explosion:Clone()
	Explosion.Parent = Visual
	Debris:AddItem(Explosion, 3)
	local Increment = 35
	--// increase
	local i = math.random(-50, 50)
	for _, v in ipairs(Explosion:GetChildren()) do
		v.CFrame = Root.CFrame
		local tween = TweenService:Create(v, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			["CFrame"] = v.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(270) * i, 0, 0),
			["Size"] = v.Size + Vector3.new(Increment, Increment, Increment),
		})
		tween:Play()
		tween:Destroy()
	end

	--// PointLight
	local PointLight = Instance.new("PointLight")
	PointLight.Color = Color3.fromRGB(255, 85, 0)
	PointLight.Range = 200
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
		Cframe = Root.CFrame, -- Position
		Amount = 25, -- How manay rocks
		Iteration = 25, -- Expand
		Max = 2, -- Length upwards
		FirstDuration = 0.25, -- Rock tween outward start duration
		RocksLength = 2, -- How long the rocks stay for
	})

	--[[ Fire P00rticle XD ]]
	--
	local Fire = VFXEffects.Particle.ParticleAttatchments.Fire:Clone()
	local Attachment = Instance.new("Attachment")
	Fire.Fire.Parent = Attachment
	Attachment.Parent = Root
	Fire:Destroy()

	Attachment.Fire.Speed = NumberRange.new(125, 150)
	Attachment.Fire.Drag = 5

	Attachment.Fire.Lifetime = NumberRange.new(0.75, 1)
	Attachment.Fire.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 15), NumberSequenceKeypoint.new(1, 0) })
	Attachment.Fire.Acceleration = Vector3.new(0, 0, 0)
	Attachment.Fire.Rate = 200

	coroutine.wrap(function()
		Attachment.Fire.Enabled = true
		for _ = 1, 2 do
			Attachment.Fire:Emit(50)
			wait(0.1)
		end
		Attachment.Fire.Enabled = false
	end)()
	Debris:AddItem(Attachment, 1)

	--[[ Stars xD ]]
	--
	local Stars = VFXEffects.Particle.ParticleAttatchments.Stars:Clone()
	Stars.Stars.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	Stars.Stars.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 2.5), NumberSequenceKeypoint.new(1, 0) })
	Stars.Stars.Drag = 5
	Stars.Stars.Rate = 100
	Stars.Stars.Acceleration = Vector3.new(0, -100, 0)
	Stars.Stars.Lifetime = NumberRange.new(1, 1.5)
	Stars.Stars.Speed = NumberRange.new(120, 200)
	Stars.Parent = Character.HumanoidRootPart

	Stars.Stars:Emit(50)
	Debris:AddItem(Stars, 1.5)

	--[[ Rocks xD ]]
	--
	local Rocks = VFXEffects.Particle.ParticleAttatchments.Rocks:Clone()
	Rocks.Rocks.Size =
		NumberSequence.new({ NumberSequenceKeypoint.new(0, math.random(5, 10) / 10), NumberSequenceKeypoint.new(1, 0) })
	Rocks.Rocks.Drag = 5
	Rocks.Rocks.Rate = 100
	Rocks.Rocks.Acceleration = Vector3.new(0, -100, 0)
	Rocks.Rocks.Lifetime = NumberRange.new(1, 1.5)
	Rocks.Rocks.Speed = NumberRange.new(100, 150)
	Rocks.Parent = Character.HumanoidRootPart
	Rocks.Rocks:Emit(100)
	Debris:AddItem(Rocks, 2)

	--// shockwave particle
	local Shockwave = VFXEffects.Particle.ParticleAttatchments.Shockwave:Clone()
	Shockwave.Shockwave.Size =
		NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 100) })
	Shockwave.Shockwave.Parent = Attachment
	Attachment.Shockwave:Emit(2)

	--// Ball Effect
	local Ball = VFXEffects.Part.Ball:Clone()
	Ball.Color = Color3.fromRGB(255, 85, 127)
	Ball.Material = Enum.Material.ForceField
	Ball.Transparency = 0
	Ball.Size = Vector3.new(5, 5, 5)
	Ball.CFrame = Root.CFrame
	Ball.Parent = Visual

	local tween = TweenService:Create(
		Ball,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ ["Transparency"] = 1, ["Size"] = Ball.Size * 15 }
	)
	tween:Play()
	tween:Destroy()
	Debris:AddItem(Ball, 0.2)

	--[[ Flying Debris Rock ]]
	--
	VFXHandler.FlyingRocks({
		i = 2, -- first loop
		j = 5, -- nested loop
		Offset = 10, -- radius from starting pos
		Origin = Root.Position, -- where to start
		Filter = { Character, Live, Visual }, -- filter raycast
		Size = Vector2.new(1, 3), -- size range random from 1,3
		AxisRange = 80, -- velocity X and Z ranges from (-AxisRange,AxisRange)
		Height = Vector2.new(50, 60), -- velocity Y ranges from X,Y
		Percent = 0.65, -- velocity * percent of nested loop
		Duration = 2, -- duration of the debris rock
		IterationDelay = 0, -- delay between each i loop
	})

	task.wait(0.2)
	--// decrase
	for _, v in ipairs(Explosion:GetChildren()) do
		local tween1 = TweenService:Create(v, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			["CFrame"] = v.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(270) * i, 0, 0),
			["Size"] = Vector3.new(0, 0, 0),
		})
		tween1:Play()
		tween1:Destroy()
	end
end
attackRemote.OnClientEvent:connect(function(info)
	local action = info.Function
	if module[action] then
		module[action](info)
	end
end)

return module
