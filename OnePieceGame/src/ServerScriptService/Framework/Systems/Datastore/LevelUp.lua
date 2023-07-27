local module = {}


local function LevelUp(Player)
	local Character = Player.Character
	local Data = Character.Data
	local ExperienceProgression = 50
	
	--/Experience Given	
	local Max = Data:GetAttribute("MaxExperience")
	local Exp = Data:GetAttribute("Experience")
	
	while (Exp >= Max) do 
		local Diff = Exp-Max
		Data:SetAttribute("Level",Data:GetAttribute("Level")+1) 
		Data:SetAttribute("StatPoints",Data:GetAttribute("StatPoints")+3)
		
		Exp = Diff
		Max += ExperienceProgression
	end
	
	
	--[[
	Data:SetAttribute("Level",Data:GetAttribute("Level")+1) 
	Data:SetAttribute("MaxExperience",Data:GetAttribute("MaxExperience")+ExperienceProgression)
	Data:SetAttribute("StatPoints",Data:GetAttribute("StatPoints")+3)
	]]
	Data:SetAttribute("MaxExperience",Max)
	wait()
	Data:SetAttribute("Experience",Exp)
	
end

function module.Check(Player)
	local Character = Player.Character
	local Data = Character.Data
	if Data:GetAttribute("Experience") >= Data:GetAttribute("MaxExperience") then 
		LevelUp(Player)
		
		--/Visual Effect
		for i,v in pairs(game.ReplicatedStorage.Assets.VFX.Misc.levelUp:Clone():GetChildren()) do
			if not Character.HumanoidRootPart:FindFirstChildOfClass("Attachment"):FindFirstChild(v.Name) then
				v.Parent = Character.HumanoidRootPart:FindFirstChildOfClass("Attachment")
				if v.Name == "longerRays" then
					v:Emit(4)
				else
					v:Emit(1)
				end
				game.Debris:AddItem(v,2)
			end
		end
		
	end
end


return module