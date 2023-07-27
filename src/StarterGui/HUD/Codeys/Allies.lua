--/Services
local Players = game:GetService("Players")

--/Modules
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)
local module = {}

--/Variables
local Remote = game.ReplicatedStorage.Remotes.Misc.Allies
local HUD = script.Parent.Parent

local Player = Players.LocalPlayer


--/TODO: Invite players
local function InvitePlayer(PlayerToInvite)
	Remote:FireServer("InvitePlayer",PlayerToInvite)
end

local function LoadAllies()
	for i,v in ipairs(Player.Allies:GetAttributes()) do
		local Ally = Players:FindFirstChild(i)
		if Ally then 
			module.AddNewAlly(Ally)
		end
	end
end

--/TODO: Accept/Reject Requests
function module.RequestDecision(PlayerRequesting)
	local Requests = HUD.AlliesFrame.Requests.List
	
	local NewRequest = HUD.AlliesFrame.Requests.RequestTemplate:Clone()
	NewRequest:FindFirstChild("Name").Text = PlayerRequesting.Name
	NewRequest.Visible = true
	NewRequest.Parent = Requests
	
	NewRequest.Accept.MouseButton1Click:Connect(function()
		Remote:FireServer("DecisionMade","Accept",PlayerRequesting)
		NewRequest:Destroy()
	end)
	
	NewRequest.Decline.MouseButton1Click:Connect(function()
		Remote:FireServer("DecisionMade","Decline",PlayerRequesting)
		NewRequest:Destroy()
	end)
end


--/TODO: Update Allies
function module.AddNewAlly(NewAlly)
	local Allies = HUD.AlliesFrame.Allies.List
	
	local NewAllied = HUD.AlliesFrame.Allies.AlliedTemplate:Clone()
	NewAllied:FindFirstChild("Name").Text = NewAlly.Name
	NewAllied.Name = NewAlly.Name
	NewAllied.Visible = true
	NewAllied.Parent = Allies	
	
	NewAllied.RemoveAlly.MouseButton1Click:Connect(function()
		Remote:FireServer("RemoveAlly",NewAlly)
		NewAllied:Destroy()
	end)
end

function module.RemoveAlly(AllyToRemove)
	local Ally = HUD.AlliesFrame.Allies.List:FindFirstChild(AllyToRemove.Name)
	Ally:Destroy()
end

--/Invite Input
local Invite = HUD.AlliesFrame.Invite
Invite.Input.FocusLost:Connect(function()
	if Players:FindFirstChild(Invite.Input.Text) then
		InvitePlayer(Invite.Input.Text)
	end
end)

LoadAllies()
--/Events
local Conn; 
Conn = Remote.OnClientEvent:connect(function(action,...)
	if #HUD:GetChildren() <= 0 then Conn:Disconnect() return end
	if module[action] then
		module[action](...)
	end
end)


return module
