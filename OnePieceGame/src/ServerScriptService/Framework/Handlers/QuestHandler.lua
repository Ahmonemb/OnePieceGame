--/Services
local Players = game:GetService("Players")

--/Modules
local module = {}
local Datastore = require(script.Parent.Parent.Systems.Datastore)
local Conversations = require(game.ReplicatedStorage.Modules.Manager.Dialogue.Conversations)

--/Variables
local Remote = game.ReplicatedStorage.Remotes.Misc.Quest

--/TODO: Starts a Quest 
function module.StartQuest(Player,NPCData,ChosenQuest)
	local Data = Player.Character:FindFirstChild("Data")
	if Data:GetAttribute("QuestName") ~= NPCData.Name and ChosenQuest then
		Data:SetAttribute("QuestTarget",ChosenQuest)
		Data:SetAttribute("QuestProgress",0)
		Data:SetAttribute("QuestMax",NPCData.Details[ChosenQuest].Maximum)
		Data:SetAttribute("QuestName",NPCData.Name)
	end
end

--/TODO: Checks for quest completion
local function CheckCompletion(Player)
	local Data = Player.Character:FindFirstChild("Data")
	
	if Data:GetAttribute("QuestProgress") >= Data:GetAttribute("QuestMax") then 
		--/Give rewards
		local Rewards = Conversations.GetConvo(Data:GetAttribute("QuestName")).Details[Data:GetAttribute("QuestTarget")].Rewards
		Data:SetAttribute("Beli",Data:GetAttribute("Beli")+Rewards.Beli)
		Data:SetAttribute("Experience",Data:GetAttribute("Experience")+Rewards.Experience)
		
		module.CancelQuest(Player)
	end
end

--/TODO: Increments progress 
function module.IncrementQuest(Player,Target)
	local Data = Player.Character:FindFirstChild("Data")
	local QuestTarget = Data:GetAttribute("QuestTarget") --string.split( Data:GetAttribute("QuestTarget"),"s")[1]
	local CurrProgress = Data:GetAttribute("QuestProgress")
	Target = string.split(Target.Name,"_")[1]
	
	--print(Target,QuestTarget,CurrProgress)
	if Data:GetAttribute("QuestName") == "" or QuestTarget ~= Target then return end 
	if CurrProgress < Data:GetAttribute("QuestMax") then 
		Data:SetAttribute("QuestProgress",CurrProgress+1)
	end
	CheckCompletion(Player)
end

--/TODO: Cancels an active quest 
function module.CancelQuest(Player)
	local Data = Player.Character:FindFirstChild("Data")
	if Data:GetAttribute("QuestName") ~= "" then 
		Data:SetAttribute("QuestName","")
		Data:SetAttribute("QuestProgress",0)
		Data:SetAttribute("QuestTarget","")
		Data:SetAttribute("QuestMax",0)
	end
end




Remote.OnServerEvent:connect(function(p,action,...)
	if module[action] then
		module[action](p,...)
	end
end)


return module
