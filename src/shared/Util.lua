local Util = {}

function Util.clampInt(value, minValue, maxValue)
	return math.floor(math.clamp(value, minValue, maxValue))
end

function Util.getCharacterRoot(character)
	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

function Util.getHumanoid(character)
	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Humanoid")
end

function Util.pick(list)
	return list[math.random(1, #list)]
end

return Util
