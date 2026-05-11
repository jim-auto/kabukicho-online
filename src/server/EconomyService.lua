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
		remotes[Constants.REMOTES.SystemMessage]:FireClient(player, ("店ランクUP: %d"):format(desiredRank))
	end

	remotes[Constants.REMOTES.SystemMessage]:FireClient(player, ("%s 獲得！ +%d円 / 評判+%d"):format(sourceName or "街の客", money, reputation))
end

function EconomyService.awardTroublemaker(player, sourceName, troubleType)
	local money = GameConfig.NPC.TroublemakerMoney
	local reputation = GameConfig.NPC.TroublemakerReputation
	local points = troubleType == "RudeCustomer" and GameConfig.NPC.BonusTroublemakerPoints or GameConfig.NPC.TroublemakerPoints

	PlayerDataService.addStat(player, Constants.STATS.Money, money)
	PlayerDataService.addStat(player, Constants.STATS.Reputation, reputation)
	PlayerDataService.addStat(player, Constants.STATS.TroublePoints, points)
	remotes[Constants.REMOTES.SystemMessage]:FireClient(player, ("%sをツッコミ退場！ 迷惑退治+%d / 評判+%d"):format(sourceName or "迷惑客", points, reputation))
end

return EconomyService
