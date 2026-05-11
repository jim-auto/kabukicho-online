local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("KabukichoOnline")
local Constants = require(Shared.Constants)
local GameConfig = require(Shared.GameConfig)

local WorldBuilder = {}

local signTexts = {
	"NEON KING",
	"HOST BATTLE",
	"CHAOS STREET",
	"NO.1 RANK",
	"FAN RUSH",
	"NIGHT TYCOON",
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
	Lighting.Brightness = 2
	Lighting.Ambient = Color3.fromRGB(35, 25, 55)
	Lighting.OutdoorAmbient = Color3.fromRGB(25, 20, 40)

	part("KO_Street", Vector3.new(GameConfig.World.StreetWidth, 1, GameConfig.World.StreetLength), CFrame.new(0, -0.5, 0), Color3.fromRGB(18, 18, 22), Enum.Material.Asphalt)
	part("KO_CenterLine", Vector3.new(4, 0.08, GameConfig.World.StreetLength), CFrame.new(0, 0.04, 0), Color3.fromRGB(255, 218, 74), Enum.Material.Neon)

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

			for propIndex = 1, 2 do
				local prop = part("KO_RollingProp", Vector3.new(4, 4, 4), CFrame.new(side * math.random(18, 36), 4, z + math.random(-14, 14)), colors[math.random(1, #colors)], Enum.Material.Neon, false)
				prop.Shape = Enum.PartType.Ball
				CollectionService:AddTag(prop, Constants.PROP_TAG)
			end

			building.Parent = workspace
		end
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
