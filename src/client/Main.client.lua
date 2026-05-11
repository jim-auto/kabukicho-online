local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local Shared = ReplicatedStorage:WaitForChild("KabukichoOnline")
local Constants = require(Shared.Constants)
local GameConfig = require(Shared.GameConfig)

local remotes = ReplicatedStorage:WaitForChild(Constants.REMOTE_FOLDER)

local gui = Instance.new("ScreenGui")
gui.Name = "KabukichoHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.fromScale(1, 1)
root.BackgroundTransparency = 1
root.Parent = gui

local statsPanel = Instance.new("Frame")
statsPanel.Name = "StatsPanel"
statsPanel.Size = UDim2.fromOffset(300, 118)
statsPanel.Position = UDim2.fromOffset(16, 16)
statsPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
statsPanel.BackgroundTransparency = 0.12
statsPanel.BorderSizePixel = 0
statsPanel.Parent = root

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 8)
statsCorner.Parent = statsPanel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -20, 0, 28)
title.Position = UDim2.fromOffset(10, 8)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.Text = "KABUKICHO ONLINE"
title.TextColor3 = Color3.fromRGB(36, 219, 255)
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = statsPanel

local statLabels = {}
local statOrder = {
	Constants.STATS.Money,
	Constants.STATS.Reputation,
	Constants.STATS.Charisma,
	Constants.STATS.ClubRank,
}

for index, statName in ipairs(statOrder) do
	local label = Instance.new("TextLabel")
	label.Name = statName
	label.Size = UDim2.new(0.5, -14, 0, 24)
	label.Position = UDim2.fromOffset(10 + ((index - 1) % 2) * 145, 42 + math.floor((index - 1) / 2) * 30)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = statName .. ": 0"
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = statsPanel
	statLabels[statName] = label
end

local message = Instance.new("TextLabel")
message.Name = "Message"
message.AnchorPoint = Vector2.new(0.5, 0)
message.Size = UDim2.fromOffset(560, 54)
message.Position = UDim2.new(0.5, 0, 0, 22)
message.BackgroundColor3 = Color3.fromRGB(255, 42, 145)
message.BackgroundTransparency = 0.08
message.BorderSizePixel = 0
message.Font = Enum.Font.GothamBlack
message.Text = ""
message.TextColor3 = Color3.new(1, 1, 1)
message.TextScaled = true
message.Visible = false
message.Parent = root

local messageCorner = Instance.new("UICorner")
messageCorner.CornerRadius = UDim.new(0, 8)
messageCorner.Parent = message

local rankingPanel = Instance.new("Frame")
rankingPanel.Name = "RankingPanel"
rankingPanel.AnchorPoint = Vector2.new(1, 0)
rankingPanel.Size = UDim2.fromOffset(280, 250)
rankingPanel.Position = UDim2.new(1, -16, 0, 16)
rankingPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
rankingPanel.BackgroundTransparency = 0.12
rankingPanel.BorderSizePixel = 0
rankingPanel.Parent = root

local rankingCorner = Instance.new("UICorner")
rankingCorner.CornerRadius = UDim.new(0, 8)
rankingCorner.Parent = rankingPanel

local rankingTitle = Instance.new("TextLabel")
rankingTitle.Size = UDim2.new(1, -20, 0, 30)
rankingTitle.Position = UDim2.fromOffset(10, 8)
rankingTitle.BackgroundTransparency = 1
rankingTitle.Font = Enum.Font.GothamBlack
rankingTitle.Text = "SERVER RANKING"
rankingTitle.TextColor3 = Color3.fromRGB(255, 230, 62)
rankingTitle.TextSize = 18
rankingTitle.TextXAlignment = Enum.TextXAlignment.Left
rankingTitle.Parent = rankingPanel

local rankingRows = {}
for i = 1, 8 do
	local row = Instance.new("TextLabel")
	row.Name = "Rank" .. i
	row.Size = UDim2.new(1, -20, 0, 24)
	row.Position = UDim2.fromOffset(10, 40 + (i - 1) * 25)
	row.BackgroundTransparency = 1
	row.Font = Enum.Font.Gotham
	row.Text = i .. ". ---"
	row.TextColor3 = Color3.fromRGB(235, 235, 235)
	row.TextSize = 14
	row.TextXAlignment = Enum.TextXAlignment.Left
	row.Parent = rankingPanel
	rankingRows[i] = row
end

local controls = Instance.new("Frame")
controls.Name = "Controls"
controls.AnchorPoint = Vector2.new(1, 1)
controls.Size = UDim2.fromOffset(272, 88)
controls.Position = UDim2.new(1, -18, 1, -18)
controls.BackgroundTransparency = 1
controls.Parent = root

local function makeButton(name, text, x)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.fromOffset(82, 82)
	button.Position = UDim2.fromOffset(x, 0)
	button.BackgroundColor3 = Color3.fromRGB(22, 22, 31)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBlack
	button.Text = text
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextScaled = true
	button.Parent = controls

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(36, 219, 255)
	stroke.Thickness = 2
	stroke.Parent = button

	return button
end

local dashButton = makeButton("DashButton", "DASH", 0)
local pushButton = makeButton("PushButton", "PUSH", 94)
local emoteButton = makeButton("EmoteButton", "POSE", 188)

local function applyResponsiveLayout()
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local compact = viewport.X < 760

	statsPanel.Size = compact and UDim2.fromOffset(250, 112) or UDim2.fromOffset(300, 118)
	title.TextSize = compact and 18 or 22
	title.TextScaled = compact

	rankingPanel.Visible = not compact
	message.Size = compact and UDim2.new(1, -24, 0, 48) or UDim2.fromOffset(560, 54)
	message.Position = compact and UDim2.new(0.5, 0, 0, 136) or UDim2.new(0.5, 0, 0, 22)

	local buttonSize = compact and 70 or 82
	local gap = compact and 8 or 12
	controls.Size = UDim2.fromOffset(buttonSize * 3 + gap * 2, buttonSize)

	for index, button in ipairs({ dashButton, pushButton, emoteButton }) do
		button.Size = UDim2.fromOffset(buttonSize, buttonSize)
		button.Position = UDim2.fromOffset((index - 1) * (buttonSize + gap), 0)
	end
end

local function showMessage(text)
	message.Text = text
	message.Visible = true
	task.delay(2.8, function()
		if message.Text == text then
			message.Visible = false
		end
	end)
end

local function updateStatsFromLeaderstats()
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return
	end

	for _, statName in ipairs(statOrder) do
		local stat = leaderstats:FindFirstChild(statName)
		if stat then
			statLabels[statName].Text = statName .. ": " .. stat.Value
		end
	end
end

local function requestDash()
	remotes[Constants.REMOTES.RequestDash]:FireServer()
end

local function requestPush()
	remotes[Constants.REMOTES.RequestPush]:FireServer()
end

local function requestEmote()
	remotes[Constants.REMOTES.RequestEmote]:FireServer()

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Jump = true
	end
end

dashButton.Activated:Connect(requestDash)
pushButton.Activated:Connect(requestPush)
emoteButton.Activated:Connect(requestEmote)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		requestDash()
	elseif input.KeyCode == Enum.KeyCode.F then
		requestPush()
	elseif input.KeyCode == Enum.KeyCode.G then
		requestEmote()
	end
end)

remotes[Constants.REMOTES.SystemMessage].OnClientEvent:Connect(showMessage)
remotes[Constants.REMOTES.ChaosEvent].OnClientEvent:Connect(function(name, eventMessage)
	showMessage(name .. ": " .. eventMessage)
end)

remotes[Constants.REMOTES.StatsChanged].OnClientEvent:Connect(function(statName, value)
	if statLabels[statName] then
		statLabels[statName].Text = statName .. ": " .. value
	end
end)

local function refreshRanking()
	local ok, rows = pcall(function()
		return remotes[Constants.REMOTES.RequestRanking]:InvokeServer()
	end)

	if not ok or type(rows) ~= "table" then
		return
	end

	for i, rowLabel in ipairs(rankingRows) do
		local row = rows[i]
		if row then
			rowLabel.Text = ("%d. %s  R%d  Rep %d"):format(i, row.name, row.clubRank, row.reputation)
		else
			rowLabel.Text = i .. ". ---"
		end
	end
end

player.ChildAdded:Connect(function(child)
	if child.Name == "leaderstats" then
		task.wait(0.1)
		updateStatsFromLeaderstats()
	end
end)

task.spawn(function()
	while true do
		updateStatsFromLeaderstats()
		refreshRanking()
		task.wait(3)
	end
end)

applyResponsiveLayout()

if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveLayout)
end
