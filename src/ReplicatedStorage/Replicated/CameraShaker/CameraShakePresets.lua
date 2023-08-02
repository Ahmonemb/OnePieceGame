-- Camera Shake Presets
-- Stephen Leitnick
-- February 26, 2018

--[[
	
	CameraShakePresets.Bump
	CameraShakePresets.Explosion
	CameraShakePresets.Earthquake
	CameraShakePresets.BadTrip
	CameraShakePresets.HandheldCamera
	CameraShakePresets.Vibration
	CameraShakePresets.RoughDriving
	
--]]

local CameraShakeInstance = require(script.Parent.CameraShakeInstance)

local CameraShakePresets = {

	Lightning1 = function()
		local c = CameraShakeInstance.new(1.15, 10, 0, 1)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		c.RotationInfluence = Vector3.new(4, 1, 1)
		return c
	end,

	Meteor = function()
		local c = CameraShakeInstance.new(0.9, 10, 0, 1)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		c.RotationInfluence = Vector3.new(4, 1, 1)
		return c
	end,

	Earthquake = function()
		local c = CameraShakeInstance.new(1.75, 10, 0, 1)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		c.RotationInfluence = Vector3.new(4, 1, 1)
		return c
	end,

	Ground = function()
		local c = CameraShakeInstance.new(2, 15, 0, 1)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		c.RotationInfluence = Vector3.new(4, 1, 1)
		return c
	end,

	Branches = function()
		local c = CameraShakeInstance.new(0.95, 10, 0, 1)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		c.RotationInfluence = Vector3.new(4, 1, 1)
		return c
	end,

	LightningBlade = function()
		local c = CameraShakeInstance.new(0.7, 10, 0, 1)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		c.RotationInfluence = Vector3.new(4, 1, 1)
		return c
	end,

	Wind = function()
		local c = CameraShakeInstance.new(0.95, 10, 0, 1)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		c.RotationInfluence = Vector3.new(4, 1, 1)
		return c
	end,

	GroundBurst = function()
		local c = CameraShakeInstance.new(0.95, 10, 0, 1)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		c.RotationInfluence = Vector3.new(4, 1, 1)
		return c
	end,

	GravitySustained = function()
		local c = CameraShakeInstance.new(0.95, 10, 0, 1)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		c.RotationInfluence = Vector3.new(4, 1, 1)
		return c
	end,

	SphereClose = function()
		local c = CameraShakeInstance.new(3, 15, 0, 1.5)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		c.RotationInfluence = Vector3.new(4, 1, 1)
		return c
	end,

	ExtremeWind = function()
		local c = CameraShakeInstance.new(1.35, 12, 0, 1)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		c.RotationInfluence = Vector3.new(1, 1, 1)
		return c
	end,

	BigExplosion = function()
		local c = CameraShakeInstance.new(5, 7, 0.2, 0.6)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		c.RotationInfluence = Vector3.new(1, 1, 1)
		return c
	end,
}

return setmetatable({}, {
	__index = function(i)
		local f = CameraShakePresets[i]
		if type(f) == "function" then
			return f()
		end
		error('No preset found with index "' .. i .. '"')
	end,
})
