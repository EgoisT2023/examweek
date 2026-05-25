local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local ItemsFolder = Workspace:WaitForChild("GameAssets"):WaitForChild("Map"):WaitForChild("Items")
local MapFolder = Workspace:WaitForChild("GameAssets"):WaitForChild("Map")

local activeHighlights = {}
local collectiblesList = {}
local espEnabled = true
local npcEspEnabled = true
local lunchLadyHighlight = nil
local lunchLadyObject = nil
local exitDoorHighlight = nil
local exitDoorObject = nil
local menuVisible = true
local floatingButton = nil
local dragCircle = false
local circleDragInput, circleDragStart, circleStartPos

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CollectiblesGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 450)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.Active = true
mainFrame.Draggable = false

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
collectiblesTab.Size = UDim2.new(0.25, -1, 1, -2)
collectiblesTab.Position = UDim2.new(0, 1, 0, 1)
collectiblesTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
collectiblesTab.Text = "📦 Items"
collectiblesTab.TextColor3 = Color3.fromRGB(255, 255, 255)
collectiblesTab.TextSize = 12
collectiblesTab.Font = Enum.Font.GothamBold
collectiblesTab.Parent = tabContainer

local teleportTab = Instance.new("TextButton")
teleportTab.Size = UDim2.new(0.25, -1, 1, -2)
teleportTab.Position = UDim2.new(0.25, 1, 0, 1)
teleportTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
teleportTab.Text = "🚀 Teleport"
teleportTab.TextColor3 = Color3.fromRGB(200, 200, 200)
teleportTab.TextSize = 12
teleportTab.Font = Enum.Font.GothamBold
teleportTab.Parent = tabContainer

local espTab = Instance.new("TextButton")
espTab.Size = UDim2.new(0.25, -1, 1, -2)
espTab.Position = UDim2.new(0.5, 1, 0, 1)
espTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
espTab.Text = "👁️ ESP"
espTab.TextColor3 = Color3.fromRGB(200, 200, 200)
espTab.TextSize = 12
espTab.Font = Enum.Font.GothamBold
espTab.Parent = tabContainer

local npcTab = Instance.new("TextButton")
npcTab.Size = UDim2.new(0.25, -1, 1, -2)
npcTab.Position = UDim2.new(0.75, 1, 0, 1)
npcTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
npcTab.Text = "👤 NPC ESP"
npcTab.TextColor3 = Color3.fromRGB(200, 200, 200)
npcTab.TextSize = 12
npcTab.Font = Enum.Font.GothamBold
npcTab.Parent = tabContainer

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

local teleportFrame = Instance.new("Frame")
teleportFrame.Size = UDim2.new(1, -10, 1, -85)
teleportFrame.Position = UDim2.new(0, 5, 0, 80)
teleportFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
teleportFrame.BackgroundTransparency = 0.2
teleportFrame.BorderSizePixel = 0
teleportFrame.Visible = false
teleportFrame.Parent = mainFrame

local teleportCorner = Instance.new("UICorner")
teleportCorner.CornerRadius = UDim.new(0, 6)
teleportCorner.Parent = teleportFrame

local teleportLayout = Instance.new("UIListLayout")
teleportLayout.SortOrder = Enum.SortOrder.Name
teleportLayout.Padding = UDim.new(0, 10)
teleportLayout.Parent = teleportFrame

local teleportToLunchLady = Instance.new("TextButton")
teleportToLunchLady.Size = UDim2.new(1, -20, 0, 45)
teleportToLunchLady.Position = UDim2.new(0, 10, 0, 10)
teleportToLunchLady.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
teleportToLunchLady.BackgroundTransparency = 0.3
teleportToLunchLady.Text = "🍽️ Teleport to LunchLady"
teleportToLunchLady.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportToLunchLady.TextSize = 13
teleportToLunchLady.Font = Enum.Font.GothamBold
teleportToLunchLady.Parent = teleportFrame

local teleportToLunchLadyCorner = Instance.new("UICorner")
teleportToLunchLadyCorner.CornerRadius = UDim.new(0, 6)
teleportToLunchLadyCorner.Parent = teleportToLunchLady

local teleportToExit = Instance.new("TextButton")
teleportToExit.Size = UDim2.new(1, -20, 0, 45)
teleportToExit.Position = UDim2.new(0, 10, 0, 65)
teleportToExit.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
teleportToExit.BackgroundTransparency = 0.3
teleportToExit.Text = "🚪 Teleport to Exit"
teleportToExit.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportToExit.TextSize = 13
teleportToExit.Font = Enum.Font.GothamBold
teleportToExit.Parent = teleportFrame

local teleportToExitCorner = Instance.new("UICorner")
teleportToExitCorner.CornerRadius = UDim.new(0, 6)
teleportToExitCorner.Parent = teleportToExit

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
espToggleButton.Text = "✅ Items ESP: ON"
espToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
espToggleButton.TextSize = 14
espToggleButton.Font = Enum.Font.GothamBold
espToggleButton.Parent = espFrame

local espToggleCorner = Instance.new("UICorner")
espToggleCorner.CornerRadius = UDim.new(0, 6)
espToggleCorner.Parent = espToggleButton

local colorLabel = Instance.new("TextLabel")
colorLabel.Size = UDim2.new(1, -20, 0, 25)
colorLabel.Position = UDim2.new(0, 10, 0, 70)
colorLabel.BackgroundTransparency = 1
colorLabel.Text = "Items ESP Color:"
colorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
colorLabel.TextSize = 12
colorLabel.Font = Enum.Font.Gotham
colorLabel.TextXAlignment = Enum.TextXAlignment.Left
colorLabel.Parent = espFrame

local colorPickerFrame = Instance.new("Frame")
colorPickerFrame.Size = UDim2.new(1, -20, 0, 35)
colorPickerFrame.Position = UDim2.new(0, 10, 0, 95)
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

local npcFrame = Instance.new("Frame")
npcFrame.Size = UDim2.new(1, -10, 1, -85)
npcFrame.Position = UDim2.new(0, 5, 0, 80)
npcFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
npcFrame.BackgroundTransparency = 0.2
npcFrame.BorderSizePixel = 0
npcFrame.Visible = false
npcFrame.Parent = mainFrame

local npcCorner = Instance.new("UICorner")
npcCorner.CornerRadius = UDim.new(0, 6)
npcCorner.Parent = npcFrame

local npcEspToggle = Instance.new("TextButton")
npcEspToggle.Size = UDim2.new(1, -20, 0, 50)
npcEspToggle.Position = UDim2.new(0, 10, 0, 10)
npcEspToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
npcEspToggle.BackgroundTransparency = 0.3
npcEspToggle.Text = "✅ NPC ESP: ON"
npcEspToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
npcEspToggle.TextSize = 14
npcEspToggle.Font = Enum.Font.GothamBold
npcEspToggle.Parent = npcFrame

local npcEspToggleCorner = Instance.new("UICorner")
npcEspToggleCorner.CornerRadius = UDim.new(0, 6)
npcEspToggleCorner.Parent = npcEspToggle

local npcColorLabel = Instance.new("TextLabel")
npcColorLabel.Size = UDim2.new(1, -20, 0, 25)
npcColorLabel.Position = UDim2.new(0, 10, 0, 70)
npcColorLabel.BackgroundTransparency = 1
npcColorLabel.Text = "NPC ESP Color:"
npcColorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
npcColorLabel.TextSize = 12
npcColorLabel.Font = Enum.Font.Gotham
npcColorLabel.TextXAlignment = Enum.TextXAlignment.Left
npcColorLabel.Parent = npcFrame

local npcColorPicker = Instance.new("Frame")
npcColorPicker.Size = UDim2.new(1, -20, 0, 35)
npcColorPicker.Position = UDim2.new(0, 10, 0, 95)
npcColorPicker.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
npcColorPicker.BackgroundTransparency = 0.3
npcColorPicker.BorderSizePixel = 0
npcColorPicker.Parent = npcFrame

local npcColorCorner = Instance.new("UICorner")
npcColorCorner.CornerRadius = UDim.new(0, 6)
npcColorCorner.Parent = npcColorPicker

local npcColorRed = Instance.new("TextButton")
npcColorRed.Size = UDim2.new(0.25, -2, 1, -4)
npcColorRed.Position = UDim2.new(0, 2, 0, 2)
npcColorRed.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
npcColorRed.Text = ""
npcColorRed.Parent = npcColorPicker

local npcColorGreen = Instance.new("TextButton")
npcColorGreen.Size = UDim2.new(0.25, -2, 1, -4)
npcColorGreen.Position = UDim2.new(0.25, 2, 0, 2)
npcColorGreen.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
npcColorGreen.Text = ""
npcColorGreen.Parent = npcColorPicker

local npcColorBlue = Instance.new("TextButton")
npcColorBlue.Size = UDim2.new(0.25, -2, 1, -4)
npcColorBlue.Position = UDim2.new(0.5, 2, 0, 2)
npcColorBlue.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
npcColorBlue.Text = ""
npcColorBlue.Parent = npcColorPicker

local npcColorYellow = Instance.new("TextButton")
npcColorYellow.Size = UDim2.new(0.25, -2, 1, -4)
npcColorYellow.Position = UDim2.new(0.75, 2, 0, 2)
npcColorYellow.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
npcColorYellow.Text = ""
npcColorYellow.Parent = npcColorPicker

local npcStatusLabel = Instance.new("TextLabel")
npcStatusLabel.Size = UDim2.new(1, -20, 0, 30)
npcStatusLabel.Position = UDim2.new(0, 10, 0, 140)
npcStatusLabel.BackgroundTransparency = 1
npcStatusLabel.Text = "LunchLady: Searching..."
npcStatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
npcStatusLabel.TextSize = 12
npcStatusLabel.Font = Enum.Font.Gotham
npcStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
npcStatusLabel.Parent = npcFrame

local currentColor = Color3.fromRGB(0, 255, 0)
local npcCurrentColor = Color3.fromRGB(255, 100, 100)

local function CreateFloatingButton()
	if floatingButton then return end
	
	floatingButton = Instance.new("ImageButton")
	floatingButton.Size = UDim2.new(0, 50, 0, 50)
	floatingButton.Position = UDim2.new(0, 20, 0, 100)
	floatingButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	floatingButton.BackgroundTransparency = 0.2
	floatingButton.Image = "rbxasset://textures/ui/Shell/WindowIcons/Close.png"
	floatingButton.ImageColor3 = Color3.fromRGB(0, 255, 0)
	floatingButton.ScaleType = Enum.ScaleType.Fit
	floatingButton.Parent = screenGui
	floatingButton.Visible = false
	
	local floatingCorner = Instance.new("UICorner")
	floatingCorner.CornerRadius = UDim.new(1, 0)
	floatingCorner.Parent = floatingButton
	
	local floatingStroke = Instance.new("UIStroke")
	floatingStroke.Color = Color3.fromRGB(0, 255, 0)
	floatingStroke.Thickness = 2
	floatingStroke.Parent = floatingButton
	
	local pulseTween = TweenService:Create(floatingButton, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency = 0.5})
	pulseTween:Play()
	
	floatingButton.MouseButton1Click:Connect(function()
		menuVisible = true
		mainFrame.Visible = true
		floatingButton.Visible = false
	end)
	
	floatingButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragCircle = true
			circleDragStart = input.Position
			circleStartPos = floatingButton.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragCircle = false
				end
			end)
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == circleDragInput and dragCircle then
			local delta = input.Position - circleDragStart
			floatingButton.Position = UDim2.new(circleStartPos.X.Scale, circleStartPos.X.Offset + delta.X, circleStartPos.Y.Scale, circleStartPos.Y.Offset + delta.Y)
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			circleDragInput = input
		end
	end)
end

local function ShowFloatingButton()
	if not floatingButton then
		CreateFloatingButton()
	end
	floatingButton.Visible = true
	local tween = TweenService:Create(floatingButton, TweenInfo.new(0.3, Enum.EasingStyle.Back), {BackgroundTransparency = 0.2})
	tween:Play()
end

local function UpdateExitDoorHighlight()
	if exitDoorHighlight then
		exitDoorHighlight:Destroy()
		exitDoorHighlight = nil
	end
	
	exitDoorObject = MapFolder:FindFirstChild("ExitDoor")
	
	if exitDoorObject and espEnabled then
		exitDoorHighlight = Instance.new("Highlight")
		exitDoorHighlight.FillColor = Color3.fromRGB(0, 200, 255)
		exitDoorHighlight.FillTransparency = 0.3
		exitDoorHighlight.OutlineColor = Color3.fromRGB(0, 200, 255)
		exitDoorHighlight.OutlineTransparency = 0.1
		exitDoorHighlight.Parent = exitDoorObject
		
		task.spawn(function()
			local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
			local tween = TweenService:Create(exitDoorHighlight, tweenInfo, {FillTransparency = 0.15, OutlineTransparency = 0})
			tween:Play()
		end)
	end
end

local function UpdateLunchLadyHighlight()
	if lunchLadyHighlight then
		lunchLadyHighlight:Destroy()
		lunchLadyHighlight = nil
	end
	
	lunchLadyObject = MapFolder:FindFirstChild("LunchLady")
	
	if lunchLadyObject then
		if npcStatusLabel then
			npcStatusLabel.Text = "LunchLady: ✅ Found"
			npcStatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
		end
		
		if npcEspEnabled then
			lunchLadyHighlight = Instance.new("Highlight")
			lunchLadyHighlight.FillColor = npcCurrentColor
			lunchLadyHighlight.FillTransparency = 0.3
			lunchLadyHighlight.OutlineColor = npcCurrentColor
			lunchLadyHighlight.OutlineTransparency = 0.1
			lunchLadyHighlight.Parent = lunchLadyObject
			
			task.spawn(function()
				local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
				local tween = TweenService:Create(lunchLadyHighlight, tweenInfo, {FillTransparency = 0.15, OutlineTransparency = 0})
				tween:Play()
			end)
		end
	else
		if npcStatusLabel then
			npcStatusLabel.Text = "LunchLady: ❌ Not Found"
			npcStatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
		end
	end
end

local function UpdateAllHighlights()
	for obj, highlight in pairs(activeHighlights) do
		highlight:Destroy()
	end
	table.clear(activeHighlights)
	
	if espEnabled then
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
	
	UpdateExitDoorHighlight()
	UpdateLunchLadyHighlight()
end

local function TeleportToPosition(targetObject, offsetY)
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
	
	local teleportPosition = targetPosition + Vector3.new(0, offsetY or 3, 0)
	humanoidRootPart.CFrame = CFrame.new(teleportPosition)
	
	local attachment = Instance.new("Attachment")
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particleEmitter.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255))
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

local function TeleportToCollectible(targetObject)
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
		button.Size = UDim2.new(1, -10, 0, 35)
		button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		button.BackgroundTransparency = 0.3
		button.Text = "📍 " .. item.Name
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.TextSize = 12
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
			TeleportToCollectible(item)
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

local function WatchForNPCs()
	while true do
		local newLunchLady = MapFolder:FindFirstChild("LunchLady")
		if newLunchLady ~= lunchLadyObject then
			lunchLadyObject = newLunchLady
			UpdateLunchLadyHighlight()
		end
		
		local newExitDoor = MapFolder:FindFirstChild("ExitDoor")
		if newExitDoor ~= exitDoorObject then
			exitDoorObject = newExitDoor
			UpdateExitDoorHighlight()
		end
		
		task.wait(0.5)
	end
end

local function MakeDraggable(frame)
	local dragging = false
	local dragInput, dragStart, startPos
	
	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
	
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

ItemsFolder.ChildAdded:Connect(OnItemsFolderChanged)
ItemsFolder.ChildRemoved:Connect(OnItemsFolderChanged)

UpdateCollectiblesList()
task.spawn(WatchForNPCs)
CreateFloatingButton()
MakeDraggable(mainFrame)

collectiblesTab.MouseButton1Click:Connect(function()
	collectiblesFrame.Visible = true
	teleportFrame.Visible = false
	espFrame.Visible = false
	npcFrame.Visible = false
	collectiblesTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	collectiblesTab.TextColor3 = Color3.fromRGB(255, 255, 255)
	teleportTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	teleportTab.TextColor3 = Color3.fromRGB(200, 200, 200)
	espTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	espTab.TextColor3 = Color3.fromRGB(200, 200, 200)
	npcTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	npcTab.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

teleportTab.MouseButton1Click:Connect(function()
	collectiblesFrame.Visible = false
	teleportFrame.Visible = true
	espFrame.Visible = false
	npcFrame.Visible = false
	teleportTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	teleportTab.TextColor3 = Color3.fromRGB(255, 255, 255)
	collectiblesTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	collectiblesTab.TextColor3 = Color3.fromRGB(200, 200, 200)
	espTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	espTab.TextColor3 = Color3.fromRGB(200, 200, 200)
	npcTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	npcTab.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

espTab.MouseButton1Click:Connect(function()
	collectiblesFrame.Visible = false
	teleportFrame.Visible = false
	espFrame.Visible = true
	npcFrame.Visible = false
	espTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	espTab.TextColor3 = Color3.fromRGB(255, 255, 255)
	collectiblesTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	collectiblesTab.TextColor3 = Color3.fromRGB(200, 200, 200)
	teleportTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	teleportTab.TextColor3 = Color3.fromRGB(200, 200, 200)
	npcTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	npcTab.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

npcTab.MouseButton1Click:Connect(function()
	collectiblesFrame.Visible = false
	teleportFrame.Visible = false
	espFrame.Visible = false
	npcFrame.Visible = true
	npcTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	npcTab.TextColor3 = Color3.fromRGB(255, 255, 255)
	collectiblesTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	collectiblesTab.TextColor3 = Color3.fromRGB(200, 200, 200)
	teleportTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	teleportTab.TextColor3 = Color3.fromRGB(200, 200, 200)
	espTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	espTab.TextColor3 = Color3.fromRGB(200, 200, 200)
	UpdateLunchLadyHighlight()
end)

teleportToLunchLady.MouseButton1Click:Connect(function()
	if lunchLadyObject then
		TeleportToPosition(lunchLadyObject, 5)
	end
end)

teleportToExit.MouseButton1Click:Connect(function()
	local exitDoor = MapFolder:FindFirstChild("ExitDoor")
	if exitDoor then
		TeleportToPosition(exitDoor, 2)
	end
end)

espToggleButton.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	if espEnabled then
		espToggleButton.Text = "✅ Items ESP: ON"
		espToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	else
		espToggleButton.Text = "❌ Items ESP: OFF"
		espToggleButton.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
	end
	UpdateAllHighlights()
end)

npcEspToggle.MouseButton1Click:Connect(function()
	npcEspEnabled = not npcEspEnabled
	if npcEspEnabled then
		npcEspToggle.Text = "✅ NPC ESP: ON"
		npcEspToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	else
		npcEspToggle.Text = "❌ NPC ESP: OFF"
		npcEspToggle.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
	end
	UpdateLunchLadyHighlight()
end)

local function SetColor(color)
	currentColor = color
	UpdateAllHighlights()
end

local function SetNPCColor(color)
	npcCurrentColor = color
	UpdateLunchLadyHighlight()
end

colorRed.MouseButton1Click:Connect(function() SetColor(Color3.fromRGB(255, 0, 0)) end)
colorGreen.MouseButton1Click:Connect(function() SetColor(Color3.fromRGB(0, 255, 0)) end)
colorBlue.MouseButton1Click:Connect(function() SetColor(Color3.fromRGB(0, 0, 255)) end)
colorYellow.MouseButton1Click:Connect(function() SetColor(Color3.fromRGB(255, 255, 0)) end)

npcColorRed.MouseButton1Click:Connect(function() SetNPCColor(Color3.fromRGB(255, 0, 0)) end)
npcColorGreen.MouseButton1Click:Connect(function() SetNPCColor(Color3.fromRGB(0, 255, 0)) end)
npcColorBlue.MouseButton1Click:Connect(function() SetNPCColor(Color3.fromRGB(0, 0, 255)) end)
npcColorYellow.MouseButton1Click:Connect(function() SetNPCColor(Color3.fromRGB(255, 255, 0)) end)

closeButton.MouseButton1Click:Connect(function()
	menuVisible = false
	mainFrame.Visible = false
	ShowFloatingButton()
end)
