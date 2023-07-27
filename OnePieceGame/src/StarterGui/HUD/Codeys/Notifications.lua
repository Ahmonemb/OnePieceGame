--/Notification
local UI = script.Parent.Parent
local tweenService = game:GetService("TweenService")
local debris = require(game.ReplicatedStorage.Modules.Misc.Debris)
local defaultTween = TweenInfo.new(.35,Enum.EasingStyle.Quad,Enum.EasingDirection.In)

local function update()
	if UI:FindFirstChild("Notifications") then
		for i,v in pairs(UI.Notifications:GetChildren()) do
			if not v:FindFirstChild("cancel") then
				local i = i-1
				local pos = v.Size.Y.Scale*i

				local tween = tweenService:Create(v,defaultTween,{Position = UDim2.new(.3,0,pos,0)})
				tween:Play()
				tween:Destroy()
			end
		end
	end
end
update()
local Conn; Conn = UI.Notifications.ChildAdded:connect(function(child)
	if #UI:GetChildren() <= 0 then Conn:Disconnect() return end
	update()
	if child:IsA("TextLabel") then
		local duration = (child:FindFirstChild("duration") ~= nil and child:FindFirstChild("duration").Value or 3) 
		coroutine.wrap(function()
			wait(duration-.6)

			local cancel = Instance.new("BoolValue")
			cancel.Name = "cancel"
			cancel.Parent = child

			local tween = tweenService:Create(child,defaultTween,{Position = UDim2.new(2,0,child.Position.Y.Scale,0)})
			tween:Play()
			tween:Destroy()
		end)()
		debris:AddItem(child,duration)
	end
end)
UI.Notifications.ChildRemoved:connect(update)

return {}