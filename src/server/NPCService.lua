local CollectionService = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("KabukichoOnline")
local Constants = require(Shared.Constants)
local GameConfig = require(Shared.GameConfig)
local Util = require(Shared.Util)

local NPCService = {}
local EconomyService

local npcNames = {
	"Neon Fan",
	"Street Streamer",
	"VIP Tourist",
	"Snack Boss",
	"Viral Dancer",
	"Lost Salaryman",
}

local function randomStreetPosition()
	local halfLength = GameConfig.World.StreetLength / 2 - 35
	local halfWidth = GameConfig.World.StreetWidth / 2 - 20
	return Vector3.new(math.random(-halfWidth, halfWidth), 3, math.random(-halfLength, halfLength))
end

local function makeNpc(index)
	local model = Instance.new("Model")
	model.Name = ("KO_Customer_%02d"):format(index)

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.CFrame = CFrame.new(randomStreetPosition())
	root.Transparency = 1
	root.Anchored = false
	root.CanCollide = false
	root.Parent = model

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(2.4, 4, 1.4)
	body.CFrame = root.CFrame
	body.Color = Util.pick({
		Color3.fromRGB(255, 42, 145),
		Color3.fromRGB(36, 219, 255),
		Color3.fromRGB(255, 230, 62),
		Color3.fromRGB(91, 255, 123),
	})
	body.Material = Enum.Material.Neon
	body.Parent = model

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = body
	weld.Parent = body

	local humanoid = Instance.new("Humanoid")
	humanoid.DisplayName = Util.pick(npcNames)
	humanoid.WalkSpeed = math.random(7, 11)
	humanoid.Parent = model

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "ScoutPrompt"
	prompt.ActionText = "Scout"
	prompt.ObjectText = humanoid.DisplayName
	prompt.HoldDuration = 0.35
	prompt.MaxActivationDistance = GameConfig.NPC.InteractDistance
	prompt.RequiresLineOfSight = false
	prompt.Parent = root

	model.PrimaryPart = root
	model.Parent = workspace
	CollectionService:AddTag(model, Constants.NPC_TAG)

	prompt.Triggered:Connect(function(player)
		if model:GetAttribute("Claimed") then
			return
		end

		model:SetAttribute("Claimed", true)
		prompt.Enabled = false
		EconomyService.awardCustomer(player, humanoid.DisplayName, 1)

		body.Color = Color3.fromRGB(255, 255, 255)
		task.delay(1.5, function()
			if model.Parent then
				model:Destroy()
			end

			task.delay(GameConfig.NPC.RespawnDelay, function()
				makeNpc(index)
			end)
		end)
	end)

	task.spawn(function()
		while model.Parent do
			local target = randomStreetPosition()
			local path = PathfindingService:CreatePath()
			path:ComputeAsync(root.Position, target)

			if path.Status == Enum.PathStatus.Success then
				for _, waypoint in ipairs(path:GetWaypoints()) do
					if not model.Parent or model:GetAttribute("Claimed") then
						return
					end
					humanoid:MoveTo(waypoint.Position)
					humanoid.MoveToFinished:Wait()
				end
			else
				humanoid:MoveTo(target)
				humanoid.MoveToFinished:Wait()
			end

			task.wait(math.random(1, 3))
		end
	end)
end

function NPCService.init(economyService)
	EconomyService = economyService

	for i = 1, GameConfig.NPC.Count do
		makeNpc(i)
	end
end

return NPCService
