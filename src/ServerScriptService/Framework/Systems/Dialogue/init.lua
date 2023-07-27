--/Services
local collectionService = game:GetService("CollectionService")

--/Modules
local module = {}
local Datastore = require(script.Parent.Parent.Systems.Datastore)
local Conversations = require(game.ReplicatedStorage.Modules.Manager.Dialogue.Conversations)
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)

--/Remotes
local Remote = game.ReplicatedStorage.Remotes.Misc.Dialogue
local PurchaseItem = game.ReplicatedStorage.Remotes.Misc.PurchaseItem
local SpawnSet = game.ReplicatedStorage.Remotes.Misc.SetSpawn

--/Variables 
local FruitRates = require(script.DFRates)

--/TODO: Click Detection
function Clickers()
	for i,v in pairs(workspace.World.NPCs:GetChildren()) do
		local NPCData = Conversations.GetConvo(v.Name)
		if NPCData then 
			local header = script.header:Clone()
			header.name.Text = v.Name
			header.title.Text = NPCData.Title
			header.title.TextColor3 = NPCData.Color
			header.icon.TextColor3 = NPCData.Color
			header.icon.Text = NPCData.Icon
			header.Parent = v.Head

			for _,Island in pairs(workspace.World.Map:GetChildren()) do
				if Island:FindFirstChild("IslandCenter") then Island.IslandCenter.Transparency = 1
					if (Island.IslandCenter.Position-v.HumanoidRootPart.Position).magnitude <= 100 then 
						v:SetAttribute("Island",Island.Name)
					end
				end
			end

			local animationTrack = game.ReplicatedStorage.Assets.Animations.Idle
			v.Humanoid:LoadAnimation(animationTrack):Play()

			local clicky = script.ClickDetector:Clone()
			clicky.Parent = v 

			clicky.MouseClick:Connect(function(Player)
				Remote:FireClient(Player,"StartDialogue",v)
			end)
		end
	end
end

--/TODO: Option Selection
function module.OptionChosen()
	
end


Clickers()


--/Events
SpawnSet.OnServerEvent:Connect(function(Player,Island)
	local Data = Player.Character.Data
	Data:SetAttribute("SpawnIsland",Island)
	G.Notify(Player,string.format("Spawn set to <b>%s Island!</b>",Island))
end)

Remote.OnServerEvent:connect(function(p,action,...)
	if module[action] then
		module[action](p,...)
	end
end)

local function BuyItem(Player,Price,Item)
	local Data = Player.Character.Data
	local Inventory = Datastore.GetData(Player,"Inventory")
	
	Data:SetAttribute("Beli",Data:GetAttribute("Beli")-Price)
	
	table.insert(Inventory,Item)
	Datastore.SetData(Player,"Inventory",Inventory)
end

PurchaseItem.OnServerInvoke = function(Player,Salesman,Item,Type)
	if not Player then return end
	local Inventory = Datastore.GetData(Player,"Inventory")
	local Beli = Player.Character.Data:GetAttribute("Beli")
	local DealerIncrement = 500
	print(Inventory)
	if table.find(Inventory,Item) then return nil end 

	local ItemData = Conversations.GetConvo(Salesman).Details
	if ItemData then 
		ItemData = ItemData[Item]
		if Beli >= ItemData.Price then
			BuyItem(Player,ItemData.Price,Item)
			G.Notify(Player,string.format("<b>Bought %s for <font color = 'rgb(0,255,127)'>$%d</font></b>",Item,ItemData.Price),3.5)
			return true
		else
			return false
		end		
	end
end


return module
