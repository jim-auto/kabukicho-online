local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("KabukichoOnline")
local Constants = require(Shared.Constants)

local RemoteBootstrap = {}

function RemoteBootstrap.init()
	local folder = ReplicatedStorage:FindFirstChild(Constants.REMOTE_FOLDER)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = Constants.REMOTE_FOLDER
		folder.Parent = ReplicatedStorage
	end

	for _, remoteName in pairs(Constants.REMOTES) do
		if not folder:FindFirstChild(remoteName) then
			local remote = Instance.new(remoteName == Constants.REMOTES.RequestRanking and "RemoteFunction" or "RemoteEvent")
			remote.Name = remoteName
			remote.Parent = folder
		end
	end

	return folder
end

return RemoteBootstrap
