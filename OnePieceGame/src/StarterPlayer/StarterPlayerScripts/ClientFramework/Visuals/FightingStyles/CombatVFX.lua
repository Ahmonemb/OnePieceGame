--/Services
local collectionService = game:GetService("CollectionService")
local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")

--/Modules
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)
local module = {}

--/Variables
local attackRemote = game.ReplicatedStorage.Remotes.FightingStyles[string.split(script.Name,"VFX")[1]]
local effectFolder = game.ReplicatedStorage.Assets.VFX.FightingStyles[string.split(script.Name,"VFX")[1]]

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

--// Modules
local Modules = ReplicatedStorage.Modules
local SharedFunctions = require(Modules.SharedFunctions)

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
	local VRoot = Target:FindFirstChild("HumanoidRootPart")
	
	if players.LocalPlayer == players:GetPlayerFromCharacter(Character) then
		_G.CamShake:ShakeOnce(3,4,0,1)
	end
	
	--SharedFunctions:BodyGyro(Target.HumanoidRootPart, 10000, 25, Vector3.new(1e4,1e4,1e4), CFrame.new(Target.HumanoidRootPart.Position, Root.Position), 0.15)
	
	if VRoot then
		--[[ Wunbo Orbies ]]--
		VFXHandler.WunboOrbies({
			j = 2; -- j (first loop)
			i = 2; -- i (second loop)
			StartPos = VRoot.Position; -- where the orbies originate
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
		hitParticle.CFrame = VRoot.CFrame
		hitParticle.particle:Emit(15)
		hitParticle.Parent = Visual
		game.Debris:AddItem(hitParticle,.75)
	end
end

attackRemote.OnClientEvent:connect(function(info)
	local action = info.Function
	if module[action] then
		module[action](info)
	end
end)

return module
