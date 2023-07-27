return {
	Name = script.Name,
	Title = "Weapon Shop",
	Type = "Shop",
	Icon = "B$",
	Color = Color3.fromRGB(85, 255, 127),
	Details = {
		["Katana"] = {
			Price = 150,
			Description = [[
				The <Font=GothamSemibold>Katana<Font=/> used by wunbo san when he was born..
				
				
				<Font=Gotham><Color=NiceGreen>B$ %d.<Color=/><Font=/><Font=Gotham>
			]],
			Order = 1
		}; 
		
		["Flintlock"] = {
			Price = 500,
			Description = [[
				The <Font=GothamSemibold>Flintlock<Font=/> is a weak gun used by weaklings..
				
				
				<Font=Gotham><Color=NiceGreen>B$ %d.<Color=/><Font=/><Font=Gotham>
			]],
			Order = 2
		};
	}
}