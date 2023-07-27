--/Services

--/Modules
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)
local attackData = require(game.ReplicatedStorage.Modules.Manager.AttackData)
local module = {}

--/Variables

--/Methods
function module.addCooldown(c,moduleName,skill,time)
	local cooldownData = attackData.getData(moduleName,skill)
	if cooldownData then
		c.Cooldowns:SetAttribute(skill,true)
		coroutine.wrap(function()
			wait(time or cooldownData.cooldown)
			c.Cooldowns:SetAttribute(skill,nil)
		end)()
	else 
		if not skill then return end
		c.Cooldowns:SetAttribute(skill,true)
		coroutine.wrap(function()
			wait(time)
			c.Cooldowns:SetAttribute(skill,nil)
		end)()
	end
end

return module
