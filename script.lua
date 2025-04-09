print("Script carregado com sucesso!")
-- Anime Power Simulator Script (Completo)

-- Desenvolvido para segurança, eficiência e funcionalidade
 
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TweenService = game:GetService("TweenService")

local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
 
-- Variáveis globais

local autoFarm = false

local autoClick = false

local autoDungeon = false

local autoRaid = false

local autoCollect = false

local autoRoll = false

local savedLocation = nil

local selectedWorld = nil

local selectedRollWorld = nil

local selectedMobs = {}

local teleportDelay = 1.5

local ariseBosses = {["Niris"] = true, ["Beru"] = true, ["Iron"] = true}
 
-- GUI Setup

local gui = Instance.new("ScreenGui", game.CoreGui)

gui.Name = "APS_GUI"
 
local main = Instance.new("Frame", gui)

main.Size = UDim2.new(0, 350, 0, 550)

main.Position = UDim2.new(0, 20, 0.5, -275)

main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

main.BorderSizePixel = 0

main.Visible = true
 
local toggleButton = Instance.new("TextButton", gui)

toggleButton.Size = UDim2.new(0, 100, 0, 30)

toggleButton.Position = UDim2.new(0, 10, 0, 10)

toggleButton.Text = "Open/Close"

toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

toggleButton.TextColor3 = Color3.new(1, 1, 1)
 
toggleButton.MouseButton1Click:Connect(function()

	main.Visible = not main.Visible

end)
 
UserInputService.InputBegan:Connect(function(input)

	if input.KeyCode == Enum.KeyCode.RightShift then

		main.Visible = not main.Visible

	end

end)
 
local y = 10

local function createButton(text, callback)

	local btn = Instance.new("TextButton", main)

	btn.Size = UDim2.new(0, 320, 0, 30)

	btn.Position = UDim2.new(0, 15, 0, y)

	btn.Text = text

	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

	btn.TextColor3 = Color3.new(1, 1, 1)

	btn.TextSize = 14

	btn.MouseButton1Click:Connect(callback)

	y = y + 35

end
 
-- Funções principais

createButton("Toggle Auto Farm", function() autoFarm = not autoFarm end)

createButton("Toggle Auto Click", function() autoClick = not autoClick end)

createButton("Toggle Auto Dungeon", function() autoDungeon = not autoDungeon end)

createButton("Toggle Auto Raid", function() autoRaid = not autoRaid end)

createButton("Toggle Auto Collect", function() autoCollect = not autoCollect end)

createButton("Toggle Auto Roll Stars", function() autoRoll = not autoRoll end)
 
createButton("Save Position", function()

	if Character and Character:FindFirstChild("HumanoidRootPart") then

		savedLocation = Character.HumanoidRootPart.CFrame

	end

end)
 
createButton("Teleport to Saved", function()

	if savedLocation then

		Character:SetPrimaryPartCFrame(savedLocation)

	end

end)
 
-- Código para usar todos os códigos

createButton("Use All Codes", function()

	local redeem = ReplicatedStorage.RemoteEvents:FindFirstChild("RedeemCode")

	local codes = {

		"RELEASE", "UPDATE1", "UPDATE2", "50KLIKES", "100KFAVORITES",

		"1MVISITS", "SORRYFORBUGS", "HAPPY2025", "NEWYEARGIFT", "RAIDREWARD"

	}

	for _, code in ipairs(codes) do

		redeem:FireServer(code)

		wait(1)

	end

end)
 
-- Gamepasses fake

createButton("Unlock All Gamepasses", function()

	local stats = LocalPlayer:FindFirstChild("PlayerStats") or Instance.new("Folder", LocalPlayer)

	stats.Name = "PlayerStats"

	local gamepasses = {"DoubleCoins", "DoubleDamage", "VIP", "AutoSell", "AutoClicker", "FastAttack", "FasterWalkspeed"}

	for _, gp in ipairs(gamepasses) do

		local g = stats:FindFirstChild(gp) or Instance.new("BoolValue", stats)

		g.Name = gp

		g.Value = true

		LocalPlayer:SetAttribute(gp, true)

	end

end)
 
-- Teleporte entre áreas

local teleportLocations = {

	["Spawn"] = CFrame.new(0, 10, 0),

	["Dungeon"] = CFrame.new(200, 10, -300),

	["Raid"] = CFrame.new(-500, 10, 100),

}
 
for name, cf in pairs(teleportLocations) do

	createButton("Teleport: " .. name, function()

		Character:MoveTo(cf.Position)

	end)

end
 
-- Loop Auto Click

task.spawn(function()

	while task.wait() do

		if autoClick then

			pcall(function()

				ReplicatedStorage.RemoteEvents.Click:FireServer()

			end)

		end

	end

end)
 
-- Auto Farm e Arise

task.spawn(function()

	while task.wait(teleportDelay) do

		if autoFarm then

			local world = workspace:FindFirstChild("Enemies")

			if world then

				for _, mob in ipairs(world:GetChildren()) do

					if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") then

						local mobName = mob.Name

						if mob.Humanoid.Health > 0 and selectedMobs[mobName] then

							Character:MoveTo(mob.HumanoidRootPart.Position + Vector3.new(0, 0, 3))

							ReplicatedStorage.RemoteEvents.Attack:FireServer(mob)

							if ariseBosses[mobName] then

								ReplicatedStorage.RemoteEvents.Arise:FireServer(mob)

							end

							wait(teleportDelay)

						end

					end

				end

			end

		end

	end

end)
 
-- Auto Dungeon

task.spawn(function()

	while task.wait(60) do

		if autoDungeon then

			ReplicatedStorage.RemoteEvents.StartDungeon:FireServer()

		end

	end

end)
 
-- Auto Raid

task.spawn(function()

	while task.wait(90) do

		if autoRaid then

			ReplicatedStorage.RemoteEvents.StartRaid:FireServer()

		end

	end

end)
 
-- Coletar Drops

task.spawn(function()

	while task.wait(2) do

		if autoCollect then

			for _, drop in pairs(workspace:FindFirstChild("Drops"):GetChildren()) do

				firetouchinterest(Character.HumanoidRootPart, drop, 0)

				firetouchinterest(Character.HumanoidRootPart, drop, 1)

			end

		end

	end

end)
 
-- Auto Roll

task.spawn(function()

	while task.wait(10) do

		if autoRoll and selectedRollWorld then

			ReplicatedStorage.RemoteEvents.RollStar:FireServer("Basic", selectedRollWorld)

		end

	end

end)
 
-- Detectar mundo e mobs

task.spawn(function()

	while task.wait(5) do

		local cam = workspace:FindFirstChild("Camera")

		if cam and cam:FindFirstChild("WorldName") then

			selectedWorld = cam.WorldName.Value

		end
 
		local enemies = workspace:FindFirstChild("Enemies")

		if enemies then

			for _, mob in ipairs(enemies:GetChildren()) do

				if not selectedMobs[mob.Name] then

					selectedMobs[mob.Name] = true

				end

			end

		end

	end

end)
 
-- Anti-lag

setfpscap(60)

for _, v in pairs(workspace:GetDescendants()) do

	if v:IsA("Texture") or v:IsA("Decal") then

		v:Destroy()

	end

end
 
