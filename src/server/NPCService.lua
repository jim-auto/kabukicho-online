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
	"ネオン客",
	"配信者客",
	"観光VIP",
	"スナック店長",
	"バズりダンサー",
	"迷子の会社員",
}

local troubleTypes = {
	{ label = "クソ客", typeName = "RudeCustomer", color = Color3.fromRGB(255, 54, 54) },
	{ label = "迷惑ナンパ", typeName = "Harasser", color = Color3.fromRGB(255, 116, 42) },
	{ label = "メシ詐欺", typeName = "MealScammer", color = Color3.fromRGB(255, 190, 52) },
	{ label = "金せびり", typeName = "CashMoocher", color = Color3.fromRGB(190, 255, 72) },
	{ label = "罵倒客", typeName = "TrashTalker", color = Color3.fromRGB(255, 42, 145) },
}

local function randomStreetPosition()
	local halfLength = GameConfig.World.StreetLength / 2 - 35
	local halfWidth = GameConfig.World.StreetWidth / 2 - 20
	return Vector3.new(math.random(-halfWidth, halfWidth), 3, math.random(-halfLength, halfLength))
end

local function despawnAndRespawn(model, index, isTroublemaker)
	task.delay(1.5, function()
		if model.Parent then
			model:Destroy()
		end

		task.delay(GameConfig.NPC.RespawnDelay, function()
			if isTroublemaker then
				NPCService.makeNpc(index, true)
			else
				NPCService.makeNpc(index, false)
			end
		end)
	end)
end

function NPCService.clearTroublemaker(model, player, forceDirection)
	if not model or model:GetAttribute("Claimed") or not model:GetAttribute("Troublemaker") then
		return false
	end

	local root = model.PrimaryPart
	local body = model:FindFirstChild("Body")
	local prompt = root and root:FindFirstChild("ScoutPrompt")

	model:SetAttribute("Claimed", true)
	if prompt then
		prompt.Enabled = false
	end

	if body then
		body.Color = Color3.fromRGB(255, 255, 255)
	end

	if root and forceDirection then
		root.AssemblyLinearVelocity = forceDirection * 72 + Vector3.new(0, 34, 0)
	end

	EconomyService.awardTroublemaker(player, model:GetAttribute("NpcLabel") or "troublemaker", model:GetAttribute("TroubleType"))
	despawnAndRespawn(model, model:GetAttribute("NpcIndex") or 1, true)
	return true
end

function NPCService.makeNpc(index, isTroublemaker)
	local model = Instance.new("Model")
	model.Name = isTroublemaker and ("KO_Troublemaker_%02d"):format(index) or ("KO_Customer_%02d"):format(index)
	model:SetAttribute("NpcIndex", index)
	model:SetAttribute("Troublemaker", isTroublemaker)
	local troubleInfo = isTroublemaker and Util.pick(troubleTypes) or nil
	if troubleInfo then
		model:SetAttribute("TroubleType", troubleInfo.typeName)
	end

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
	body.Color = troubleInfo and troubleInfo.color or Util.pick({
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
	humanoid.DisplayName = troubleInfo and troubleInfo.label or Util.pick(npcNames)
	humanoid.WalkSpeed = isTroublemaker and math.random(11, 15) or math.random(7, 11)
	humanoid.Parent = model
	model:SetAttribute("NpcLabel", humanoid.DisplayName)

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "ScoutPrompt"
	prompt.ActionText = isTroublemaker and "ツッコミ退場" or "客引き"
	prompt.ObjectText = humanoid.DisplayName
	prompt.HoldDuration = isTroublemaker and 0.15 or 0.35
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

		if isTroublemaker then
			EconomyService.awardTroublemaker(player, humanoid.DisplayName, model:GetAttribute("TroubleType"))
		else
			EconomyService.awardCustomer(player, humanoid.DisplayName, 1)
		end

		body.Color = Color3.fromRGB(255, 255, 255)
		despawnAndRespawn(model, index, isTroublemaker)
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
		NPCService.makeNpc(i, false)
	end

	for i = 1, GameConfig.NPC.TroublemakerCount do
		NPCService.makeNpc(i, true)
	end
end

return NPCService
