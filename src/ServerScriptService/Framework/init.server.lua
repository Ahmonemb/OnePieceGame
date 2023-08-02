--/Initializers
for _, v in pairs(script:GetDescendants()) do
	if v:IsA("ModuleScript") then
		require(v)
	end
end
