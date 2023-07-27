local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Animations = ReplicatedStorage:WaitForChild("Assets").Animations.FightingStyles.Combat
local Debris = game:GetService("Debris")

local RParams = RaycastParams.new()
RParams.FilterType = Enum.RaycastFilterType.Include
RParams.FilterDescendantsInstances = {workspace.Map}

local module = {
	["Slice"] = function(Player, Params)
		local HRP = Player.Character.HumanoidRootPart
		Player.Character.Humanoid.WalkSpeed = 1
		Player.Character.Humanoid.JumpHeight = 1
		
		local animTrack = Player.Character.Humanoid.Animator:LoadAnimation(Animations.Slice)
		animTrack:Play()
		animTrack:AdjustSpeed(2)
		
		local Name = "Slice"
		local IsClient = RS:IsClient()

		local AllSounds = ReplicatedStorage:WaitForChild("Assets").Sounds
		local Sound;

		for _, v in pairs(AllSounds:GetChildren()) do
			if (v.Name == Name) then
				Sound = v:Clone();
			end
		end

		Sound.PlaybackSpeed =  1
		Sound.Volume = 1
		Sound.Parent = HRP
		Sound:Play()

		Debris:AddItem(Sound, Sound.TimeLength)
		
		for i = 0, 2 do
			local Slice = game.ReplicatedStorage.Assets.VFX.TestSkillSet.Slice:Clone()
			Slice.CFrame = Params.CFrame * CFrame.Angles(math.rad(90),0,math.rad(70 + (i * 20)))
			Slice.Parent = workspace.FX
			TS:Create(Slice, TweenInfo.new(.5), {Transparency = 1}):Play()
			local Start = time()
			local LastRock = time()
			game.Debris:AddItem(Slice, 2)
			local Connection
			task.delay(.5, function()
				Slice.Dots.Enabled = false
				Slice.Shards.Enabled = false
				Slice.Wisp.Enabled = false
				Slice.Wisp2.Enabled = false
				Connection:Disconnect()
				task.wait(1)
				Slice:Destroy()
			end)
			Connection = RS.RenderStepped:Connect(function(DT)
				local Result = workspace:Raycast(Slice.Trail5.WorldPosition + Vector3.new(0,12,0), Vector3.new(0,-12,0), RParams)
				if Result then
					Slice.TrailGreen.Enabled = true
					Slice.TrailBlack.Enabled = true
					Slice.Trail.Position = Vector3.new(-4.8, .4, Slice.Position.Y - Result.Position.Y -.01)
					Slice.Trail2.Position = Vector3.new(-4.8, -.4, Slice.Position.Y - Result.Position.Y -.01)
					Slice.Trail3.Position = Vector3.new(-4.8, .4, Slice.Position.Y - Result.Position.Y -.005)
					Slice.Trail4.Position = Vector3.new(-4.8, -.4, Slice.Position.Y - Result.Position.Y -.005)
				else
					Slice.TrailGreen.Enabled = false
					Slice.TrailBlack.Enabled = false
				end
				Slice.CFrame = Slice.CFrame * CFrame.new(-150 * DT,0,0)
				if time() - LastRock > .01 then
					local Result = workspace:Raycast(Vector3.new(Slice.Trail.WorldPosition.X, Slice.Position.Y, Slice.Trail.WorldPosition.Z), Vector3.new(0,-6,0), RParams)
					if Result then
						local Rock = game.ReplicatedStorage.Assets.VFX.TestSkillSet.Rock:Clone()
						Rock.CFrame = CFrame.new(Result.Position) * CFrame.new(math.random(-20,20)/10,-3,math.random(-20,20)/10) 
							* CFrame.Angles(math.rad(math.random(-20,20)/10),math.rad(math.random(-20,20)/10),math.rad(math.random(-20,20)/10))
						Rock.Size = Vector3.new(math.random(10,30)/10,math.random(10,30)/10,math.random(10,30)/10)
						Rock.Parent = workspace.FX
						Rock.Material = Result.Material
						Rock.Color = Result.Instance.Color
						TS:Create(Rock, TweenInfo.new(.2), {
							CFrame = Rock.CFrame * CFrame.new(0,math.random(25,35)/10,0)
								* CFrame.Angles(math.rad(math.random(0, 180)),math.rad(math.random(0,180)),math.rad(math.random(0,180))),
						}):Play()	
						task.delay(1,function()
							TS:Create(Rock, TweenInfo.new(.5), {
								Position = Rock.Position - Vector3.new(0,3,0),
								Orientation = Vector3.new(math.random(0,180),math.random(0,180),math.random(0,180))
							}):Play()
						end)
						game.Debris:AddItem(Rock, 2)
					end	
					local Result = workspace:Raycast(Vector3.new(Slice.Trail2.WorldPosition.X, Slice.Position.Y, Slice.Trail2.WorldPosition.Z), Vector3.new(0,-6,0), RParams)
					if Result then
						local Rock = game.ReplicatedStorage.Assets.VFX.TestSkillSet.Rock:Clone()
						Rock.CFrame = CFrame.new(Result.Position) * CFrame.new(math.random(-20,20)/10,-3,math.random(-20,20)/10) 
							* CFrame.Angles(math.rad(math.random(-20,20)/10),math.rad(math.random(-20,20)/10),math.rad(math.random(-20,20)/10))
						Rock.Size = Vector3.new(math.random(10,30)/10,math.random(10,30)/10,math.random(10,30)/10)
						Rock.Parent = workspace.FX
						Rock.Material = Result.Material
						Rock.Color = Result.Instance.Color
						TS:Create(Rock, TweenInfo.new(.2), {
							CFrame = Rock.CFrame * CFrame.new(0,math.random(25,35)/10,0)
								* CFrame.Angles(math.rad(math.random(0, 180)),math.rad(math.random(0,180)),math.rad(math.random(0,180))),
						}):Play()	
						task.delay(1,function()
							TS:Create(Rock, TweenInfo.new(.5), {
								Position = Rock.Position - Vector3.new(0,3,0),
								Orientation = Vector3.new(math.random(0,180),math.random(0,180),math.random(0,180))
							}):Play()
						end)
					end	
					LastRock = time()
				end
			end)
		end
		Player.Character.Humanoid.WalkSpeed = 16
		Player.Character.Humanoid.JumpHeight = 7.2
	end,
	
	["Charge"] = function(Player, Params)
		local HRP = Params.Character.HumanoidRootPart
		local RightArm = Params.Character:WaitForChild("Right Arm")
		local Mouse = Player:GetMouse()
		local Direction = Instance.new("BodyGyro", HRP)
		Direction.CFrame = CFrame.new(HRP.Position, Mouse.Hit.Position)
		Direction.MaxTorque = Vector3.new(999999,999999,999999)
		Direction.P = 20000
		Direction.D = 0
		Direction.Name = "AlignBeam"
		Params.Character.Humanoid.AutoRotate = false
		local Model = game.ReplicatedStorage.Assets.VFX.TestSkillSet.Charge:Clone()
		Model.Parent = workspace.FX
		local WindCount = 0
		
		local animTrack = Player.Character.Humanoid.Animator:LoadAnimation(Animations.Kamehameha)
		animTrack:Play()
		animTrack.TimePosition = 0
		animTrack:AdjustSpeed(0)
		
		local Name = "Charge"
		local IsClient = RS:IsClient()

		local AllSounds = ReplicatedStorage:WaitForChild("Assets").Sounds
		local Sound;

		for _, v in pairs(AllSounds:GetChildren()) do
			if (v.Name == Name) then
				Sound = v:Clone();
			end
		end

		Sound.PlaybackSpeed =  1
		Sound.Volume = 1
		Sound.Parent = HRP
		Sound:Play()

		Debris:AddItem(Sound, Sound.TimeLength)
		

		while HRP:FindFirstChild("BeamLiftPosition") do
			if time() - WindCount > .2 then
				local Wind = game.ReplicatedStorage.Assets.VFX.TestSkillSet.Wind:Clone()
				Wind.Parent = workspace.FX
				Wind.CFrame = RightArm.CFrame * CFrame.new(-.3,1,1) * CFrame.Angles(math.rad(math.random(0,180)),math.rad(math.random(0,180)),math.rad(math.random(0,180)))
				TS:Create(Wind, TweenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
					Size = Vector3.new(0, 0, 0),
					CFrame = Wind.CFrame * CFrame.Angles(0, math.random(0,180),0),
					Transparency = 1,
				}):Play()
				game.Debris:AddItem(Wind, 1)
				task.wait(.2)
				WindCount = time()
			end
			Model.CFrame = RightArm.CFrame * CFrame.new(-.3,.5,1)
			Direction.CFrame = CFrame.new(RightArm.Position, Mouse.Hit.Position)
			task.wait()
		end

		local StartTime = time()
		repeat
			Model.CFrame = RightArm.CFrame * CFrame.new(-.3,1,1)
			Direction.CFrame = CFrame.new(RightArm.Position, Mouse.Hit.Position)
			task.wait()
		until time() - StartTime > 1

		for i,Particle in pairs(Model.Attachment1:GetChildren()) do
			Particle.Enabled = false
		end
		game.Debris:AddItem(Model, 1)
		task.wait(2)
		Params.Character.Humanoid.AutoRotate = true
		Direction:Destroy()

	end,
	
	["Beam"] = function(Player, Params)
		local HRP = Params.Character.HumanoidRootPart
		local Mouse = Player:GetMouse()
		local MAXDIST = 200
		local EndPos = Mouse.Hit.Position
		local StartPos = (HRP.CFrame * CFrame.new(1,1,-1)).Position
		local Result = workspace:Raycast(StartPos, (StartPos - EndPos).Unit * -MAXDIST, RParams)
		if Result then
			EndPos = Result.Position
		else
			EndPos = (StartPos - EndPos).Unit * -MAXDIST + StartPos
		end
		local Dist = (StartPos - EndPos).Magnitude
		local Speed = Dist/300
		if Player.Character == Params.Character then
			task.spawn(function()
				game.ReplicatedStorage.Remotes.Server:InvokeServer("Skill", "None", {{EndPosition = EndPos, StartPosition = StartPos}, "BeamHit", "TestSkillSet"})
			end)
		end
		local Model = game.ReplicatedStorage.Assets.VFX.TestSkillSet.Beam:Clone()
		Model.Parent = workspace.FX
		StartPos = (HRP.CFrame * CFrame.new(1,1,-1)).Position
		
		Model.Kame1.CFrame = CFrame.new(StartPos,EndPos)
		Model.Kame2.CFrame = CFrame.new(StartPos,EndPos)
		
		task.spawn(function()
			for i = 0, 10 do
				local Shock = game.ReplicatedStorage.Assets.VFX.TestSkillSet.Shockwave:Clone()
				Shock.CFrame = CFrame.new(StartPos,EndPos) * CFrame.Angles(math.rad(90),0,0)
				Shock.Parent = workspace.FX
				TS:Create(Shock, TweenInfo.new(.3, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
					Size = Vector3.new(20, 5, 20),
					Transparency = 1,
				}):Play()
				game.Debris:AddItem(Shock, 1)
				task.wait(.1)
			end
		end)
		
		TS:Create(Model.Kame2, TweenInfo.new(Speed, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
			Position = EndPos,
		}):Play()
		
		Model.OuterBeam.CFrame = CFrame.new(StartPos,EndPos) * CFrame.Angles(math.rad(90),0,0)
		Model.InnerBeam.CFrame = CFrame.new(StartPos,EndPos) * CFrame.Angles(math.rad(90),0,0)
		TS:Create(Model.OuterBeam, TweenInfo.new(Speed, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
			Size = Vector3.new(2.5, Dist, 2.5),
			Position = (StartPos + EndPos)/2,
		}):Play()
		TS:Create(Model.InnerBeam, TweenInfo.new(Speed, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
			Size = Vector3.new(1, Dist, 1),
			Position = (StartPos + EndPos)/2,
		}):Play()
		
		local anim
		
		for i,v in pairs(Player.Character.Humanoid:GetPlayingAnimationTracks()) do 
			if v.Name == "Kamehameha" then
				anim = v
			end
		end
		
		if anim then
			anim:AdjustSpeed(1)
			anim.TimePosition = 1.02
			anim:AdjustSpeed(0)
		end
		
		local Name = "BeamShoot"
		local IsClient = RS:IsClient()

		local AllSounds = ReplicatedStorage:WaitForChild("Assets").Sounds
		local Sound;

		for _, v in pairs(AllSounds:GetChildren()) do
			if (v.Name == Name) then
				Sound = v:Clone();
			end
		end

		Sound.PlaybackSpeed =  1
		Sound.Volume = 1
		Sound.Parent = HRP
		Sound:Play()

		Debris:AddItem(Sound, Sound.TimeLength)
		
		while HRP:FindFirstChild("BeamShootPosition") do
			task.wait()
		end
		for i,Particle in pairs(Model.Kame1.Attachment1:GetChildren()) do
			Particle.Enabled = false
		end
		for i,Particle in pairs(Model.Kame2.Attachment1:GetChildren()) do
			Particle.Enabled = false
		end
		
		game.Debris:AddItem(Model, .15)
		anim:AdjustSpeed(1)
	end,
	
}

return module
