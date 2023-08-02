local player = game.Players.LocalPlayer
local BP = player.Backpack

for _, v in pairs(BP:GetDescendants()) do
	if v:IsA("BaseScript") then
		v.Disabled = false
	end
end
