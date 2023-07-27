--/Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

--/Modules
local RichText = require(script.RichText)
local Conversations = require(script.Conversations)
local module = {}

--/Variables
local Player = Players.LocalPlayer
local Data = Player.Character:WaitForChild("Data",5)

local Remote = game.ReplicatedStorage.Remotes.Misc.Dialogue
local QuestRemote = game.ReplicatedStorage.Remotes.Misc.Quest
local PurchaseRemote = game.ReplicatedStorage.Remotes.Misc.PurchaseItem
local SetSpawn = game.ReplicatedStorage.Remotes.Misc.SetSpawn
local BoatSpawn = game.ReplicatedStorage.Remotes.Functions.BoatSpawn

local ChosenQuest

local HUD = Player.PlayerGui:FindFirstChild("HUD")
local Dialogue = Player.PlayerGui:FindFirstChild("Dialogue")

local Connections = {}

--/FruitShop Frame
require(Dialogue.Codeys.FruitShop)


--/Methods
--/TODO: Open/Close the frame
function FrameMovement(Info,Open,DontDisable)
	HUD = Player.PlayerGui:FindFirstChild("HUD")
	Dialogue = Player.PlayerGui:FindFirstChild("Dialogue")
	if Open then
		HUD.Enabled = false 
		Dialogue.Enabled = true 

		Dialogue.Frame:TweenPosition(UDim2.new(Dialogue.Frame.Position.X.Scale,0,Dialogue.Frame.OpenedPosition.Value,0), "Out", "Quad", .5)
		Dialogue.Frame.Title.Text.Text = Info.Name 
		
		wait(.5)
	else
		Dialogue.Frame:TweenPosition(UDim2.new(Dialogue.Frame.Position.X.Scale,0,1.3,0), "In", "Quad", .5)
		wait(.5)
		
		
		
		for i,v in pairs(Dialogue.Frame.Text:GetChildren()) do
			if v:IsA("Frame") then 
				v:Destroy()
			end
		end
		
		if DontDisable then return end
		HUD.Enabled = true 
		Dialogue.Enabled = false 
	end
end

--/TODO: Load Available Options
function LoadOptions(Frame,Details)
	local OptionList = Frame.Options
	local Options = {}
	
	if typeof(Details) == "table" then
		for k = 1,5 do
			for i,v in pairs(Details) do 
				if v.Order == k then
					local Option = Frame.OptionTemplate:Clone()
					Option.Click.Text = i
					Option.Name = i
					Option.Visible = true
					Option.Parent = OptionList
					Option:TweenSize(UDim2.new(1,0,Option.Size.Y.Scale,0),"Out","Quad",.3)

					Options[k] = Option
				end
			end
		end
		--return Options
	else
		if Details == true then 
			Options = {"Accept","Decline"}
		elseif Details == false then 
			Options = {"Buy","..."}
		else
			Options = {"..."}
		end
		for i = 1,#Options do 
			local Option = Frame.OptionTemplate:Clone()
			Option.Click.Text = Options[i]
			Option.Name = Options[i]
			Option.Visible = true
			Option.Parent = OptionList
			Option:TweenSize(UDim2.new(1,0,Option.Size.Y.Scale,0),"Out","Quad",.3)
			
			Options[i] = Option
		end
	end
	return Options
end

--/TODO: Remove Options 
function RemoveOptions(Frame)
	local OptionList = Frame.Options
	
	coroutine.wrap(function()
		for i,v in pairs(OptionList:GetChildren()) do
			if v:IsA("Frame") then
				v:TweenSize(UDim2.new(0,0,v.Size.Y.Scale,0),"In","Quad",.45)
				coroutine.wrap(function() wait(.45) v:Destroy() end)()
				wait()
			end
		end
	end)()
end

--/TODO: Makes for the speaking part
function Speaking(Frame,Sentence)
	
	local dialogue
	dialogue = RichText:New(Frame.Text,Sentence)
	dialogue:Animate(true)
	return dialogue
end

--/TODO: Main Function
function module.StartDialogue(NPC)
	local Name = NPC.Name
	local Info = Conversations.GetConvo(Name)
	if not Info then return end
	
	FrameMovement(Info,true)
	
	
	--/Starting Convo
	local Frame = Dialogue.Frame
	local IntroConvo,Delay 
	
	if Info.Type == "Quest" then
		IntroConvo = "Select a quest."
		Delay = .2
		
		if Data:GetAttribute("QuestName") ~= "" then 
			Speaking(Frame,"You already have an active quest, finish that first.")
			wait(.25)
			local Options = LoadOptions(Frame)
			local conn;
			conn = Options[1].Click.MouseButton1Click:Connect(function()
				conn:Disconnect()
				RemoveOptions(Frame)
				wait(.2)
				FrameMovement(Info,false)
			end)
			return
		end
	elseif Info.Type == "Shop" then IntroConvo = "Select a Weapon"
	elseif Info.Type == "BoatDealer" then
		IntroConvo = "Do you want to take a look at my boats?"
	elseif Info.Type == "SpawnSet" then
		IntroConvo = string.format("Do you want to set your spawn at <Font=GothamBold>%s Island?<Font=/>",NPC:GetAttribute("Island"))
	end
	
	Speaking(Frame,IntroConvo)
	wait(Delay)
	
	if Info.Type == "Quest" then
		local Quests = Info.Details
		local Options = LoadOptions(Frame,Quests)
		
		local function Decisions()
			Options = LoadOptions(Frame,true)
			for i,v in pairs(Options) do 
				Connections[v.Name] = v.Click.MouseButton1Click:Connect(function()
					for _,conn in pairs(Connections) do conn:Disconnect() end
					RemoveOptions(Frame)
					
					if v.Name == "Accept" then
						Speaking(Frame,"Good luck.")
						QuestRemote:FireServer("StartQuest",Info,ChosenQuest)
					else
						Speaking(Frame,"Come back next time.")
					end
					wait(.45)
					FrameMovement(Info,false)
				end)
			end
		end
		
		for i,v in pairs(Options) do
			local Quest = Quests[v.Name]
			Connections[v.Name] = v.Click.MouseButton1Click:Connect(function()
				for _,conn in pairs(Connections) do conn:Disconnect() end
				RemoveOptions(Frame,false)
				ChosenQuest = v.Name
				
				Speaking(Frame,Quest.Description:format(Quest.Maximum,Quest.Requirement,Quest.Rewards.Beli,Quest.Rewards.Experience))
				wait(Delay)
				
				Decisions()
				
			end)
		end
	elseif Info.Type == "Shop" then 
		local Weapons = Info.Details 
		local Options = LoadOptions(Frame,Weapons) 
		
		local function Decisions(Item)
			Options = LoadOptions(Frame,false)
			for i,v in pairs(Options) do 
				Connections[v.Name] = v.Click.MouseButton1Click:Connect(function()
					for _,conn in pairs(Connections) do conn:Disconnect() end
					RemoveOptions(Frame)

					if v.Name == "Buy" then
						--/Check if successfully bought
						local Success = PurchaseRemote:InvokeServer(Info.Name,Item)
						if Success then 
							Speaking(Frame,"Thanks for buying!")
						elseif Success == false then 
							Speaking(Frame,"You lack sufficient funds.")
						else
							Speaking(Frame,"You already own this item.")
						end
					else
						Speaking(Frame,"Come back next time.")
					end
					wait(.45)
					FrameMovement(Info,false)
				end)
			end
		end
		
		for i,v in pairs(Options) do
			local Weapon = Weapons[v.Name]
			Connections[v.Name] = v.Click.MouseButton1Click:Connect(function()
				for _,conn in pairs(Connections) do conn:Disconnect() end
				RemoveOptions(Frame)
				ChosenQuest = v.Name

				Speaking(Frame,Weapon.Description:format(Weapon.Price))
				wait(Delay)

				Decisions(v.Name)
			end)
		end
	elseif Info.Type == "SpawnSet" then
		local Options = LoadOptions(Frame,{
			["Yes"] = {Order = 1},
			["No"] = {Order = 2},
		}) 

		local function Decisions()
			for i,v in pairs(Options) do 
				Connections[v.Name] = v.Click.MouseButton1Click:Connect(function()
					for _,conn in pairs(Connections) do conn:Disconnect() end
					RemoveOptions(Frame)
					local Item = v.Name

					if v.Name == "Yes" then
						--/Check if successfully bought
						SetSpawn:FireServer(NPC:GetAttribute("Island"))
						Speaking(Frame,"You will now spawn here.")
					else
						Speaking(Frame,"...")
					end
					wait(.45)
					FrameMovement(Info,false)
				end)
			end
		end

		Decisions()
	elseif Info.Type == "BoatDealer" then 
		local Boats = Info.Details 
		local Options = LoadOptions(Frame,Boats) 

		local function Decisions(Item)
			Options = LoadOptions(Frame,false)
			for i,v in pairs(Options) do 
				Connections[v.Name] = v.Click.MouseButton1Click:Connect(function()
					for _,conn in pairs(Connections) do conn:Disconnect() end
					RemoveOptions(Frame)

					if v.Name == "Buy" then
						--/Check if successfully bought
						local Success = BoatSpawn:InvokeServer(Item,NPC)
						if Success then 
							Speaking(Frame,"Your boat has been spawned.")
						else
							Speaking(Frame,"You lack sufficient funds.")
						end
					else
						Speaking(Frame,"Come back next time.")
					end
					wait(.45)
					FrameMovement(Info,false)
				end)
			end
		end

		for i,v in pairs(Options) do
			local Boat = Boats[v.Name]
			Connections[v.Name] = v.Click.MouseButton1Click:Connect(function()
				for _,conn in pairs(Connections) do conn:Disconnect() end
				RemoveOptions(Frame)

				if v.Name ~= "Return" then
					ChosenQuest = v.Name

					Speaking(Frame,string.format("This will cost B$ %d, will you buy it?",Boat.Price))
					wait(Delay)

					Decisions(v.Name)
				else
					wait(.45)
					FrameMovement(Info,false)
				end
			end)
		end
	end
	
	
	
end


--/Events
Remote.OnClientEvent:connect(function(action,...)
	if module[action] then
		module[action](...)
	end
end)

return module
