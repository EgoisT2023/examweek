-- Create ScreenGui
local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FoodCannonTracker"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Variables
local isActive = false
local trackingConnection = nil
local auraConnection = nil
local moneyActive = false
local currentFoodType = "Candy"
local currentMode = "Single"
local auraRadius = 10
local auraFoodType = "Candy"
local replicatorEvent = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("FoodCannon"):WaitForChild("GetItem")
local battlepassEvent = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("Battlepass"):WaitForChild("BP_ClaimReward")

-- Get player CFrame by name
local function getPlayerCFrameByName(username)
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr.Name:lower() == username:lower() then
            local character = plr.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if hrp then
                return hrp.CFrame, plr
            end
        end
    end
    return nil, nil
end

-- Generate circle positions
local function getCirclePositions(centerCFrame, radius, count)
    local positions = {}
    local angleStep = (2 * math.pi) / count
    
    for i = 0, count - 1 do
        local angle = angleStep * i
        local xOffset = math.cos(angle) * radius
        local zOffset = math.sin(angle) * radius
        local offset = centerCFrame:VectorToWorldSpace(Vector3.new(xOffset, 0, zOffset))
        local position = centerCFrame.Position + offset
        positions[i + 1] = CFrame.new(position)
    end
    
    return positions
end

-- Single tracking
local function startTracking(username)
    if trackingConnection then
        trackingConnection:Disconnect()
        trackingConnection = nil
    end
    
    trackingConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isActive or currentMode ~= "Single" then return end
        
        local targetCFrame, targetPlayer = getPlayerCFrameByName(username)
        if targetCFrame and targetPlayer then
            local args = {currentFoodType, targetCFrame}
            replicatorEvent:InvokeServer(unpack(args))
        end
    end)
end

-- Aura tracking
local function startAura(username)
    if auraConnection then
        auraConnection:Disconnect()
        auraConnection = nil
    end
    
    auraConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isActive or currentMode ~= "Aura" then return end
        
        local targetCFrame, targetPlayer = getPlayerCFrameByName(username)
        if targetCFrame and targetPlayer then
            local positions = getCirclePositions(targetCFrame, auraRadius, 8)
            
            for _, posCFrame in ipairs(positions) do
                local args = {auraFoodType, posCFrame}
                replicatorEvent:InvokeServer(unpack(args))
            end
        end
    end)
end

-- Stop all trackers
local function stopTracking()
    if trackingConnection then
        trackingConnection:Disconnect()
        trackingConnection = nil
    end
    if auraConnection then
        auraConnection:Disconnect()
        auraConnection = nil
    end
    isActive = false
end

-- Get players by prefix
local function getPlayersByPrefix(prefix)
    if prefix == "" then return {} end
    local matches = {}
    local lowerPrefix = prefix:lower()
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr.Name:lower():sub(1, #lowerPrefix) == lowerPrefix then
            table.insert(matches, plr.Name)
        end
    end
    table.sort(matches)
    return matches
end

-- Create dropdown
local function createDropdown(parent, textBox)
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(1, 0, 0, 0)
    dropdown.Position = UDim2.new(0, 0, 1, 2)
    dropdown.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    dropdown.BackgroundTransparency = 0.05
    dropdown.BorderSizePixel = 0
    dropdown.Visible = false
    dropdown.ZIndex = 10
    dropdown.Parent = parent
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 5)
    dropdownCorner.Parent = dropdown
    
    local dropdownList = Instance.new("ScrollingFrame")
    dropdownList.Size = UDim2.new(1, 0, 1, 0)
    dropdownList.BackgroundTransparency = 1
    dropdownList.BorderSizePixel = 0
    dropdownList.ScrollBarThickness = 5
    dropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
    dropdownList.Parent = dropdown
    
    local dropdownListLayout = Instance.new("UIListLayout")
    dropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    dropdownListLayout.Padding = UDim.new(0, 2)
    dropdownListLayout.Parent = dropdownList
    
    local function updateDropdown(prefix)
        for _, child in ipairs(dropdownList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        local matches = getPlayersByPrefix(prefix)
        local height = 0
        
        for _, match in ipairs(matches) do
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, -10, 0, 30)
            button.Position = UDim2.new(0, 5, 0, height)
            button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            button.Text = match
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.TextSize = 14
            button.TextXAlignment = Enum.TextXAlignment.Left
            button.Font = Enum.Font.Gotham
            button.BorderSizePixel = 0
            button.ZIndex = 10
            button.Parent = dropdownList
            
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 3)
            buttonCorner.Parent = button
            
            button.MouseButton1Click:Connect(function()
                textBox.Text = match
                dropdown.Visible = false
            end)
            
            button.MouseEnter:Connect(function()
                button.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
            end)
            
            button.MouseLeave:Connect(function()
                button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            end)
            
            height = height + 32
        end
        
        if #matches > 0 then
            local maxHeight = math.min(height, 150)
            dropdown.Size = UDim2.new(1, 0, 0, maxHeight)
            dropdownList.CanvasSize = UDim2.new(0, 0, 0, height)
            dropdown.Visible = true
        else
            dropdown.Visible = false
        end
    end
    
    textBox:GetPropertyChangedSignal("Text"):Connect(function()
        if textBox:IsFocused() then
            updateDropdown(textBox.Text)
        end
    end)
    
    textBox.Focused:Connect(function()
        updateDropdown(textBox.Text)
    end)
    
    textBox.FocusLost:Connect(function()
        task.wait(0.2)
        dropdown.Visible = false
    end)
    
    return dropdown
end

-- Create GUI
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 480, 0, 500)
mainFrame.Position = UDim2.new(0.5, -240, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = true
mainFrame.Parent = screenGui

local corners = Instance.new("UICorner")
corners.CornerRadius = UDim.new(0, 10)
corners.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Phantom.Code AMR"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Tab container
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(0.98, 0, 0, 40)
tabContainer.Position = UDim2.new(0.01, 0, 0, 40)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

-- Single Tab
local singleTab = Instance.new("TextButton")
singleTab.Size = UDim2.new(0.32, 0, 1, 0)
singleTab.Position = UDim2.new(0, 0, 0, 0)
singleTab.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
singleTab.Text = "🎯 SINGLE"
singleTab.TextColor3 = Color3.fromRGB(255, 255, 255)
singleTab.TextScaled = true
singleTab.Font = Enum.Font.GothamBold
singleTab.Parent = tabContainer

local singleCorner = Instance.new("UICorner")
singleCorner.CornerRadius = UDim.new(0, 8)
singleCorner.Parent = singleTab

-- Aura Tab
local auraTab = Instance.new("TextButton")
auraTab.Size = UDim2.new(0.32, 0, 1, 0)
auraTab.Position = UDim2.new(0.34, 0, 0, 0)
auraTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
auraTab.Text = "✨ AURA"
auraTab.TextColor3 = Color3.fromRGB(255, 255, 255)
auraTab.TextScaled = true
auraTab.Font = Enum.Font.GothamBold
auraTab.Parent = tabContainer

local auraCorner = Instance.new("UICorner")
auraCorner.CornerRadius = UDim.new(0, 8)
auraCorner.Parent = auraTab

-- Money Tab
local moneyTab = Instance.new("TextButton")
moneyTab.Size = UDim2.new(0.32, 0, 1, 0)
moneyTab.Position = UDim2.new(0.68, 0, 0, 0)
moneyTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
moneyTab.Text = "💰 MONEY"
moneyTab.TextColor3 = Color3.fromRGB(255, 255, 255)
moneyTab.TextScaled = true
moneyTab.Font = Enum.Font.GothamBold
moneyTab.Parent = tabContainer

local moneyCorner = Instance.new("UICorner")
moneyCorner.CornerRadius = UDim.new(0, 8)
moneyCorner.Parent = moneyTab

-- Content frames
local singleContent = Instance.new("Frame")
singleContent.Size = UDim2.new(0.9, 0, 0, 380)
singleContent.Position = UDim2.new(0.05, 0, 0, 90)
singleContent.BackgroundTransparency = 1
singleContent.Visible = true
singleContent.Parent = mainFrame

local auraContent = Instance.new("Frame")
auraContent.Size = UDim2.new(0.9, 0, 0, 380)
auraContent.Position = UDim2.new(0.05, 0, 0, 90)
auraContent.BackgroundTransparency = 1
auraContent.Visible = false
auraContent.Parent = mainFrame

local moneyContent = Instance.new("Frame")
moneyContent.Size = UDim2.new(0.9, 0, 0, 380)
moneyContent.Position = UDim2.new(0.05, 0, 0, 90)
moneyContent.BackgroundTransparency = 1
moneyContent.Visible = false
moneyContent.Parent = mainFrame

-- ========== SINGLE SHOT CONTENT ==========
local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, 0, 0, 40)
textBox.Position = UDim2.new(0, 0, 0, 0)
textBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.PlaceholderText = "Enter player name..."
textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
textBox.Text = ""
textBox.Font = Enum.Font.Gotham
textBox.TextSize = 14
textBox.ClearTextOnFocus = false
textBox.Parent = singleContent

local textBoxCorner = Instance.new("UICorner")
textBoxCorner.CornerRadius = UDim.new(0, 5)
textBoxCorner.Parent = textBox
createDropdown(singleContent, textBox)

local foodTypeLabel = Instance.new("TextLabel")
foodTypeLabel.Size = UDim2.new(1, 0, 0, 25)
foodTypeLabel.Position = UDim2.new(0, 0, 0, 50)
foodTypeLabel.BackgroundTransparency = 1
foodTypeLabel.Text = "Select food type:"
foodTypeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
foodTypeLabel.TextSize = 12
foodTypeLabel.Font = Enum.Font.Gotham
foodTypeLabel.Parent = singleContent

local candyButton = Instance.new("TextButton")
candyButton.Size = UDim2.new(0.48, 0, 0, 32)
candyButton.Position = UDim2.new(0, 0, 0, 80)
candyButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
candyButton.Text = "🍬 CANDY"
candyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
candyButton.TextScaled = true
candyButton.Font = Enum.Font.GothamBold
candyButton.Parent = singleContent

local candyCornButton = Instance.new("TextButton")
candyCornButton.Size = UDim2.new(0.48, 0, 0, 32)
candyCornButton.Position = UDim2.new(0.52, 0, 0, 80)
candyCornButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
candyCornButton.Text = "🌽 CANDYCORN"
candyCornButton.TextColor3 = Color3.fromRGB(255, 255, 255)
candyCornButton.TextScaled = true
candyCornButton.Font = Enum.Font.GothamBold
candyCornButton.Parent = singleContent

local candyCaneButton = Instance.new("TextButton")
candyCaneButton.Size = UDim2.new(0.48, 0, 0, 32)
candyCaneButton.Position = UDim2.new(0, 0, 0, 120)
candyCaneButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
candyCaneButton.Text = "🍬🍫 CANDYCANE"
candyCaneButton.TextColor3 = Color3.fromRGB(255, 255, 255)
candyCaneButton.TextScaled = true
candyCaneButton.Font = Enum.Font.GothamBold
candyCaneButton.Parent = singleContent

local gingerbreadButton = Instance.new("TextButton")
gingerbreadButton.Size = UDim2.new(0.48, 0, 0, 32)
gingerbreadButton.Position = UDim2.new(0.52, 0, 0, 120)
gingerbreadButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
gingerbreadButton.Text = "🍪 GINGERBREAD"
gingerbreadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
gingerbreadButton.TextScaled = true
gingerbreadButton.Font = Enum.Font.GothamBold
gingerbreadButton.Parent = singleContent

local buckButton = Instance.new("TextButton")
buckButton.Size = UDim2.new(0.48, 0, 0, 32)
buckButton.Position = UDim2.new(0.26, 0, 0, 160)
buckButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
buckButton.Text = "🦌 BUCK"
buckButton.TextColor3 = Color3.fromRGB(255, 255, 255)
buckButton.TextScaled = true
buckButton.Font = Enum.Font.GothamBold
buckButton.Parent = singleContent

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.45, 0, 0, 45)
toggleButton.Position = UDim2.new(0, 0, 0, 210)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
toggleButton.Text = "▶ ENABLE"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = singleContent

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0.45, 0, 0, 45)
closeButton.Position = UDim2.new(0.55, 0, 0, 210)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "🔽 MINIMIZE"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = singleContent

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 0, 40)
statusText.Position = UDim2.new(0, 0, 0, 270)
statusText.BackgroundTransparency = 1
statusText.Text = "📡 Status: Waiting"
statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
statusText.TextSize = 13
statusText.Font = Enum.Font.Gotham
statusText.Parent = singleContent

-- ========== AURA CONTENT ==========
local textBox3 = Instance.new("TextBox")
textBox3.Size = UDim2.new(1, 0, 0, 40)
textBox3.Position = UDim2.new(0, 0, 0, 0)
textBox3.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
textBox3.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox3.PlaceholderText = "Enter player name..."
textBox3.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
textBox3.Text = ""
textBox3.Font = Enum.Font.Gotham
textBox3.TextSize = 14
textBox3.ClearTextOnFocus = false
textBox3.Parent = auraContent

local textBoxCorner3 = Instance.new("UICorner")
textBoxCorner3.CornerRadius = UDim.new(0, 5)
textBoxCorner3.Parent = textBox3
createDropdown(auraContent, textBox3)

local auraFoodLabel = Instance.new("TextLabel")
auraFoodLabel.Size = UDim2.new(1, 0, 0, 25)
auraFoodLabel.Position = UDim2.new(0, 0, 0, 50)
auraFoodLabel.BackgroundTransparency = 1
auraFoodLabel.Text = "Select food type for aura:"
auraFoodLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
auraFoodLabel.TextSize = 12
auraFoodLabel.Font = Enum.Font.Gotham
auraFoodLabel.Parent = auraContent

local auraCandyButton = Instance.new("TextButton")
auraCandyButton.Size = UDim2.new(0.48, 0, 0, 32)
auraCandyButton.Position = UDim2.new(0, 0, 0, 80)
auraCandyButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
auraCandyButton.Text = "🍬 CANDY"
auraCandyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
auraCandyButton.TextScaled = true
auraCandyButton.Font = Enum.Font.GothamBold
auraCandyButton.Parent = auraContent

local auraCornButton = Instance.new("TextButton")
auraCornButton.Size = UDim2.new(0.48, 0, 0, 32)
auraCornButton.Position = UDim2.new(0.52, 0, 0, 80)
auraCornButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
auraCornButton.Text = "🌽 CANDYCORN"
auraCornButton.TextColor3 = Color3.fromRGB(255, 255, 255)
auraCornButton.TextScaled = true
auraCornButton.Font = Enum.Font.GothamBold
auraCornButton.Parent = auraContent

local auraCaneButton = Instance.new("TextButton")
auraCaneButton.Size = UDim2.new(0.48, 0, 0, 32)
auraCaneButton.Position = UDim2.new(0, 0, 0, 120)
auraCaneButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
auraCaneButton.Text = "🍬🍫 CANDYCANE"
auraCaneButton.TextColor3 = Color3.fromRGB(255, 255, 255)
auraCaneButton.TextScaled = true
auraCaneButton.Font = Enum.Font.GothamBold
auraCaneButton.Parent = auraContent

local auraGingerButton = Instance.new("TextButton")
auraGingerButton.Size = UDim2.new(0.48, 0, 0, 32)
auraGingerButton.Position = UDim2.new(0.52, 0, 0, 120)
auraGingerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
auraGingerButton.Text = "🍪 GINGERBREAD"
auraGingerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
auraGingerButton.TextScaled = true
auraGingerButton.Font = Enum.Font.GothamBold
auraGingerButton.Parent = auraContent

local auraBuckButton = Instance.new("TextButton")
auraBuckButton.Size = UDim2.new(0.48, 0, 0, 32)
auraBuckButton.Position = UDim2.new(0.26, 0, 0, 160)
auraBuckButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
auraBuckButton.Text = "🦌 BUCK"
auraBuckButton.TextColor3 = Color3.fromRGB(255, 255, 255)
auraBuckButton.TextScaled = true
auraBuckButton.Font = Enum.Font.GothamBold
auraBuckButton.Parent = auraContent

local radiusLabel = Instance.new("TextLabel")
radiusLabel.Size = UDim2.new(0.35, 0, 0, 30)
radiusLabel.Position = UDim2.new(0, 0, 0, 205)
radiusLabel.BackgroundTransparency = 1
radiusLabel.Text = "Aura radius:"
radiusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
radiusLabel.TextSize = 13
radiusLabel.Font = Enum.Font.Gotham
radiusLabel.TextXAlignment = Enum.TextXAlignment.Left
radiusLabel.Parent = auraContent

local radiusBox = Instance.new("TextBox")
radiusBox.Size = UDim2.new(0.55, 0, 0, 35)
radiusBox.Position = UDim2.new(0.42, 0, 0, 203)
radiusBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
radiusBox.TextColor3 = Color3.fromRGB(255, 255, 255)
radiusBox.Text = "10"
radiusBox.PlaceholderText = "Radius (1-30)"
radiusBox.Font = Enum.Font.Gotham
radiusBox.TextSize = 14
radiusBox.Parent = auraContent

local radiusCorner = Instance.new("UICorner")
radiusCorner.CornerRadius = UDim.new(0, 5)
radiusCorner.Parent = radiusBox

radiusBox:GetPropertyChangedSignal("Text"):Connect(function()
    local newRadius = tonumber(radiusBox.Text)
    if newRadius and newRadius > 0 then
        auraRadius = math.min(newRadius, 30)
        radiusBox.Text = tostring(auraRadius)
    elseif radiusBox.Text ~= "" then
        radiusBox.Text = tostring(auraRadius)
    end
end)

local toggleButton3 = Instance.new("TextButton")
toggleButton3.Size = UDim2.new(0.45, 0, 0, 45)
toggleButton3.Position = UDim2.new(0, 0, 0, 250)
toggleButton3.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
toggleButton3.Text = "▶ ENABLE"
toggleButton3.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton3.TextScaled = true
toggleButton3.Font = Enum.Font.GothamBold
toggleButton3.Parent = auraContent

local closeButton3 = Instance.new("TextButton")
closeButton3.Size = UDim2.new(0.45, 0, 0, 45)
closeButton3.Position = UDim2.new(0.55, 0, 0, 250)
closeButton3.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton3.Text = "🔽 MINIMIZE"
closeButton3.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton3.TextScaled = true
closeButton3.Font = Enum.Font.GothamBold
closeButton3.Parent = auraContent

local statusText3 = Instance.new("TextLabel")
statusText3.Size = UDim2.new(1, 0, 0, 40)
statusText3.Position = UDim2.new(0, 0, 0, 310)
statusText3.BackgroundTransparency = 1
statusText3.Text = "📡 Status: Waiting"
statusText3.TextColor3 = Color3.fromRGB(200, 200, 200)
statusText3.TextSize = 13
statusText3.Font = Enum.Font.Gotham
statusText3.Parent = auraContent

-- ========== MONEY CONTENT ==========
local moneyTitle = Instance.new("TextLabel")
moneyTitle.Size = UDim2.new(1, 0, 0, 30)
moneyTitle.Position = UDim2.new(0, 0, 0, 0)
moneyTitle.BackgroundTransparency = 1
moneyTitle.Text = "💰 Auto Farm"
moneyTitle.TextColor3 = Color3.fromRGB(255, 200, 100)
moneyTitle.TextSize = 14
moneyTitle.Font = Enum.Font.GothamBold
moneyTitle.Parent = moneyContent

local rewardLabel = Instance.new("TextLabel")
rewardLabel.Size = UDim2.new(1, 0, 0, 25)
rewardLabel.Position = UDim2.new(0, 0, 0, 40)
rewardLabel.BackgroundTransparency = 1
rewardLabel.Text = "By @SVINYABG"
rewardLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
rewardLabel.TextSize = 12
rewardLabel.Font = Enum.Font.Gotham
rewardLabel.Parent = moneyContent

local rateLabel = Instance.new("TextLabel")
rateLabel.Size = UDim2.new(0.4, 0, 0, 30)
rateLabel.Position = UDim2.new(0, 0, 0, 75)
rateLabel.BackgroundTransparency = 1
rateLabel.Text = "Rate (times to execute):"
rateLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
rateLabel.TextSize = 13
rateLabel.Font = Enum.Font.Gotham
rateLabel.TextXAlignment = Enum.TextXAlignment.Left
rateLabel.Parent = moneyContent

local rateBox = Instance.new("TextBox")
rateBox.Size = UDim2.new(0.5, 0, 0, 35)
rateBox.Position = UDim2.new(0.48, 0, 0, 73)
rateBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
rateBox.TextColor3 = Color3.fromRGB(255, 255, 255)
rateBox.Text = "1000"
rateBox.PlaceholderText = "1-9999"
rateBox.Font = Enum.Font.Gotham
rateBox.TextSize = 14
rateBox.Parent = moneyContent

local rateCorner = Instance.new("UICorner")
rateCorner.CornerRadius = UDim.new(0, 5)
rateCorner.Parent = rateBox

local moneyRate = 1000

local function updateRate()
    local num = tonumber(rateBox.Text)
    if num then
        moneyRate = math.clamp(math.floor(num), 1, 9999)
        rateBox.Text = tostring(moneyRate)
    elseif rateBox.Text ~= "" then
        rateBox.Text = tostring(moneyRate)
    end
end

rateBox:GetPropertyChangedSignal("Text"):Connect(updateRate)

local moneyStatusText = Instance.new("TextLabel")
moneyStatusText.Size = UDim2.new(1, 0, 0, 40)
moneyStatusText.Position = UDim2.new(0, 0, 0, 130)
moneyStatusText.BackgroundTransparency = 1
moneyStatusText.Text = "💰 Status: Ready"
moneyStatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
moneyStatusText.TextSize = 13
moneyStatusText.Font = Enum.Font.Gotham
moneyStatusText.Parent = moneyContent

local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(1, 0, 0, 20)
progressBar.Position = UDim2.new(0, 0, 0, 180)
progressBar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
progressBar.BorderSizePixel = 0
progressBar.Parent = moneyContent

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
progressFill.BorderSizePixel = 0
progressFill.Parent = progressBar

local progressCorner = Instance.new("UICorner")
progressCorner.CornerRadius = UDim.new(1, 0)
progressCorner.Parent = progressBar

local toggleMoneyButton = Instance.new("TextButton")
toggleMoneyButton.Size = UDim2.new(0.8, 0, 0, 50)
toggleMoneyButton.Position = UDim2.new(0.1, 0, 0, 220)
toggleMoneyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
toggleMoneyButton.Text = "💰 START FARM"
toggleMoneyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleMoneyButton.TextScaled = true
toggleMoneyButton.Font = Enum.Font.GothamBold
toggleMoneyButton.Parent = moneyContent

local moneyButtonCorner = Instance.new("UICorner")
moneyButtonCorner.CornerRadius = UDim.new(0, 8)
moneyButtonCorner.Parent = toggleMoneyButton

local closeButton4 = Instance.new("TextButton")
closeButton4.Size = UDim2.new(0.8, 0, 0, 45)
closeButton4.Position = UDim2.new(0.1, 0, 0, 290)
closeButton4.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton4.Text = "🔽 MINIMIZE"
closeButton4.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton4.TextScaled = true
closeButton4.Font = Enum.Font.GothamBold
closeButton4.Parent = moneyContent

local closeCorner4 = Instance.new("UICorner")
closeCorner4.CornerRadius = UDim.new(0, 5)
closeCorner4.Parent = closeButton4

-- Icon button
local iconButton = Instance.new("ImageButton")
iconButton.Size = UDim2.new(0, 50, 0, 50)
iconButton.Position = UDim2.new(0.85, 0, 0.8, 0)
iconButton.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
iconButton.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
iconButton.Visible = false
iconButton.Parent = screenGui

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(1, 0)
iconCorner.Parent = iconButton

local iconText = Instance.new("TextLabel")
iconText.Size = UDim2.new(1, 0, 1, 0)
iconText.BackgroundTransparency = 1
iconText.Text = "🎯"
iconText.TextColor3 = Color3.fromRGB(255, 255, 255)
iconText.TextScaled = true
iconText.Font = Enum.Font.GothamBold
iconText.Parent = iconButton

-- Money farm function - EXECUTES INSTANTLY (no delay)
local currentIteration = 0
local moneyTask = nil

local function executeMoneyFarm()
    local args = {1, "Basic", "Stars x4000"}
    
    for i = 1, moneyRate do
        pcall(function()
            battlepassEvent:InvokeServer(unpack(args))
        end)
        currentIteration = i
        
        -- Update progress
        local percent = i / moneyRate
        progressFill.Size = UDim2.new(percent, 0, 1, 0)
        moneyStatusText.Text = "💰 Status: RUNNING (" .. i .. " / " .. moneyRate .. ")"
        
        -- NO DELAY - executes as fast as possible
    end
    
    moneyStatusText.Text = "💰 Status: COMPLETED (" .. moneyRate .. " times)"
    progressFill.Size = UDim2.new(1, 0, 1, 0)
    task.wait(2)
    if not moneyActive then
        progressFill.Size = UDim2.new(0, 0, 1, 0)
        moneyStatusText.Text = "💰 Status: Ready"
    end
    moneyActive = false
    toggleMoneyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    toggleMoneyButton.Text = "💰 START FARM"
end

local function startMoneyFarm()
    if moneyTask then
        task.cancel(moneyTask)
        moneyTask = nil
    end
    
    moneyActive = true
    currentIteration = 0
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    moneyStatusText.Text = "💰 Status: STARTING..."
    toggleMoneyButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    toggleMoneyButton.Text = "🛑 STOP FARM"
    
    moneyTask = task.spawn(function()
        executeMoneyFarm()
    end)
end

local function stopMoneyFarm()
    moneyActive = false
    if moneyTask then
        task.cancel(moneyTask)
        moneyTask = nil
    end
    toggleMoneyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    toggleMoneyButton.Text = "💰 START FARM"
    moneyStatusText.Text = "💰 Status: STOPPED"
    progressFill.Size = UDim2.new(0, 0, 1, 0)
end

-- Money farm toggle
local function onToggleMoney()
    if not moneyActive then
        if isActive then
            stopTracking()
            isActive = false
        end
        updateRate()
        startMoneyFarm()
    else
        stopMoneyFarm()
    end
end

toggleMoneyButton.MouseButton1Click:Connect(onToggleMoney)

-- Single shot food type selection
candyButton.MouseButton1Click:Connect(function()
    currentFoodType = "Candy"
    candyButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    candyCornButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    candyCaneButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    gingerbreadButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    buckButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    iconText.Text = "🍬"
end)

candyCornButton.MouseButton1Click:Connect(function()
    currentFoodType = "CandyCorn"
    candyCornButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    candyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    candyCaneButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    gingerbreadButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    buckButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    iconText.Text = "🌽"
end)

candyCaneButton.MouseButton1Click:Connect(function()
    currentFoodType = "CandyCane"
    candyCaneButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    candyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    candyCornButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    gingerbreadButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    buckButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    iconText.Text = "🍬🍫"
end)

gingerbreadButton.MouseButton1Click:Connect(function()
    currentFoodType = "Gingerbread"
    gingerbreadButton.BackgroundColor3 = Color3.fromRGB(160, 100, 50)
    candyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    candyCornButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    candyCaneButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    buckButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    iconText.Text = "🍪"
end)

buckButton.MouseButton1Click:Connect(function()
    currentFoodType = "Buck"
    buckButton.BackgroundColor3 = Color3.fromRGB(139, 69, 19)
    candyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    candyCornButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    candyCaneButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    gingerbreadButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    iconText.Text = "🦌"
end)

-- Aura food type selection
auraCandyButton.MouseButton1Click:Connect(function()
    auraFoodType = "Candy"
    auraCandyButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    auraCornButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    auraCaneButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    auraGingerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    auraBuckButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
end)

auraCornButton.MouseButton1Click:Connect(function()
    auraFoodType = "CandyCorn"
    auraCornButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    auraCandyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    auraCaneButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    auraGingerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    auraBuckButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
end)

auraCaneButton.MouseButton1Click:Connect(function()
    auraFoodType = "CandyCane"
    auraCaneButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    auraCandyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    auraCornButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    auraGingerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    auraBuckButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
end)

auraGingerButton.MouseButton1Click:Connect(function()
    auraFoodType = "Gingerbread"
    auraGingerButton.BackgroundColor3 = Color3.fromRGB(160, 100, 50)
    auraCandyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    auraCornButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    auraCaneButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    auraBuckButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
end)

auraBuckButton.MouseButton1Click:Connect(function()
    auraFoodType = "Buck"
    auraBuckButton.BackgroundColor3 = Color3.fromRGB(139, 69, 19)
    auraCandyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    auraCornButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    auraCaneButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    auraGingerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
end)

-- Tab switching
singleTab.MouseButton1Click:Connect(function()
    singleTab.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    auraTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    moneyTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    singleContent.Visible = true
    auraContent.Visible = false
    moneyContent.Visible = false
    currentMode = "Single"
    iconText.Text = "🎯"
    
    if moneyActive then
        stopMoneyFarm()
    end
    
    if isActive and currentMode ~= "Single" then
        local targetName = textBox.Text
        if targetName ~= "" then
            stopTracking()
            currentMode = "Single"
            isActive = true
            startTracking(targetName)
            statusText.Text = "📡 Status: Tracking " .. targetName .. " (" .. currentFoodType .. ")"
        end
    end
end)

auraTab.MouseButton1Click:Connect(function()
    auraTab.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
    singleTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    moneyTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    singleContent.Visible = false
    auraContent.Visible = true
    moneyContent.Visible = false
    currentMode = "Aura"
    iconText.Text = "✨"
    
    if moneyActive then
        stopMoneyFarm()
    end
    
    if isActive and currentMode ~= "Aura" then
        local targetName = textBox3.Text
        if targetName ~= "" then
            stopTracking()
            currentMode = "Aura"
            isActive = true
            startAura(targetName)
            statusText3.Text = "📡 Status: Aura (" .. auraFoodType .. ") around " .. targetName .. " (radius " .. auraRadius .. ")"
        end
    end
end)

moneyTab.MouseButton1Click:Connect(function()
    moneyTab.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    singleTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    auraTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    singleContent.Visible = false
    auraContent.Visible = false
    moneyContent.Visible = true
    currentMode = "Money"
    iconText.Text = "💰"
    
    if isActive then
        stopTracking()
        isActive = false
    end
end)

-- Single enable/disable
local function onToggleSingle()
    local targetName = textBox.Text
    if targetName == "" then
        statusText.Text = "❌ Error: Enter a name!"
        return
    end
    
    if not isActive or currentMode ~= "Single" then
        if moneyActive then
            stopMoneyFarm()
        end
        stopTracking()
        currentMode = "Single"
        isActive = true
        startTracking(targetName)
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        toggleButton.Text = "⏹ DISABLE"
        statusText.Text = "📡 Status: Tracking " .. targetName .. " (" .. currentFoodType .. ")"
    else
        stopTracking()
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        toggleButton.Text = "▶ ENABLE"
        statusText.Text = "📡 Status: Stopped"
    end
end

local function onToggleAura()
    local targetName = textBox3.Text
    if targetName == "" then
        statusText3.Text = "❌ Error: Enter a name!"
        return
    end
    
    if not isActive or currentMode ~= "Aura" then
        if moneyActive then
            stopMoneyFarm()
        end
        stopTracking()
        currentMode = "Aura"
        isActive = true
        startAura(targetName)
        toggleButton3.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        toggleButton3.Text = "⏹ DISABLE"
        statusText3.Text = "📡 Status: Aura (" .. auraFoodType .. ") around " .. targetName .. " (radius " .. auraRadius .. ")"
    else
        stopTracking()
        toggleButton3.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        toggleButton3.Text = "▶ ENABLE"
        statusText3.Text = "📡 Status: Stopped"
    end
end

toggleButton.MouseButton1Click:Connect(onToggleSingle)
toggleButton3.MouseButton1Click:Connect(onToggleAura)

-- Minimize/Restore
local function hideWindow()
    mainFrame.Visible = false
    iconButton.Visible = true
end

local function showWindow()
    mainFrame.Visible = true
    iconButton.Visible = false
end

closeButton.MouseButton1Click:Connect(hideWindow)
closeButton3.MouseButton1Click:Connect(hideWindow)
closeButton4.MouseButton1Click:Connect(hideWindow)
iconButton.MouseButton1Click:Connect(showWindow)

-- Update status
game:GetService("RunService").Heartbeat:Connect(function()
    if isActive then
        if currentMode == "Single" and singleContent.Visible then
            local targetName = textBox.Text
            if targetName ~= "" then
                local _, targetPlayer = getPlayerCFrameByName(targetName)
                if targetPlayer then
                    statusText.Text = "📡 Status: Tracking " .. targetPlayer.Name .. " (" .. currentFoodType .. ")"
                else
                    statusText.Text = "⚠️ Status: Player not found!"
                end
            end
        elseif currentMode == "Aura" and auraContent.Visible then
            local targetName = textBox3.Text
            if targetName ~= "" then
                local _, targetPlayer = getPlayerCFrameByName(targetName)
                if targetPlayer then
                    statusText3.Text = "📡 Status: Aura (" .. auraFoodType .. ") around " .. targetPlayer.Name .. " (radius " .. auraRadius .. ")"
                else
                    statusText3.Text = "⚠️ Status: Player not found!"
                end
            end
        end
    end
end)

-- Cleanup
player:WaitForChild("PlayerGui").ChildRemoved:Connect(function(gui)
    if gui == screenGui then
        stopTracking()
        stopMoneyFarm()
    end
end)

print("✅ GUI Loaded! 3 tabs: SINGLE, AURA, MONEY")
print("💰 MONEY: Rate = how many times to execute INSTANTLY (no delay)")