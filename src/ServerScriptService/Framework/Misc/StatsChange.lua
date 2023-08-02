--/Services

--/Modules
local module = {}

--/Variables
local Remote = game.ReplicatedStorage.Remotes.Misc.Stats

--/TODO: Add Stats
function module.StatsAdd(p, Name)
	local Data = p.Character:FindFirstChild("Data")
	if Data and Data:GetAttribute(Name) and Data:GetAttribute("StatPoints") > 0 then
		Data:SetAttribute(Name, Data:GetAttribute(Name) + 1)
		Data:SetAttribute("StatPoints", Data:GetAttribute("StatPoints") - 1)
	end
end

--/TODO: Reset Stats
-- function module.ResetStats()
-- 	local message = "<b>Bought %s for <font color = 'rgb(0,255,127)'>$%d</font></b>"
-- end

--/Events
Remote.OnServerEvent:connect(function(p, action, info)
	if module[action] then
		module[action](p, info)
	end
end)

return module
