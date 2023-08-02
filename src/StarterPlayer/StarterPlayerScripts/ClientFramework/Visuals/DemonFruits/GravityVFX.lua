--/Services
local collectionService = game:GetService("CollectionService")
local players = game:GetService("Players")

--/Modules
local hitDetection = require(game.ReplicatedStorage.Modules.Misc.HitDetection)
local module = {}

--/Variables
local attackRemote = game.ReplicatedStorage.Remotes.DemonFruits[string.split(script.Name, "VFX")[1]]
--local effectFolder = game.ReplicatedStorage.Assets.VFX.DemonFruits[string.split(script.Name,"VFX")[1]]

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

local GravityColor = Color3.fromRGB(180, 128, 255)

function module.Move1(Data)
	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")

	local Distance = 75

	SoundManager:Play(Root, "Woosh", { Volume = 2 })
	--[[ KnockbackLines ]]
	--
	VFXHandler.KnockbackLines({
		MAX = 1,
		ITERATION = 5,
		WIDTH = 0.35,
		DURATION = 0.15,
		LENGTH = 10,
		COLOR1 = GravityColor,
		COLOR2 = Color3.fromRGB(0, 0, 0),
		STARTPOS = Root.CFrame * CFrame.new(0, 0, 10),
		ENDGOAL = CFrame.new(0, 0, -Distance),
	})

	--[[ Wunbo Orbies ]]
	--
	VFXHandler.WunboOrbies({
		j = 2, -- j (first loop)
		i = 2, -- i (second loop)
		StartPos = Character["Right Arm"].Position, -- where the orbies originate
		Duration = 0.15, -- how long orbies last
		Width = 0.35, -- width (x,y) sizes
		Length = 3, -- length (z) size
		Color1 = Color3.fromRGB(0, 0, 0), -- color of half of the orbies, color2 is the other half
		Color2 = GravityColor, -- color of half of the orbies, color2 is the other half
		Distance = CFrame.new(0, 0, 10), -- how far the orbies travel
	})

	--[[ Side Rocks ]]
	--
	VFXHandler.SideRocks({
		StartPos = Root.CFrame, -- origin position
		Offset = 10, -- how far apart the two rock piles are in the X-axis
		Amount = 10, -- amount of rocks on each pile (determines the length of pile)
		Size = Vector3.new(5, 5, 5), -- size of each rock (vector3)
		Filter = { Character, Live, Visual }, -- filter raycast
		IterationDelay = 0, -- iteration between each rock placed
		Duration = 2, -- how long the rocks last
	})

	--//
	local RootCFrame = Root.CFrame
	for Index = 1, 2 do
		--
		local cs = VFXEffects.Mesh.Ring2:Clone()
		cs.Size = Vector3.new(15, 2, 15)
		local c1, c2 =
			RootCFrame * CFrame.Angles(math.pi / 2, 0, 0),
			RootCFrame * CFrame.new(0, 0, -Distance) * CFrame.Angles(math.pi / 2, 0, 0)
		cs.CFrame = c1
		cs.Material = Enum.Material.Neon
		if Index % 2 == 0 then
			cs.Color = Color3.fromRGB(0, 0, 0)
		else
			cs.Color = GravityColor
		end
		cs.Parent = Visual

		local Tween = TweenService:Create(
			cs,
			TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{ ["Transparency"] = 1, ["Size"] = Vector3.new(30, 0, 30), ["CFrame"] = c2 }
		)
		Tween:Play()
		Tween:Destroy()

		Debris:AddItem(cs, 0.15)
		wait(0.1)
	end
end

function module.Move2(Data)
	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")

	--[[ Crater on Ground ]]
	--
	VFXHandler.Crater({
		Cframe = Root.CFrame, -- Position
		Amount = 25, -- How manay rocks
		Iteration = 30, -- Expand
		Max = 3, -- Length upwards
		FirstDuration = 0.35, -- Rock tween outward start duration
		RocksLength = 3, -- How long the rocks stay for
	})
	local RootCFrame = Root.CFrame

	SoundManager:Play(Root, "YamiCharge", { Volume = 2 })
	--[[ Lines in Front/Gravity Force ]]
	--
	coroutine.wrap(function()
		local WIDTH, LENGTH = 0.35, 5
		for j = 1, 60 do
			for i = 1, math.random(1, 2) do
				local Sphere = VFXEffects.Part.Sphere:Clone()
				Sphere.Transparency = 0
				Sphere.Mesh.Scale = Vector3.new(WIDTH, LENGTH, WIDTH)
				Sphere.Material = Enum.Material.Neon
				if j % 2 == 0 then
					Sphere.Color = Color3.fromRGB(0, 0, 0)
				else
					Sphere.Color = GravityColor
				end
				Sphere.CFrame = RootCFrame * CFrame.new(math.random(-10, 10) * i * 2, 10, math.random(-10, 10) * i * 2)
				Sphere.Parent = Visual

				local tween = TweenService:Create(
					Sphere,
					TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ ["Transparency"] = 1, ["Position"] = Sphere.Position + Vector3.new(0, -15, 0) }
				)
				tween:Play()
				tween:Destroy()
				Debris:AddItem(Sphere, 0.1)
			end
			wait()
		end
	end)()

	for j = 1, 50 do
		for _ = 1, math.random(1, 2) do
			--[[ Raycast ]]
			--
			local StartPosition = (
				Vector3.new(math.sin(360 * j) * math.random(10, 14) * 2, 0, math.cos(360 * j) * math.random(10, 14) * 2)
				+ RootCFrame.Position
			)
			local EndPosition = CFrame.new(StartPosition).UpVector * -10

			local RayData = RaycastParams.new()
			RayData.FilterDescendantsInstances = { Character, Live, Visual } or Visual
			RayData.FilterType = Enum.RaycastFilterType.Exclude
			RayData.IgnoreWater = true

			local ray = workspace:Raycast(StartPosition, EndPosition, RayData)
			if ray then
				local partHit, pos = ray.Instance or nil, ray.Position or nil
				if partHit then
					local Block = VFXEffects.Part.Block:Clone()

					local X, Y, Z = math.random(20, 50) / 20, math.random(20, 50) / 20, math.random(20, 50) / 20
					Block.Size = Vector3.new(X, Y, Z)

					Block.Position = pos
					Block.Rotation = Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))
					Block.Transparency = 0
					Block.Color = partHit.Color
					Block.Material = partHit.Material
					Block.Parent = Visual

					local Tween = TweenService:Create(
						Block,
						TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							["Transparency"] = 1,
							["Orientation"] = Block.Orientation
								+ Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360)),
							["Position"] = Block.Position + Vector3.new(0, math.random(10, 14), 0),
						}
					)
					Tween:Play()
					Tween:Destroy()

					Debris:AddItem(Block, 0.15)
				end
			end
		end
		wait()
	end
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

	while collectionService:HasTag(Character, "GravityFlight") do
		bv.Velocity = Root.CFrame.lookVector * 75
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

	local RootCFrame = Root.CFrame * CFrame.new(0, 3, 0)

	local function MeteorCall()
		local Rings = {}

		SoundManager:Play(Root, "Woosh", { Volume = 1 })

		local Ring2 = workspace.Ring2:Clone()
		Ring2.CFrame = RootCFrame * CFrame.new(0, 50, 0) * CFrame.fromEulerAnglesXYZ(math.rad(180), 0, 0)
		Ring2.Size = Vector3.new(0, 100, 0)
		Ring2.Parent = Visual

		local tween2 = TweenService:Create(
			Ring2,
			TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ ["Size"] = Vector3.new(3, 100, 3) }
		)
		tween2:Play()
		tween2:Destroy()

		table.insert(Rings, Ring2)
		for i = 0, 10 do
			local Ring3 = workspace.Ring2:Clone()
			Ring3.CFrame = RootCFrame * CFrame.new(0, i * 10, 0) * CFrame.fromEulerAnglesXYZ(math.rad(180), 0, 0)
			Ring3.Parent = Visual
			table.insert(Rings, Ring3)
			task.wait()
		end

		task.wait(0.35)
		for _, v in ipairs(Rings) do
			local tween3 = TweenService:Create(
				v,
				TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ ["Size"] = Vector3.new(0, Ring2.Size.Y, 0) }
			)
			tween3:Play()
			tween3:Destroy()
		end
		task.wait(0.15)
		for i, v in ipairs(Rings) do
			v:Destroy()
			Rings[i] = nil
		end
	end

	task.spawn(function()
		MeteorCall()
	end)
	--wait(0.25)

	local Projectile = VFXEffects.Model.Meteor:Clone()
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
			Debris:AddItem(Projectile, 0.25)

			local Explosion = VFXEffects.Model.Explosion:Clone()
			Explosion.Parent = Visual
			Debris:AddItem(Explosion, 3)
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

			SoundManager:Play(Explosion.Main, "loudRockSlam", { Volume = 2 })

			--[[ Wunbo Orbies ]]
			--
			VFXHandler.WunboOrbies({
				j = 4, -- j (first loop)
				i = 6, -- i (second loop)
				StartPos = Explosion.Main.Position, -- where the orbies originate
				Duration = 0.15, -- how long orbies last
				Width = 5, -- width (x,y) sizes
				Length = 20, -- length (z) size
				Color1 = Color3.fromRGB(255, 255, 255), -- color of half of the orbies, color2 is the other half
				Color2 = Color3.fromRGB(255, 85, 127), -- color of half of the orbies, color2 is the other half
				Distance = CFrame.new(0, 0, 80), -- how far the orbies travel
			})

			task.spawn(function()
				for i1 = 1, 3 do
					local Ring2 = workspace.Ring2:Clone()
					Ring2.CFrame = Projectile.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(180), 0, 0)
					Ring2.Parent = Visual

					local tween1 = TweenService:Create(
						Ring2,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							["CFrame"] = Projectile.CFrame
								* CFrame.new(0, i1 * 15, 0)
								* CFrame.fromEulerAnglesXYZ(math.rad(180), 0, 0),
							["Transparency"] = 1,
							["Size"] = Vector3.new(75, 2, 75),
						}
					)
					tween1:Play()
					tween1:Destroy()
					Debris:AddItem(Ring2, 0.25)
					task.wait(0.1)
				end
			end)

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
				Cframe = CFrame.new(Projectile.Position), -- Position
				Amount = 25, -- How manay rocks
				Iteration = 25, -- Expand
				Max = 2, -- Length upwards
				FirstDuration = 0.25, -- Rock tween outward start duration
				RocksLength = 2, -- How long the rocks stay for
			})

			local shock = VFXEffects.Mesh.upwardShock:Clone()
			shock.CFrame = Projectile.CFrame * CFrame.fromEulerAnglesXYZ(0, math.rad(90), 0)
			shock.Color = Color3.fromRGB(255, 255, 255)
			shock.Size = Vector3.new(0, 0, 0)
			local tween1 =
				TweenService:Create(shock, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = Vector3.new(75, 105, 75),
					CFrame = shock.CFrame * CFrame.new(0, 35, 0) * CFrame.Angles(0, math.pi / 2, 0),
				})
			tween1:Play()
			tween1:Destroy()
			coroutine.wrap(function()
				wait(0.2)
				local tween2 = TweenService:Create(
					shock,
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{ Size = Vector3.new(0, 80, 0), Color = Color3.fromRGB(255, 85, 0) }
				)
				tween2:Play()
				tween2:Destroy()
				game.Debris:AddItem(shock, 0.2)
			end)()
			shock.Parent = Visual

			--[[ Fire P00rticle XD ]]
			--
			local Fire = VFXEffects.Particle.ParticleAttatchments.Fire:Clone()
			local Attachment = Instance.new("Attachment")
			Fire.Fire.Parent = Attachment
			Attachment.Parent = Explosion.Main
			Fire:Destroy()

			Attachment.Fire.Speed = NumberRange.new(125, 150)
			Attachment.Fire.Drag = 5

			Attachment.Fire.Lifetime = NumberRange.new(0.75, 1)
			Attachment.Fire.Size =
				NumberSequence.new({ NumberSequenceKeypoint.new(0, 15), NumberSequenceKeypoint.new(1, 0) })
			Attachment.Fire.Acceleration = Vector3.new(0, 0, 0)
			Attachment.Fire.Rate = 200

			coroutine.wrap(function()
				Attachment.Fire.Enabled = true
				for _ = 1, 2 do
					Attachment.Fire:Emit(100)
					task.wait(0.1)
				end
				Attachment.Fire.Enabled = false
			end)()
			Debris:AddItem(Attachment, 1)

			--[[ Stars xD ]]
			--
			local Stars = VFXEffects.Particle.ParticleAttatchments.Stars:Clone()
			Stars.Stars.Color = ColorSequence.new(Color3.fromRGB(255, 85, 0))
			Stars.Stars.Size =
				NumberSequence.new({ NumberSequenceKeypoint.new(0, 2.5), NumberSequenceKeypoint.new(1, 0) })
			Stars.Stars.Drag = 5
			Stars.Stars.Rate = 100
			Stars.Stars.Acceleration = Vector3.new(0, -100, 0)
			Stars.Stars.Lifetime = NumberRange.new(1, 1.5)
			Stars.Stars.Speed = NumberRange.new(120, 200)
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
			Rocks.Rocks.Speed = NumberRange.new(100, 150)
			Rocks.Parent = Explosion.Main
			Rocks.Rocks:Emit(100)
			Debris:AddItem(Rocks, 2)

			--// shockwave particle
			local Shockwave = VFXEffects.Particle.ParticleAttatchments.Shockwave:Clone()
			Shockwave.Shockwave.Size =
				NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 100) })
			Shockwave.Shockwave.Parent = Attachment
			Attachment.Shockwave:Emit(1)

			--// Ball Effect
			local Ball = VFXEffects.Part.Ball:Clone()
			Ball.Color = Color3.fromRGB(255, 85, 127)
			Ball.Material = Enum.Material.ForceField
			Ball.Transparency = 0
			Ball.Size = Vector3.new(5, 5, 5)
			Ball.CFrame = Projectile.CFrame
			Ball.Parent = Visual

			local tween2 = TweenService:Create(
				Ball,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ ["Transparency"] = 1, ["Size"] = Ball.Size * 30 }
			)
			tween2:Play()
			tween2:Destroy()
			Debris:AddItem(Ball, 0.2)

			--[[ Flying Debris Rock ]]
			--
			VFXHandler.FlyingRocks({
				i = 2, -- first loop
				j = 5, -- nested loop
				Offset = 10, -- radius from starting pos
				Origin = Projectile.Position, -- where to start
				Filter = { Character, Live, Visual }, -- filter raycast
				Size = Vector2.new(5, 8), -- size range random from 1,3
				AxisRange = 80, -- velocity X and Z ranges from (-AxisRange,AxisRange)
				Height = Vector2.new(50, 60), -- velocity Y ranges from X,Y
				Percent = 0.99, -- velocity * percent of nested loop
				Duration = 2, -- duration of the debris rock
				IterationDelay = 0, -- delay between each i loop
			})
		end
	end)()

	task.wait(projectileData.Lifetime)

	if Projectile and not hitSomething then
		tween:Pause()
		Projectile.Anchored = true
		Debris:AddItem(Projectile, 0.5)
	end
end

function module.Screen()
	local ColorCorrection = Instance.new("ColorCorrectionEffect")
	ColorCorrection.Parent = game:GetService("Lighting")

	local tween2 = TweenService:Create(
		ColorCorrection,
		TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ ["TintColor"] = Color3.fromRGB(170, 85, 255), ["Brightness"] = 0, ["Contrast"] = 0, ["Saturation"] = 0 }
	)
	tween2:Play()
	tween2:Destroy()

	task.wait(0.75)

	local tween3 = TweenService:Create(
		ColorCorrection,
		TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ ["TintColor"] = Color3.fromRGB(149, 149, 149), ["Brightness"] = 0, ["Contrast"] = 0, ["Saturation"] = -1 }
	)
	tween3:Play()
	tween3:Destroy()

	task.wait(1)
	local tween4 = TweenService:Create(
		ColorCorrection,
		TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ ["TintColor"] = Color3.fromRGB(255, 255, 255), ["Brightness"] = 0, ["Contrast"] = 0, ["Saturation"] = 0 }
	)
	tween4:Play()
	tween4:Destroy()

	Debris:AddItem(ColorCorrection, 1)
end

function module.TargetPush(Data)
	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")
	local Target = Data.Target

	if not Target:FindFirstChild("HumanoidRootPart") then
		return
	end

	SharedFunctions:DestroyForce(Target.HumanoidRootPart, "BodyGyro")
	SharedFunctions:DestroyForce(Target.HumanoidRootPart, "BodyPosition")
	SharedFunctions:BodyPosition(
		Target.HumanoidRootPart,
		200,
		25,
		Vector3.new(1e5, 1e5, 1e5),
		(Root.CFrame * CFrame.new(0, 0, -75)).Position,
		0.35
	)

	coroutine.wrap(function()
		for _ = 1, 10 do
			if not Target:FindFirstChild("HumanoidRootPart") then
				return
			end
			local StartPos = Target.HumanoidRootPart.Position
			local EndPosition = CFrame.new(StartPos).UpVector * -10

			local RayData = RaycastParams.new()
			RayData.FilterDescendantsInstances = { Target, Live, Visual } or Visual
			RayData.FilterType = Enum.RaycastFilterType.Exclude
			RayData.IgnoreWater = true

			local ray = game.Workspace:Raycast(StartPos, EndPosition, RayData)
			if ray then
				local partHit, pos = ray.Instance or nil, ray.Position or nil
				if partHit then
					if (StartPos - pos).Magnitude <= 10 then
						for i = 1, 2 do
							local Smoke = VFXEffects.Particle.Smoke:Clone()
							local Attachment = Instance.new("Attachment")
							if i == 1 then
								Attachment.Parent = Target["Right Leg"]
							else
								Attachment.Parent = Target["Left Leg"]
							end
							Smoke.Smoke.Parent = Attachment
							Smoke:Destroy()
							Attachment.Smoke.Size = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0),
								NumberSequenceKeypoint.new(1, 1),
							})
							Attachment.Smoke.Color = ColorSequence.new(partHit.Color)
							Attachment.Smoke.Acceleration = Character.HumanoidRootPart.CFrame.LookVector * 150
							Attachment.Smoke.Drag = -5
							Attachment.Smoke.Lifetime = NumberRange.new(0.25)
							Attachment.Smoke.Speed = NumberRange.new(5)
							Attachment.Position = Attachment.Position - Vector3.new(0, -3, 0)
							Attachment.Smoke:Emit(30)
							Debris:AddItem(Attachment, 0.5)
						end
					end
				end
			end
			wait(0.05)
		end
	end)()
end

attackRemote.OnClientEvent:Connect(function(info)
	local action = info.Function
	if module[action] then
		module[action](info)
	end
end)

return module
