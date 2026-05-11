local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("KabukichoOnline")
local Constants = require(Shared.Constants)
local GameConfig = require(Shared.GameConfig)

local WorldBuilder = {}

local signTexts = {
	"ネオン王",
	"ホストバトル",
	"カオス通り",
	"目指せNo.1",
	"客ラッシュ",
	"夜街タイクーン",
	"迷惑退場",
	"ツッコミSHOW",
	"バズポーズ",
}

local colors = {
	Color3.fromRGB(255, 42, 145),
	Color3.fromRGB(36, 219, 255),
	Color3.fromRGB(255, 230, 62),
	Color3.fromRGB(91, 255, 123),
}

local function part(name, size, cframe, color, material, anchored)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = anchored ~= false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = workspace
	return p
end

local function makeTextSign(parent, text)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.LightInfluence = 0
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 30
	gui.Parent = parent

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBlack
	label.Text = text
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Parent = gui
end

function WorldBuilder.init()
	Lighting.ClockTime = 22
	Lighting.Brightness = 2.7
	Lighting.Ambient = Color3.fromRGB(35, 25, 55)
	Lighting.OutdoorAmbient = Color3.fromRGB(25, 20, 40)

	local bloom = Instance.new("BloomEffect")
	bloom.Name = "KO_NeonBloom"
	bloom.Intensity = 1.1
	bloom.Size = 42
	bloom.Threshold = 0.75
	bloom.Parent = Lighting

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Name = "KO_NightMist"
	atmosphere.Color = Color3.fromRGB(110, 74, 155)
	atmosphere.Decay = Color3.fromRGB(28, 20, 46)
	atmosphere.Density = 0.32
	atmosphere.Haze = 1.7
	atmosphere.Parent = Lighting

	part("KO_Street", Vector3.new(GameConfig.World.StreetWidth, 1, GameConfig.World.StreetLength), CFrame.new(0, -0.5, 0), Color3.fromRGB(18, 18, 22), Enum.Material.Asphalt)
	part("KO_CenterLine", Vector3.new(4, 0.08, GameConfig.World.StreetLength), CFrame.new(0, 0.04, 0), Color3.fromRGB(255, 218, 74), Enum.Material.Neon)
	part("KO_LeftSidewalk", Vector3.new(22, 1.2, GameConfig.World.StreetLength), CFrame.new(-48, 0, 0), Color3.fromRGB(38, 38, 48), Enum.Material.Concrete)
	part("KO_RightSidewalk", Vector3.new(22, 1.2, GameConfig.World.StreetLength), CFrame.new(48, 0, 0), Color3.fromRGB(38, 38, 48), Enum.Material.Concrete)

	for lampIndex = 1, 18 do
		local z = -GameConfig.World.StreetLength / 2 + lampIndex * 28
		for side = -1, 1, 2 do
			local pole = part("KO_NeonPole", Vector3.new(1.2, 18, 1.2), CFrame.new(side * 42, 9, z), Color3.fromRGB(18, 18, 22), Enum.Material.Metal)
			local lamp = part("KO_NeonLamp", Vector3.new(5, 2, 5), CFrame.new(side * 42, 19, z), colors[math.random(1, #colors)], Enum.Material.Neon)
			local light = Instance.new("PointLight")
			light.Color = lamp.Color
			light.Range = 34
			light.Brightness = 2.4
			light.Parent = lamp
			pole.Parent = workspace
		end
	end

	for i = 1, GameConfig.World.BlockCount do
		local z = -GameConfig.World.StreetLength / 2 + i * (GameConfig.World.StreetLength / GameConfig.World.BlockCount)
		for side = -1, 1, 2 do
			local x = side * 72
			local height = math.random(28, 58)
			local building = part("KO_NeonClub", Vector3.new(34, height, 28), CFrame.new(x, height / 2, z), Color3.fromRGB(28, 28, 38), Enum.Material.SmoothPlastic)

			local sign = part("KO_NeonSign", Vector3.new(26, 8, 1), CFrame.new(x - side * 17.6, math.random(10, height - 5), z), colors[math.random(1, #colors)], Enum.Material.Neon)
			sign.CFrame *= CFrame.Angles(0, side == 1 and math.rad(-90) or math.rad(90), 0)
			makeTextSign(sign, signTexts[math.random(1, #signTexts)])

			local light = Instance.new("PointLight")
			light.Color = sign.Color
			light.Range = 28
			light.Brightness = 2
			light.Parent = sign

			for windowIndex = 1, 4 do
				local windowZ = z - 10 + windowIndex * 5
				local windowY = math.clamp(8 + windowIndex * 7, 8, height - 4)
				local window = part("KO_NeonWindow", Vector3.new(1, 4, 3), CFrame.new(x - side * 17.1, windowY, windowZ), colors[math.random(1, #colors)], Enum.Material.Neon)
				window.CFrame *= CFrame.Angles(0, side == 1 and math.rad(-90) or math.rad(90), 0)
			end

			if i % 3 == 0 then
				local blade = part("KO_BladeSign", Vector3.new(1, 16, 7), CFrame.new(x - side * 21, math.min(height - 8, 24), z + 10), colors[math.random(1, #colors)], Enum.Material.Neon)
				makeTextSign(blade, "NO.1")
			end

			for propIndex = 1, 2 do
				local prop = part("KO_RollingProp", Vector3.new(4, 4, 4), CFrame.new(side * math.random(18, 36), 4, z + math.random(-14, 14)), colors[math.random(1, #colors)], Enum.Material.Neon, false)
				prop.Shape = Enum.PartType.Ball
				CollectionService:AddTag(prop, Constants.PROP_TAG)
			end

			building.Parent = workspace
		end
	end

	for gateIndex = 1, 3 do
		local z = -180 + gateIndex * 115
		part("KO_NeonGateTop", Vector3.new(74, 3, 3), CFrame.new(0, 28, z), colors[math.random(1, #colors)], Enum.Material.Neon)
		part("KO_NeonGateLeft", Vector3.new(3, 28, 3), CFrame.new(-37, 14, z), colors[math.random(1, #colors)], Enum.Material.Neon)
		part("KO_NeonGateRight", Vector3.new(3, 28, 3), CFrame.new(37, 14, z), colors[math.random(1, #colors)], Enum.Material.Neon)
	end

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "KO_MainSpawn"
	spawn.Size = Vector3.new(18, 1, 18)
	spawn.CFrame = CFrame.new(0, 1, -GameConfig.World.StreetLength / 2 + 28)
	spawn.Color = Color3.fromRGB(36, 219, 255)
	spawn.Material = Enum.Material.Neon
	spawn.Anchored = true
	spawn.Parent = workspace
end

return WorldBuilder
