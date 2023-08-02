local StateManager = {}

--// Services \\--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Libraries \\--
local Modules = ReplicatedStorage.Modules
local GlobalFunctions = require(Modules.GlobalFunctions)
local States = require(script.States)

--// Create Profile
function StateManager:CreateProfile(Character)
	for i, v in pairs(States) do
		Character.States:SetAttribute(i, v.value)
	end
end

--// Set Value
function StateManager:SetValue(Character, State, NewValue, Duration)
	local Thread
	local func = function()
		local Profile = Character:FindFirstChild("States")
		-- set new attribute value
		Profile:SetAttribute(State, NewValue)
		local MAX_DURATION_RANGE = 3
		if Duration and (Duration >= MAX_DURATION_RANGE) then
			task.wait(Duration)
			Thread = nil
		elseif Duration and (Duration < MAX_DURATION_RANGE) then
			GlobalFunctions.wait(Duration)
			Thread = nil
		end

		-- check data type
		local data_type = typeof(self:GetValue(Character, State))

		-- return to old value
		if data_type == "number" or data_type == "string" then
			Profile:SetAttribute(State, NewValue)
		elseif data_type == "boolean" then
			Profile:SetAttribute(State, not NewValue)
		end
	end
	Thread = coroutine.create(func)
	coroutine.resume(Thread)
end

--// Get Value
function StateManager:GetValue(Character, State)
	local Profile = Character:FindFirstChild("States")

	--// restrict combo exceeding maximum
	local CurrentCombo, MaxCombo = Profile:GetAttribute("Combo"), Profile:GetAttribute("MaxCombo")
	if CurrentCombo > MaxCombo then
		self:SetValue(Character, "Combo", 0)
		self:SetValue(Character, "Variation", "")
	end

	return Profile:GetAttribute(State)
end

--// Increment value
function StateManager:Increment(Character, State, Duration, Amount)
	local Profile = Character:FindFirstChild("States")
	Amount = Amount or 1

	--// String Addition (combo variations)
	local data_type = typeof(self:GetValue(Character, State))

	--// Combo counter reset after a certain combo window has exceeded
	local combo_window = 1
	local LastPressed = self:GetValue(Character, "LastPressed") -- return the last os.clock() when clicked
	local Elapsed_Time = (os.clock() - LastPressed) -- time elapsed from old click to new click

	if Elapsed_Time <= combo_window then
		if data_type == "string" then
			Profile:SetAttribute(State, self:GetValue(Character, State) .. Amount)
		else
			self:SetValue(Character, State, self:GetValue(Character, State) + Amount, Duration or 0) -- increment value for certain duration
		end
	else
		if data_type == "string" then
			self:SetValue(Character, State, "")
		else
			self:SetValue(Character, State, 0)
		end
	end
	self:SetValue(Character, "LastPressed", os.clock())
end
return StateManager
