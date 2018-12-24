--[[
	
	State
	manage mutable state easily
	
--]]

local Events = require(script.Events)

local function DeepCopy(tbl)
	if typeof(tbl) ~= "table" then return tbl end
	
	local copy = {}
	for key, value in pairs(tbl) do
		copy[DeepCopy(key)] = DeepCopy(value)
	end
	
	return copy
end


local State = {}

State.States = {}

function State.GetAllStates()
	local ls = {}
	for key, value in pairs(State.States) do
		ls[#ls + 1] = key
	end
	return ls
end

function State.Create(id)
	if State.States[id] then return end
	State.States[id] = {
		Events = Events(),
		State = {}
	}
end

function State.Wrap(id)
	return setmetatable({}, {
		__index = function(_, key)
			local value = State[key]
			if typeof(value) ~= "function" then return value end
			return function(...)
				return value(id, ...)
			end
		end
	})
end

function State.GetCopy(id)
	if not State.States[id] then warn("Attempt to get copy of empty state discarded - ID: " ..id) return end
	return DeepCopy(State.States[id].State)
end

function State.Push(id, mutator, mutatorInfo)
	if not State.States[id] then warn("Attempt to push to empty state discarded - ID: " ..id) return end
	
	local original = State.GetCopy(id)
	local changes = typeof(mutator) == "table" and mutator or mutator(original)
	local final = State.GetCopy(id)
	
	for key, value in pairs(changes) do
		final[key] = value
	end
	
	State.States[id].State = final
	State.States[id].Events:fire("StateMutated", original, final, mutatorInfo)
end

function State.On(id, eventName, callback)
	if not State.States[id] then warn("Attempt to bind to empty state discarded - ID: " ..id) return end
	State.States[id].Events:on(eventName, callback)
end

return State
