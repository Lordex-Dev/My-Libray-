-- // LocalScript (StarterPlayerScripts)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")

-- Prefixos permitidos
local COMMAND_PREFIXES = {"?", ";", ":", "!"}
local MAX_ARGS = 20
local frozen = false

-- // Funções gerais
local function isCommand(message, cmd)
	local messageLower = message:lower()
	for _, prefix in ipairs(COMMAND_PREFIXES) do
		local command = prefix .. cmd:lower()
		if messageLower:sub(1, #command) == command then
			return true
		end
	end
	return false
end

local function isTargetName(messageWord, myName)
	myName = myName:lower()
	return myName:sub(1, #messageWord:lower()) == messageWord:lower()
end

local function sendMessage(message)
	local chatChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
	if chatChannel then
		chatChannel:SendAsync(message)
	else
		warn("Erro ao enviar mensagem no chat.")
	end
end

-- // Ações
local function resetCharacter()
	if LocalPlayer.Character then
		LocalPlayer.Character:BreakJoints()
	end
end

local function bringToPlayer(targetPlayer)
	if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
	if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

	local targetHRP = targetPlayer.Character.HumanoidRootPart
	local offset = targetHRP.CFrame.LookVector * 5
	LocalPlayer.Character:SetPrimaryPartCFrame(targetHRP.CFrame + offset)
end

local function freezeCharacter()
	if not LocalPlayer.Character then return end
	local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if humanoid and hrp then
		frozen = true
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		hrp.Anchored = true
	end
end

local function unfreezeCharacter()
	if not LocalPlayer.Character then return end
	local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if humanoid and hrp then
		frozen = false
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
		hrp.Anchored = false
	end
end

local function kickPlayer()
	LocalPlayer:Kick("Kicked by Ryu")
end

-- // Sistema de comandos
local function onPlayerChatted(player, message)
	if player.Name ~= "Inscritos105" then return end

	-- Mantém mensagem original para preservar maiúsculas
	local messageOriginal = message
	local messageLower = message:lower()

	-- Separa as palavras (minúsculas só para comparar nomes/comandos)
	local words = {}
	for word in messageLower:gmatch("%S+") do
		table.insert(words, word)
	end

	local myName = LocalPlayer.Name:lower()

	-- ?kill
	if isCommand(messageLower, "kill") then
		for i = 2, math.min(#words, MAX_ARGS + 1) do
			if isTargetName(words[i], myName) then
				resetCharacter()
				break
			end
		end
	end

	-- ?bring
	if isCommand(messageLower, "bring") then
		for i = 2, math.min(#words, MAX_ARGS + 1) do
			if isTargetName(words[i], myName) then
				bringToPlayer(player)
				break
			end
		end
	end

	-- ?freeze
	if isCommand(messageLower, "freeze") then
		for i = 2, math.min(#words, MAX_ARGS + 1) do
			if isTargetName(words[i], myName) then
				freezeCharacter()
				break
			end
		end
	end

	-- ?unfreeze
	if isCommand(messageLower, "unfreeze") then
		for i = 2, math.min(#words, MAX_ARGS + 1) do
			if isTargetName(words[i], myName) then
				unfreezeCharacter()
				break
			end
		end
	end

	-- ?say ou ?chat
	if isCommand(messageLower, "say") or isCommand(messageLower, "chat") then
		-- Divide novamente preservando maiúsculas
		local wordsOriginal = {}
		for word in messageOriginal:gmatch("%S+") do
			table.insert(wordsOriginal, word)
		end

		if #wordsOriginal < 3 then return end

		local targetNameLower = wordsOriginal[2]:lower()
		if isTargetName(targetNameLower, myName) then
			local startIndex = messageOriginal:find(wordsOriginal[3])
			if startIndex then
				local phrase = messageOriginal:sub(startIndex)
				sendMessage(phrase)
			end
		end
	end

	-- ?kick
	if isCommand(messageLower, "kick") then
		if #words < 2 then return end
		local targetNameLower = words[2]:lower()
		if isTargetName(targetNameLower, myName) then
			kickPlayer()
		end
	end
end

-- // Conectar eventos de chat
local function connectPlayers()
	for _, player in ipairs(Players:GetPlayers()) do
		player.Chatted:Connect(function(msg)
			onPlayerChatted(player, msg)
		end)
	end

	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(msg)
			onPlayerChatted(player, msg)
		end)
	end)
end

connectPlayers()
