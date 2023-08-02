--PUT THIS SCRIPT IN STARTERPACK, STOP DISLIKING IT BECAUSE YOU DIDN'T USE IT RIGHT

local sounds = game:GetService("SoundService")
local runtime = game:GetService("RunService")
script:WaitForChild("FootstepSounds").Parent = sounds
local materials = sounds:WaitForChild("FootstepSounds")
local plr = game.Players.LocalPlayer
repeat
	task.wait()
until plr.Character
local char = plr.Character
local hum = char:WaitForChild("Humanoid")
local walking

hum.Running:connect(function(speed)
	if speed > hum.WalkSpeed / 2 then
		walking = true
	else
		walking = false
	end
end)

function getMaterial()
	local floormat = hum.FloorMaterial
	if not floormat then
		floormat = "Air"
	end
	local matstring = string.split(tostring(floormat), "Enum.Material.")[2]
	local material = matstring
	return material
end

local lastmat
runtime.Heartbeat:connect(function()
	if walking then
		local material = getMaterial()
		if material ~= lastmat and lastmat ~= nil then
			materials[lastmat].Playing = false
		end
		local materialSound = materials[material]
		if char:FindFirstChild("Running") == nil then
			materialSound.PlaybackSpeed = hum.WalkSpeed / 25
		else
			materialSound.PlaybackSpeed = hum.WalkSpeed / 21
		end
		materialSound.Playing = true
		lastmat = material
	else
		for _, sound in pairs(materials:GetChildren()) do
			sound.Playing = false
		end
	end
end)
