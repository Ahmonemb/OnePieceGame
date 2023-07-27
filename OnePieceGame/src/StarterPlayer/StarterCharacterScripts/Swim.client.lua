local Character = script.Parent
local WaterLevel = -3

local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)
local IsSwimming = false 
local TriedJumping = false

local BP = Instance.new("BodyPosition")
BP.MaxForce = Vector3.new(0,1,0)*1e6 

game:GetService("UserInputService").InputBegan:Connect(function(Input,Typing)
	if Typing or TriedJumping or not IsSwimming then return end
	if Input.KeyCode == Enum.KeyCode.Space then
		TriedJumping = true 
		BP.Position += Vector3.new(0,15,0)
		wait(.38)
		TriedJumping = false
	end
end)

while Character.Humanoid.Health > 0 do 
	if not TriedJumping then
		if Character.HumanoidRootPart.Position.Y <= WaterLevel then
			BP.Position = Vector3.new(Character.HumanoidRootPart.Position.X,WaterLevel,Character.HumanoidRootPart.Position.Z)
			BP.Parent = Character.HumanoidRootPart
			if not IsSwimming then 
				IsSwimming = true 
				G.playAnim(Character.Humanoid,"Misc","Swimming")
			end
		else
			BP.Parent = nil
			if IsSwimming then 
				IsSwimming = false 
				G.stopAnim(Character.Humanoid,"Swimming")
			end
		end
	end
	wait()
end