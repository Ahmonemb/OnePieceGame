--/Services
wait(1)
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

--/Variables
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:wait()
local Humanoid = Character.Humanoid
local HUD = script.Parent

local Data = Character:FindFirstChild("Data")
local States = Character:FindFirstChild("States")

local OpenedMenu = false
local Connections = {}

local StatsRemote = game.ReplicatedStorage.Remotes.Misc.Stats


--/Health, Experience and Stamina
HUD.Health.Value.Text = string.format("HEALTH: %d/%d",Humanoid.Health,Humanoid.MaxHealth)
HUD.Health.Bar:TweenSize(UDim2.new((Humanoid.Health/Humanoid.MaxHealth),0,1,0),"Out","Quad",.6)
Humanoid.HealthChanged:Connect(function()
	HUD.Health.Value.Text = string.format("HEALTH: %d/%d",Humanoid.Health,Humanoid.MaxHealth)
	HUD.Health.Bar:TweenSize(UDim2.new((Humanoid.Health/Humanoid.MaxHealth),0,1,0),"Out","Quad",.6)
end)

HUD.Experience.Value.Text = string.format("EXPERIENCE: %d/%d",Data:GetAttribute("Experience"),Data:GetAttribute("MaxExperience"))
HUD.Experience.Bar:TweenSize(UDim2.new((Data:GetAttribute("Experience")/Data:GetAttribute("MaxExperience")),0,1,0),"Out","Quad",.6)
Data:GetAttributeChangedSignal("Experience"):Connect(function()
	HUD.Experience.Value.Text = string.format("EXPERIENCE: %d/%d",Data:GetAttribute("Experience"),Data:GetAttribute("MaxExperience"))
	wait(.1)
	HUD.Experience.Bar:TweenSize(UDim2.new((Data:GetAttribute("Experience")/Data:GetAttribute("MaxExperience")),0,1,0),"Out","Quad",.6)
end)

HUD.Stamina.Value.Text = string.format("STAMINA: %d/%d",States:GetAttribute("Stamina"),States:GetAttribute("MaxStamina"))
HUD.Stamina.Bar:TweenSize(UDim2.new((States:GetAttribute("Stamina")/States:GetAttribute("MaxStamina")),0,1,0),"Out","Quad",.6)
States:GetAttributeChangedSignal("Stamina"):Connect(function()
	HUD.Stamina.Value.Text = string.format("STAMINA: %d/%d",States:GetAttribute("Stamina"),States:GetAttribute("MaxStamina"))
	HUD.Stamina.Bar:TweenSize(UDim2.new((States:GetAttribute("Stamina")/States:GetAttribute("MaxStamina")),0,1,0),"Out","Quad",.6)
end)

--/Values
HUD.Level.Text = "Level "..Data:GetAttribute("Level")
Data:GetAttributeChangedSignal("Level"):Connect(function() HUD.Level.Text = "Level "..Data:GetAttribute("Level") end)

HUD.Beli.Text = "B$ "..Data:GetAttribute("Beli")
Data:GetAttributeChangedSignal("Beli"):Connect(function() HUD.Beli.Text = "B$ "..Data:GetAttribute("Beli") end)

--/Stats Frame
local StatsFrame = HUD.StatsFrame.Stats
for i,v in pairs(StatsFrame:GetChildren()) do
	if v:IsA("Frame") then
		v.Value.Text = Data:GetAttribute(v.Name)
		v.Add.MouseButton1Click:Connect(function()
			if Data:GetAttribute("StatPoints") > 0 then
				StatsRemote:FireServer("StatsAdd",v.Name)
				v.Value.Text = Data:GetAttribute(v.Name)
				StatsFrame.StatPoints.Text = "STAT POINTS: "..Data:GetAttribute("StatPoints")
			end
		end)
	elseif v.Name == "StatPoints" then 
		v.Text = "STAT POINTS: "..Data:GetAttribute(v.Name)
		Data:GetAttributeChangedSignal(v.Name):Connect(function()
			v.Text = "STAT POINTS: "..Data:GetAttribute(v.Name)
		end)
	end
end

--/Allies Frame
require(script.Allies)

--/Quest Frame
require(script.Quests)

--/Inventory Frame
require(script.Inventory)

--/Notificiation Frame
require(script.Notifications)

--/Buttons to Open Frames
HUD.Menu.Click.MouseButton1Click:Connect(function()
	if not OpenedMenu then
		OpenedMenu = true 
		HUD.Menu.Click.Text = "CLOSE"
		for i,v in pairs(HUD.Menu:GetChildren()) do 
			if v:IsA("Frame") then 
				v.Visible = true 
				Connections[v.Name] = v.Click.MouseButton1Click:Connect(function()
					local frame = HUD:FindFirstChild(v.Name.."Frame")
					if frame and frame.OpenedSize then
						if frame.Size.X.Scale <= 0 then
							local sizes = string.split(frame.OpenedSize.Value,",")
							frame.Visible = true
							frame:TweenSize(UDim2.new(tonumber(sizes[1]),tonumber(sizes[2]),tonumber(sizes[3]),tonumber(sizes[4])),"Out","Quad",.5)
						else
							frame:TweenSize(UDim2.new(0,0,0,0),"In","Quad",.5)
							coroutine.wrap(function() wait(.5) frame.Visible = false end)()
						end
					end
				end)
			end 
		end
	else
		OpenedMenu = false 
		HUD.Menu.Click.Text = "MENU"
		for i,v in pairs(HUD.Menu:GetChildren()) do
			if v:IsA("Frame") then
				v.Visible = false
				Connections[v.Name]:Disconnect()
			end
		end
	end
end)
