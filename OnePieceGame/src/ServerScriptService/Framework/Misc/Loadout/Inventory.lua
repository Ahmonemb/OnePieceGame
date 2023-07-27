--/Services
local collectionService = game:GetService("CollectionService")

--/Modules
local module = {}
local Datastore = require(script.Parent.Parent.Parent.Systems.Datastore)

--/Variables
local Remote = game.ReplicatedStorage.Remotes.Misc.Inventory
local Tools = game.ServerStorage.Tools


--/TODO: Add to inventory
function module.AddItem()
	
end

--/TODO: Update player tool inventory
local function UpdateTools(Player,NewTool,Inventory)
	local Data = Player.Character.Data
	
	if Tools:FindFirstChild(NewTool) and Data:GetAttribute("EquippedWeapon") ~= "" then 
		local CurrentWeapon = Data:GetAttribute("EquippedWeapon")
		local ToolCheck = Player.Character:FindFirstChild(CurrentWeapon) or Player.Backpack:FindFirstChild(CurrentWeapon)
		if ToolCheck then 
			table.insert(Inventory,CurrentWeapon)
			ToolCheck:Destroy()
		end
	end
	
	NewTool = Tools:FindFirstChild(NewTool):Clone()
	NewTool.Parent = Player.Backpack
end

--/TODO: Equip item from inventory 
function module.EquipItem(Player,Item)
	local Inventory =  Datastore.GetData(Player,"Inventory")
	local Data = Player.Character.Data
	
	if Tools:FindFirstChild(Item) and table.find(Inventory,Item) then
		for i,v in pairs(Inventory) do 
			if v == Item then 
				table.remove(Inventory,i)
			end
		end
		
		UpdateTools(Player,Item,Inventory)
		Data:SetAttribute("EquippedWeapon",Item)
		
		Remote:FireClient(Player,"UpdateInventory",Inventory)
	end
end

--/TODO: Load Items
function module.LoadItem(Player)
	wait(1)
	
	local Data = Player.Character.Data
	local CurrWeapon = Data:GetAttribute("EquippedWeapon")
	if CurrWeapon ~= "" then 
		local Tool = Tools:FindFirstChild(CurrWeapon):Clone()
		Tool.Parent = Player.Backpack
	end
	
	Remote:FireClient(Player,"LoadInventory",Datastore.GetData(Player,"Inventory"))
end


Remote.OnServerEvent:Connect(function(p,action,...)
	if module[action] then
		module[action](p,...)
	end
end)

return module
