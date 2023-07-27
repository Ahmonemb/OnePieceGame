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
local attackRemote = game.ReplicatedStorage.Remotes.FightingStyles[string.split(script.Name,"VFX")[1]]
local effectFolder = game.ReplicatedStorage.Assets.VFX.DemonFruits["Light"]


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

function module.OneSwordStyle(info)
	local c = info.Character
	local equippedWeapons = c.Weapons
	local storage = effectFolder
	local states = c.States

	if not equippedWeapons:GetAttribute("OneSwordStyle") then
		equippedWeapons:SetAttribute("OneSwordStyle",true)

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
		equippedWeapons:SetAttribute("OneSwordStyle",nil)

		local sword = equippedWeapons:FindFirstChild("lightSword")
		tweenService:Create(sword,TweenInfo.new(.1),{Transparency = 1}):Play()
		game.Debris:AddItem(sword,.1)
	end
end

function module.CombatSwing(Data)
	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")
	local CurrentCombo = Data.CurrentCombo
end;

function module.Knockback(Data)
	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")
	
	local Target = Data.Target
	
	SharedFunctions:DestroyForce(Target.HumanoidRootPart, "BodyGyro")
	SharedFunctions:DestroyForce(Target.HumanoidRootPart, "BodyPosition")
	
	if not Target:FindFirstChild("PseudoTorso") then --MOB
		SharedFunctions:BodyPosition(Target.HumanoidRootPart, 200, 25, Vector3.new(1e5,1e5,1e5), (Root.CFrame * CFrame.new(0,0,-50)).Position, 0.35)
	end
	
	
	coroutine.wrap(function()
		for i = 1, 10 do
			local StartPos = Target.HumanoidRootPart.Position
			local EndPosition = CFrame.new(StartPos).UpVector * -10

			local RayData = RaycastParams.new()
			RayData.FilterDescendantsInstances = {Target, Live, Visual} or Visual
			RayData.FilterType = Enum.RaycastFilterType.Blacklist
			RayData.IgnoreWater = true

			local ray = game.Workspace:Raycast(StartPos, EndPosition, RayData)
			if ray then

				local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
				if partHit then
					if (StartPos - pos).Magnitude <= 10 then
						for i = 1,2 do
							local Smoke = VFXEffects.Particle.Smoke:Clone()
							local Attachment = Instance.new("Attachment")
							if i == 1 then
								Attachment.Parent = Target["Right Leg"]
							else
								Attachment.Parent = Target["Left Leg"]
							end
							Smoke.Smoke.Parent = Attachment
							Smoke:Destroy()
							Attachment.Smoke.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}
							Attachment.Smoke.Color = ColorSequence.new(partHit.Color)
							Attachment.Smoke.Acceleration = Character.HumanoidRootPart.CFrame.LookVector*150
							Attachment.Smoke.Drag = -5
							Attachment.Smoke.Lifetime = NumberRange.new(.25)
							Attachment.Smoke.Speed = NumberRange.new(5)
							Attachment.Position = Attachment.Position - Vector3.new(0,-3,0)
							Attachment.Smoke:Emit(30)
							Debris:AddItem(Attachment, .5)
						end
					end			
				end
			end	
			wait(0.05)
		end
	end)()
	
	--[[ KnockbackLines ]]--
	VFXHandler.KnockbackLines({
		MAX = 2;
		ITERATION = 5;
		WIDTH = 0.35;
		LENGTH = 10;
		COLOR1 = Color3.fromRGB(255, 255, 255);
		COLOR2 = Color3.fromRGB(0, 0, 0);
		STARTPOS = Character.HumanoidRootPart.CFrame * CFrame.new(0,-5,0);
		ENDGOAL = CFrame.new(0,0,-50);
	});
	
	--[[ Wunbo Orbies ]]--
	VFXHandler.WunboOrbies({
		j = 2; -- j (first loop)
		i = 6; -- i (second loop)
		StartPos = Target.HumanoidRootPart.Position; -- where the orbies originate
		Duration = 0.15; -- how long orbies last
		Width = 1; -- width (x,y) sizes
		Length = 5; -- length (z) size
		Color1 = Color3.fromRGB(255, 255, 255); -- color of half of the orbies, color2 is the other half
		Color2 = Color3.fromRGB(0, 0, 0); -- color of half of the orbies, color2 is the other half
		Distance = CFrame.new(0,0,25); -- how far the orbies travel
	})
end;

function module.CombatHit(Data)
	
	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")
	local Target = Data.Target
	
	if players.LocalPlayer == players:GetPlayerFromCharacter(Character) then
		_G.CamShake:ShakeOnce(3,4,0,1)
	end
	
	--SharedFunctions:BodyGyro(Target.HumanoidRootPart, 10000, 25, Vector3.new(1e4,1e4,1e4), CFrame.new(Target.HumanoidRootPart.Position, Root.Position), 0.15)
	
	--[[ Wunbo Orbies ]]--
	VFXHandler.WunboOrbies({
		j = 2; -- j (first loop)
		i = 2; -- i (second loop)
		StartPos = Target.HumanoidRootPart.Position; -- where the orbies originate
		Duration = 0.15; -- how long orbies last
		Width = 0.5; -- width (x,y) sizes
		Length = 2.5; -- length (z) size
		Color1 = Color3.fromRGB(255, 255, 255); -- color of half of the orbies, color2 is the other half
		Distance = CFrame.new(0,0,7); -- how far the orbies travel
	})
	
	for _,v in pairs(Target:GetChildren()) do 
		if v:IsA("BasePart") then
			local outline = v:Clone()
			outline.Size += Vector3.new(1,1,1)*.02
			outline.Material = "Neon"
			outline.Color = Color3.fromRGB(255, 46, 46)
			outline.Transparency = .75
			local weld = Instance.new("Weld")
			weld.Part0 = outline
			weld.C0 = weld.Part0.CFrame:inverse()
			weld.Part1 = v
			weld.C1 = weld.Part1.CFrame:inverse()
			weld.Parent = outline
			tweenService:Create(outline,TweenInfo.new(.2),{Transparency = 1}):Play()
			outline.Parent = v
			game.Debris:AddItem(outline,.2)
		end
	end
	
	local hitParticle = Assets.VFX.FightingStyles.Combat.Melee.hitEffect:Clone()
	hitParticle.CFrame = Target.HumanoidRootPart.CFrame
	hitParticle.particle:Emit(15)
	hitParticle.Parent = Visual
	game.Debris:AddItem(hitParticle,.75)
end

function module.Move1(Data)

	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")
	local projectileCFrame = Data.projectileCFrame
	local projectileData = Data.projectileData
	local hitSomething = false

	local Projectile = VFXEffects.Mesh.Slash:Clone()
	Projectile.CFrame = projectileCFrame
	Projectile.Parent = Visual

	local tween = TweenService:Create(Projectile, TweenInfo.new(projectileData.Lifetime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["CFrame"] = Projectile.CFrame * CFrame.new(0,0, -projectileData.Velocity * projectileData.Lifetime)})
	tween:Play()
	tween:Destroy()

	Debris:AddItem(Projectile, projectileData.Lifetime)
	
	coroutine.wrap(function()
		while (not hitSomething) and (Projectile.Parent) do 
			--[[ Side Rocks ]]--
			VFXHandler.SideRocks({
				StartPos = Projectile.CFrame; -- origin position
				Offset = 5; -- how far apart the two rock piles are in the X-axis
				Amount = 1; -- amount of rocks on each pile (determines the length of pile)
				Size = Vector3.new(2,2,2); -- size of each rock (vector3)
				Filter = {Character, Live, Visual}; -- filter raycast
				IterationDelay = 0; -- iteration between each rock placed
				Duration = 2; -- how long the rocks last 
			});
			wait()
		end
	end)()

	coroutine.wrap(function()
		local hitPoint = hitDetection:ProjectileActive(projectileData)

		if hitPoint then
			hitSomething = true
			--// hit something effects go here
			tween:Pause()
			Projectile.Size = Vector3.new(0,0,0)
			Projectile.Anchored = true
			Debris:AddItem(Projectile, 1)

			SoundManager:Play(Projectile, "pikaExplosion", {Volume = 2, TimePosition = 8.5})

			--//
			local Block = VFXEffects.Part.Block:Clone()
			Block.Anchored = true
			Block.Size = Vector3.new(0,0,0)
			Block.CanCollide = false
			Block.Anchored = true
			Block.CFrame = Projectile.CFrame	
			Block.Parent = Visual
			Debris:AddItem(Block, 1.5)

			--[[ Wunbo Orbies ]]--
			VFXHandler.WunboOrbies({
				j = 4; -- j (first loop)
				i = 6; -- i (second loop)
				StartPos = Projectile.Position; -- where the orbies originate
				Duration = 0.15; -- how long orbies last
				Width = 2; -- width (x,y) sizes
				Length = 10; -- length (z) size
				Color1 = Color3.fromRGB(255, 255, 255); -- color of half of the orbies, color2 is the other half
				Color2 = Color3.fromRGB(0, 0, 0); -- color of half of the orbies, color2 is the other half
				Distance = CFrame.new(0,0,50); -- how far the orbies travel
			})

			local CrashSmoke = VFXEffects.Particle.Smoke:Clone()
			CrashSmoke.Parent = Visual
			CrashSmoke.CanCollide = false
			CrashSmoke.Position = Projectile.Position
			CrashSmoke.Smoke.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 5), NumberSequenceKeypoint.new(1, 5)}
			CrashSmoke.Size = Vector3.new(15,0,15)
			CrashSmoke.Smoke:Emit(80)
			CrashSmoke.Anchored = true

			delay(1,function()
				CrashSmoke.Smoke.Enabled = false 
			end)
			Debris:AddItem(CrashSmoke,3)				
			
			for _ = 1,10 do
				
				--// Circle Slash
				local circleslash = VFXEffects.Model.circleslash:Clone()
				local one = circleslash.one
				local two = circleslash.two
				local StartSizeOne = Vector3.new(15,15,2)
				local StartSizeTwo = Vector3.new(15,15,2)
				local Multiple = 3
				for _,v in ipairs(circleslash:GetDescendants()) do
					if v:IsA("Decal") and v.Parent.Name == "one" then
						v.Color3 = Color3.fromRGB(85, 170, 2550)
					elseif v:IsA("Decal") and v.Parent.Name == "two" then
						v.Color3 = Color3.fromRGB(2550, 2550, 2550)
					end
				end

				one.Size = StartSizeOne
				two.Size = StartSizeTwo
				circleslash.Parent = Visual

				local Offset = math.random(-360,360)

				one.CFrame = Projectile.CFrame * CFrame.new(0,1,0) * CFrame.fromEulerAnglesXYZ(math.rad(math.random(-360,360)),math.rad(math.random(-360,360)),math.rad(math.random(-360,360)))
				two.CFrame = Projectile.CFrame * CFrame.new(0,1,0) * CFrame.fromEulerAnglesXYZ(math.rad(math.random(-360,360)),math.rad(math.random(-360,360)),math.rad(math.random(-360,360)))

				Debris:AddItem(circleslash, 0.5)

				--// Tween one		
				local TweenOne = TweenService:Create(one, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["CFrame"] = one.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(270)),["Size"] = StartSizeOne * Multiple})
				TweenOne:Play()
				TweenOne:Destroy()

				--// Tween two
				local TweenTwo = TweenService:Create(two, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["CFrame"] = two.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(270)),["Size"] = StartSizeTwo * Multiple})
				TweenTwo:Play()
				TweenTwo:Destroy()

				--// Tween Decals
				for i, v in ipairs(one:GetChildren()) do
					if v:IsA("Decal") then
						local tween = TweenService:Create(v, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
						tween:Play()
						tween:Destroy()
					end	
				end

				for i, v in ipairs(two:GetChildren()) do
					local tween = TweenService:Create(v, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
					tween:Play()
					tween:Destroy()
				end
				wait()
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
	local Root = Character:FindFirstChild("HumanoidRootPart")		
	
	spawn(function()
		for _ = 1,5 do
			SoundManager:Play(Root, "SwordSlash", {Volume = 1})
			wait(0.15)
		end
	end)
	for _ = 1,30 do

		--// Circle Slash
		local circleslash = VFXEffects.Model.circleslash:Clone()
		local one = circleslash.one
		local two = circleslash.two
		local StartSizeOne = Vector3.new(7.5,7.5,1)
		local StartSizeTwo = Vector3.new(7.5,7.5,1)
		local Multiple = 2
		for _,v in ipairs(circleslash:GetDescendants()) do
			if v:IsA("Decal") and v.Parent.Name == "one" then
				v.Color3 = Color3.fromRGB(85, 170, 2550)
			elseif v:IsA("Decal") and v.Parent.Name == "two" then
				v.Color3 = Color3.fromRGB(2550, 2550, 2550)
			end
		end

		one.Size = StartSizeOne
		two.Size = StartSizeTwo
		circleslash.Parent = Visual

		local Offset = math.random(-360,360)

		one.CFrame = Root.CFrame * CFrame.new(0,1,-5) * CFrame.fromEulerAnglesXYZ(math.rad(math.random(-360,360)),math.rad(math.random(-360,360)),math.rad(math.random(-360,360)))
		two.CFrame = Root.CFrame * CFrame.new(0,1,-5) * CFrame.fromEulerAnglesXYZ(math.rad(math.random(-360,360)),math.rad(math.random(-360,360)),math.rad(math.random(-360,360)))
		
		--[[ Wunbo Orbies ]]--
		VFXHandler.WunboOrbies({
			j = 1; -- j (first loop)
			i = 2; -- i (second loop)
			StartPos = one.Position; -- where the orbies originate
			Duration = 0.15; -- how long orbies last
			Width = 0.25; -- width (x,y) sizes
			Length = 1; -- length (z) size
			Color1 = Color3.fromRGB(255, 255, 255); -- color of half of the orbies, color2 is the other half
			Color2 = Color3.fromRGB(85, 85, 255); -- color of half of the orbies, color2 is the other half
			Distance = CFrame.new(0,0,10); -- how far the orbies travel
		})	
		
		--// part slashes
		local originalPos = one.Position
		local beam = VFXEffects.Part.Block:Clone()
		beam.Shape = "Block"
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = "Sphere"
		mesh.Parent = beam
		beam.Size = Vector3.new(0.5,0.5,15)
		beam.Material = Enum.Material.Neon
		beam.BrickColor = BrickColor.new("Institutional white")
		beam.Transparency = 0
		beam.Parent = Visual

		beam.CFrame = CFrame.new(originalPos + Vector3.new(math.random(-1,1),math.random(-1,1),math.random(-1,1)), originalPos) 
		local tween = TweenService:Create(beam, TweenInfo.new(.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {["Size"] = beam.Size + Vector3.new(0,0, math.random(.5,1))})
		local tween2 = TweenService:Create(beam, TweenInfo.new(.1, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {["Size"] = Vector3.new(0,0,15)})		
		tween:Play()
		tween:Destroy()
		tween2:Play()
		tween2:Destroy()
		Debris:AddItem(beam, .1)
		--
		
		Debris:AddItem(circleslash, 0.5)

		--// Tween one		
		local TweenOne = TweenService:Create(one, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["CFrame"] = one.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(270)),["Size"] = StartSizeOne * Multiple})
		TweenOne:Play()
		TweenOne:Destroy()

		--// Tween two
		local TweenTwo = TweenService:Create(two, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["CFrame"] = two.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(270)),["Size"] = StartSizeTwo * Multiple})
		TweenTwo:Play()
		TweenTwo:Destroy()

		--// Tween Decals
		for i, v in ipairs(one:GetChildren()) do
			if v:IsA("Decal") then
				local tween = TweenService:Create(v, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
				tween:Play()
				tween:Destroy()
			end	
		end

		for i, v in ipairs(two:GetChildren()) do
			local tween = TweenService:Create(v, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
			tween:Play()
			tween:Destroy()
		end
		wait()
	end
end


function module.Move3(Data)

	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")
	
	local RootStartPosition = Character.HumanoidRootPart.CFrame
	
	SoundManager:Play(Root, "LionSong", {Volume = 2})
	--[[ Side Shockwaves ]]--
	for j = 1,2 do

		local Offset = 5;
		local Rot = 288;
		local GoalSize = Vector3.new(50, 0.5, 10);
		if j == 1 then
		else
			Offset = Offset * -1;
			Rot = 252
		end

		local SideWind = VFXEffects.Mesh.SideWind:Clone()
		SideWind.Size = Vector3.new(8, 0.05, 2)
		SideWind.Color = Color3.fromRGB(255, 255, 255)
		SideWind.Material = Enum.Material.SmoothPlastic
		SideWind.Transparency = -1
		SideWind.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(Offset,-0.5,0) * CFrame.fromEulerAnglesXYZ(math.rad(90),math.rad(180),math.rad(Rot))
		SideWind.Parent = Visual

		--[[ Tween the Side Shockwaves ]]--
		local tween = TweenService:Create(SideWind, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["CFrame"] = SideWind.CFrame * CFrame.new(-10,0,0), ["Size"] = GoalSize, ["Transparency"] = 1})
		tween:Play()
		tween:Destroy()

		Debris:AddItem(SideWind, .2)
	end
	-- LINES TEST
	
	coroutine.wrap(function()
		local Trail = VFXEffects.Trail.GroundTrail:Clone()
		Trail.Trail.Lifetime = 3
		Trail.Position = Root.Position
		Trail.Transparency = 1
		Trail.Parent = Visual

		--// tween the attachments
		local tween = TweenService:Create(Trail.Start, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Position"] = Vector3.new(0,0,.25)})
		tween:Play()
		tween:Destroy()

		local tween = TweenService:Create(Trail.End, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Position"] = Vector3.new(0,0,-0.25)})
		tween:Play()
		tween:Destroy()

		local i = 0
		for j = 1,20 do
			i += 1.5
			
			--[[ Side Rocks ]]--
			VFXHandler.SideRocks({
				StartPos = Root.CFrame; -- origin position
				Offset = 5; -- how far apart the two rock piles are in the X-axis
				Amount = 1; -- amount of rocks on each pile (determines the length of pile)
				Size = Vector3.new(1,1,1); -- size of each rock (vector3)
				Filter = {Character, Live, Visual}; -- filter raycast
				IterationDelay = 0; -- iteration between each rock placed
				Duration = 2; -- how long the rocks last 
			});
			--[[ Raycast ]]--
			local StartPosition = (Character.HumanoidRootPart.CFrame).Position
			local EndPosition = CFrame.new(StartPosition).UpVector * -10

			local RayData = RaycastParams.new()
			RayData.FilterDescendantsInstances = {Character, Live, Visual} or Visual
			RayData.FilterType = Enum.RaycastFilterType.Blacklist
			RayData.IgnoreWater = true

			local ray = game.Workspace:Raycast(StartPosition, EndPosition, RayData)
			if ray then
				local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
				if partHit then
					Trail.Position = pos 
				end
			end
			game:GetService("RunService").Heartbeat:Wait()
			
			--// Circle Slash
			local circleslash = VFXEffects.Model.circleslash:Clone()
			local one = circleslash.one
			local two = circleslash.two
			local StartSizeOne = Vector3.new(15,15,1)
			local StartSizeTwo = Vector3.new(15,15,2)
			local Multiple = math.random(2,3)
			for _,v in ipairs(circleslash:GetDescendants()) do
				if v:IsA("Decal") and v.Parent.Name == "one" then
					v.Color3 = Color3.fromRGB(85, 170, 2550)
				elseif v:IsA("Decal") and v.Parent.Name == "two" then
					v.Color3 = Color3.fromRGB(2550, 2550, 2550)
				end
			end

			one.Size = StartSizeOne
			two.Size = StartSizeTwo
			circleslash.Parent = Visual

			one.CFrame = RootStartPosition * CFrame.new(0,1,-i) * CFrame.fromEulerAnglesXYZ(math.rad(math.random(0,360)),math.rad(math.random(0,360)),0)
			two.CFrame = RootStartPosition * CFrame.new(0,1,-i) * CFrame.fromEulerAnglesXYZ(math.rad(math.random(0,360)),math.rad(math.random(0,360)),0)

			Debris:AddItem(circleslash, 0.5)
			--// PointLight
			local PointLight = Instance.new("PointLight")
			PointLight.Color = Color3.fromRGB(85, 170, 255)
			PointLight.Range = 25
			PointLight.Brightness = 1
			PointLight.Parent = one

			local LightTween = TweenService:Create(PointLight, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Range"] = 0, ["Brightness"] = 0})
			LightTween:Play()
			LightTween:Destroy()

			--// Tween one		
			local TweenOne = TweenService:Create(one, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["CFrame"] = one.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(270)),["Size"] = StartSizeOne * Multiple})
			TweenOne:Play()
			TweenOne:Destroy()

			--// Tween two
			local TweenTwo = TweenService:Create(two, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {["CFrame"] = two.CFrame * CFrame.fromEulerAnglesXYZ(0,0,math.rad(270)),["Size"] = StartSizeTwo * Multiple})
			TweenTwo:Play()
			TweenTwo:Destroy()
			--// Tween Decals
			for i, v in ipairs(one:GetChildren()) do
				if v:IsA("Decal") then
					local tween = TweenService:Create(v, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
					tween:Play()
					tween:Destroy()
				end	
			end

			for i, v in ipairs(two:GetChildren()) do
				local tween = TweenService:Create(v, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["Transparency"] = 1})
				tween:Play()
				tween:Destroy()
			end


		end
		Debris:AddItem(Trail, 3)
	end)()
end;

function module.Screen(Data)

	local Character = Data.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")

	local ColorCorrection = Instance.new("ColorCorrectionEffect")
	ColorCorrection.Parent = game:GetService("Lighting") 

	local tween2 = TweenService:Create(ColorCorrection, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["TintColor"] = Color3.fromRGB(255, 0, 0), ["Brightness"] = 0, ["Contrast"] = 0, ["Saturation"] = 0})
	tween2:Play()
	tween2:Destroy()

	wait(0.75)

	local tween2 = TweenService:Create(ColorCorrection, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {["TintColor"] = Color3.fromRGB(255, 255, 255), ["Brightness"] = 0, ["Contrast"] = 0, ["Saturation"] = 0})
	tween2:Play()
	tween2:Destroy()

	Debris:AddItem(ColorCorrection, 1)
end;

if game:GetService("RunService"):IsClient() then
	attackRemote.OnClientEvent:connect(function(info)
		local action = info.Function
		if module[action] then
			module[action](info)
		end
	end)
end

return module
