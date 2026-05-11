local GameConfig = {}

GameConfig.World = {
	StreetLength = 520,
	StreetWidth = 110,
	BlockCount = 10,
}

GameConfig.Player = {
	WalkSpeed = 16,
	DashSpeed = 30,
	DashDuration = 1.15,
	DashCooldown = 4,
	PushRange = 10,
	PushCooldown = 2.25,
	PushDamage = 8,
	PushForce = 85,
}

GameConfig.NPC = {
	Count = 36,
	InteractDistance = 10,
	RespawnDelay = 8,
	BaseMoney = 18,
	BaseReputation = 6,
	BaseCharismaChance = 0.35,
}

GameConfig.Economy = {
	ClubRankEveryReputation = 180,
	MaxClubRank = 20,
	RankMoneyBonus = 0.08,
}

GameConfig.Chaos = {
	FirstEventDelay = 20,
	IntervalMin = 35,
	IntervalMax = 60,
	EventDuration = 18,
}

return GameConfig
