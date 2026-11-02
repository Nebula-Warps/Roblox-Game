
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Leaderboard = require(ServerStorage.Leaderboard)
local PlayerData = require(ServerStorage.PlayerData)


local IncreaseJumpPowerFunction = ReplicatedStorage.Instances.IncreaseJumpPowerFunction

local JUMP_KEY_NAME = PlayerData.JUMP_KEY_NAME
local COIN_KEY_NAME = PlayerData.COIN_KEY_NAME
local JUMP_POWER_INCREMENT = 25
local JUMP_COIN_COST = 5

local function updateJumpPower(player, updateFunction)

	local newJumpPower = PlayerData.updateValue(player, JUMP_KEY_NAME, updateFunction)


	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		humanoid.JumpPower = newJumpPower

		Leaderboard.setStat(player, JUMP_KEY_NAME, newJumpPower)
	end
end

local function onPurchaseJumpIncrease(player)
	local coinAmount = PlayerData.getValue(player, COIN_KEY_NAME)
	if coinAmount < JUMP_COIN_COST then
		return false
	end

	updateJumpPower(player, function(oldJumpPower)
		oldJumpPower = oldJumpPower or 0
		return oldJumpPower + JUMP_POWER_INCREMENT
	end)

	local newCoinAmount = PlayerData.updateValue(player, COIN_KEY_NAME, function(oldCoinAmount)
		return oldCoinAmount - JUMP_COIN_COST
	end)

	Leaderboard.setStat(player, COIN_KEY_NAME, newCoinAmount)
	return true
end

local function onCharacterAdded(player)
	-- Reset player's jump power when the character is added
	updateJumpPower(player, function(_)
		return 0
	end)
end


for _, player in Players:GetPlayers() do
	onCharacterAdded(player)
end


local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function()
		onCharacterAdded(player)
	end)
end

local function onPlayerRemoved(player)
	updateJumpPower(player, function(_)
		return nil
	end)
end

IncreaseJumpPowerFunction.OnServerInvoke = onPurchaseJumpIncrease
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoved)