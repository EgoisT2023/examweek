local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 400)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
title.Text = "AutoFarm GUI"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local tab1 = Instance.new("TextButton")
tab1.Size = UDim2.new(0, 110, 0, 30)
tab1.Position = UDim2.new(0, 10, 0, 40)
tab1.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
tab1.Text = "Pass Farm"
tab1.TextColor3 = Color3.fromRGB(255, 255, 255)
tab1.TextScaled = true
tab1.Font = Enum.Font.GothamBold
tab1.Parent = mainFrame

local tab2 = Instance.new("TextButton")
tab2.Size = UDim2.new(0, 110, 0, 30)
tab2.Position = UDim2.new(0, 125, 0, 40)
tab2.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
tab2.Text = "Box Farm"
tab2.TextColor3 = Color3.fromRGB(200, 200, 200)
tab2.TextScaled = true
tab2.Font = Enum.Font.GothamBold
tab2.Parent = mainFrame

local tab3 = Instance.new("TextButton")
tab3.Size = UDim2.new(0, 110, 0, 30)
tab3.Position = UDim2.new(0, 240, 0, 40)
tab3.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
tab3.Text = "Buy Items"
tab3.TextColor3 = Color3.fromRGB(200, 200, 200)
tab3.TextScaled = true
tab3.Font = Enum.Font.GothamBold
tab3.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 18
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = mainFrame

closeButton.MouseButton1Click:Connect(function()
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

local container = Instance.new("Frame")
container.Size = UDim2.new(1, -20, 1, -90)
container.Position = UDim2.new(0, 10, 0, 75)
container.BackgroundTransparency = 1
container.Parent = mainFrame

local function ClearContainer()
    for _, child in pairs(container:GetChildren()) do
        child:Destroy()
    end
end

local runningPass = false
local runningBox = false
local passCoroutine = nil
local boxCoroutine = nil

local function StartPassFarm()
    runningPass = true
    passCoroutine = task.spawn(function()
        while runningPass do
            local args1 = {
                "ClaimTier",
                10
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Cosmos"):WaitForChild("Services"):WaitForChild("SummerEventService"):WaitForChild("Remotes"):WaitForChild("TaskEvent"):FireServer(unpack(args1))
            
            task.wait()
            
            local args2 = {
                "Sell",
                "Galactic Narwhal",
                1
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Cosmos"):WaitForChild("Services"):WaitForChild("ItemService"):WaitForChild("Remotes"):WaitForChild("TaskEvent"):FireServer(unpack(args2))
            
            task.wait()
        end
    end)
end

local function StopPassFarm()
    runningPass = false
    if passCoroutine then
        task.cancel(passCoroutine)
        passCoroutine = nil
    end
end

local function StartBoxFarm()
    runningBox = true
    boxCoroutine = task.spawn(function()
        while runningBox do
            pcall(function()
                local boxPrompt = workspace:FindFirstChild("BoxPrompt")
                if boxPrompt then
                    local proximityPrompt = boxPrompt:FindFirstChild("ProximityPrompt")
                    if proximityPrompt then
                        local character = player.Character
                        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                        if humanoidRootPart then
                            humanoidRootPart.CFrame = boxPrompt.CFrame + Vector3.new(0, 3, 0)
                            fireproximityprompt(proximityPrompt)
                        end
                    end
                end
            end)
            
            pcall(function()
                local boxEvent = workspace:FindFirstChild("Map"):FindFirstChild("Map"):FindFirstChild("BoxEvent")
                if boxEvent then
                    local touchInterest = boxEvent:FindFirstChild("TouchInterest")
                    if touchInterest then
                        local character = player.Character
                        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                        if humanoidRootPart then
                            firetouchinterest(humanoidRootPart, boxEvent, 0)
                            firetouchinterest(humanoidRootPart, boxEvent, 1)
                        end
                    end
                end
            end)
            
            task.wait()
        end
    end)
end

local function StopBoxFarm()
    runningBox = false
    if boxCoroutine then
        task.cancel(boxCoroutine)
        boxCoroutine = nil
    end
end

local function CreateTab1()
    ClearContainer()
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 50)
    statusLabel.Position = UDim2.new(0, 0, 0, 0)
    statusLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    statusLabel.Text = "Stopped"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = container
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, 0, 0, 45)
    toggleButton.Position = UDim2.new(0, 0, 0, 70)
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    toggleButton.Text = "Start"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextScaled = true
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Parent = container
    
    local isRunning = false
    
    toggleButton.MouseButton1Click:Connect(function()
        if isRunning then
            StopPassFarm()
            isRunning = false
            toggleButton.Text = "Start"
            toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
            statusLabel.Text = "Stopped"
            statusLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        else
            StartPassFarm()
            isRunning = true
            toggleButton.Text = "Stop"
            toggleButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            statusLabel.Text = "Running..."
            statusLabel.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        end
    end)
end

local function CreateTab2()
    ClearContainer()
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 50)
    statusLabel.Position = UDim2.new(0, 0, 0, 0)
    statusLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    statusLabel.Text = "Stopped"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = container
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, 0, 0, 45)
    toggleButton.Position = UDim2.new(0, 0, 0, 70)
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    toggleButton.Text = "Start"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextScaled = true
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Parent = container
    
    local isRunning = false
    
    toggleButton.MouseButton1Click:Connect(function()
        if isRunning then
            StopBoxFarm()
            isRunning = false
            toggleButton.Text = "Start"
            toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
            statusLabel.Text = "Stopped"
            statusLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        else
            StartBoxFarm()
            isRunning = true
            toggleButton.Text = "Stop"
            toggleButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            statusLabel.Text = "Running..."
            statusLabel.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        end
    end)
end

local function CreateTab3()
    ClearContainer()
    
    local items = {
        "Sparkle Dumpling", "Glitter Whale", "Galactic Unicorn",
        "Glitter Octopus", "Glitter Dumpling", "Glitter Crab",
        "Supernova Bear", "Glitter Clownfish", "Glitter Axolotl",
        "Glitter Smores", "Glitter Gingerbread"
    }
    
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.ScrollBarThickness = 8
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #items * 55)
    scrollingFrame.Parent = container
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = scrollingFrame
    
    for _, itemName in ipairs(items) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 45)
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        button.Text = "Buy " .. itemName
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        button.Font = Enum.Font.GothamBold
        button.Parent = scrollingFrame
        
        button.MouseButton1Click:Connect(function()
            local args = {
                "Buy",
                itemName
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Cosmos"):WaitForChild("Services"):WaitForChild("MerchantService"):WaitForChild("Remotes"):WaitForChild("TaskEvent"):FireServer(unpack(args))
            
            button.Text = "Bought!"
            button.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
            task.wait(0.3)
            button.Text = "Buy " .. itemName
            button.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        end)
    end
end

tab1.MouseButton1Click:Connect(function()
    tab1.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    tab1.TextColor3 = Color3.fromRGB(255, 255, 255)
    tab2.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    tab2.TextColor3 = Color3.fromRGB(200, 200, 200)
    tab3.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    tab3.TextColor3 = Color3.fromRGB(200, 200, 200)
    CreateTab1()
end)

tab2.MouseButton1Click:Connect(function()
    tab2.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    tab2.TextColor3 = Color3.fromRGB(255, 255, 255)
    tab1.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    tab1.TextColor3 = Color3.fromRGB(200, 200, 200)
    tab3.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    tab3.TextColor3 = Color3.fromRGB(200, 200, 200)
    CreateTab2()
end)

tab3.MouseButton1Click:Connect(function()
    tab3.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    tab3.TextColor3 = Color3.fromRGB(255, 255, 255)
    tab1.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    tab1.TextColor3 = Color3.fromRGB(200, 200, 200)
    tab2.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    tab2.TextColor3 = Color3.fromRGB(200, 200, 200)
    CreateTab3()
end)

CreateTab1()
