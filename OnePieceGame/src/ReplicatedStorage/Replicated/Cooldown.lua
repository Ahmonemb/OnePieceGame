local Cooldown = {}

local Cooldowns = {}

function Cooldown:AddCooldown(Name, Length, Player)
	Cooldowns[Name] = {Active = true}
	if not Cooldowns[Name]["Time"] then
		Cooldowns[Name]["Time"] = 0
	end
	Cooldowns[Name]["Time"] += 1
	
	local Ver = Cooldowns[Name]["Time"]
	task.delay(Length, function()
		if Cooldowns[Name] and Cooldowns[Name]["Time"] == Ver then
			Cooldowns[Name] = nil
		end
	end)
end

function Cooldown:CheckCooldown(Name, Player)
	if Cooldowns[Name] then
		return true
	else
		return false
	end
end

return Cooldown
