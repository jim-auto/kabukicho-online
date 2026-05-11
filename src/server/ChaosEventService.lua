local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("KabukichoOnline")
local Constants = require(Shared.Constants)
local GameConfig = require(Shared.GameConfig)

local ChaosEventService = {}
local EconomyService
local remotes

local events = {
	{
		name = "Cash Rain",
		message = "Cash Rain! Scout customers for bonus money!",
		multiplier = 2,
		run = function()
			for i = 1, 36 do
				local coin = Instance.new("Part")
				coin.Name = "KO_CashRainCoin"
				coin.Shape = Enum.PartType.Cylinder
				coin.Size = Vector3.new(0.4, 3, 3)
				coin.CFrame = CFrame.new(math.random(-45, 45), math.random(35, 65), math.random(-220, 220)) * CFrame.Angles(0, 0, math.rad(90))
				coin.Color = Color3.fromRGB(255, 230, 62)
				coin.Material = Enum.Material.Neon
				coin.Parent = workspace
				Debris:AddItem(coin, GameConfig.Chaos.EventDuration)
			end
		end,
	},
	{
		name = "Neon Rush",
		message = "Neon Rush! Everyone gets a speed burst!",
		run = function()
			for _, player in ipairs(Players:GetPlayers()) do
				local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.WalkSpeed = GameConfig.Player.DashSpeed
					task.delay(8, function()
						if humanoid.Parent then
							humanoid.WalkSpeed = GameConfig.Player.WalkSpeed
						end
					end)
				end
			end
		end,
	},
	{
		name = "Street Jam",
		message = "Street Jam! Giant neon props are rolling in!",
		run = function()
			for i = 1, 14 do
				local ball = Instance.new("Part")
				ball.Name = "KO_StreetJamBall"
				ball.Shape = Enum.PartType.Ball
				ball.Size = Vector3.new(7, 7, 7)
				ball.CFrame = CFrame.new(math.random(-35, 35), 12, math.random(-230, 230))
				ball.Color = Color3.fromRGB(255, 42, 145)
				ball.Material = Enum.Material.Neon
				ball.Parent = workspace
				ball.AssemblyLinearVelocity = Vector3.new(math.random(-40, 40), 0, math.random(-40, 40))
				Debris:AddItem(ball, GameConfig.Chaos.EventDuration)
			end
		end,
	},
}

function ChaosEventService.init(remoteFolder, economyService)
	remotes = remoteFolder
	EconomyService = economyService

	task.spawn(function()
		task.wait(GameConfig.Chaos.FirstEventDelay)
		while true do
			ChaosEventService.startRandom()
			task.wait(math.random(GameConfig.Chaos.IntervalMin, GameConfig.Chaos.IntervalMax))
		end
	end)
end

function ChaosEventService.startRandom()
	local event = events[math.random(1, #events)]
	remotes[Constants.REMOTES.ChaosEvent]:FireAllClients(event.name, event.message)
	remotes[Constants.REMOTES.SystemMessage]:FireAllClients(event.message)
	event.run(EconomyService)
end

return ChaosEventService
