local Functions = require(script.Parent.Parent.Functions)
local RS = game:GetService("ReplicatedStorage")
local Animations = RS:WaitForChild("Assets").Animations.FightingStyles.Combat
local Debris = game:GetService("Debris")
local Assets = RS:WaitForChild("Assets")
local frameWork = script.Parent.Parent.Parent
local damageModule = require(frameWork.Misc.Damage)

local TestSkillSet = {
	["Slice"] = function(Player, ...)
		local Data = (...)
		print("Reached Server")
		local Character = Player.Character
		local CF = Character.HumanoidRootPart.CFrame
		Functions.FireClientWithDistance(
			{
				Origin = Character.HumanoidRootPart.Position,
				Distance = 125,
				Remote = game.ReplicatedStorage.Remotes.Effects},
			    {"Slice", {Character = Character, CFrame = CF},

			}
		)
		local Params = OverlapParams.new()
		Params.FilterType = Enum.RaycastFilterType.Exclude
		Params.FilterDescendantsInstances = {workspace.Map, Character}
		local EPart = nil
		for i = 0, 2 do
			task.spawn(function()
				local Hits = {}
				local NCF = CF * CFrame.Angles(0, math.rad(-20 + (i * 20)),0)
				
				for i = 1, 15 do
					local Hitbox = workspace:GetPartBoundsInBox(NCF * CFrame.new(0,0, i * -5), Vector3.new(2, 13, 5), Params)
					for Index, Part in pairs(Hitbox) do
						if Part.Parent:FindFirstChild("Humanoid") then
							if Hits[Part.Parent] == nil then
								Hits[Part.Parent] = true
								EPart = Part
								local bv = Instance.new("BodyVelocity", Part.Parent.HumanoidRootPart)
								bv.MaxForce = Vector3.one * 999999
								bv.Velocity = (Part.Parent.HumanoidRootPart.CFrame.Position - Player.Character.HumanoidRootPart.CFrame.Position).Unit * 10
								bv.Name = "vel"
								task.delay(.2, function()
									bv:Destroy()
								end)
								
								local DmgCounter = Assets:WaitForChild("VFX"):WaitForChild("Combat"):WaitForChild("DmgCounter"):Clone()
								DmgCounter.Parent = workspace
								DmgCounter.Position = Part.Parent.HumanoidRootPart.CFrame.Position
								DmgCounter.Counter.Number.Text = "-".."10"

								local goal = {}
								goal.TextColor3 = Color3.fromRGB(255, 255, 255)
								local info = TweenInfo.new(.1,Enum.EasingStyle.Sine,Enum.EasingDirection.In,0,true,0)
								local tween = game:GetService("TweenService"):Create(DmgCounter.Counter.Number,info,goal)
								tween:Play()

								task.delay(.4, function()
									DmgCounter:Destroy()
								end)
								
								local Sound = Assets:WaitForChild("Sounds"):WaitForChild("PunchSound"):Clone()
								Sound.Parent = Part.Parent.HumanoidRootPart
								Sound:Play()		
								game.Debris:AddItem(Sound,1)
								
								Part.Parent.Humanoid.Animator:LoadAnimation(Animations.BeamStun):Play()
								Part.Parent.Humanoid:TakeDamage(10)
								Part:SetAttribute("Stunned", true)
								local Hit = game.ReplicatedStorage.Assets.VFX.TestSkillSet.Hit:Clone()
								Hit.CFrame = Part.Parent.HumanoidRootPart.CFrame
								Hit.Orientation = Vector3.new(math.random(0,180),math.random(0,180),math.random(0,180))
								Hit.Parent = workspace.FX
								Hit.Attachment.Shards:Emit(25)
								game.Debris:AddItem(Hit,1)
							end
						end
					end
					task.wait(.033)
				end
				
			end)
		end
		if EPart then
			EPart.Parent:SetAttribute("Stunned", false)
		end
	end,
	
	["Beam"] = function(Player, ...)
		print("Reached Server")
		local Character = Player.Character
		Character:SetAttribute("InAir", true)
		local BP = Instance.new("BodyPosition", Character.HumanoidRootPart)
		BP.Position = Character.HumanoidRootPart.Position + Vector3.new(0,20,0)
		BP.MaxForce = Vector3.one * 999999
		BP.D = 200
		BP.P = 800
		BP.Name = "BeamLiftPosition"
		
		Functions.FireClientWithDistance({
			Origin = Character.HumanoidRootPart.Position,
			Distance = 125,
			Remote = game.ReplicatedStorage.Remotes.Effects},
			{"Charge", {Character = Character}
		})
		local Inputs = require(game.ServerScriptService.ServerHandler.Inputs)
		task.wait(1)
		while Inputs.InputTable[Player]["R"] do
			task.wait()
		end
		BP:Destroy()
		local BP = Instance.new("BodyPosition", Character.HumanoidRootPart)
		BP.Position = Character.HumanoidRootPart.Position
		BP.MaxForce = Vector3.one * 999999
		BP.D = 200
		BP.P = 800
		BP.Name = "BeamShootPosition"

		Functions.FireClientWithDistance({
			Origin = Character.HumanoidRootPart.Position,
			Distance = 125,
			Remote = game.ReplicatedStorage.Remotes.Effects},
		{"Beam", {Character = Character}
		})
		task.wait(3)
		BP:Destroy()
		Character:SetAttribute("InAir", false)
	end,
	
	["BeamHit"] = function(Player, ...)
		local Data = (...)
		local Character = Player.Character
		local Params = OverlapParams.new()
		Params.FilterType = Enum.RaycastFilterType.Exclude
		Params.FilterDescendantsInstances = {workspace.Map, Character}
		game.ReplicatedStorage.Remotes.Effects:FireClient(Player, {"BeamCameraShake", {}})
		local Dist = (Data.StartPosition - Data.EndPosition).Magnitude
		
		local EPart = nil
		
		for i = 1, 30 do
			local Hits = {}
			local Hitbox = workspace:GetPartBoundsInBox(CFrame.new((Data.StartPosition + Data.EndPosition)/2, Data.EndPosition), Vector3.new(4,4,Dist), Params)
			for Index, Part in pairs(Hitbox) do
				if Hits[Part.Parent] == nil then
					Hits[Part.Parent] = true
					if Part.Parent:FindFirstChild("Humanoid") then
						if Part.Parent.Humanoid.Animator:LoadAnimation(Animations.BeamStun).IsPlaying then
							Part.Parent.Humanoid.Animator:LoadAnimation(Animations.BeamStun):Stop()
						end
						local bv = Instance.new("BodyVelocity", Part.Parent.HumanoidRootPart)
						bv.MaxForce = Vector3.one * 999999
						bv.Velocity = (Part.Parent.HumanoidRootPart.CFrame.Position - Player.Character.HumanoidRootPart.CFrame.Position).Unit * 10
						bv.Name = "vel"
						task.delay(.2, function()
							bv:Destroy()
						end)
						Part.Parent.Humanoid.Animator:LoadAnimation(Animations.BeamStun):Play()
						Part.Parent.Humanoid:TakeDamage(5)
						
						local DmgCounter = Assets:WaitForChild("VFX"):WaitForChild("Combat"):WaitForChild("DmgCounter"):Clone()
						DmgCounter.Parent = workspace
						DmgCounter.Position = Part.Parent.HumanoidRootPart.CFrame.Position
						DmgCounter.Counter.Number.Text = "-".."5"

						local goal = {}
						goal.TextColor3 = Color3.fromRGB(255, 255, 255)
						local info = TweenInfo.new(.1,Enum.EasingStyle.Sine,Enum.EasingDirection.In,0,true,0)
						local tween = game:GetService("TweenService"):Create(DmgCounter.Counter.Number,info,goal)
						tween:Play()
						
						local Sound = Assets:WaitForChild("Sounds"):WaitForChild("PunchSound"):Clone()
						Sound.Parent = Part.Parent.HumanoidRootPart
						Sound:Play()		
						game.Debris:AddItem(Sound,1)
						
						task.delay(.4, function()
							DmgCounter:Destroy()
						end)
						
						Part.Parent.Humanoid.WalkSpeed = 5
						Part.Parent.Humanoid.JumpPower = 0
						Part:SetAttribute("Stunned", true)
						EPart = Part
					end
				end
				
			end
			task.wait(.1)
		end
		if EPart then
			EPart.Parent:SetAttribute("Stunned", false)
			EPart.Parent.Humanoid.Animator:LoadAnimation(Animations.BeamStun):Stop()
		end
	end,
}

return TestSkillSet
