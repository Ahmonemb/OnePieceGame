--/Initializers
for i,v in pairs(script:GetDescendants()) do
	if v:IsA("ModuleScript") then
		require(v)
	end
end