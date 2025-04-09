
--===[ GUI Setup ]===--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "AnimeScriptGUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 540)
Frame.Position = UDim2.new(0, 20, 0.5, -270)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0

--===[ Toggle Menu Button ]===--
local toggleButton = Instance.new("TextButton", ScreenGui)
toggleButton.Size = UDim2.new(0, 100, 0, 30)
toggleButton.Position = UDim2.new(0, 20, 0, 20)
toggleButton.Text = "Open/Close Menu"
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 14

toggleButton.MouseButton1Click:Connect(function()
	Frame.Visible = not Frame.Visible
end)

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

--===[ Auto Functions ]===--
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
			local mobs = workspace:FindFirstChild("Enemies")
			if mobs then
				for _, mob in pairs(mobs:GetChildren()) do
					if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
						Character:MoveTo(mob.HumanoidRootPart.Position + Vector3.new(0, 0, 3))
						ReplicatedStorage.RemoteEvents.Attack:FireServer(mob)
						wait(0.5)
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
