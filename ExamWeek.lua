local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local ItemsFolder = Workspace:WaitForChild("GameAssets"):WaitForChild("Map"):WaitForChild("Items")
local MapFolder = Workspace:WaitForChild("GameAssets"):WaitForChild("Map")

local activeHighlights = {}
local collectiblesList = {}
local espEnabled = true
local lunchLadyEspEnabled = true
local lunchLadyHighlight = nil
local lunchLadyObject = nil

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CollectiblesGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 600)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
titleLabel.BackgroundTransparency = 0.1
titleLabel.Text = "📦 Collectibles Manager"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleLabel

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 18
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleLabel

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 35)
tabContainer.Position = UDim2.new(0, 0, 0, 40)
tabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
tabContainer.BackgroundTransparency = 0.2
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainFrame

local collectiblesTab = Instance.new("TextButton")
collectiblesTab.Size = UDim2.new(0.34, -1, 1, -2)
collectiblesTab.Position = UDim2.new(0, 1, 0, 1)
collectiblesTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
collectiblesTab.Text = "📦 Collectibles"
collectiblesTab.TextColor3 = Color3.fromRGB(255, 255, 255)
collectiblesTab.TextSize = 13
collectiblesTab.Font = Enum.Font.GothamBold
collectiblesTab.Parent = tabContainer

local espTab = Instance.new("TextButton")
espTab.Size = UDim2.new(0.33, -1, 1, -2)
espTab.Position = UDim2.new(0.34, 1, 0, 1)
espTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
espTab.Text = "👁️ ESP"
espTab.TextColor3 = Color3.fromRGB(200, 200, 200)
espTab.TextSize = 13
espTab.Font = Enum.Font.GothamBold
espTab.Parent = tabContainer

local lunchLadyTab = Instance.new("TextButton")
lunchLadyTab.Size = UDim2.new(0.33, -1, 1, -2)
lunchLadyTab.Position = UDim2.new(0.67, 1, 0, 1)
lunchLadyTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
lunchLadyTab.Text = "🍽️ LunchLady"
lunchLadyTab.TextColor3 = Color3.fromRGB(200, 200, 200)
lunchLadyTab.TextSize = 13
lunchLadyTab.Font = Enum.Font.GothamBold
lunchLadyTab.Parent = tabContainer

local collectiblesFrame = Instance.new("ScrollingFrame")
collectiblesFrame.Size = UDim2.new(1, -10, 1, -85)
collectiblesFrame.Position = UDim2.new(0, 5, 0, 80)
collectiblesFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
collectiblesFrame.BackgroundTransparency = 0.2
collectiblesFrame.BorderSizePixel = 0
collectiblesFrame.ScrollBarThickness = 6
collectiblesFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
collectiblesFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
collectiblesFrame.Parent = mainFrame

local collectiblesCorner = Instance.new("UICorner")
collectiblesCorner.CornerRadius = UDim.new(0, 6)
collectiblesCorner.Parent = collectiblesFrame

local collectiblesLayout = Instance.new("UIListLayout")
collectiblesLayout.SortOrder = Enum.SortOrder.Name
collectiblesLayout.Padding = UDim.new(0, 5)
collectiblesLayout.Parent = collectiblesFrame

local espFrame = Instance.new("Frame")
espFrame.Size = UDim2.new(1, -10, 1, -85)
espFrame.Position = UDim2.new(0, 5, 0, 80)
espFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
espFrame.BackgroundTransparency = 0.2
espFrame.BorderSizePixel = 0
espFrame.Visible = false
espFrame.Parent = mainFrame

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 6)
espCorner.Parent = espFrame

local espToggleButton = Instance.new("TextButton")
espToggleButton.Size = UDim2.new(1, -20, 0, 50)
espToggleButton.Position = UDim2.new(0, 10, 0, 10)
espToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
espToggleButton.BackgroundTransparency = 0.3
espToggleButton.Text = "✅ Collectibles ESP: ON"
espToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
espToggleButton.TextSize = 14
espToggleButton.Font = Enum.Font.GothamBold
espToggleButton.Parent = espFrame

local espToggleCorner = Instance.new("UICorner")
espToggleCorner.CornerRadius = UDim.new(0, 6)
espToggleCorner.Parent = espToggleButton

local colorLabel = Instance.new("TextLabel")
colorLabel.Size = UDim2.new(1, -20, 0, 30)
colorLabel.Position = UDim2.new(0, 10, 0, 70)
colorLabel.BackgroundTransparency = 1
colorLabel.Text = "Collectibles ESP Color:"
colorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
colorLabel.TextSize = 13
colorLabel.Font = Enum.Font.Gotham
colorLabel.TextXAlignment = Enum.TextXAlignment.Left
colorLabel.Parent = espFrame

local colorPickerFrame = Instance.new("Frame")
colorPickerFrame.Size = UDim2.new(1, -20, 0, 40)
colorPickerFrame.Position = UDim2.new(0, 10, 0, 100)
colorPickerFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
colorPickerFrame.BackgroundTransparency = 0.3
colorPickerFrame.BorderSizePixel = 0
colorPickerFrame.Parent = espFrame

local colorPickerCorner = Instance.new("UICorner")
colorPickerCorner.CornerRadius = UDim.new(0, 6)
colorPickerCorner.Parent = colorPickerFrame

local colorRed = Instance.new("TextButton")
colorRed.Size = UDim2.new(0.25, -2, 1, -4)
colorRed.Position = UDim2.new(0, 2, 0, 2)
colorRed.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
colorRed.Text = ""
colorRed.Parent = colorPickerFrame

local colorGreen = Instance.new("TextButton")
colorGreen.Size = UDim2.new(0.25, -2, 1, -4)
colorGreen.Position = UDim2.new(0.25, 2, 0, 2)
colorGreen.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
colorGreen.Text = ""
colorGreen.Parent = colorPickerFrame

local colorBlue = Instance.new("TextButton")
colorBlue.Size = UDim2.new(0.25, -2, 1, -4)
colorBlue.Position = UDim2.new(0.5, 2, 0, 2)
colorBlue.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
colorBlue.Text = ""
colorBlue.Parent = colorPickerFrame

local colorYellow = Instance.new("TextButton")
colorYellow.Size = UDim2.new(0.25, -2, 1, -4)
colorYellow.Position = UDim2.new(0.75, 2, 0, 2)
colorYellow.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
colorYellow.Text = ""
colorYellow.Parent = colorPickerFrame

local lunchLadyFrame = Instance.new("Frame")
lunchLadyFrame.Size = UDim2.new(1, -10, 1, -85)
lunchLadyFrame.Position = UDim2.new(0, 5, 0, 80)
lunchLadyFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
lunchLadyFrame.BackgroundTransparency = 0.2
lunchLadyFrame.BorderSizePixel = 0
lunchLadyFrame.Visible = false
lunchLadyFrame.Parent = mainFrame

local lunchLadyCorner = Instance.new("UICorner")
lunchLadyCorner.CornerRadius = UDim.new(0, 6)
lunchLadyCorner.Parent = lunchLadyFrame

local lunchLadyToggle = Instance.new("TextButton")
lunchLadyToggle.Size = UDim2.new(1, -20, 0, 50)
lunchLadyToggle.Position = UDim2.new(0, 10, 0, 10)
lunchLadyToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
lunchLadyToggle.BackgroundTransparency = 0.3
lunchLadyToggle.Text = "✅ LunchLady ESP: ON"
lunchLadyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
lunchLadyToggle.TextSize = 14
lunchLadyToggle.Font = Enum.Font.GothamBold
lunchLadyToggle.Parent = lunchLadyFrame

local lunchLadyToggleCorner = Instance.new("UICorner")
lunchLadyToggleCorner.CornerRadius = UDim.new(0, 6)
lunchLadyToggleCorner.Parent = lunchLadyToggle

local lunchLadyColorLabel = Instance.new("TextLabel")
lunchLadyColorLabel.Size = UDim2.new(1, -20, 0, 30)
lunchLadyColorLabel.Position = UDim2.new(0, 10, 0, 70)
lunchLadyColorLabel.BackgroundTransparency = 1
lunchLadyColorLabel.Text = "LunchLady ESP Color:"
lunchLadyColorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
lunchLadyColorLabel.TextSize = 13
lunchLadyColorLabel.Font = Enum.Font.Gotham
lunchLadyColorLabel.TextXAlignment = Enum.TextXAlignment.Left
lunchLadyColorLabel.Parent = lunchLadyFrame

local lunchLadyColorPicker = Instance.new("Frame")
lunchLadyColorPicker.Size = UDim2.new(1, -20, 0, 40)
lunchLadyColorPicker.Position = UDim2.new(0, 10, 0, 100)
lunchLadyColorPicker.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
lunchLadyColorPicker.BackgroundTransparency = 0.3
lunchLadyColorPicker.BorderSizePixel = 0
lunchLadyColorPicker.Parent = lunchLadyFrame

local lunchLadyColorCorner = Instance.new("UICorner")
lunchLadyColorCorner.CornerRadius = UDim.new(0, 6)
lunchLadyColorCorner.Parent = lunchLadyColorPicker

local lunchLadyColorRed = Instance.new("TextButton")
lunchLadyColorRed.Size = UDim2.new(0.25, -2, 1, -4)
lunchLadyColorRed.Position = UDim2.new(0, 2, 0, 2)
lunchLadyColorRed.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
lunchLadyColorRed.Text = ""
lunchLadyColorRed.Parent = lunchLadyColorPicker

local lunchLadyColorGreen = Instance.new("TextButton")
lunchLadyColorGreen.Size = UDim2.new(0.25, -2, 1, -4)
lunchLadyColorGreen.Position = UDim2.new(0.25, 2, 0, 2)
lunchLadyColorGreen.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
lunchLadyColorGreen.Text = ""
lunchLadyColorGreen.Parent = lunchLadyColorPicker

local lunchLadyColorBlue = Instance.new("TextButton")
lunchLadyColorBlue.Size = UDim2.new(0.25, -2, 1, -4)
lunchLadyColorBlue.Position = UDim2.new(0.5, 2, 0, 2)
lunchLadyColorBlue.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
lunchLadyColorBlue.Text = ""
lunchLadyColorBlue.Parent = lunchLadyColorPicker

local lunchLadyColorYellow = Instance.new("TextButton")
lunchLadyColorYellow.Size = UDim2.new(0.25, -2, 1, -4)
lunchLadyColorYellow.Position = UDim2.new(0.75, 2, 0, 2)
lunchLadyColorYellow.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
lunchLadyColorYellow.Text = ""
lunchLadyColorYellow.Parent = lunchLadyColorPicker

local currentColor = Color3.fromRGB(0, 255, 0)
local lunchLadyCurrentColor = Color3.fromRGB(255, 100, 100)

local function UpdateLunchLadyHighlight()
	if lunchLadyHighlight then
		lunchLadyHighlight:Destroy()
		lunchLadyHighlight = nil
	end
	
	if not lunchLadyEspEnabled then return end
	
	lunchLadyObject = MapFolder:FindFirstChild("LunchLady")
	
	if lunchLadyObject then
		lunchLadyHighlight = Instance.new("Highlight")
		lunchLadyHighlight.FillColor = lunchLadyCurrentColor
		lunchLadyHighlight.FillTransparency = 0.3
		lunchLadyHighlight.OutlineColor = lunchLadyCurrentColor
		lunchLadyHighlight.OutlineTransparency = 0.1
		lunchLadyHighlight.Parent = lunchLadyObject
		
		task.spawn(function()
			local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
			local tween = TweenService:Create(lunchLadyHighlight, tweenInfo, {FillTransparency = 0.15, OutlineTransparency = 0})
			tween:Play()
		end)
	end
end

local function UpdateAllHighlights()
	for obj, highlight in pairs(activeHighlights) do
		highlight:Destroy()
	end
	table.clear(activeHighlights)
	
	if not espEnabled then return end
	
	for _, item in ipairs(collectiblesList) do
		local highlight = Instance.new("Highlight")
		highlight.FillColor = currentColor
		highlight.FillTransparency = 0.4
		highlight.OutlineColor = currentColor
		highlight.OutlineTransparency = 0.2
		highlight.Parent = item
		activeHighlights[item] = highlight
		
		task.spawn(function()
			local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
			local tween = TweenService:Create(highlight, tweenInfo, {FillTransparency = 0.2, OutlineTransparency = 0})
			tween:Play()
		end)
	end
end

local function TeleportToObject(targetObject)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	
	if not humanoidRootPart then return end
	
	local targetPosition
	
	if targetObject:IsA("Model") and targetObject.PrimaryPart then
		targetPosition = targetObject.PrimaryPart.Position
	elseif targetObject:IsA("BasePart") then
		targetPosition = targetObject.Position
	else
		local part = targetObject:FindFirstChildWhichIsA("BasePart")
		if part then
			targetPosition = part.Position
		else
			return
		end
	end
	
	local teleportPosition = targetPosition + Vector3.new(0, 3, 0)
	humanoidRootPart.CFrame = CFrame.new(teleportPosition)
	
	local attachment = Instance.new("Attachment")
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particleEmitter.Color = ColorSequence.new(currentColor)
	particleEmitter.Rate = 200
	particleEmitter.Lifetime = NumberRange.new(0.3)
	particleEmitter.SpreadAngle = Vector2.new(360, 360)
	particleEmitter.VelocityInheritance = 0
	particleEmitter.Parent = attachment
	attachment.Parent = humanoidRootPart
	
	task.wait(0.3)
	particleEmitter:Destroy()
	attachment:Destroy()
end

local function UpdateCollectiblesListGUI()
	for _, button in ipairs(collectiblesFrame:GetChildren()) do
		if button:IsA("TextButton") then
			button:Destroy()
		end
	end
	
	local sortedCollectibles = {}
	for _, item in ipairs(collectiblesList) do
		table.insert(sortedCollectibles, item)
	end
	table.sort(sortedCollectibles, function(a, b) return a.Name < b.Name end)
	
	for _, item in ipairs(sortedCollectibles) do
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(1, -10, 0, 40)
		button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		button.BackgroundTransparency = 0.3
		button.Text = "📍 " .. item.Name
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.TextSize = 14
		button.Font = Enum.Font.Gotham
		button.AutoButtonColor = true
		button.Parent = collectiblesFrame
		
		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 4)
		buttonCorner.Parent = button
		
		button.MouseEnter:Connect(function()
			local tween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.1})
			tween:Play()
		end)
		
		button.MouseLeave:Connect(function()
			local tween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.3})
			tween:Play()
		end)
		
		button.MouseButton1Click:Connect(function()
			TeleportToObject(item)
		end)
	end
end

local function UpdateCollectiblesList()
	collectiblesList = {}
	
	for _, item in ipairs(ItemsFolder:GetChildren()) do
		if item.Name == "Collectible" and (item:IsA("Model") or item:IsA("BasePart")) then
			table.insert(collectiblesList, item)
		end
	end
	
	UpdateCollectiblesListGUI()
	UpdateAllHighlights()
end

local function OnItemsFolderChanged()
	task.wait(0.1)
	UpdateCollectiblesList()
end

local function WatchForLunchLady()
	while true do
		local newLunchLady = MapFolder:FindFirstChild("LunchLady")
		if newLunchLady ~= lunchLadyObject then
			lunchLadyObject = newLunchLady
			UpdateLunchLadyHighlight()
		end
		task.wait(0.5)
	end
end

ItemsFolder.ChildAdded:Connect(OnItemsFolderChanged)
ItemsFolder.ChildRemoved:Connect(OnItemsFolderChanged)

UpdateCollectiblesList()
task.spawn(WatchForLunchLady)

collectiblesTab.MouseButton1Click:Connect(function()
	collectiblesFrame.Visible = true
	espFrame.Visible = false
	lunchLadyFrame.Visible = false
	collectiblesTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	collectiblesTab.TextColor3 = Color3.fromRGB(255, 255, 255)
	espTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	espTab.TextColor3 = Color3.fromRGB(200, 200, 200)
	lunchLadyTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	lunchLadyTab.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

espTab.MouseButton1Click:Connect(function()
	collectiblesFrame.Visible = false
	espFrame.Visible = true
	lunchLadyFrame.Visible = false
	espTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	espTab.TextColor3 = Color3.fromRGB(255, 255, 255)
	collectiblesTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	collectiblesTab.TextColor3 = Color3.fromRGB(200, 200, 200)
	lunchLadyTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	lunchLadyTab.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

lunchLadyTab.MouseButton1Click:Connect(function()
	collectiblesFrame.Visible = false
	espFrame.Visible = false
	lunchLadyFrame.Visible = true
	lunchLadyTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	lunchLadyTab.TextColor3 = Color3.fromRGB(255, 255, 255)
	collectiblesTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	collectiblesTab.TextColor3 = Color3.fromRGB(200, 200, 200)
	espTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	espTab.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

espToggleButton.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	if espEnabled then
		espToggleButton.Text = "✅ Collectibles ESP: ON"
		espToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	else
		espToggleButton.Text = "❌ Collectibles ESP: OFF"
		espToggleButton.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
	end
	UpdateAllHighlights()
end)

lunchLadyToggle.MouseButton1Click:Connect(function()
	lunchLadyEspEnabled = not lunchLadyEspEnabled
	if lunchLadyEspEnabled then
		lunchLadyToggle.Text = "✅ LunchLady ESP: ON"
		lunchLadyToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	else
		lunchLadyToggle.Text = "❌ LunchLady ESP: OFF"
		lunchLadyToggle.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
	end
	UpdateLunchLadyHighlight()
end)

local function SetColor(color)
	currentColor = color
	UpdateAllHighlights()
end

local function SetLunchLadyColor(color)
	lunchLadyCurrentColor = color
	UpdateLunchLadyHighlight()
end

colorRed.MouseButton1Click:Connect(function() SetColor(Color3.fromRGB(255, 0, 0)) end)
colorGreen.MouseButton1Click:Connect(function() SetColor(Color3.fromRGB(0, 255, 0)) end)
colorBlue.MouseButton1Click:Connect(function() SetColor(Color3.fromRGB(0, 0, 255)) end)
colorYellow.MouseButton1Click:Connect(function() SetColor(Color3.fromRGB(255, 255, 0)) end)

lunchLadyColorRed.MouseButton1Click:Connect(function() SetLunchLadyColor(Color3.fromRGB(255, 0, 0)) end)
lunchLadyColorGreen.MouseButton1Click:Connect(function() SetLunchLadyColor(Color3.fromRGB(0, 255, 0)) end)
lunchLadyColorBlue.MouseButton1Click:Connect(function() SetLunchLadyColor(Color3.fromRGB(0, 0, 255)) end)
lunchLadyColorYellow.MouseButton1Click:Connect(function() SetLunchLadyColor(Color3.fromRGB(255, 255, 0)) end)

closeButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
	if mainFrame.Visible then
		closeButton.Text = "✕"
	else
		closeButton.Text = "☰"
	end
end)

local dragging = false
local dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

mainFrame.InputBegan:Connect(function(input)
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

mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)
