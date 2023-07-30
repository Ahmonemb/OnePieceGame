local RS = game:GetService("ReplicatedStorage")
local RegionModule = require(RS:WaitForChild("Combat"):WaitForChild("RotatedRegion3"))
local Stuns = require(RS:WaitForChild("Combat"):WaitForChild("Stuns"))
local AttackEvent = RS:WaitForChild("Remotes").ServerCombat
local Assets = RS:WaitForChild("Assets")

local HitboxSettings = {}
HitboxSettings.__index = HitboxSettings

function HitboxSettings.new(plr,HitboxSize)
	local HS = {}
	setmetatable(HS,HitboxSettings)
	HS.Player = plr
	HS.Character = plr.Character or plr.CharacterAdded:Wait()
	HS.Humanoid = HS.Character:WaitForChild("Humanoid")
	HS.Combo = 0
	HS.MaxCombo = 5
	HS.Forward = true
	HS.HitWait = .2
	HS.HitDelay = .35
	HS.ResetTime = 2.5
	HS.PunchDebounce = false
	HS.LastCooldown = true
	HS.LastCooldownTime = 3
	HS.ScreenShake = true
	HS.HSize = HitboxSize
	HS.Damage = 5
	HS.Animation1 = nil
	HS.Animation2 = nil
	HS.Animation3 = nil
	HS.Animation4 = nil
	HS.Animation5 = nil
	HS.SpaceHold = false
	HS.AirCombo = false
	
	return HS
end

function HitboxSettings:Attack()

	if self.PunchDebounce == false then
	
	for i,v in pairs(Stuns) do
		if self.Character:FindFirstChild(v) then print(v) return end	
		end
		
		if self.Character:FindFirstChild("Blocking") then return end
		
		
		self.PunchDebounce = true
		if self.Combo ~= 4 then
			task.delay(self.HitDelay,function()
				self.PunchDebounce = false
			end)
		elseif self.Combo == 5 and self.LastCooldown == true then
			task.delay(self.LastCooldownTime,function()
				self.PunchDebounce = false
			end)
		end
		

		if not self.Character.HumanoidRootPart:FindFirstChild("SendUp") then
			self.Combo += 1
		end
		
		
		if self.Combo == 1 then
			AttackEvent:FireServer("Animation",self.Animation1)
		end
		
		if self.Combo == 2 then
			AttackEvent:FireServer("Animation",self.Animation2)
		end
		
		if self.Combo == 3 then
			AttackEvent:FireServer("Animation",self.Animation3)
		end
		
		if self.Combo == 4 then
			AttackEvent:FireServer("Animation",self.Animation4)
		end
		
		if self.Combo == 5 then
			AttackEvent:FireServer("Animation",self.Animation5)
			task.delay(self.HitWait,function()
				if self.AirCombo == true then
					AttackEvent:FireServer("Hitbox",nil,Assets.Animations.FightingStyles.Combat:WaitForChild("MidHit"),5,self.HSize,true,true)
					self.AirCombo = false
				else
					AttackEvent:FireServer("Hitbox",nil,Assets.Animations.FightingStyles.Combat:WaitForChild("MidHit"),5,self.HSize,true,false)
				end
				
				end)
		end

		task.delay(self.HitWait,function()
			if self.Combo == 1 then
				AttackEvent:FireServer("Hitbox",nil,Assets.Animations.FightingStyles.Combat:WaitForChild("MidHit"),5,self.HSize,false,false)
			elseif  self.Combo == 2 then
				AttackEvent:FireServer("Hitbox",nil,Assets.Animations.FightingStyles.Combat:WaitForChild("MidHit"),5,self.HSize,false,false)
			elseif  self.Combo == 3 then
				AttackEvent:FireServer("Hitbox",nil,Assets.Animations.FightingStyles.Combat:WaitForChild("LeftHit"),5,self.HSize,false,false)
			elseif  self.Combo == 4 then
				if self.SpaceHold == false then
					AttackEvent:FireServer("Hitbox",nil,Assets.Animations.FightingStyles.Combat:WaitForChild("RightHit"),5,self.HSize,false,false)
				elseif self.AirCombo == false and self.SpaceHold == true then
					AttackEvent:FireServer("Hitbox",nil,Assets.Animations.FightingStyles.Combat:WaitForChild("RightHit"),5,self.HSize,false,true)
					self.AirCombo = true
					self.Character.Cooldowns:SetAttribute("InAir", true)
					
					task.wait(0.37)
					self.Combo = 0
					self.PunchDebounce = false

					task.delay(4,function()
						self.AirCombo = false
						self.Character.Cooldowns:SetAttribute("InAir", false)
					end)
				else
					AttackEvent:FireServer("Hitbox",nil,Assets.Animations.FightingStyles.Combat:WaitForChild("RightHit"),5,self.HSize,false,false)
				end
			end
			
		end)

		local function reset()
			if self.Combo >= self.MaxCombo then
				self.Combo = 0
				task.delay(self.LastCooldownTime,function()
					self.PunchDebounce = false
				end)
			end
		end
		
		local function reset2()
			if self.Combo >= self.MaxCombo then
				self.Combo = 0
				task.delay(self.HitDelay,function()
					self.PunchDebounce = false
				end)
			end
		end
		
		local function reset3()
			local Combo = self.Combo
			task.delay(self.ResetTime,function()
				if Combo == self.Combo and not self.Character.HumanoidRootPart:FindFirstChild("HoldBP") then
					self.Combo = 0
				end
			end)
		end
		
		reset3()
		
		if self.LastCooldown == true then
			reset()
		else
			reset2()
		end
	end
end



return HitboxSettings
