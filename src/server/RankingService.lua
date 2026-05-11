local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("KabukichoOnline")
local Constants = require(Shared.Constants)

local RankingService = {}
local PlayerDataService

function RankingService.init(remoteFolder, playerDataService)
	PlayerDataService = playerDataService

	remoteFolder[Constants.REMOTES.RequestRanking].OnServerInvoke = function()
		return RankingService.getTop(8)
	end
end

function RankingService.getTop(limit)
	local rows = {}
	for _, player in ipairs(Players:GetPlayers()) do
		local money = PlayerDataService.getStat(player, Constants.STATS.Money)
		local reputation = PlayerDataService.getStat(player, Constants.STATS.Reputation)
		local clubRank = PlayerDataService.getStat(player, Constants.STATS.ClubRank)
		local troublePoints = PlayerDataService.getStat(player, Constants.STATS.TroublePoints)
		table.insert(rows, {
			name = player.DisplayName,
			money = money and money.Value or 0,
			reputation = reputation and reputation.Value or 0,
			clubRank = clubRank and clubRank.Value or 1,
			troublePoints = troublePoints and troublePoints.Value or 0,
		})
	end

	table.sort(rows, function(a, b)
		if a.reputation == b.reputation then
			return a.money > b.money
		end
		return a.reputation > b.reputation
	end)

	while #rows > limit do
		table.remove(rows)
	end

	return rows
end

return RankingService
