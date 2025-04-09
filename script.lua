--===[ GUI Setup ]===--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
 
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "AnimeScriptGUI"
 
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 620)
Frame.Position = UDim2.new(0, 20, 0.5, -310)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
 
local function createButton(name, position, callback)
	local btn = Instance.new("TextButton", Frame)
	btn.Size = UDim2.new(0, 260, 0, 30)
	btn.Position = UDim2.new(0, 20, 0, position)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 16
	btn.MouseButton1Click:Connect(callback)
	return btn
end
 
--===[ Variáveis ]===--
local autoFarm, autoClick, autoRaid, autoDungeon, autoCollect, autoRoll = false, false, false, false, false, false
local savedLocation = nil
local selectedWorld = "1"
local selectedMobs = {}
local teleportDelay = 1
 
--===[ Campos adicionais GUI ]===--
local mobBox = Instance.new("TextBox", Frame)
mobBox.Size = UDim2.new(0, 260, 0, 30)
mobBox.Position = UDim2.new(0, 20, 0, 530)
mobBox.PlaceholderText = "Mobs (ex: Enemy1,Enemy2)"
mobBox.TextColor3 = Color3.new(1,1,1)
mobBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mobBox.FocusLost:Connect(function()
	selectedMobs = {}
	for mob in string.gmatch(mobBox.Text, "[^,%s]+") do
		table.insert(selectedMobs, mob)
	end
end)
 
local worldBox = Instance.new("TextBox", Frame)
worldBox.Size = UDim2.new(0, 120, 0, 30)
worldBox.Position = UDim2.new(0, 20, 0, 570)
worldBox.PlaceholderText = "Mundo (ex: 1, 2)"
worldBox.TextColor3 = Color3.new(1,1,1)
worldBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
worldBox.FocusLost:Connect(function()
	selectedWorld = worldBox.Text
end)
 
local delayBox = Instance.new("TextBox", Frame)
delayBox.Size = UDim2.new(0, 120, 0, 30)
delayBox.Position = UDim2.new(0, 160, 0, 570)
delayBox.PlaceholderText = "Delay (s)"
delayBox.Text = "1"
delayBox.TextColor3 = Color3.new(1,1,1)
delayBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
delayBox.FocusLost:Connect(function()
	local val = tonumber(delayBox.Text)
	if val then teleportDelay = val end
end)
 
--===[ Funções Automáticas ]===--
spawn(function()
	while true do
		if autoClick then
			ReplicatedStorage.RemoteEvents.Click:FireServer()
		end
		wait()
	end
end)
 
spawn(function()
	while true do
		if autoFarm then
			local mobsFolder = workspace:FindFirstChild("Enemies")
			if mobsFolder then
				for _, mob in pairs(mobsFolder:GetChildren()) do
					if #selectedMobs == 0 or table.find(selectedMobs, mob.Name) then
						if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
							Character:MoveTo(mob.HumanoidRootPart.Position + Vector3.new(0, 0, 3))
							ReplicatedStorage.RemoteEvents.Attack:FireServer(mob)
							wait(teleportDelay)
						end
					end
				end
			end
		end
		wait(1)
	end
end)
 
spawn(function()
	while true do
		if autoRaid then
			ReplicatedStorage.RemoteEvents.StartRaid:FireServer()
		end
		wait(90)
	end
end)
 
spawn(function()
	while true do
		if autoDungeon then
			ReplicatedStorage.RemoteEvents.StartDungeon:FireServer()
		end
		wait(60)
	end
end)
 
spawn(function()
	while true do
		if autoCollect then
			for _, drop in pairs(workspace.Drops:GetChildren()) do
				if drop:IsA("BasePart") then
					firetouchinterest(Character.HumanoidRootPart, drop, 0)
					wait(0.1)
					firetouchinterest(Character.HumanoidRootPart, drop, 1)
				end
			end
		end
		wait(2)
	end
end)
 
spawn(function()
	while true do
		if autoRoll then
			ReplicatedStorage.RemoteEvents.RollStar:FireServer("Basic")
		end
		wait(10)
	end
end)
 
--===[ Botões GUI ]===--
createButton("Toggle Auto Clicker", 10, function() autoClick = not autoClick end)
createButton("Toggle Auto Farm", 50, function() autoFarm = not autoFarm end)
createButton("Toggle Auto Dungeon", 90, function() autoDungeon = not autoDungeon end)
createButton("Toggle Auto Raid", 130, function() autoRaid = not autoRaid end)
createButton("Toggle Collect Drops", 170, function() autoCollect = not autoCollect end)
createButton("Toggle Auto Roll Stars", 210, function() autoRoll = not autoRoll end)
 
--===[ Teleporte Rápido ]===--
local TeleportLocations = {
	["Spawn"] = CFrame.new(0, 10, 0),
	["Dungeon"] = CFrame.new(200, 10, -300),
	["RaidZone"] = CFrame.new(-500, 10, 100),
}
 
createButton("Teleport: Spawn", 250, function()
	Character:MoveTo(TeleportLocations["Spawn"].Position)
end)
 
createButton("Teleport: Dungeon", 290, function()
	Character:MoveTo(TeleportLocations["Dungeon"].Position)
end)
 
createButton("Teleport: Raid Zone", 330, function()
	Character:MoveTo(TeleportLocations["RaidZone"].Position)
end)
 
--===[ Salvar/Carregar Posição ]===--
createButton("Save My Position", 370, function()
	if Character and Character:FindFirstChild("HumanoidRootPart") then
		savedLocation = Character.HumanoidRootPart.CFrame
	end
end)
 
createButton("Teleport to Saved", 410, function()
	if savedLocation then
		Character:SetPrimaryPartCFrame(savedLocation)
	end
end)
 
--===[ Usar Todos os Códigos de Recompensa ]===--
local allCodes = {
	"RELEASE", "UPDATE1", "UPDATE2", "50KLIKES", "100KFAVORITES",
	"1MVISITS", "SORRYFORBUGS", "HAPPY2025", "NEWYEARGIFT", "RAIDREWARD"
}
 
createButton("Use All Codes", 450, function()
	local redeemRemote = ReplicatedStorage:FindFirstChild("RemoteEvents"):FindFirstChild("RedeemCode")
	if redeemRemote then
		for _, code in ipairs(allCodes) do
			redeemRemote:FireServer(code)
			wait(1.5)
		end
	else
		warn("RedeemCode Remote não encontrado.")
	end
end)
 
--===[ Ativar Todas as Gamepasses (Fake - client sided) ]===--
createButton("Unlock All Gamepasses", 490, function()
	local function spoofGamepass(featureName, value)
		local stats = LocalPlayer:FindFirstChild("PlayerStats") or Instance.new("Folder", LocalPlayer)
		stats.Name = "PlayerStats"
		local val = stats:FindFirstChild(featureName) or Instance.new("BoolValue", stats)
		val.Name = featureName
		val.Value = value
	end
 
	local gamepasses = {
		"DoubleCoins", "DoubleDamage", "VIP", "AutoSell",
		"AutoClicker", "FastAttack", "FasterWalkspeed"
	}
 
	for _, gp in ipairs(gamepasses) do
		spoofGamepass(gp, true)
		LocalPlayer:SetAttribute(gp, true)
	end
 
	print("Gamepasses ativadas no cliente!")
end)
 
--===[ Anti Ban Simples - Fake Heartbeat ]===--
spawn(function()
	while true do
		local heartbeat = ReplicatedStorage:FindFirstChild("RemoteEvents"):FindFirstChild("Heartbeat")
		if heartbeat then
			heartbeat:FireServer()
		end
		wait(math.random(20, 40))
	end
end)
