local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("KabukichoOnline")
local Constants = require(Shared.Constants)
local GameConfig = require(Shared.GameConfig)

local EconomyService = {}
local PlayerDataService
local remotes

function EconomyService.init(remoteFolder, playerDataService)
	remotes = remoteFolder
	PlayerDataService = playerDataService
end

function EconomyService.awardCustomer(player, sourceName, multiplier)
	local clubRank = PlayerDataService.getStat(player, Constants.STATS.ClubRank)
	local rankValue = clubRank and clubRank.Value or 1
	local bonus = 1 + ((rankValue - 1) * GameConfig.Economy.RankMoneyBonus)
	local totalMultiplier = (multiplier or 1) * bonus

	local money = math.floor(GameConfig.NPC.BaseMoney * totalMultiplier)
	local reputation = math.floor(GameConfig.NPC.BaseReputation * totalMultiplier)

	PlayerDataService.addStat(player, Constants.STATS.Money, money)
	local newReputation = PlayerDataService.addStat(player, Constants.STATS.Reputation, reputation)

	if math.random() < GameConfig.NPC.BaseCharismaChance then
		PlayerDataService.addStat(player, Constants.STATS.Charisma, 1)
	end

	local desiredRank = math.clamp(math.floor(newReputation / GameConfig.Economy.ClubRankEveryReputation) + 1, 1, GameConfig.Economy.MaxClubRank)
	if desiredRank > rankValue then
		PlayerDataService.setStat(player, Constants.STATS.ClubRank, desiredRank)
		remotes[Constants.REMOTES.SystemMessage]:FireClient(player, ("Club Rank UP: %d"):format(desiredRank))
	end

	remotes[Constants.REMOTES.SystemMessage]:FireClient(player, ("+%d yen / +%d rep from %s"):format(money, reputation, sourceName or "street fan"))
end

return EconomyService
