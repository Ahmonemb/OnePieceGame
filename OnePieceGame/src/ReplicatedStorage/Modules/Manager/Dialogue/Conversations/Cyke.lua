return {
	Name = script.Name,
	Title = "Boat Dealer",
	Icon = "$$$",
	Color = Color3.fromRGB(83, 255, 109),
	Type = "BoatDealer",
	Details = {
		["Rowboat"] = {
			Price = 500,
			MaxSpeed = 20,
			Acceleration = .25,
			Coordinate = CFrame.new(0,0,15)*CFrame.Angles(0,math.rad(90),0),
			TurnSpeed = .01,
			Order = 1
		}; 
		["Caravel"] = {
			Price = 1500,
			MaxSpeed = 45,
			Acceleration = .4,
			Coordinate = CFrame.new(0,0,30)*CFrame.Angles(0,math.rad(180),0),
			TurnSpeed = .02,
			Order = 2
		}; 
		["Return"] = {
			Price = 0,
			Order = 3
		}
	}
}