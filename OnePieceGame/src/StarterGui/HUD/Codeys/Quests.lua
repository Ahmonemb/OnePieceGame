--/Services
local Players = game:GetService("Players")

--/Modules
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)
local Conversations = require(game.ReplicatedStorage.Modules.Manager.Dialogue.Conversations)
local module = {}

--/Variables
local Remote = game.ReplicatedStorage.Remotes.Misc.Quest
local HUD = script.Parent.Parent

local QuestFrame = HUD.Quest

local Player = Players.LocalPlayer
local Data = Player.Character:WaitForChild("Data",5)

local Connections = {}

--/Load Quest 
function LoadQuest()
	local Value = Data:GetAttribute("QuestName")
	
	if Value ~= "" then 
		local QuestData = Conversations.GetConvo(Value)
		local QuestTarget = Data:GetAttribute("QuestTarget")

		QuestFrame.Visible = true 
		QuestFrame.Progress.Text = string.format("[%d/%d]",Data:GetAttribute("QuestProgress"),Data:GetAttribute("QuestMax"))
		QuestFrame.Beli.Text = string.format("B$ %d",QuestData.Details[QuestTarget].Rewards.Beli)
		QuestFrame.Experience.Text = string.format("%d Experience",QuestData.Details[QuestTarget].Rewards.Experience)
		QuestFrame.Description.Text = string.split(QuestData.Details[QuestTarget].Description,".")[1]:format(QuestData.Details[QuestTarget].Maximum)
		
		QuestFrame.Cancel.Click.MouseButton1Click:Connect(function()
			if Data:GetAttribute("QuestName") ~= "" then
				Remote:FireServer("CancelQuest")
				LoadQuest()
			end
		end)
	else
		QuestFrame.Visible = false
	end
end

local function UpdateQuest()
	local Quest = Data:GetAttribute("QuestName")
	local Progress = Data:GetAttribute("QuestProgress")
	local Max = Data:GetAttribute("QuestMax")
	
	if Quest == "" then return end
	if Progress < Max then 
		QuestFrame.Progress.Text = string.format("[%d/%d]",Progress,Max)
		if Progress == Max then 
			QuestFrame.Visible = false
		end
	end
	
end

LoadQuest()

--/Events\--
--/TODO: Changed Event to detect a new quest started
local NameConn; NameConn = Data:GetAttributeChangedSignal("QuestName"):Connect(function()
	if #HUD:GetChildren() <= 0 then NameConn:Disconnect() return end
	LoadQuest()
end)


--/TODO: Changed event to detect progress of quest changing
local ProgressConn; ProgressConn = Data:GetAttributeChangedSignal("QuestProgress"):Connect(function()
	if #HUD:GetChildren() <= 0 then ProgressConn:Disconnect() return end
	UpdateQuest()
end)

--/Events
local Conn; 
Conn = Remote.OnClientEvent:connect(function(action,...)
	if #HUD:GetChildren() <= 0 then Conn:Disconnect() return end
	if module[action] then
		module[action](...)
	end
end)

return module
