local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("KabukichoOnline")
local Constants = require(Shared.Constants)
local GameConfig = require(Shared.GameConfig)

local PlayerDataService = {}

local remotes

local function makeInt(parent, name, value)
	local intValue = Instance.new("IntValue")
	intValue.Name = name
	intValue.Value = value
	intValue.Parent = parent
	return intValue
end

function PlayerDataService.init(remoteFolder)
	remotes = remoteFolder

	Players.PlayerAdded:Connect(function(player)
		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player

		makeInt(leaderstats, Constants.STATS.Money, 0)
		makeInt(leaderstats, Constants.STATS.Reputation, 0)
		makeInt(leaderstats, Constants.STATS.Charisma, 1)
		makeInt(leaderstats, Constants.STATS.ClubRank, 1)

		player:SetAttribute("LastDashAt", -999)
		player:SetAttribute("LastPushAt", -999)

		player.CharacterAdded:Connect(function(character)
			local humanoid = character:WaitForChild("Humanoid", 10)
			if humanoid then
				humanoid.WalkSpeed = GameConfig.Player.WalkSpeed
			end
		end)
	end)
end

function PlayerDataService.getStat(player, statName)
	local leaderstats = player:FindFirstChild("leaderstats")
	local stat = leaderstats and leaderstats:FindFirstChild(statName)
	return stat
end

function PlayerDataService.setStat(player, statName, value)
	local stat = PlayerDataService.getStat(player, statName)
	if not stat then
		return
	end

	stat.Value = value
	if remotes then
		remotes[Constants.REMOTES.StatsChanged]:FireClient(player, statName, value)
	end
end

function PlayerDataService.addStat(player, statName, delta)
	local stat = PlayerDataService.getStat(player, statName)
	if not stat then
		return 0
	end

	stat.Value += delta
	if remotes then
		remotes[Constants.REMOTES.StatsChanged]:FireClient(player, statName, stat.Value)
	end
	return stat.Value
end

return PlayerDataService
