local HitboxSettings = {}

function HitboxSettings.new(plr)
	local HS = {}
	HS.Player = plr
	HS.Character = plr.Character
	HS.HumRP = HS.Character:WaitForChild("HumanoidRootPart")
	HS.Combo = 1
	HS.DoingCombo = 0
	HS.MaxCombo = 5
	HS.Knockback1 = true
	HS.Knockback2 = true
	HS.HitWait = .2
	HS.Hitbox = Instance.new("Part",workspace)
	HS.Hitbox.Size = Vector3.new()
end




return HitboxSettings
