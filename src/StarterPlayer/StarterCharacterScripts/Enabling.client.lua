local player = game.Players.LocalPlayer
local Char = player.Character
local BP = player.Backpack

for i,v in pairs(BP:GetDescendants()) do
	if v:IsA("BaseScript") then
		v.Disabled = false
	end
end
