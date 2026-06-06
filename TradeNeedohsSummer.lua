local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmGUI"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 220)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
title.Text = "AutoFarm - Summer Event"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 50)
statusLabel.Position = UDim2.new(0.05, 0, 0.25, 0)
statusLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
statusLabel.Text = "Stopped"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextWrapped = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.Parent = mainFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = statusLabel

local counterLabel = Instance.new("TextLabel")
counterLabel.Size = UDim2.new(0.9, 0, 0, 30)
counterLabel.Position = UDim2.new(0.05, 0, 0.55, 0)
counterLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
counterLabel.Text = "Completed: 0"
counterLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
counterLabel.TextWrapped = true
counterLabel.Font = Enum.Font.Gotham
counterLabel.TextSize = 12
counterLabel.Parent = mainFrame

local counterCorner = Instance.new("UICorner")
counterCorner.CornerRadius = UDim.new(0, 6)
counterCorner.Parent = counterLabel

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8, 0, 0, 45)
toggleButton.Position = UDim2.new(0.1, 0, 0.75, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
toggleButton.Text = "Start"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleButton

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 18
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    running = false
    screenGui:Destroy()
end)

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

local running = false
local farmCoroutine = nil
local iterationCount = 0

local function DoFarmCycle()
    local args1 = {
        "ClaimTier",
        10
    }
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local cosmos = replicatedStorage:FindFirstChild("Cosmos")
    local services = cosmos and cosmos:FindFirstChild("Services")
    local summerService = services and services:FindFirstChild("SummerEventService")
    local remotes = summerService and summerService:FindFirstChild("Remotes")
    local taskEvent = remotes and remotes:FindFirstChild("TaskEvent")
    
    if taskEvent then
        taskEvent:FireServer(unpack(args1))
    end
    
    task.wait()
    
    local args2 = {
        "Sell",
        "Galactic Narwhal",
        1
    }
    local itemService = services and services:FindFirstChild("ItemService")
    local itemRemotes = itemService and itemService:FindFirstChild("Remotes")
    local itemTaskEvent = itemRemotes and itemRemotes:FindFirstChild("TaskEvent")
    
    if itemTaskEvent then
        itemTaskEvent:FireServer(unpack(args2))
    end
end

local function StartFarmLoop()
    iterationCount = 0
    while running do
        local success, err = pcall(function()
            DoFarmCycle()
        end)
        
        if not success then
            statusLabel.Text = "Error: " .. tostring(err):sub(1, 50)
            statusLabel.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        else
            iterationCount = iterationCount + 1
            counterLabel.Text = "Completed: " .. iterationCount
            statusLabel.Text = "Running... cycle " .. iterationCount
            statusLabel.BackgroundColor3 = Color3.fromRGB(0, 120, 100)
        end
        
        task.wait()
    end
end

toggleButton.MouseButton1Click:Connect(function()
    if running then
        running = false
        toggleButton.Text = "Start"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        statusLabel.Text = "Stopped"
        statusLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    else
        running = true
        toggleButton.Text = "Stop"
        toggleButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        statusLabel.Text = "Starting..."
        statusLabel.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            StartFarmLoop()
        end)
        
        statusLabel.Text = "Running"
        statusLabel.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    end
end)