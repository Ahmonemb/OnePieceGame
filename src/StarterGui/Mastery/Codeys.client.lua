--/Services
task.wait()
local Players = game:GetService("Players")

--/Modules
local AttackData = require(game.ReplicatedStorage.Modules.Manager.AttackData)

--/Variables
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local HUD = script.Parent

local Positions = {
	0.87, --/1 Move
	0.79, --/2 Moves
	0.71, --/3 Moves
	0.635, --/4 Moves
	0.55, --/5 Moves
}

local Keys = { "Z", "X", "C", "V", "F" }

local Remote = game.ReplicatedStorage.Remotes.Misc.Mastery

local Conn
Conn = Remote.OnClientEvent:Connect(function(MasteryData, Action)
	if Character.Humanoid.Health <= 0 then
		Conn:Disconnect()
		return
	end
	if Action == "Load" then
		for i, v in pairs(MasteryData) do
			local SkillData = AttackData.getData(i)
			if SkillData then
				local MasteryCard = HUD.Template:Clone()
				MasteryCard.Name = i
				MasteryCard.Title.Text.Text = i

				--print(i,v,SkillData)
				MasteryCard.Mastery.Level.Text = string.format("MASTERY %d (MAX. %d)", v.Level, SkillData.MaxMastery)
				MasteryCard.Mastery.Experience.Text = string.format("%d/%d", v.Experience, v.MaxExperience)
				MasteryCard.Mastery.Bar.Size = UDim2.new((v.Experience / v.MaxExperience), 0, 1, 0)

				for i1, v1 in pairs(Keys) do
					for name, move in pairs(SkillData) do
						if name ~= "MaxMastery" and move.Key == v1 then
							--/Create a keybind in the card
							local MastMove = MasteryCard.Template:Clone()
							MastMove.Name = name
							MastMove:FindFirstChild("Name").Text = name
							MastMove.Visible = true
							MastMove.Mastery.Text = string.format("MAS. %s", move.Mastery)
							MastMove.Key.Text = move.Key
							MastMove.Parent = MasteryCard.List

							MasteryCard.OpenedPosition.Value = Positions[i1]
						end
					end
				end
				MasteryCard.Parent = HUD
			end
		end
	elseif Action == "Update" then
		for i, v in pairs(MasteryData) do
			local SkillData = AttackData.getData(i)
			local MasteryCard = HUD:FindFirstChild(i)

			MasteryCard.Mastery.Level.Text = string.format("MASTERY %d (MAX. %d)", v.Level, SkillData.MaxMastery)
			MasteryCard.Mastery.Experience.Text = string.format("%d/%d", v.Experience, v.MaxExperience)
			MasteryCard.Mastery.Bar:TweenSize(
				UDim2.new((v.Experience / v.MaxExperience), 0, 1, 0),
				"Out",
				"Linear",
				0.45
			)
		end
	end
end)
