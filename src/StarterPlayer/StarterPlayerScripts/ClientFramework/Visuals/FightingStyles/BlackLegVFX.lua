--/Services
local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")

--/Modules
local module = {}

--/Variables
local attackRemote = game.ReplicatedStorage.Remotes.FightingStyles[string.split(script.Name, "VFX")[1]]

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

--// Modules
local SharedFunctions = require(Modules.SharedFunctions)

function module.Knockback(Data)
	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")

	local Target = Data.Target

	SharedFunctions:DestroyForce(Target.HumanoidRootPart, "BodyGyro")
	SharedFunctions:DestroyForce(Target.HumanoidRootPart, "BodyPosition")

	if not Target:FindFirstChild("PseudoTorso") then --MOB
		SharedFunctions:BodyPosition(
			Target.HumanoidRootPart,
			200,
			25,
			Vector3.new(1e5, 1e5, 1e5),
			(Root.CFrame * CFrame.new(0, 0, -50)).Position,
			0.35
		)
	end

	coroutine.wrap(function()
		for _ = 1, 10 do
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

	--[[ KnockbackLines ]]
	--
	VFXHandler.KnockbackLines({
		MAX = 2,
		ITERATION = 5,
		WIDTH = 0.35,
		LENGTH = 10,
		COLOR1 = Color3.fromRGB(255, 255, 255),
		COLOR2 = Color3.fromRGB(0, 0, 0),
		STARTPOS = Character.HumanoidRootPart.CFrame * CFrame.new(0, -5, 0),
		ENDGOAL = CFrame.new(0, 0, -50),
	})

	--[[ Wunbo Orbies ]]
	--
	VFXHandler.WunboOrbies({
		j = 2, -- j (first loop)
		i = 6, -- i (second loop)
		StartPos = Target.HumanoidRootPart.Position, -- where the orbies originate
		Duration = 0.15, -- how long orbies last
		Width = 1, -- width (x,y) sizes
		Length = 5, -- length (z) size
		Color1 = Color3.fromRGB(255, 255, 255), -- color of half of the orbies, color2 is the other half
		Color2 = Color3.fromRGB(0, 0, 0), -- color of half of the orbies, color2 is the other half
		Distance = CFrame.new(0, 0, 25), -- how far the orbies travel
	})
end

function module.CombatHit(Data)
	local Character = Data.Character
	local Target = Data.Target

	if players.LocalPlayer == players:GetPlayerFromCharacter(Character) then
		_G.CamShake:ShakeOnce(3, 4, 0, 1)
	end

	--SharedFunctions:BodyGyro(Target.HumanoidRootPart, 10000, 25, Vector3.new(1e4,1e4,1e4), CFrame.new(Target.HumanoidRootPart.Position, Root.Position), 0.15)

	--[[ Wunbo Orbies ]]
	--
	VFXHandler.WunboOrbies({
		j = 2, -- j (first loop)
		i = 2, -- i (second loop)
		StartPos = Target.HumanoidRootPart.Position, -- where the orbies originate
		Duration = 0.15, -- how long orbies last
		Width = 0.5, -- width (x,y) sizes
		Length = 2.5, -- length (z) size
		Color1 = Color3.fromRGB(255, 255, 255), -- color of half of the orbies, color2 is the other half
		Distance = CFrame.new(0, 0, 7), -- how far the orbies travel
	})

	for _, v in pairs(Target:GetChildren()) do
		if v:IsA("BasePart") then
			local outline = v:Clone()
			outline.Size += Vector3.new(1, 1, 1) * 0.02
			outline.Material = "Neon"
			outline.Color = Color3.fromRGB(255, 46, 46)
			outline.Transparency = 0.75
			local weld = Instance.new("Weld")
			weld.Part0 = outline
			weld.C0 = weld.Part0.CFrame:inverse()
			weld.Part1 = v
			weld.C1 = weld.Part1.CFrame:inverse()
			weld.Parent = outline
			tweenService:Create(outline, TweenInfo.new(0.2), { Transparency = 1 }):Play()
			outline.Parent = v
			game.Debris:AddItem(outline, 0.2)
		end
	end

	local hitParticle = Assets.VFX.FightingStyles.Combat.Melee.hitEffect:Clone()
	hitParticle.CFrame = Target.HumanoidRootPart.CFrame
	hitParticle.particle:Emit(15)
	hitParticle.Parent = Visual
	game.Debris:AddItem(hitParticle, 0.75)
end

function module.Move1(Data)
	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")

	--[[ Play Sound ]]
	--
	SoundManager:Play(Root, "Ground Slam", { Volume = 2 })

	--[[ Crater on Ground ]]
	--
	VFXHandler.Crater({
		Cframe = CFrame.new(Root.Position), -- Position
		Amount = 10, -- How manay rocks
		Iteration = 10, -- Expand
		Max = 2, -- Length upwards
		FirstDuration = 0.25, -- Rock tween outward start duration
		RocksLength = 2, -- How long the rocks stay for
	})

	--[[ Rocks xD ]]
	--
	local Rocks = VFXEffects.Particle.ParticleAttatchments.Rocks:Clone()
	Rocks.Rocks.Size =
		NumberSequence.new({ NumberSequenceKeypoint.new(0, math.random(5, 10) / 20), NumberSequenceKeypoint.new(1, 0) })
	Rocks.Rocks.Drag = 5
	Rocks.Rocks.Rate = 100
	Rocks.Rocks.Acceleration = Vector3.new(0, -50, 0)
	Rocks.Rocks.Lifetime = NumberRange.new(1, 1.5)
	Rocks.Rocks.Speed = NumberRange.new(60, 75)
	Rocks.Parent = Root
	Rocks.Rocks:Emit(15)
	Debris:AddItem(Rocks, 2)

	--// Ball Effect
	local Ball = VFXEffects.Part.Ball:Clone()
	Ball.Color = Color3.fromRGB(255, 255, 255)
	Ball.Material = Enum.Material.ForceField
	Ball.Transparency = 0
	Ball.Size = Vector3.new(5, 5, 5)
	Ball.CFrame = Root.CFrame
	Ball.Parent = Visual

	local tween = TweenService:Create(
		Ball,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ ["Transparency"] = 1, ["Size"] = Ball.Size * 7 }
	)
	tween:Play()
	tween:Destroy()
	Debris:AddItem(Ball, 0.2)

	local CrashSmoke = VFXEffects.Particle.Smoke:Clone()
	CrashSmoke.Parent = Visual
	CrashSmoke.CanCollide = false
	CrashSmoke.Position = Root.Position
	CrashSmoke.Smoke.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 5), NumberSequenceKeypoint.new(1, 5) })
	CrashSmoke.Size = Vector3.new(15, 0, 15)
	CrashSmoke.Smoke.Speed = NumberRange.new(5, 15)
	CrashSmoke.Smoke:Emit(100)
	CrashSmoke.Anchored = true

	local beam = VFXEffects.Part.Sphere:Clone()
	beam.Transparency = 0
	beam.Size = Vector3.new(20, 50, 20)
	beam.Material = "Neon"
	beam.Color = Color3.fromRGB(255, 255, 255)
	beam.CFrame = Root.CFrame * CFrame.new(0, -7, 0)
	beam.Parent = Visual

	local tween1 = TweenService:Create(
		beam,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ ["CFrame"] = beam.CFrame * CFrame.new(0, 15, 0), ["Transparency"] = 1, ["Size"] = Vector3.new(0, 50, 0) }
	)
	tween1:Play()
	tween1:Destroy()
	Debris:AddItem(beam, 0.25)

	local ring2 = VFXEffects.Mesh.Ring2OG:Clone()
	ring2.Color = Color3.fromRGB(255, 255, 255)
	ring2.Material = "Neon"
	ring2.Transparency = 0
	ring2.CFrame = Root.CFrame * CFrame.new(0, -3, 0) * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
	ring2.Size = Vector3.new(14, 14, 0.05)
	ring2.Parent = Visual
	Debris:AddItem(ring2, 0.8)

	local tween2 = TweenService:Create(ring2, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		["CFrame"] = ring2.CFrame * CFrame.new(0, 0, -10),
		["Transparency"] = 1,
		["Size"] = Vector3.new(20, 20, 0.05),
	})
	tween2:Play()
	tween2:Destroy()
	Debris:AddItem(Ball, 0.8)

	local shockwave5 = VFXEffects.Mesh.shockwave5:Clone()
	shockwave5.CFrame = Root.CFrame * CFrame.new(0, -1, 0) * CFrame.fromEulerAnglesXYZ(0, math.rad(90), 0)
	shockwave5.Size = Vector3.new(10, 3.5, 10)
	shockwave5.Transparency = 0.5
	shockwave5.Material = "Neon"
	shockwave5.Color = Color3.fromRGB(255, 255, 255)
	shockwave5.Parent = Visual
	Debris:AddItem(shockwave5, 0.35)

	local tween3 = TweenService:Create(
		shockwave5,
		TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ ["Transparency"] = 1, ["Size"] = Vector3.new(25, 5, 25) }
	)
	tween3:Play()
	tween3:Destroy()
	Debris:AddItem(Ball, 0.35)

	--[[ Wunbo Orbies ]]
	--
	VFXHandler.WunboOrbies({
		j = 2, -- j (first loop)
		i = 4, -- i (second loop)
		StartPos = Root.Position, -- where the orbies originate
		Duration = 0.15, -- how long orbies last
		Width = 1, -- width (x,y) sizes
		Length = 5, -- length (z) size
		Color1 = Color3.fromRGB(255, 255, 255), -- color of half of the orbies, color2 is the other half
		Color2 = Color3.fromRGB(0, 0, 0), -- color of half of the orbies, color2 is the other half
		Distance = CFrame.new(0, 0, 50), -- how far the orbies travel
	})

	task.delay(1, function()
		CrashSmoke.Smoke.Enabled = false
	end)
	Debris:AddItem(CrashSmoke, 3)
end

function module.Move2(Data)
	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")

	--[[ Play Sound ]]
	--
	SoundManager:Play(Root, "rockslamExplosion", { Volume = 1 })

	--[[ Crater on Ground ]]
	--
	VFXHandler.Crater({
		Cframe = CFrame.new(Root.Position), -- Position
		Amount = 15, -- How manay rocks
		Iteration = 15, -- Expand
		Max = 2, -- Length upwards
		FirstDuration = 0.25, -- Rock tween outward start duration
		RocksLength = 2, -- How long the rocks stay for
	})

	local shock = VFXEffects.Mesh.upwardShock:Clone()
	shock.CFrame = CFrame.new(Root.Position) * CFrame.fromEulerAnglesXYZ(0, math.rad(90), 0)
	shock.Color = Color3.fromRGB(255, 255, 255)
	shock.Size = Vector3.new(0, 0, 0)
	local tween = TweenService:Create(shock, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(35, 50, 35),
		CFrame = shock.CFrame * CFrame.new(0, 25, 0) * CFrame.Angles(0, math.pi / 2, 0),
	})
	tween:Play()
	tween:Destroy()
	coroutine.wrap(function()
		wait(0.2)
		local tween1 = TweenService:Create(
			shock,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ Size = Vector3.new(0, 80, 0), Color = Color3.fromRGB(189, 189, 189) }
		)
		tween1:Play()
		tween1:Destroy()
		game.Debris:AddItem(shock, 0.2)
	end)()
	shock.Parent = Visual

	--[[ Rocks xD ]]
	--
	local Rocks = VFXEffects.Particle.ParticleAttatchments.Rocks:Clone()
	Rocks.Rocks.Size =
		NumberSequence.new({ NumberSequenceKeypoint.new(0, math.random(5, 10) / 20), NumberSequenceKeypoint.new(1, 0) })
	Rocks.Rocks.Drag = 5
	Rocks.Rocks.Rate = 100
	Rocks.Rocks.Acceleration = Vector3.new(0, -50, 0)
	Rocks.Rocks.Lifetime = NumberRange.new(1, 1.5)
	Rocks.Rocks.Speed = NumberRange.new(60, 75)
	Rocks.Parent = Root
	Rocks.Rocks:Emit(15)
	Debris:AddItem(Rocks, 2)

	--// Ball Effect
	local Ball = VFXEffects.Part.Ball:Clone()
	Ball.Color = Color3.fromRGB(255, 255, 255)
	Ball.Material = Enum.Material.ForceField
	Ball.Transparency = 0
	Ball.Size = Vector3.new(5, 5, 5)
	Ball.CFrame = Root.CFrame
	Ball.Parent = Visual

	local tween1 = TweenService:Create(
		Ball,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ ["Transparency"] = 1, ["Size"] = Ball.Size * 7 }
	)
	tween1:Play()
	tween1:Destroy()
	Debris:AddItem(Ball, 0.2)

	local beam = VFXEffects.Part.Sphere:Clone()
	beam.Transparency = 0
	beam.Size = Vector3.new(20, 50, 20)
	beam.Material = "Neon"
	beam.Color = Color3.fromRGB(255, 255, 255)
	beam.CFrame = Root.CFrame * CFrame.new(0, -7, 0)
	beam.Parent = Visual

	local tween2 = TweenService:Create(
		beam,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ ["CFrame"] = beam.CFrame * CFrame.new(0, 15, 0), ["Transparency"] = 1, ["Size"] = Vector3.new(0, 50, 0) }
	)
	tween2:Play()
	tween2:Destroy()
	Debris:AddItem(beam, 0.25)

	local ring2 = VFXEffects.Mesh.Ring2OG:Clone()
	ring2.Color = Color3.fromRGB(255, 255, 255)
	ring2.Material = "Neon"
	ring2.Transparency = 0
	ring2.CFrame = Root.CFrame * CFrame.new(0, -3, 0) * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
	ring2.Size = Vector3.new(14, 14, 0.05)
	ring2.Parent = Visual

	local tween3 = TweenService:Create(ring2, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		["CFrame"] = ring2.CFrame * CFrame.new(0, 0, -10),
		["Transparency"] = 1,
		["Size"] = Vector3.new(20, 20, 0.05),
	})
	tween3:Play()
	tween3:Destroy()
	Debris:AddItem(ring2, 0.8)

	local shockwave5 = VFXEffects.Mesh.shockwave5:Clone()
	shockwave5.CFrame = Root.CFrame * CFrame.new(0, -1, 0) * CFrame.fromEulerAnglesXYZ(0, math.rad(90), 0)
	shockwave5.Size = Vector3.new(10, 3.5, 10)
	shockwave5.Transparency = 0.5
	shockwave5.Material = "Neon"
	shockwave5.Color = Color3.fromRGB(255, 255, 255)
	shockwave5.Parent = Visual

	local tween4 = TweenService:Create(
		shockwave5,
		TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ ["Transparency"] = 1, ["Size"] = Vector3.new(40, 5, 40) }
	)
	tween4:Play()
	tween4:Destroy()
	Debris:AddItem(shockwave5, 0.35)

	--[[ Wunbo Orbies ]]
	--
	VFXHandler.WunboOrbies({
		j = 2, -- j (first loop)
		i = 4, -- i (second loop)
		StartPos = Root.Position, -- where the orbies originate
		Duration = 0.15, -- how long orbies last
		Width = 1, -- width (x,y) sizes
		Length = 5, -- length (z) size
		Color1 = Color3.fromRGB(255, 255, 255), -- color of half of the orbies, color2 is the other half
		Color2 = Color3.fromRGB(0, 0, 0), -- color of half of the orbies, color2 is the other half
		Distance = CFrame.new(0, 0, 50), -- how far the orbies travel
	})
end

function module.Move3(Data)
	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")

	task.spawn(function()
		for _ = 1, 5 do
			--[[ Play Sound ]]
			--
			SoundManager:Play(Root, "Spiny", { Volume = 1 })
			wait(0.15)
		end
	end)
	for _ = 1, 15 do
		local ring2 = VFXEffects.Mesh.Ring2OG:Clone()
		ring2.Color = Color3.fromRGB(255, 255, 255)
		ring2.Material = "Neon"
		ring2.Transparency = 0
		ring2.CFrame = Root.CFrame * CFrame.new(0, 2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
		ring2.Size = Vector3.new(5, 5, 0.05)
		ring2.Parent = Visual
		Debris:AddItem(ring2, 0.15)

		local tween = TweenService:Create(ring2, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			["CFrame"] = ring2.CFrame * CFrame.new(0, 0, -2),
			["Transparency"] = 1,
			["Size"] = Vector3.new(10, 10, 0.05),
		})
		tween:Play()
		tween:Destroy()
		Debris:AddItem(ring2, 0.15)

		local CrashSmoke = VFXEffects.Particle.Smoke:Clone()
		CrashSmoke.Parent = Visual
		CrashSmoke.CanCollide = false
		CrashSmoke.Position = Root.Position
		CrashSmoke.Smoke.Size =
			NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 3) })
		CrashSmoke.Size = Vector3.new(15, 0, 15)
		CrashSmoke.Smoke.Speed = NumberRange.new(5, 15)
		CrashSmoke.Smoke.Lifetime = NumberRange.new(0.35, 0.5)
		CrashSmoke.Smoke:Emit(25)
		CrashSmoke.Anchored = true
		Debris:AddItem(CrashSmoke, 0.5)

		local shockwave5 = VFXEffects.Mesh.shockwave5:Clone()
		shockwave5.CFrame = Root.CFrame * CFrame.new(0, -1, 0) * CFrame.fromEulerAnglesXYZ(0, math.rad(90), 0)
		shockwave5.Size = Vector3.new(5, 1, 5)
		shockwave5.Transparency = 0.5
		shockwave5.Material = "Neon"
		shockwave5.Color = Color3.fromRGB(255, 255, 255)
		shockwave5.Parent = Visual
		Debris:AddItem(shockwave5, 0.35)

		local tween1 =
			TweenService:Create(shockwave5, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				["CFrame"] = shockwave5.CFrame * CFrame.Angles(0, math.pi, 0),
				["Transparency"] = 1,
				["Size"] = Vector3.new(20, 3.5, 20),
			})
		tween1:Play()
		tween1:Destroy()
		Debris:AddItem(shockwave5, 0.35)

		task.wait(0.1)
	end
end

function module.Move4(Data)
	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")

	--[[ Play Sound ]]
	--
	SoundManager:Play(Root, "KnockbackCrash", { Volume = 2 })

	local beam = VFXEffects.Part.Sphere:Clone()
	beam.Transparency = 0
	beam.Mesh.Scale = Vector3.new(20, 20, 60)
	beam.Material = "Neon"
	beam.Color = Color3.fromRGB(255, 255, 255)
	beam.CFrame = Root.CFrame * CFrame.new(0, 0, -40)
	beam.Parent = Visual

	local tween = TweenService:Create(
		beam.Mesh,
		TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ ["Scale"] = Vector3.new(0, 0, 60) }
	)
	tween:Play()
	tween:Destroy()
	Debris:AddItem(beam, 0.25)

	local ring2 = VFXEffects.Mesh.Ring2OG:Clone()
	ring2.Color = Color3.fromRGB(255, 255, 255)
	ring2.Material = "Neon"
	ring2.Transparency = 0
	ring2.CFrame = Root.CFrame * CFrame.new(0, -3, 0) * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
	ring2.Size = Vector3.new(14, 14, 0.05)
	ring2.Parent = Visual

	local tween1 = TweenService:Create(
		ring2,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ ["Transparency"] = 1, ["Size"] = Vector3.new(20, 20, 0.05) }
	)
	tween1:Play()
	tween1:Destroy()
	Debris:AddItem(ring2, 0.5)

	local shockwaveOG = VFXEffects.Mesh.shockwaveOG:Clone()
	shockwaveOG.CFrame = Root.CFrame * CFrame.new(0, 0, -3) * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
	shockwaveOG.Size = Vector3.new(5, 2, 5)
	shockwaveOG.Transparency = 0
	shockwaveOG.Material = "Neon"
	shockwaveOG.Color = Color3.fromRGB(255, 255, 255)
	shockwaveOG.Parent = Visual

	local tween2 =
		TweenService:Create(shockwaveOG, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			["CFrame"] = shockwaveOG.CFrame * CFrame.fromEulerAnglesXYZ(0, 5, 0),
			["Transparency"] = 1,
			["Size"] = Vector3.new(25, 5, 25),
		})
	tween2:Play()
	tween2:Destroy()
	Debris:AddItem(shockwaveOG, 0.25)

	local shockwaveOG2 = VFXEffects.Mesh.shockwaveOG:Clone()
	shockwaveOG2.CFrame = Root.CFrame * CFrame.fromEulerAnglesXYZ(0, math.rad(90), 0)
	shockwaveOG2.Size = Vector3.new(10, 5, 10)
	shockwaveOG2.Transparency = 0
	shockwaveOG2.Material = "Neon"
	shockwaveOG2.Color = Color3.fromRGB(255, 255, 255)
	shockwaveOG2.Parent = Visual

	local tween3 =
		TweenService:Create(shockwaveOG2, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			["CFrame"] = shockwaveOG.CFrame * CFrame.fromEulerAnglesXYZ(0, 5, 0),
			["Transparency"] = 1,
			["Size"] = Vector3.new(30, 15, 30),
		})
	tween3:Play()
	tween3:Destroy()
	Debris:AddItem(shockwaveOG2, 0.25)

	local ring3 = VFXEffects.Mesh.Ring2OG:Clone()
	ring3.Color = Color3.fromRGB(255, 255, 255)
	ring3.Material = "Neon"
	ring3.Transparency = 0
	ring3.CFrame = Root.CFrame * CFrame.new(0, -2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
	ring3.Size = Vector3.new(5, 5, 0.05)
	ring3.Parent = Visual

	local tween4 = TweenService:Create(
		ring3,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ ["Transparency"] = 1, ["Size"] = Vector3.new(30, 30, 0.05) }
	)
	tween4:Play()
	tween4:Destroy()
	Debris:AddItem(ring3, 0.5)

	task.wait(0.05)
	--[[ KnockbackLines ]]
	--
	VFXHandler.KnockbackLines({
		MAX = 1,
		ITERATION = 5,
		WIDTH = 0.35,
		DURATION = 0.15,
		LENGTH = 10,
		COLOR1 = Color3.fromRGB(255, 255, 255),
		COLOR2 = Color3.fromRGB(0, 0, 0),
		STARTPOS = Root.CFrame,
		ENDGOAL = CFrame.new(0, 0, -50),
	})

	--[[ Side Rocks ]]
	--
	VFXHandler.SideRocks({
		StartPos = Root.CFrame, -- origin position
		Offset = 10, -- how far apart the two rock piles are in the X-axis
		Amount = 10, -- amount of rocks on each pile (determines the length of pile)
		Size = Vector3.new(2, 2, 2), -- size of each rock (vector3)
		Filter = { Character, Live, Visual }, -- filter raycast
		IterationDelay = 0, -- iteration between each rock placed
		Duration = 2, -- how long the rocks last
	})
end

attackRemote.OnClientEvent:connect(function(info)
	local action = info.Function
	if module[action] then
		module[action](info)
	end
end)

return module
