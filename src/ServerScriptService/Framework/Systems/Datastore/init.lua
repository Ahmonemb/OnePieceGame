--/Services
local profileService = require(script.ProfileService)
local players = game:GetService("Players")

--/Modules
local template = require(script.PlayerStats)
local LevelUp = require(script.LevelUp)
local module = {}

--/Variables
local key = "Testing.043"
local profiles = {}

local gameProfile = profileService.GetProfileStore(key, template)

--/Methods
function Init(p, data)
	local c = p.Character
	local dataFolder = c.Data

	--/Loading data as attributes
	for i, v in pairs(data) do
		if typeof(v) ~= "table" and i ~= "Bounty" then
			dataFolder:SetAttribute(i, v)

			--/Update the attribute and it updates data
			dataFolder:GetAttributeChangedSignal(i):connect(function()
				data[i] = dataFolder:GetAttribute(i)

				if i == "Experience" then
					LevelUp.Check(p)
				end
			end)
		end
	end

	p.leaderstats["Bounty/Respect"].Value = data.Bounty
	p.leaderstats["Bounty/Respect"].Changed:Connect(function(value)
		data.Bounty = value
	end)
end

function module.GetData(Player, Name)
	local DataSearch = profiles[Player].Data[Name]
	return DataSearch or warn(Name .. " does not exist.")
end

function module.SetData(Player, Name, Value)
	local DataSearch = profiles[Player].Data[Name]

	DataSearch = Value
end

--/Events
players.PlayerAdded:connect(function(p)
	p.CharacterAdded:connect(function(c)
		if not profiles[p] then
			task.wait(1)
		end

		Init(p, profiles[p].Data)
	end)
	local profile = gameProfile:LoadProfileAsync(p.Name .. "_" .. p.UserId, "ForceLoad")
	if profile then
		profile:Reconcile()

		--/Incase it was loaded in another server
		profile:ListenToRelease(function()
			profiles[p] = nil
			p:Kick()
		end)

		if p:IsDescendantOf(players) then
			--/Profile loaded successfully
			profiles[p] = profile
			print(profile.Data)
		else
			--/Player left before the profile was loaded
			profile:Release()
		end
	else
		--/Profile cant be loaded cuz theres another server tryna load it at the same time
		p:Kick()
	end
end)

players.PlayerRemoving:connect(function(p)
	local profile = profiles[p]
	if profile then
		profile:Release()
	end
end)

return module
