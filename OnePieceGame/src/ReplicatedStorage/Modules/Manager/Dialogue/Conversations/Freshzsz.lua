return {
	Name = script.Name,
	Title = "Defeat the Bandits",
	Color = Color3.fromRGB(255, 255, 127),
	Icon = "?",
	Type = "Quest",
	QuestType = "Repeat",
	Details = {
		["Bandit"] = {
			Rewards = {Beli = 50, Experience = 1000},
			Maximum = 5,
			Requirement = 1,
			Description = [[
				Defeat %d Bandits for Freshzsz.
				Level %d Required.
				<Font=GothamSemibold>REWARDS.<Font=/>
				<Font=Gotham><Color=NiceGreen>B$ %d.<Color=/><Font=/><Font=Gotham>
				<Color=PastelYellow>%d Exp.<Color=/><Font=/>
			]],
			Order = 1
		};
		
		["Bandit Boss"] = {
			Rewards = {Beli = 500, Experience = 1850},
			Maximum = 1,
			Requirement = 15,
			Description = [[
				Defeat %d Bandit Boss for Freshzsz.
				Level %d Required.
				<Font=GothamSemibold>REWARDS.<Font=/>
				<Font=Gotham><Color=NiceGreen>B$ %d.<Color=/><Font=/><Font=Gotham>
				<Color=PastelYellow>%d Exp.<Color=/><Font=/>
			]],
			Order = 2
		};
	}
}