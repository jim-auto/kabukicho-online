local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("KabukichoOnline")
local Constants = require(Shared.Constants)
local GameConfig = require(Shared.GameConfig)
local Util = require(Shared.Util)

local PvPService = {}
local NPCService

local function canUse(player, attrName, cooldown)
	local now = os.clock()
	local last = player:GetAttribute(attrName) or -999
	if now - last < cooldown then
		return false
	end
	player:SetAttribute(attrName, now)
	return true
end

function PvPService.init(remoteFolder, npcService)
	NPCService = npcService

	remoteFolder[Constants.REMOTES.RequestDash].OnServerEvent:Connect(function(player)
		if not canUse(player, "LastDashAt", GameConfig.Player.DashCooldown) then
			return
		end

		local humanoid = Util.getHumanoid(player.Character)
		if not humanoid then
			return
		end

		humanoid.WalkSpeed = GameConfig.Player.DashSpeed
		task.delay(GameConfig.Player.DashDuration, function()
			if humanoid.Parent then
				humanoid.WalkSpeed = GameConfig.Player.WalkSpeed
			end
		end)
	end)

	remoteFolder[Constants.REMOTES.RequestPush].OnServerEvent:Connect(function(player)
		if not canUse(player, "LastPushAt", GameConfig.Player.PushCooldown) then
			return
		end

		local root = Util.getCharacterRoot(player.Character)
		if not root then
			return
		end

		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			if otherPlayer ~= player then
				local otherRoot = Util.getCharacterRoot(otherPlayer.Character)
				local otherHumanoid = Util.getHumanoid(otherPlayer.Character)

				if otherRoot and otherHumanoid and (otherRoot.Position - root.Position).Magnitude <= GameConfig.Player.PushRange then
					local direction = (otherRoot.Position - root.Position)
					if direction.Magnitude < 0.1 then
						direction = root.CFrame.LookVector
					else
						direction = direction.Unit
					end

					otherHumanoid:TakeDamage(GameConfig.Player.PushDamage)

					local velocity = Instance.new("LinearVelocity")
					velocity.Attachment0 = otherRoot:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", otherRoot)
					velocity.MaxForce = 65000
					velocity.VectorVelocity = direction * GameConfig.Player.PushForce + Vector3.new(0, 24, 0)
					velocity.Parent = otherRoot
					Debris:AddItem(velocity, 0.22)
				end
			end
		end

		if NPCService then
			for _, npc in ipairs(CollectionService:GetTagged(Constants.NPC_TAG)) do
				if npc:GetAttribute("Troublemaker") and not npc:GetAttribute("Claimed") then
					local npcRoot = npc.PrimaryPart
					if npcRoot and (npcRoot.Position - root.Position).Magnitude <= GameConfig.Player.PushRange + 2 then
						local direction = npcRoot.Position - root.Position
						if direction.Magnitude < 0.1 then
							direction = root.CFrame.LookVector
						else
							direction = direction.Unit
						end

						NPCService.clearTroublemaker(npc, player, direction)
					end
				end
			end
		end
	end)

	remoteFolder[Constants.REMOTES.RequestEmote].OnServerEvent:Connect(function(player)
		remoteFolder[Constants.REMOTES.SystemMessage]:FireAllClients(player.DisplayName .. " がネオンポーズを決めた！")
	end)
end

return PvPService
