local module = {}

local FruitShop = script.Parent.Parent.FruitShop

for _, v in pairs(FruitShop.List:GetChildren()) do
	if v:IsA("Frame") then
		v.TItle.Text = v.Name

		--/Beli Purchases
		v.Beli.Click.MouseButton1Click:Connect(function() end)

		--/Robux Purchases
		v.Robux.Click.MouseButton1Click:Connect(function() end)
	end
end

return module
