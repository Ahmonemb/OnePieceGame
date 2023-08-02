--/Services
local tweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--/Modules
local cooldownHandler = require(script.Parent.Parent.Parent.Handlers.CooldownHandler)
local attackData = require(game.ReplicatedStorage.Modules.Manager.AttackData)
local damageModule = require(script.Parent.Parent.Parent.Misc.Damage)
local module = {}
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Values = require(ReplicatedStorage:WaitForChild("Combat"):WaitForChild("Values"))

--/Variables
local attackRemote = game.ReplicatedStorage.Remotes.FightingStyles[script.Name]
local count = {}

--// Modules
local Modules = ReplicatedStorage.Modules
local SharedFunctions = require(Modules.SharedFunctions)

local MAX_COMBO = 4
local COMBO_TIME_WINDOW = 0.8
local COMBO_CD = 0.25
--/TODO: Simple melee combat

function module.Melee(p)
	local c = typeof(p) == "Instance" and p.Character or p.Model
	local cooldowns = c.Cooldowns
	local states = c.States

	local function Curve(t, p0, p1, p2)
		local A = p0:Lerp(p1, t)
		local B = p1:Lerp(p2, t)
		return A:Lerp(B, t)
	end

	local skillName = "Melee"

	local skillData = attackData.getData(script.Name, skillName)
	local damage = skillData.baseDamage + c.Data:GetAttribute("Strength")
	local knockback = false

	local HumanoidRootpart = typeof(p) == "Instance" and c.HumanoidRootPart or p.Torso

	if cooldowns:GetAttribute(skillName) then
		return
	end

	cooldownHandler.addCooldown(c, script.Name, skillName, COMBO_CD)

	if not count[p.Name] then
		count[p.Name] = 1
	end

	--SharedFunctions:FireAllDistanceClients(c, script.Name, 25, {CurrentCombo = count[p.Name], Character = c, Function = "CombatSwing"})

	if (os.clock() - states:GetAttribute("MeleeClicked")) > COMBO_TIME_WINDOW or count[p.Name] >= MAX_COMBO then
		if count[p.Name] >= MAX_COMBO then
			damage += math.random(5)
			knockback = true
		end
		count[p.Name] = 1
	else
		count[p.Name] += 1
	end

	local target = damageModule.getGTP(p, Vector3.new(5, 5, 5), HumanoidRootpart.CFrame * CFrame.new(0, 0, -4), true)

	if target then
		local EhumRP = target.HumanoidRootPart
		local Ehum = target.Humanoid
		local LookVector1 = (EhumRP.Position - HumanoidRootpart.Position).unit
		local LookVector2 = EhumRP.CFrame.LookVector
		local DotProduct = math.acos(LookVector2:Dot(LookVector1))
		if target:FindFirstChild("PseudoTorso") then
			if target:GetAttribute("Health") <= 0 then
				return
			end
		else
			if target.Humanoid.Health <= 0 then
				return
			end
		end

		if target:FindFirstChild("Blocking") and target:FindFirstChild("BlockHealth").Value <= 0 and DotProduct > 1 then
			local BlockFX =
				Assets:WaitForChild("VFX"):WaitForChild("Combat"):WaitForChild("GBFX"):WaitForChild("HitFX"):Clone()
			BlockFX.Parent = EhumRP
			game.Debris:AddItem(BlockFX, 2)

			for _, v in pairs(EhumRP.Parent:GetChildren()) do
				if v.Name == "Blocking" then
					v:Destroy()
				end
			end

			local AnimTracks = Ehum:GetPlayingAnimationTracks()

			for _, v in pairs(AnimTracks) do
				v:Stop()
			end

			local GB = Ehum:LoadAnimation(Assets:WaitForChild("Animations").FightingStyles.Combat:WaitForChild("GB"))
			GB:Play()
			task.delay(1.5, function()
				GB:Stop()
			end)

			local Sound = Assets:WaitForChild("Sounds").Sounds.Combat:WaitForChild("BB"):Clone()
			Sound.Parent = EhumRP
			Sound:Play()
			game.Debris:AddItem(Sound, 3)

			local DmgCounter = Assets:WaitForChild("VFX"):WaitForChild("Combat"):WaitForChild("DmgCounter"):Clone()
			DmgCounter.Parent = workspace
			DmgCounter.Position = EhumRP.Position
			DmgCounter.Counter.Number.Text = "Broken"

			Values:CreateValue("BoolValue", EhumRP.Parent, "StopStun", false, 1.5)

			local goal = {}
			goal.TextColor3 = Color3.fromRGB(255, 255, 255)
			local info = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true, 0)
			local tween = game:GetService("TweenService"):Create(DmgCounter.Counter.Number, info, goal)
			tween:Play()

			game.Debris:AddItem(DmgCounter, 0.4)

			local P1 = EhumRP.Position
			local P2 = EhumRP.Position + Vector3.new(math.random(-3, 3), math.random(2, 10), math.random(-3, 3))
			local P3 = P2 + Vector3.new(0, -15, 0)

			task.spawn(function()
				for i = 0, 1, 0.045 do
					local newpos = Curve(i, P1, P2, P3)
					DmgCounter.Position = newpos
					task.wait()
				end
			end)

			local BV = Instance.new("BodyVelocity")
			BV.Velocity = HumanoidRootpart.CFrame.LookVector * 10
			BV.MaxForce = Vector3.new(15000, 15000, 15000)
			BV.Parent = EhumRP
			game.Debris:AddItem(BV, 0.2)

			local BV2 = Instance.new("BodyVelocity")
			BV2.Velocity = HumanoidRootpart.CFrame.LookVector * 10
			BV2.MaxForce = Vector3.new(15000, 15000, 15000)
			BV2.Parent = HumanoidRootpart
			game.Debris:AddItem(BV2, 0.2)

			for _, v in pairs(BlockFX:GetChildren()) do
				local EmitCount = v:GetAttribute("EmitCount")
				if EmitCount then
					v:Emit(EmitCount)
				end
			end
			return
		end

		print(target)
		if target:FindFirstChild("Blocking") and DotProduct > 1 then
			target:FindFirstChild("BlockHealth").Value -= 25
			print(target:FindFirstChild("BlockHealth").Value)
			local BlockFX =
				Assets:WaitForChild("VFX"):WaitForChild("Combat"):WaitForChild("BlockFX"):WaitForChild("HitFX"):Clone()
			BlockFX.Parent = EhumRP
			game.Debris:AddItem(BlockFX, 2)

			local Sound = Assets:WaitForChild("Sounds").Sounds.Combat:WaitForChild("Blocked"):Clone()
			Sound.Parent = EhumRP
			Sound:Play()
			game.Debris:AddItem(Sound, 1)

			local DmgCounter = Assets:WaitForChild("VFX"):WaitForChild("Combat"):WaitForChild("DmgCounter"):Clone()
			DmgCounter.Parent = workspace
			DmgCounter.Position = EhumRP.Position
			DmgCounter.Counter.Number.Text = "Blocked"
			DmgCounter.Counter.Number.TextColor3 = Color3.fromRGB(199, 199, 199)
			DmgCounter.Counter.Number.TextStrokeColor3 = Color3.fromRGB(152, 152, 152)

			local goal = {}
			goal.TextColor3 = Color3.fromRGB(255, 255, 255)
			local info = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true, 0)
			local tween = game:GetService("TweenService"):Create(DmgCounter.Counter.Number, info, goal)
			tween:Play()

			game.Debris:AddItem(DmgCounter, 0.4)

			local P1 = EhumRP.Position
			local P2 = EhumRP.Position + Vector3.new(math.random(-3, 3), math.random(2, 10), math.random(-3, 3))
			local P3 = P2 + Vector3.new(0, -15, 0)

			task.spawn(function()
				for i = 0, 1, 0.045 do
					local newpos = Curve(i, P1, P2, P3)
					DmgCounter.Position = newpos
					task.wait()
				end
			end)

			local BV = Instance.new("BodyVelocity")
			BV.Velocity = HumanoidRootpart.CFrame.LookVector * 10
			BV.MaxForce = Vector3.new(15000, 15000, 15000)
			BV.Parent = EhumRP
			game.Debris:AddItem(BV, 0.2)

			local BV2 = Instance.new("BodyVelocity")
			BV2.Velocity = HumanoidRootpart.CFrame.LookVector * 10
			BV2.MaxForce = Vector3.new(15000, 15000, 15000)
			BV2.Parent = HumanoidRootpart
			game.Debris:AddItem(BV2, 0.2)

			for _, v in pairs(BlockFX:GetChildren()) do
				local EmitCount = v:GetAttribute("EmitCount")
				if EmitCount then
					v:Emit(EmitCount)
				end
			end
			return
		else
			local logiaCheck = damageModule.damageSNG(p, target, damage, { script.Name, skillName })
			if not logiaCheck then
				SharedFunctions:FireAllDistanceClients(
					c,
					script.Name,
					25,
					{ Target = target, Character = c, Function = "CombatHit" }
				)
				if knockback then
					if target:FindFirstChild("PseudoTorso") then
						tweenService
							:Create(
								target.PseudoTorso,
								TweenInfo.new(0.6),
								{ Position = (c.HumanoidRootPart.CFrame * CFrame.new(0, 0, -50)).Position }
							)
							:Play()
					end
					SharedFunctions:FireAllDistanceClients(
						c,
						script.Name,
						25,
						{ Target = target, Character = c, Function = "Knockback" }
					)
				end
			end
		end
	end

	states:SetAttribute("MeleeClicked", os.clock())
end

--/Events
attackRemote.OnServerEvent:connect(function(p, action, info)
	if module[action] then
		module[action](p, info)
	end
end)

return module
