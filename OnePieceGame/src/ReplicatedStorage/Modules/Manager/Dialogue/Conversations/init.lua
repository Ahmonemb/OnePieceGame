local module = {}
local NPCData = {}

for i,v in pairs(script:GetChildren()) do
	NPCData[v.Name] = require(v)
end

function module.GetConvo(Name)
	return NPCData[Name] or warn("Couldn't find "..Name)
end

return module
