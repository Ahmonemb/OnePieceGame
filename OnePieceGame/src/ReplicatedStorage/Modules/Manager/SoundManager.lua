--[[ Services ]]--
local UserInput = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local PlayersService = game:GetService("Players")

--// Libraries \\--
local Debris = game:GetService("Debris")
local Modules = ReplicatedStorage.Modules
local SharedFunctions = require(Modules.SharedFunctions)

--// Folders \\--
local Assets = ReplicatedStorage.Assets
local Sounds = Assets.Sounds

local SoundManager = {}

function SoundManager:Play(Parent, Name, Data)
	local Name = Name
	local IsClient = RunService:IsClient()
	
	local AllSounds = SharedFunctions:DeepSearch(Sounds, "Sound")
	local Sound;
	
	for _, v in ipairs(AllSounds) do
		if (v.Name == Name) then
			Sound = v:Clone();
		end
	end
	
	Sound.PlaybackSpeed = Data.PlaybackSpeed or 1
	Sound.TimePosition = Data.TimePosition or 0
	Sound.Volume = Data.Volume or 1
	Sound.Parent = Parent
	Sound:Play()

	Debris:AddItem(Sound, Sound.TimeLength)
end;

return SoundManager
