--/Modules
local G = require(script.Parent.Parent.GlobalFunctions)
local module = {}

--/Variables
local dataList = {}
for i,v in pairs(script:GetDescendants()) do
	if v:IsA("ModuleScript") then
		dataList[v.Name] = require(v)
	end
end

--/Methods
function module.getData(moduleName,skillName)
	if not dataList[moduleName] then return nil end
	
	local data = dataList[moduleName][skillName]
	return data or dataList[moduleName]
end
return module
