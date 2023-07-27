--/Services
local Players = game:GetService("Players")

--/Modules
local G = require(game.ReplicatedStorage.Modules.GlobalFunctions)
local module = {}

--/Variables
local Remote = game.ReplicatedStorage.Remotes.Misc.Inventory
local HUD = script.Parent.Parent

local Player = Players.LocalPlayer
local Data = Player.Character.Data
local Connections = {}


--/TODO: Loads Inventory when player spawns
function module.LoadInventory(Inventory)
	local InventoryFrame = HUD:FindFirstChild("InventoryFrame")
	local Template = InventoryFrame.ItemTemplate
	local Items = InventoryFrame.Items
	
	for i,v in pairs(Inventory) do
		local Item = Template:Clone()
		Item.Click.Text = v 
		Item.Visible = true 
		Item.Name = v 
		Item.Parent = Items
		
		Item.Click.MouseButton1Click:Connect(function()
			Remote:FireServer("EquipItem",v)
		end)
	end
end

--/Adds and Removes specific items
function module.UpdateInventory(Inventory)
	local InventoryFrame = HUD:FindFirstChild("InventoryFrame")
	local Template = InventoryFrame.ItemTemplate
	local Items = InventoryFrame.Items
	
	local Item = Items:FindFirstChild(Data:GetAttribute("EquippedWeapon"))
	if Item then Item:Destroy() end
	
	for i,v in pairs(Inventory) do
		local NewItem = Items:FindFirstChild(v)
		if not NewItem then 
			NewItem = Template:Clone()
			NewItem.Click.Text = v 
			NewItem.Visible = true 
			NewItem.Name = v 
			NewItem.Parent = Items

			NewItem.Click.MouseButton1Click:Connect(function()
				Remote:FireServer("EquipItem",v)
			end)
		end
	end
end

--/Events
local Conn; 
Conn = Remote.OnClientEvent:connect(function(action,...)
	if #HUD:GetChildren() <= 0 then Conn:Disconnect() return end
	if module[action] then
		module[action](...)
	end
end)


return module
