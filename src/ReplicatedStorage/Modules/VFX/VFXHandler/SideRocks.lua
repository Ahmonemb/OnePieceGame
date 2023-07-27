local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Visual = workspace.World.Visual

return function(Data)
	
	local StartPos = Data.StartPos
	local Offset = Data.Offset
	local Amount = Data.Amount
	local Size = Data.Size
	
	local Filter = Data.Filter
	
	local IterationDelay = Data.IterationDelay
	local Duration = Data.Duration or 2
	
	--[[ Rocks Following Trail ]]--
	for loops = 1,2 do
		coroutine.wrap(function()
			local GroundRocks = {}
			for i = 1,Amount do
				
				--[[ Change Offset. Two Rocks on Both Sides. ]]--
				if loops == 2 then Offset *= -1 end
				
				--[[ Raycast ]]--
				local StartPosition = (StartPos * CFrame.new(Offset,0,-i*5)).Position
				local EndPosition = CFrame.new(StartPosition).UpVector * -10

				local RayData = RaycastParams.new()
				RayData.FilterDescendantsInstances = Filter or Visual
				RayData.FilterType = Enum.RaycastFilterType.Blacklist
				RayData.IgnoreWater = true

				local ray = game.Workspace:Raycast(StartPosition, EndPosition, RayData)
				if ray then
					local partHit, pos, normVector = ray.Instance or nil, ray.Position or nil, ray.Normal or nil
					if partHit then
						local Block = script.Block:Clone()

						Block.Size = Size

						Block.Position = pos
						Block.Anchored = true
						Block.Rotation = Vector3.new(math.random(-360,360),math.random(-360,360),math.random(-360,360))
						Block.Transparency = 0
						Block.Color = partHit.Color
						Block.Material = partHit.Material
						Block.Parent = Visual
						GroundRocks[i] = Block;
						
						Debris:AddItem(Block, Duration + 0.5)
					end
				end		
				if IterationDelay then
					if IterationDelay == 0 then
						game:GetService("RunService").Heartbeat:Wait()
					else
						wait(IterationDelay)
					end
				end
			end	
			--[[ Delete Rocks ]]--
			wait(Duration)
			if #GroundRocks >= 0 then
				for _,v in ipairs(GroundRocks) do
					local Tween = TweenService:Create(v,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0),{["Color"] = Color3.fromRGB(152, 194, 219)})
					Tween:Play()
					Tween:Destroy()
					v.Anchored = false
					Debris:AddItem(v, 0.5)
					wait()
				end
			end
		end)()
	end

end
