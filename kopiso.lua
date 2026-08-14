-- Box Farm GUI (полный цикл: взять → отдать → награда)
local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BoxFarmGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 230)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -115)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BackgroundTransparency = 0.95
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "📦 Box Farm"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 28, 0, 28)
closeButton.Position = UDim2.new(1, -34, 0, 4)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BackgroundTransparency = 0.8
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 16
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Drag
local dragging = false
local dragStart, startPos
local userInputService = game:GetService("UserInputService")

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

userInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local container = Instance.new("Frame")
container.Size = UDim2.new(1, -16, 1, -110)
container.Position = UDim2.new(0, 8, 0, 60)
container.BackgroundTransparency = 1
container.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0, 0)
statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
statusLabel.BackgroundTransparency = 0.8
statusLabel.Text = "⏹ Stopped"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Parent = container

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = statusLabel

-- === ПОЛЗУНОК СКОРОСТИ ===
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(1, 0, 0, 30)
speedFrame.Position = UDim2.new(0, 0, 0, 38)
speedFrame.BackgroundTransparency = 1
speedFrame.Parent = container

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.5, -5, 1, 0)
speedLabel.Position = UDim2.new(0, 0, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "⏱ Speed: 0.8s"
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.TextSize = 13
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedFrame

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.3, 0, 1, 0)
speedBox.Position = UDim2.new(0.7, 0, 0, 0)
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
speedBox.BackgroundTransparency = 0.8
speedBox.Text = "0.8"
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.TextSize = 14
speedBox.Font = Enum.Font.GothamBold
speedBox.TextXAlignment = Enum.TextXAlignment.Center
speedBox.Parent = speedFrame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 6)
speedCorner.Parent = speedBox

local delay = 0.8

speedBox.FocusLost:Connect(function()
    local val = tonumber(speedBox.Text)
    if val and val > 0 then
        delay = val
        speedLabel.Text = "⏱ Speed: " .. delay .. "s"
        print("⏱ Скорость изменена на:", delay)
    else
        speedBox.Text = tostring(delay)
    end
end)

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, 0, 0, 35)
toggleButton.Position = UDim2.new(0, 0, 0, 76)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
toggleButton.BackgroundTransparency = 0.9
toggleButton.Text = "▶ START"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 16
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = container

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

-- === ФАРМ (взять → отдать → награда) ===
local running = false
local farmCoroutine = nil
local clickCount = 0

local vahoquest = workspace:FindFirstChild("vahoquest")
local boxGive = vahoquest and vahoquest:FindFirstChild("boxgive")  -- ОТДАТЬ
local boxTake = vahoquest and vahoquest:FindFirstChild("boxTake")  -- ВЗЯТЬ
local promptGive = boxGive and boxGive:FindFirstChild("ProximityPrompt")
local promptTake = boxTake and boxTake:FindFirstChild("ProximityPrompt")

-- Третья точка (награда)
local simulatorCircle = workspace:FindFirstChild("SimulatorCircle")
local gradientCylinder = simulatorCircle and simulatorCircle:FindFirstChild("GradientCylinder")

local dialogEvent = game:GetService("ReplicatedStorage"):FindFirstChild("LoaderRemotes")
local takeMoneyEvent = dialogEvent and dialogEvent:FindFirstChild("DialogAction")

print("🔍 boxgive:", boxGive)
print("🔍 boxTake:", boxTake)
print("🔍 GradientCylinder:", gradientCylinder)
print("🔍 DialogAction:", takeMoneyEvent)

local function hasBox()
    local playerName = player.Name
    local playerModel = workspace:FindFirstChild(playerName)
    if not playerModel then return false end
    return playerModel:FindFirstChild("LoaderBox") ~= nil
end

local function takeReward()
    if takeMoneyEvent then
        takeMoneyEvent:FireServer("TakeMoney")
        print("💰 Награда получена!")
    else
        print("❌ DialogAction не найден")
    end
end

local function farmLoop()
    while running do
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local hasBoxNow = hasBox()
                hrp.CanCollide = false
                
                -- ===== ФАЗА 1: ВЗЯТЬ КОРОБКУ =====
                if not hasBoxNow then
                    if boxTake and promptTake then
                        hrp.CFrame = boxTake.CFrame + Vector3.new(0, 2, 0)
                        task.wait(0.1)
                        fireproximityprompt(promptTake)
                        clickCount = clickCount + 1
                        statusLabel.Text = "📦 Taking... (" .. clickCount .. ")"
                        print("📦 Взял коробку")
                    end
                end
                
                -- ===== ФАЗА 2: ОТДАТЬ КОРОБКУ =====
                if hasBox() then
                    if boxGive and promptGive then
                        hrp.CFrame = boxGive.CFrame + Vector3.new(0, 2, 0)
                        task.wait(0.1)
                        fireproximityprompt(promptGive)
                        statusLabel.Text = "📤 Giving... (" .. clickCount .. ")"
                        print("📤 Отдал коробку")
                    end
                end
                
                -- ===== ФАЗА 3: ПОЛУЧИТЬ НАГРАДУ =====
                if not hasBox() and gradientCylinder then
                    hrp.CFrame = gradientCylinder.CFrame + Vector3.new(0, 2, 0)
                    task.wait(0.1)
                    takeReward()
                    statusLabel.Text = "💰 Reward! (" .. clickCount .. ")"
                    print("💰 Награда получена!")
                end
                
                hrp.CanCollide = true
            end
        end
        task.wait(delay)
    end
end

local function StartBoxFarm()
    if running then return end
    
    if not boxGive or not boxTake or not promptGive or not promptTake then
        statusLabel.Text = "❌ Objects not found!"
        statusLabel.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        print("❌ Ошибка: объекты не найдены")
        return
    end
    
    if not gradientCylinder then
        print("⚠️ GradientCylinder не найден, но фарм продолжится")
    end
    
    if not takeMoneyEvent then
        print("⚠️ DialogAction не найден, награда не будет работать")
    end
    
    running = true
    clickCount = 0
    statusLabel.Text = "⚡ RUNNING"
    statusLabel.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
    toggleButton.Text = "⏹ STOP"
    toggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    
    farmCoroutine = task.spawn(farmLoop)
end

local function StopBoxFarm()
    running = false
    if farmCoroutine then
        task.cancel(farmCoroutine)
        farmCoroutine = nil
    end
    statusLabel.Text = "⏹ Stopped (" .. clickCount .. " cycles)"
    statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    toggleButton.Text = "▶ START"
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
    
    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CanCollide = true end
    end
end

toggleButton.MouseButton1Click:Connect(function()
    if running then
        StopBoxFarm()
    else
        StartBoxFarm()
    end
end)

player.CharacterAdded:Connect(function()
    if running then
        StopBoxFarm()
    end
end)

screenGui:GetPropertyChangedSignal("Parent"):Connect(function()
    if not screenGui.Parent then
        StopBoxFarm()
    end
end)

print("✅ Box Farm GUI (полный цикл) загружен")