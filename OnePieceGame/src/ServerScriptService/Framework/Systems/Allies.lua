--/Services
local collectionService = game:GetService("CollectionService")

--/Modules
local module = {}

--/Variables
local Remote = game.ReplicatedStorage.Remotes.Misc.Allies
local Invites = {}


--/TODO: Inviting a Player
function module.InvitePlayer(Player,PlayerToInvite)
	if not Invites[Player.Name] then Invites[Player.Name] = {} end
	local Allies = Player.Allies:GetAttributes()
	
	PlayerToInvite = game.Players:FindFirstChild(PlayerToInvite)
	if PlayerToInvite and not Allies[PlayerToInvite.Name] and not table.find(Invites[Player.Name],PlayerToInvite) then	
		table.insert(Invites[Player.Name],PlayerToInvite)
		Remote:FireClient(PlayerToInvite,"RequestDecision",Player)		
	end
end

--/TODO: Decision Making
function module.DecisionMade(InvitedPlayer,Decision,Player)
	
	if Decision == "Accept" then
		
		Player.Allies:SetAttribute(InvitedPlayer.Name,true)
		InvitedPlayer.Allies:SetAttribute(Player.Name,true)
		
		Remote:FireClient(InvitedPlayer,"AddNewAlly",Player)
		Remote:FireClient(Player,"AddNewAlly",InvitedPlayer)
	end
	
	local InviteePosition = table.find(Invites[Player.Name],InvitedPlayer)
	if InviteePosition then
		table.remove(Invites[Player.Name],InviteePosition)
	end
end

--/TODO: Removing an Ally
function module.RemoveAlly(Player,AllyToRemove)
	Player.Allies:SetAttribute(AllyToRemove.Name,nil)
	AllyToRemove.Allies:SetAttribute(Player.Name,nil)
	
	Remote:FireClient(AllyToRemove,"RemoveAlly",Player)
end

--/Events
Remote.OnServerEvent:connect(function(p,action,...)
	if module[action] then
		module[action](p,...)
	end
end)


return module
