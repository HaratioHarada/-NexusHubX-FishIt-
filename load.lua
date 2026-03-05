local GameVersion = "1.0.0"
local ScriptEnabled = true

-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local camera = workspace.CurrentCamera
local mouse = Players.LocalPlayer:GetMouse()

-- Local Player
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
	LocalPlayer = Players:WaitForChild("LocalPlayer")
end
local Character = LocalPlayer.Character or LocalPlayer:WaitForChild("Character")
local Humanoid = Character and Character:FindFirstChild("Humanoid")
local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")

-- Переменные для функций
local noclipEnabled = false
local airwalkEnabled = false
local airwalkPart = nil
local infiniteJumpEnabled = false
local currentSpeed = 16
local currentJump = 50
local keybind = Enum.KeyCode.G
local isPingMonitorEnabled = false
local isPotatoGraphicsEnabled = false
local isChangingKeybind = false
local pingMonitorFrame = nil
local pingValueLabel = nil
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
-- Цветовая схема (как в оригинале)
local Colors = {
	Background = Color3.fromRGB(15, 15, 15),
	Sidebar = Color3.fromRGB(18, 18, 18),
	ContentArea = Color3.fromRGB(20, 20, 20),
	Button = Color3.fromRGB(30, 30, 30),
	ButtonHover = Color3.fromRGB(45, 45, 45),
	ButtonSelected = Color3.fromRGB(60, 100, 180),
	Text = Color3.fromRGB(220, 220, 220),
	TextSelected = Color3.fromRGB(255, 255, 255),
	Stroke = Color3.fromRGB(60, 60, 60),
	ToggleOff = Color3.fromRGB(90, 90, 90),
	ToggleOn = Color3.fromRGB(60, 180, 100)
}
-- Создаём ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NexusHubX_FishIt"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui
-- Создание Ping Monitor UI
local function createPingMonitorUI()
	-- Создаем фрейм для Ping Monitor
	pingMonitorFrame = Instance.new("Frame")
	pingMonitorFrame.Name = "PingMonitorFrame"
	pingMonitorFrame.Size = UDim2.new(0, 150, 0, 80)
	pingMonitorFrame.Position = UDim2.new(0, 10, 0, 10)
	pingMonitorFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	pingMonitorFrame.BackgroundTransparency = 0.2
	pingMonitorFrame.BorderSizePixel = 0
	pingMonitorFrame.Visible = false
	pingMonitorFrame.ZIndex = 100
	pingMonitorFrame.Parent = screenGui
	
	-- UICorner для закругленных углов
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = pingMonitorFrame
	
	-- UIStroke для рамки
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(60, 60, 60)
	stroke.Thickness = 1
	stroke.Parent = pingMonitorFrame
	
	-- Заголовок
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, 0, 0, 25)
	titleLabel.Position = UDim2.new(0, 0, 0, 5)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "Ping Monitor"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 14
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Center
	titleLabel.Parent = pingMonitorFrame
	
	-- Разделитель
	local separator = Instance.new("Frame")
	separator.Name = "Separator"
	separator.Size = UDim2.new(1, -20, 0, 1)
	separator.Position = UDim2.new(0, 10, 0, 30)
	separator.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	separator.BorderSizePixel = 0
	separator.Parent = pingMonitorFrame
	
	-- UICorner для разделителя
	local separatorCorner = Instance.new("UICorner")
	separatorCorner.CornerRadius = UDim.new(0, 0.5)
	separatorCorner.Parent = separator
	
	-- Значение пинга
	pingValueLabel = Instance.new("TextLabel")
	pingValueLabel.Name = "PingValueLabel"
	pingValueLabel.Size = UDim2.new(1, 0, 0, 30)
	pingValueLabel.Position = UDim2.new(0, 0, 0, 40)
	pingValueLabel.BackgroundTransparency = 1
	pingValueLabel.Text = "Ping: -- ms"
	pingValueLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	pingValueLabel.TextSize = 16
	pingValueLabel.Font = Enum.Font.Gotham
	pingValueLabel.TextXAlignment = Enum.TextXAlignment.Center
	pingValueLabel.Parent = pingMonitorFrame
end
-- Создаем Ping Monitor UI
createPingMonitorUI()
-- Создаём MainFrame (как в оригинале)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 700, 0, 500)
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui
-- UICorner для MainFrame
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame
-- UIStroke для MainFrame
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Colors.Stroke
mainStroke.Thickness = 1
mainStroke.Parent = mainFrame
-- Создаём ButtonContainer (как в оригинале)
local buttonContainer = Instance.new("Frame")
buttonContainer.Name = "ButtonContainer"
buttonContainer.Size = UDim2.new(0, 60, 0, 30)
buttonContainer.Position = UDim2.new(1, -65, 0, 5)
buttonContainer.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
buttonContainer.BackgroundTransparency = 1
buttonContainer.BorderSizePixel = 1
buttonContainer.Parent = mainFrame
-- Кнопка свернуть (-)
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 25, 0, 25)
minimizeButton.Position = UDim2.new(0, 0, 0, 0)
minimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minimizeButton.BackgroundTransparency = 0
minimizeButton.BorderSizePixel = 1
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextSize = 20
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Parent = buttonContainer
-- UICorner для кнопки свернуть
local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 6)
minimizeCorner.Parent = minimizeButton
-- Hover эффект для кнопки свернуть
minimizeButton.MouseEnter:Connect(function()
	TweenService:Create(minimizeButton, TweenInfo.new(0.2), {
		BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	}):Play()
end)
minimizeButton.MouseLeave:Connect(function()
	TweenService:Create(minimizeButton, TweenInfo.new(0.2), {
		BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	}):Play()
end)
-- Кнопка закрыть (×) - как в оригинале
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(0, 30, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BackgroundTransparency = 0
closeButton.BorderSizePixel = 1
closeButton.BorderColor3 = Color3.fromRGB(27, 42, 53)
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 20
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = buttonContainer
-- UICorner для кнопки закрыть
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton
-- Hover эффект для кнопки закрыть (как в оригинале)
closeButton.MouseEnter:Connect(function()
	TweenService:Create(closeButton, TweenInfo.new(0.2), {
		BackgroundColor3 = Color3.fromRGB(220, 70, 70)
	}):Play()
end)
closeButton.MouseLeave:Connect(function()
	TweenService:Create(closeButton, TweenInfo.new(0.2), {
		BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	}):Play()
end)
-- Создаём Sidebar (как в оригинале)
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 180, 1, 0)
sidebar.Position = UDim2.new(0, 0, 0, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
sidebar.BackgroundTransparency = 0.3
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame
-- UICorner для Sidebar
local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 12)
sidebarCorner.Parent = sidebar
-- UIPadding для Sidebar
local sidebarPadding = Instance.new("UIPadding")
sidebarPadding.PaddingTop = UDim.new(0, 10)
sidebarPadding.PaddingLeft = UDim.new(0, 10)
sidebarPadding.PaddingRight = UDim.new(0, 10)
sidebarPadding.PaddingBottom = UDim.new(0, 10)
sidebarPadding.Parent = sidebar
-- Декоративная иконка в Sidebar (как в оригинале)
local decorativeIcon = Instance.new("TextButton")
decorativeIcon.Name = "DecorativeIcon"
decorativeIcon.Size = UDim2.new(0, 40, 0, 40)
decorativeIcon.Position = UDim2.new(0, 5, 0, 5)
decorativeIcon.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
decorativeIcon.BackgroundTransparency = 1
decorativeIcon.BorderSizePixel = 1
decorativeIcon.Text = ""
decorativeIcon.Parent = sidebar
-- UICorner для DecorativeIcon
local decorativeCorner = Instance.new("UICorner")
decorativeCorner.CornerRadius = UDim.new(0, 8)
decorativeCorner.Parent = decorativeIcon
-- UIStroke для DecorativeIcon
local decorativeStroke = Instance.new("UIStroke")
decorativeStroke.Color = Color3.fromRGB(100, 100, 100)
decorativeStroke.Thickness = 1
decorativeStroke.Parent = decorativeIcon
-- IconImage внутри DecorativeIcon (как в оригинале)
local decorativeIconImage = Instance.new("ImageLabel")
decorativeIconImage.Name = "IconImage"
decorativeIconImage.Size = UDim2.new(1, 0, 1, 0)
decorativeIconImage.Position = UDim2.new(0, 0, 0, 0)
decorativeIconImage.BackgroundTransparency = 1
decorativeIconImage.BorderSizePixel = 0
decorativeIconImage.Image = "rbxassetid://77552247496328" -- Иконка (как в оригинале)
decorativeIconImage.ScaleType = Enum.ScaleType.Fit
decorativeIconImage.Parent = decorativeIcon
-- UICorner для IconImage
local decorativeImageCorner = Instance.new("UICorner")
decorativeImageCorner.CornerRadius = UDim.new(0, 8)
decorativeImageCorner.Parent = decorativeIconImage
-- UIStroke для IconImage (как в оригинале)
local decorativeImageStroke = Instance.new("UIStroke")
decorativeImageStroke.Name = "IconStroke"
decorativeImageStroke.Color = Color3.fromRGB(251, 255, 255)
decorativeImageStroke.Thickness = 2.5
decorativeImageStroke.Transparency = 0
decorativeImageStroke.Parent = decorativeIconImage
-- Заголовок в Sidebar (как в оригинале)
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1.02352953, -70, 0, 40)
title.Position = UDim2.new(0, 51, 0, -3)
title.BackgroundTransparency = 1
title.Text = "NexusHubX - FishIt!"
title.TextColor3 = Color3.fromRGB(220, 220, 220)
title.TextSize = 12
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = sidebar
-- UICorner для Title
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title
-- Создаём ContentArea (как в оригинале)
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -180, 1, 0)
contentArea.Position = UDim2.new(0, 180, 0, 0)
contentArea.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
contentArea.BackgroundTransparency = 1
contentArea.BorderSizePixel = 0
contentArea.Parent = mainFrame
-- UICorner для ContentArea
local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 12)
contentCorner.Parent = contentArea
-- UIStroke для ContentArea
local contentStroke = Instance.new("UIStroke")
contentStroke.Color = Colors.Stroke
local contentStrokeTransparency = Instance.new("NumberValue")
contentStrokeTransparency.Name = "Transparency"
contentStrokeTransparency.Value = 0.5
contentStrokeTransparency.Parent = contentStroke
contentStroke.Parent = contentArea
-- UIPadding для ContentArea
local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingTop = UDim.new(0, 15)
contentPadding.PaddingLeft = UDim.new(0, 15)
contentPadding.PaddingRight = UDim.new(0, 15)
contentPadding.PaddingBottom = UDim.new(0, 15)
contentPadding.Parent = contentArea
-- Заголовок категории
local categoryTitle = Instance.new("TextLabel")
categoryTitle.Name = "CategoryTitle"
categoryTitle.Size = UDim2.new(1, 0, 0, 30)
categoryTitle.Position = UDim2.new(0, 0, 0, 0)
categoryTitle.BackgroundTransparency = 1
categoryTitle.Text = "Farm"
categoryTitle.TextColor3 = Colors.Text
categoryTitle.TextSize = 20
categoryTitle.Font = Enum.Font.GothamBold
categoryTitle.TextXAlignment = Enum.TextXAlignment.Left
categoryTitle.Parent = contentArea
-- UICorner для CategoryTitle
local categoryTitleCorner = Instance.new("UICorner")
categoryTitleCorner.CornerRadius = UDim.new(0, 8)
categoryTitleCorner.Parent = categoryTitle
-- Создаём ScrollFrame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, 0, 1, -40)
scrollFrame.Position = UDim2.new(0, 0, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
scrollFrame.Parent = contentArea
-- UICorner для ScrollFrame
local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 8)
scrollCorner.Parent = scrollFrame
-- UIStroke для ScrollFrame
local scrollStroke = Instance.new("UIStroke")
scrollStroke.Color = Colors.Stroke
scrollStroke.Thickness = 1
scrollStroke.Parent = scrollFrame
-- UIListLayout для ScrollFrame
local scrollLayout = Instance.new("UIListLayout")
scrollLayout.Padding = UDim.new(0, 10)
scrollLayout.Parent = scrollFrame
-- Категории
local categories = {"Farm", "Shop", "Teleport", "Auto Favorite", "Webhook", "Misc", "Settings"}
local categoryButtons = {}
local categoryFrames = {}
local currentCategory = "Farm"
-- Функция для создания кнопки категории (как в оригинале)
local function createCategoryButton(categoryName, index)
	local button = Instance.new("TextButton")
	button.Name = categoryName .. "Button"
	button.Size = UDim2.new(1, -20, 0, 40)
	button.Position = UDim2.new(0, 5, 0, 40 + (index - 1) * 45)
	button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	button.BackgroundTransparency = 0.8
	button.BorderSizePixel = 0
	button.Text = categoryName
	button.TextColor3 = Color3.fromRGB(220, 220, 220)
	button.TextSize = 14
	button.Font = Enum.Font.Gotham
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.Parent = sidebar
	
	-- UICorner (как в оригинале)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button
	
	-- UIPadding (как в оригинале)
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 15)
	padding.Parent = button
	
	-- UIStroke (как в оригинале)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(40, 40, 40)
	stroke.Thickness = 1
	stroke.Parent = button
	
	-- Hover эффект (как в оригинале)
	button.MouseEnter:Connect(function()
		if currentCategory ~= categoryName then
			TweenService:Create(button, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(60, 60, 60),
				BackgroundTransparency = 0.6
			}):Play()
		end
	end)
	
	button.MouseLeave:Connect(function()
		if currentCategory ~= categoryName then
			TweenService:Create(button, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				BackgroundTransparency = 0.8
			}):Play()
		end
	end)
	
	return button
end
-- Функция для создания toggle элемента (как в оригинале)
local function createToggleElement(parent, featureName, callback)
	local elementFrame = Instance.new("Frame")
	elementFrame.Name = featureName
	elementFrame.Size = UDim2.new(0.959, 0, 0, 40)
	elementFrame.Position = UDim2.new(0.02, 0, 0, 0)
	elementFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	elementFrame.BackgroundTransparency = 0.5
	elementFrame.BorderSizePixel = 0
	elementFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
	elementFrame.Parent = parent
	
	-- UICorner (как в оригинале)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = elementFrame
	
	-- UIStroke (как в оригинале)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(60, 60, 60)
	stroke.Thickness = 1
	stroke.Parent = elementFrame
	
	-- Заголовок (как в оригинале)
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -60, 1, 0)
	title.Position = UDim2.new(0, 15, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = featureName
	title.TextColor3 = Color3.fromRGB(220, 220, 220)
	title.TextSize = 16
	title.Font = Enum.Font.Gotham
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Center
	title.Parent = elementFrame
	
	-- Toggle кнопка (как в оригинале)
	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "Toggle"
	toggleButton.Size = UDim2.new(0, 40, 0, 24)
	toggleButton.Position = UDim2.new(1, -55, 0.5, -12)
	toggleButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
	toggleButton.BackgroundTransparency = 0
	toggleButton.BorderSizePixel = 0
	toggleButton.Text = ""
	toggleButton.TextSize = 8
	toggleButton.Font = Enum.Font.FredokaOne
	toggleButton.Parent = elementFrame
	
	-- UICorner для toggle (как в оригинале)
	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 12)
	toggleCorner.Parent = toggleButton
	
	-- Circle внутри toggle (как в оригинале)
	local circle = Instance.new("Frame")
	circle.Name = "Circle"
	circle.Size = UDim2.new(0, 20, 0, 20)
	circle.Position = UDim2.new(0, 2, 0.5, -10)
	circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	circle.BackgroundTransparency = 0
	circle.BorderSizePixel = 0
	circle.Parent = toggleButton
	
	-- UICorner для circle (как в оригинале)
	local circleCorner = Instance.new("UICorner")
	circleCorner.CornerRadius = UDim.new(0, 10)
	circleCorner.Parent = circle
	
	-- Переменная состояния
	local isToggled = false
	
	-- Функция для обновления состояния toggle (как в оригинале)
	local function updateToggle()
		if isToggled then
			TweenService:Create(toggleButton, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(120, 120, 120)
			}):Play()
			TweenService:Create(circle, TweenInfo.new(0.2), {
				Position = UDim2.new(0, 18, 0.5, -10)
			}):Play()
		else
			TweenService:Create(toggleButton, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(90, 90, 90)
			}):Play()
			TweenService:Create(circle, TweenInfo.new(0.2), {
				Position = UDim2.new(0, 2, 0.5, -10)
			}):Play()
		end
	end
	
	-- Click callback
	toggleButton.MouseButton1Click:Connect(function()
		isToggled = not isToggled
		updateToggle()
		callback(isToggled)
	end)
	
	return elementFrame
end
-- Функция для создания кнопки с подменю
local function createMenuButton(parent, featureName, callback)
	local elementButton = Instance.new("TextButton")
	elementButton.Name = featureName
	elementButton.Size = UDim2.new(0.959, 0, 0, 40)
	elementButton.Position = UDim2.new(0.02, 0, 0, 0)
	elementButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	elementButton.BackgroundTransparency = 0.5
	elementButton.BorderSizePixel = 0
	elementButton.BorderColor3 = Color3.fromRGB(60, 60, 60)
	elementButton.Text = ""
	elementButton.Parent = parent
	
	-- UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = elementButton
	
	-- UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(60, 60, 60)
	stroke.Thickness = 1
	stroke.Parent = elementButton
	
	-- Заголовок
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -60, 1, 0)
	title.Position = UDim2.new(0, 15, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = featureName
	title.TextColor3 = Color3.fromRGB(220, 220, 220)
	title.TextSize = 16
	title.Font = Enum.Font.Gotham
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Center
	title.Parent = elementButton
	
	-- Стрелка
	local arrow = Instance.new("TextLabel")
	arrow.Name = "Arrow"
	arrow.Size = UDim2.new(0, 30, 0, 30)
	arrow.Position = UDim2.new(1, -40, 0.5, -15)
	arrow.BackgroundTransparency = 1
	arrow.Text = "▼"
	arrow.TextColor3 = Color3.fromRGB(180, 180, 180)
	arrow.TextSize = 14
	arrow.Font = Enum.Font.GothamBold
	arrow.TextXAlignment = Enum.TextXAlignment.Center
	arrow.TextYAlignment = Enum.TextYAlignment.Center
	arrow.Parent = elementButton
	
	-- Hover эффект
	elementButton.MouseEnter:Connect(function()
		TweenService:Create(elementButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		}):Play()
	end)
	
	elementButton.MouseLeave:Connect(function()
		TweenService:Create(elementButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		}):Play()
	end)
	
	-- Click callback
	elementButton.MouseButton1Click:Connect(function()
		callback()
	end)
	
	return elementButton
end
-- Функция для создания кнопки keybind
local function createKeybindButton(parent, featureName, callback)
	local elementFrame = Instance.new("Frame")
	elementFrame.Name = featureName
	elementFrame.Size = UDim2.new(0.959, 0, 0, 40)
	elementFrame.Position = UDim2.new(0.02, 0, 0, 0)
	elementFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	elementFrame.BackgroundTransparency = 0.5
	elementFrame.BorderSizePixel = 0
	elementFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
	elementFrame.Parent = parent
	
	-- UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = elementFrame
	
	-- UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(60, 60, 60)
	stroke.Thickness = 1
	stroke.Parent = elementFrame
	
	-- Заголовок
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -60, 1, 0)
	title.Position = UDim2.new(0, 15, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = featureName
	title.TextColor3 = Color3.fromRGB(220, 220, 220)
	title.TextSize = 16
	title.Font = Enum.Font.Gotham
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Center
	title.Parent = elementFrame
	
	-- Кнопка keybind
	local keybindButton = Instance.new("TextButton")
	keybindButton.Name = "Keybind"
	keybindButton.Size = UDim2.new(0, 80, 0, 24)
	keybindButton.Position = UDim2.new(1, -90, 0.5, -12)
	keybindButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
	keybindButton.BackgroundTransparency = 0
	keybindButton.BorderSizePixel = 0
	keybindButton.Text = keybind.Name
	keybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	keybindButton.TextSize = 12
	keybindButton.Font = Enum.Font.GothamBold
	keybindButton.Parent = elementFrame
	
	-- UICorner для кнопки
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = keybindButton
	
	-- Click callback
	keybindButton.MouseButton1Click:Connect(function()
		if isChangingKeybind then return end
		
		isChangingKeybind = true
		keybindButton.Text = "Press any key..."
		keybindButton.TextColor3 = Color3.fromRGB(255, 200, 100)
		
		local inputConnection
		inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then return end
			
			if input.KeyCode ~= Enum.KeyCode.Unknown and input.UserInputType == Enum.UserInputType.Keyboard then
				keybind = input.KeyCode
				keybindButton.Text = keybind.Name
				keybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
				isChangingKeybind = false
				inputConnection:Disconnect()
				callback(keybind)
			end
		end)
	end)
	
	return elementFrame
end
-- Функция для создания подменю с телепортами
local function createTeleportMenu(parent, locations, title)
	-- Создаем фрейм подменю
	local menuFrame = Instance.new("Frame")
	menuFrame.Name = title .. "Menu"
	menuFrame.Size = UDim2.new(1, 0, 0, 400)
	menuFrame.Position = UDim2.new(0, 0, 0, 0)
	menuFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	menuFrame.BackgroundTransparency = 0
	menuFrame.BorderSizePixel = 0
	menuFrame.Visible = false
	menuFrame.ZIndex = 10
	menuFrame.Parent = parent
	
	-- UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = menuFrame
	
	-- UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(80, 80, 80)
	stroke.Thickness = 1
	stroke.Parent = menuFrame
	
	-- Заголовок
	local menuTitle = Instance.new("TextLabel")
	menuTitle.Name = "MenuTitle"
	menuTitle.Size = UDim2.new(1, 0, 0, 35)
	menuTitle.Position = UDim2.new(0, 0, 0, 0)
	menuTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	menuTitle.BackgroundTransparency = 0
	menuTitle.BorderSizePixel = 0
	menuTitle.Text = title
	menuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	menuTitle.TextSize = 16
	menuTitle.Font = Enum.Font.GothamBold
	menuTitle.TextXAlignment = Enum.TextXAlignment.Center
	menuTitle.TextYAlignment = Enum.TextYAlignment.Center
	menuTitle.Parent = menuFrame
	
	-- UICorner для заголовка
	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 8)
	titleCorner.Parent = menuTitle
	
	-- Кнопка закрыть
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -35, 0, 2.5)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeButton.BackgroundTransparency = 0
	closeButton.BorderSizePixel = 0
	closeButton.Text = "×"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 20
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = menuFrame
	
	-- UICorner для кнопки закрыть
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeButton
	
	-- ScrollFrame для списка
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "ScrollFrame"
	scrollFrame.Size = UDim2.new(1, -20, 1, -45)
	scrollFrame.Position = UDim2.new(0, 10, 0, 40)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
	scrollFrame.Parent = menuFrame
	
	-- UIListLayout
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 5)
	layout.Parent = scrollFrame
	
	-- Создаем кнопки для каждой локации
	for _, location in ipairs(locations) do
		local button = Instance.new("TextButton")
		button.Name = location.name
		button.Size = UDim2.new(1, 0, 0, 35)
		button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		button.BackgroundTransparency = 0
		button.BorderSizePixel = 0
		button.Text = location.name
		button.TextColor3 = Color3.fromRGB(220, 220, 220)
		button.TextSize = 14
		button.Font = Enum.Font.Gotham
		button.TextXAlignment = Enum.TextXAlignment.Left
		button.Parent = scrollFrame
		
		-- UICorner
		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 6)
		btnCorner.Parent = button
		
		-- UIPadding
		local btnPadding = Instance.new("UIPadding")
		btnPadding.PaddingLeft = UDim.new(0, 10)
		btnPadding.Parent = button
		
		-- Hover эффект
		button.MouseEnter:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			}):Play()
		end)
		
		button.MouseLeave:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			}):Play()
		end)
		
		-- Teleport callback
		button.MouseButton1Click:Connect(function()
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(location.pos)
			end
			menuFrame.Visible = false
		end)
	end
	
	-- Обновляем размер ScrollFrame
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #locations * 40)
	
	-- Кнопка закрыть
	closeButton.MouseButton1Click:Connect(function()
		menuFrame.Visible = false
	end)
	
	-- Закрытие при клике вне меню
	local function closeMenuIfClickedOutside(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local mousePos = input.Position
			local menuPos = menuFrame.AbsolutePosition
			local menuSize = menuFrame.AbsoluteSize
			
			-- Проверяем, клик ли вне меню
			if mousePos.X < menuPos.X or mousePos.X > menuPos.X + menuSize.X or
			   mousePos.Y < menuPos.Y or mousePos.Y > menuPos.Y + menuSize.Y then
				menuFrame.Visible = false
			end
		end
	end
	
	-- Подключаем обработчик клика вне меню
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if menuFrame.Visible then
			closeMenuIfClickedOutside(input)
		end
	end)
	
	return menuFrame
end
-- Функция для создания меню игроков
local function createPlayerMenu(parent)
	-- Создаем фрейм подменю
	local menuFrame = Instance.new("Frame")
	menuFrame.Name = "PlayerMenu"
	menuFrame.Size = UDim2.new(1, 0, 0, 400)
	menuFrame.Position = UDim2.new(0, 0, 0, 0)
	menuFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	menuFrame.BackgroundTransparency = 0
	menuFrame.BorderSizePixel = 0
	menuFrame.Visible = false
	menuFrame.ZIndex = 10
	menuFrame.Parent = parent
	
	-- UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = menuFrame
	
	-- UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(80, 80, 80)
	stroke.Thickness = 1
	stroke.Parent = menuFrame
	
	-- Заголовок
	local menuTitle = Instance.new("TextLabel")
	menuTitle.Name = "MenuTitle"
	menuTitle.Size = UDim2.new(1, 0, 0, 35)
	menuTitle.Position = UDim2.new(0, 0, 0, 0)
	menuTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	menuTitle.BackgroundTransparency = 0
	menuTitle.BorderSizePixel = 0
	menuTitle.Text = "Select Player"
	menuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	menuTitle.TextSize = 16
	menuTitle.Font = Enum.Font.GothamBold
	menuTitle.TextXAlignment = Enum.TextXAlignment.Center
	menuTitle.TextYAlignment = Enum.TextYAlignment.Center
	menuTitle.Parent = menuFrame
	
	-- UICorner для заголовка
	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 8)
	titleCorner.Parent = menuTitle
	
	-- Кнопка закрыть
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -35, 0, 2.5)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeButton.BackgroundTransparency = 0
	closeButton.BorderSizePixel = 0
	closeButton.Text = "×"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 20
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = menuFrame
	
	-- UICorner для кнопки закрыть
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeButton
	
	-- ScrollFrame для списка
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "ScrollFrame"
	scrollFrame.Size = UDim2.new(1, -20, 1, -45)
	scrollFrame.Position = UDim2.new(0, 10, 0, 40)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
	scrollFrame.Parent = menuFrame
	
	-- UIListLayout
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 5)
	layout.Parent = scrollFrame
	
	-- Функция для обновления списка игроков
	local function updatePlayerList()
		-- Очищаем старые кнопки
		for _, child in scrollFrame:GetChildren() do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		
		-- Получаем всех игроков
		local playersList = Players:GetPlayers()
		
		-- Создаем кнопки для каждого игрока
		for _, targetPlayer in ipairs(playersList) do
			if targetPlayer ~= LocalPlayer then -- Не показываем себя
				local button = Instance.new("TextButton")
				button.Name = targetPlayer.Name
				button.Size = UDim2.new(1, 0, 0, 35)
				button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
				button.BackgroundTransparency = 0
				button.BorderSizePixel = 0
				button.Text = targetPlayer.Name
				button.TextColor3 = Color3.fromRGB(220, 220, 220)
				button.TextSize = 14
				button.Font = Enum.Font.Gotham
				button.TextXAlignment = Enum.TextXAlignment.Left
				button.Parent = scrollFrame
				
				-- UICorner
				local btnCorner = Instance.new("UICorner")
				btnCorner.CornerRadius = UDim.new(0, 6)
				btnCorner.Parent = button
				
				-- UIPadding
				local btnPadding = Instance.new("UIPadding")
				btnPadding.PaddingLeft = UDim.new(0, 10)
				btnPadding.Parent = button
				
				-- Hover эффект
				button.MouseEnter:Connect(function()
					TweenService:Create(button, TweenInfo.new(0.2), {
						BackgroundColor3 = Color3.fromRGB(70, 70, 70)
					}):Play()
				end)
				
				button.MouseLeave:Connect(function()
					TweenService:Create(button, TweenInfo.new(0.2), {
						BackgroundColor3 = Color3.fromRGB(50, 50, 50)
					}):Play()
				end)
				
				-- Teleport callback
				button.MouseButton1Click:Connect(function()
					if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
						LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
					end
					menuFrame.Visible = false
				end)
			end
		end
		
		-- Обновляем размер ScrollFrame
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #playersList * 40)
	end
	
	-- Кнопка закрыть
	closeButton.MouseButton1Click:Connect(function()
		menuFrame.Visible = false
	end)
	
	-- Обновляем список при открытии
	menuFrame:GetPropertyChangedSignal("Visible"):Connect(function()
		if menuFrame.Visible then
			updatePlayerList()
		end
	end)
	
	return menuFrame
end
-- Функция для создания slider элемента
local function createSliderElement(parent, featureName, minValue, maxValue, defaultValue, callback)
	local elementFrame = Instance.new("Frame")
	elementFrame.Name = featureName
	elementFrame.Size = UDim2.new(0.959, 0, 0, 60)
	elementFrame.Position = UDim2.new(0.02, 0, 0, 0)
	elementFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	elementFrame.BackgroundTransparency = 0.5
	elementFrame.BorderSizePixel = 0
	elementFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
	elementFrame.Parent = parent
	
	-- UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = elementFrame
	
	-- UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(60, 60, 60)
	stroke.Thickness = 1
	stroke.Parent = elementFrame
	
	-- Заголовок
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -100, 0, 25)
	title.Position = UDim2.new(0, 15, 0, 5)
	title.BackgroundTransparency = 1
	title.Text = featureName
	title.TextColor3 = Color3.fromRGB(220, 220, 220)
	title.TextSize = 16
	title.Font = Enum.Font.Gotham
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Center
	title.Parent = elementFrame
	
	-- Значение
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Name = "ValueLabel"
	valueLabel.Size = UDim2.new(0, 80, 0, 25)
	valueLabel.Position = UDim2.new(1, -90, 0, 5)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(defaultValue)
	valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	valueLabel.TextSize = 14
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = elementFrame
	
	-- Slider track
	local sliderTrack = Instance.new("ImageButton")
	sliderTrack.Name = "SliderTrack"
	sliderTrack.Size = UDim2.new(1, -30, 0, 8)
	sliderTrack.Position = UDim2.new(0, 15, 1, -20)
	sliderTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	sliderTrack.BorderSizePixel = 0
	sliderTrack.Image = ""
	sliderTrack.Parent = elementFrame
	
	-- UICorner для track
	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(0, 4)
	trackCorner.Parent = sliderTrack
	
	-- Slider fill
	local sliderFill = Instance.new("Frame")
	sliderFill.Name = "SliderFill"
	sliderFill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
	sliderFill.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
	sliderFill.BorderSizePixel = 0
	sliderFill.Parent = sliderTrack
	
	-- UICorner для fill
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 4)
	fillCorner.Parent = sliderFill
	
	-- Slider knob
	local sliderKnob = Instance.new("ImageButton")
	sliderKnob.Name = "SliderKnob"
	sliderKnob.Size = UDim2.new(0, 16, 0, 16)
	sliderKnob.Position = UDim2.new((defaultValue - minValue) / (maxValue - minValue), -8, 0.5, -8)
	sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sliderKnob.BorderSizePixel = 0
	sliderKnob.Image = ""
	sliderKnob.Parent = sliderTrack
	
	-- UICorner для knob
	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(0, 8)
	knobCorner.Parent = sliderKnob
	
	-- Переменная состояния
	local currentValue = defaultValue
	local isDragging = false
	
	-- Функция для обновления slider
	local function updateSlider(input)
		local mousePos = input.Position.X
		local trackPos = sliderTrack.AbsolutePosition.X
		local trackSize = sliderTrack.AbsoluteSize.X
		local relativePos = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
		
		currentValue = math.floor(minValue + relativePos * (maxValue - minValue))
		valueLabel.Text = tostring(currentValue)
		sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
		sliderKnob.Position = UDim2.new(relativePos, -8, 0.5, -8)
		
		callback(currentValue)
		return relativePos
	end
	
	-- Mouse events
	sliderKnob.MouseButton1Down:Connect(function()
		isDragging = true
	end)
	
	sliderTrack.MouseButton1Down:Connect(function(input)
		isDragging = true
		updateSlider(input)
	end)
	
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then
			updateSlider(input)
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
			updateSlider(input)
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = false
		end
	end)
	
	-- Инициализация ползунка
	updateSlider({Position = Vector2.new(sliderTrack.AbsolutePosition.X + (defaultValue - minValue) / (maxValue - minValue) * sliderTrack.AbsoluteSize.X, 0)})
	
	return elementFrame
end
local function createCategoryFrame(categoryName)
	local frame = Instance.new("Frame")
	frame.Name = categoryName .. "Frame"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.Parent = scrollFrame
	
	-- UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame
	
	-- UIPadding
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 10)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.PaddingBottom = UDim.new(0, 10)
	padding.Parent = frame
	
	-- UIListLayout
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.Parent = frame
	
	-- Добавляем toggle элементы в зависимости от категории
	if categoryName == "Farm" then
		createToggleElement(frame, "Auto Fish", function(isToggled)
			-- Auto Fish functionality
			print("Auto Fish:", isToggled)
		end)
		
		createToggleElement(frame, "Auto Reel", function(isToggled)
			-- Auto Reel functionality
			print("Auto Reel:", isToggled)
		end)
		
		createToggleElement(frame, "Auto Cast", function(isToggled)
			-- Auto Cast functionality
			print("Auto Cast:", isToggled)
		end)
		
	elseif categoryName == "Shop" then
		
	elseif categoryName == "Teleport" then
		-- Локации для телепортации
		local locations = {
			{["name"] = "Fisherman Island", ["pos"] = Vector3.new(34.2641716003418, 9.628792762756348, 2803.64599609375)},
			{["name"] = "Traveling Merchant", ["pos"] = Vector3.new(-137.52841186523438, 3.2620537281036377, 2768.219970703125)},
			{["name"] = "Planetary Observatory", ["pos"] = Vector3.new(394.7527770996094, 7.251010417938232, 2157.100341796875)},
			{["name"] = "Crater Island", ["pos"] = Vector3.new(969.0936279296875, 7.362037181854248, 4872.45166015625)},
			{["name"] = "Tropical Grove", ["pos"] = Vector3.new(-2129.407958984375, 53.48722839355469, 3741.8310546875)},
			{["name"] = "Weather Machine", ["pos"] = Vector3.new(-1519.586669921875, 6.499998569488525, 1884.587646484375)},
			{["name"] = "Coral Reefs", ["pos"] = Vector3.new(-3186.4384765625, 10.021647453308105, 2250.93359375)},
			{["name"] = "Crater Island", ["pos"] = Vector3.new(986.1216430664062, 30.208383560180664, 4952.654296875)},
			{["name"] = "Pirate Cove", ["pos"] = Vector3.new(3358.006591796875, 4.192970275878906, 3519.951171875)},
			{["name"] = "Pirate Treasure Room", ["pos"] = Vector3.new(3302.267333984375, -299.5013122558594, 3016.651123046875)},
			{["name"] = "Leviathans Lair", ["pos"] = Vector3.new(3473.525146484375, -287.84320068359375, 3474.171630859375)},
			{["name"] = "Crystal Depths", ["pos"] = Vector3.new(5686.9443359375, -891.0681762695312, 15294.7333984375)},
			{["name"] = "Esoteric Depths", ["pos"] = Vector3.new(3193.7265625, -1302.7301025390625, 1420.59814453125)},
			{["name"] = "Kohana", ["pos"] = Vector3.new(-643.0057373046875, 16.030197143554688, 615.0732421875)},
			{["name"] = "Kohana Volcano", ["pos"] = Vector3.new(-497.61676025390625, 22.394704818725586, 177.54757690429688)},
			{["name"] = "Lava Basin", ["pos"] = Vector3.new(1042.163818359375, 85.89966583251953, -10246.27734375)},
			{["name"] = "Ancient Jungle", ["pos"] = Vector3.new(1453.7100830078125, 7.6254987716674805, -329.9733581542969)},
			{["name"] = "Sacred Temple", ["pos"] = Vector3.new(1475.955078125, -21.849966049194336, -630.0169067382812)},
			{["name"] = "Ancient Ruin", ["pos"] = Vector3.new(6050.234375, -585.9246215820312, 4713.1767578125)},
			{["name"] = "Treasure Room", ["pos"] = Vector3.new(-3599.53759765625, -266.57379150390625, -1572.31298828125)},
			{["name"] = "Sisiphys Statue", ["pos"] = Vector3.new(-3698.338623046875, -135.57444763183594, -1026.4268798828125)},
			{["name"] = "Underground Cellar", ["pos"] = Vector3.new(2135.52490234375, -91.19860076904297, -699.4429931640625)}
		}
		
		-- Создаем меню телепортации на острова
		local islandMenu = createTeleportMenu(frame, locations, "Teleport to Island")
		
		-- Кнопка Teleport to Island
		createMenuButton(frame, "Teleport to Island", function()
			islandMenu.Visible = true
		end)
		
		-- Создаем меню игроков
		local playerMenu = createPlayerMenu(frame)
		
		-- Кнопка Teleport to Player
		createMenuButton(frame, "Teleport to Player", function()
			playerMenu.Visible = true
		end)
		
	elseif categoryName == "Auto Favorite" then
		createToggleElement(frame, "Auto Favorite All", function(isToggled)
					end)
		createToggleElement(frame, "Auto Favorite Rare", function(isToggled)
					end)
		
	elseif categoryName == "Webhook" then
		createToggleElement(frame, "Send Webhook", function(isToggled)
					end)
		createToggleElement(frame, "Auto Webhook", function(isToggled)
					end)
		
	elseif categoryName == "Misc" then
		-- Noclip (вкл/выкл)
		createToggleElement(frame, "Noclip", function(isToggled)
						noclipEnabled = isToggled
		end)
		
		-- Speed (ползунок от 16 до 200)
		createSliderElement(frame, "Speed", 16, 200, 16, function(value)
			currentSpeed = value
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
				LocalPlayer.Character.Humanoid.WalkSpeed = value
			end
		end)
		
		-- Airwalk (вкл/выкл)
		createToggleElement(frame, "Airwalk", function(isToggled)
						airwalkEnabled = isToggled
			
			if isToggled then
				-- Создаем невидимую платформу
				airwalkPart = Instance.new("Part")
				airwalkPart.Name = "AirwalkPart"
				airwalkPart.Size = Vector3.new(5, 1, 5)
				airwalkPart.Transparency = 1
				airwalkPart.CanCollide = true
				airwalkPart.Anchored = true
				airwalkPart.Parent = workspace
				
				-- Обновляем позицию платформы
				RunService.RenderStepped:Connect(function()
					if airwalkEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
						local hrp = LocalPlayer.Character.HumanoidRootPart
						airwalkPart.Position = Vector3.new(hrp.Position.X, hrp.Position.Y - 3, hrp.Position.Z)
					end
				end)
			else
				-- Удаляем платформу
				if airwalkPart then
					airwalkPart:Destroy()
					airwalkPart = nil
				end
			end
		end)
		
		-- Jump (ползунок от 50 до 200)
		createSliderElement(frame, "Jump", 50, 200, 50, function(value)
			currentJump = value
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
				LocalPlayer.Character.Humanoid.JumpPower = value
			end
		end)
		
		-- InfinityJump (вкл/выкл)
		createToggleElement(frame, "InfinityJump", function(isToggled)
						infiniteJumpEnabled = isToggled
		end)
		
	elseif categoryName == "Settings" then
		-- Keybind кнопка
		createKeybindButton(frame, "Keybind", function(newKeybind)
					end)
		
		-- Ping Monitor toggle
		createToggleElement(frame, "Ping Monitor", function(isToggled)
			isPingMonitorEnabled = isToggled
						
			if pingMonitorFrame then
				pingMonitorFrame.Visible = isToggled
			end
		end)
		
		-- Potato Graphics toggle
		createToggleElement(frame, "Potato Graphics", function(isToggled)
			isPotatoGraphicsEnabled = isToggled
						
			if isPotatoGraphicsEnabled then
				enablePotatoGraphics()
			else
				disablePotatoGraphics()
			end
		end)
	end
	
	return frame
end
-- Potato Graphics функции
local function enablePotatoGraphics()
	local Lighting = game:GetService("Lighting")
	local Workspace = game:GetService("Workspace")
	
	pcall(function()
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 1e9
		Lighting.Brightness = 1
		Lighting.Ambient = Color3.fromRGB(140,140,140)
		Lighting.OutdoorAmbient = Color3.fromRGB(140,140,140)
		Lighting.EnvironmentDiffuseScale = 0
		Lighting.EnvironmentSpecularScale = 0
	end)
	
	for _,v in ipairs(Lighting:GetChildren()) do
		if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
			v:Destroy()
		end
	end
	
	local sky = Instance.new("Sky")
	local SKY_ID = "rbxassetid://79747281250125"
	
	sky.SkyboxBk = SKY_ID
	sky.SkyboxDn = SKY_ID
	sky.SkyboxFt = SKY_ID
	sky.SkyboxLf = SKY_ID
	sky.SkyboxRt = SKY_ID
	sky.SkyboxUp = SKY_ID
	sky.SunAngularSize = 0
	sky.MoonAngularSize = 0
	sky.StarCount = 0
	sky.Parent = Lighting
	
	local function removeEffect(obj)
		if obj:IsA("ParticleEmitter")
		or obj:IsA("Trail")
		or obj:IsA("Beam")
		or obj:IsA("Explosion")
		or obj:IsA("Smoke")
		or obj:IsA("Fire") then
			obj:Destroy()
		end
	end
	
	local function cleanPart(part)
		part.CastShadow = false
		part.Reflectance = 0
		part.Material = Enum.Material.Plastic
		part.Color = Color3.fromRGB(150,150,150)
	end
	
	for _,obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			cleanPart(obj)
		elseif obj:IsA("Decal") or obj:IsA("Texture") then
			obj:Destroy()
		else
			removeEffect(obj)
		end
	end
	
	Workspace.DescendantAdded:Connect(function(obj)
		if obj:IsA("BasePart") then
			task.wait()
			cleanPart(obj)
		elseif obj:IsA("Decal") or obj:IsA("Texture") then
			obj:Destroy()
		else
			removeEffect(obj)
		end
	end)
	
	local function cleanCharacter(char)
		for _,v in ipairs(char:GetDescendants()) do
			if v:IsA("Shirt")
			or v:IsA("Pants")
			or v:IsA("ShirtGraphic") then
				v:Destroy()
			elseif v:IsA("Decal") and v.Name == "face" then
				v:Destroy()
			elseif v:IsA("BasePart") then
				cleanPart(v)
			elseif v:IsA("Accessory") then
				local handle = v:FindFirstChild("Handle")
				if handle and handle:IsA("BasePart") then
					cleanPart(handle)
				end
			end
		end
	end
	
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr.Character then
			cleanCharacter(plr.Character)
		end
		plr.CharacterAdded:Connect(cleanCharacter)
	end
	
	for _,model in ipairs(Workspace:GetDescendants()) do
		if model:IsA("Model") and model:FindFirstChildWhichIsA("Humanoid") then
			cleanCharacter(model)
		end
	end
	
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end
local function disablePotatoGraphics()
	-- Сбрасываем настройки на значения по умолчанию
	local Lighting = game:GetService("Lighting")
	
	pcall(function()
		Lighting.GlobalShadows = true
		Lighting.FogEnd = 100000
		Lighting.Brightness = 2
		Lighting.Ambient = Color3.fromRGB(100, 100, 100)
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
		Lighting.EnvironmentDiffuseScale = 1
		Lighting.EnvironmentSpecularScale = 1
	end)
	
	settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
end
-- Создаём все категории
for i, category in ipairs(categories) do
	local button = createCategoryButton(category, i)
	categoryButtons[category] = button
	
	local frame = createCategoryFrame(category)
	categoryFrames[category] = frame
end
-- Функция для показа категории (как в оригинале)
local function showCategory(categoryName)
	-- Скрываем все фреймы
	for _, frame in pairs(categoryFrames) do
		frame.Visible = false
	end
	
	-- Сбрасываем все кнопки
	for name, button in pairs(categoryButtons) do
		TweenService:Create(button, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BackgroundTransparency = 0.8,
			TextColor3 = Color3.fromRGB(220, 220, 220)
		}):Play()
	end
	
	-- Показываем выбранную категорию
	if categoryFrames[categoryName] then
		categoryFrames[categoryName].Visible = true
	end
	
	-- Подсвечиваем выбранную кнопку (как в оригинале)
	if categoryButtons[categoryName] then
		TweenService:Create(categoryButtons[categoryName], TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(60, 100, 180),
			BackgroundTransparency = 0.6,
			TextColor3 = Color3.fromRGB(255, 255, 255)
		}):Play()
	end
	
	-- Обновляем заголовок
	categoryTitle.Text = categoryName
	currentCategory = categoryName
end
-- Подключаем кнопки категорий
for category, button in pairs(categoryButtons) do
	button.MouseButton1Click:Connect(function()
		showCategory(category)
	end)
end
-- Показываем первую категорию
showCategory("Farm")
-- Создаём иконку меню (как в оригинале)
local menuIcon = Instance.new("TextButton")
menuIcon.Name = "MenuIcon"
menuIcon.Size = UDim2.new(0, 50, 0, 50)
menuIcon.Position = UDim2.new(0, 10, 0.5, -25)
menuIcon.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
menuIcon.BackgroundTransparency = 0.2
menuIcon.BorderSizePixel = 0
menuIcon.Text = ""
menuIcon.TextColor3 = Color3.fromRGB(27, 42, 53)
menuIcon.TextSize = 8
menuIcon.Font = Enum.Font.Arial
menuIcon.Parent = screenGui
-- UICorner для иконки
local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 12)
iconCorner.Parent = menuIcon
-- UIStroke для иконки
local iconStroke = Instance.new("UIStroke")
iconStroke.Color = Color3.fromRGB(27, 42, 53)
iconStroke.Thickness = 1
iconStroke.Parent = menuIcon
-- Создаём IconImage (как в оригинале)
local iconImage = Instance.new("ImageLabel")
iconImage.Name = "IconImage"
iconImage.Size = UDim2.new(1, 0, 1, 0)
iconImage.Position = UDim2.new(0, 0, 0, 0)
iconImage.BackgroundTransparency = 1
iconImage.BorderSizePixel = 0
iconImage.Image = "rbxassetid://77552247496328" -- Иконка меню (как в оригинале)
iconImage.ScaleType = Enum.ScaleType.Fit
iconImage.Parent = menuIcon
-- UICorner для IconImage
local iconImageCorner = Instance.new("UICorner")
iconImageCorner.CornerRadius = UDim.new(0, 8)
iconImageCorner.Parent = iconImage
-- UIStroke для IconImage (как в оригинале)
local iconImageStroke = Instance.new("UIStroke")
iconImageStroke.Name = "IconStroke"
iconImageStroke.Color = Color3.fromRGB(251, 255, 255)
iconImageStroke.Thickness = 2.5
iconImageStroke.Transparency = 0
iconImageStroke.Parent = iconImage
-- Переменная состояния меню
local menuOpen = false
-- Функция для переключения меню
local function toggleMenu()
	menuOpen = not menuOpen
	mainFrame.Visible = menuOpen
	
	if menuOpen then
		-- Анимация открытия
		mainFrame.Size = UDim2.new(0, 0, 0, 0)
		TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
			Size = UDim2.new(0, 700, 0, 500)
		}):Play()
	else
		-- Анимация закрытия
		TweenService:Create(mainFrame, TweenInfo.new(0.2), {
			Size = UDim2.new(0, 0, 0, 0)
		}):Play()
		task.wait(0.2)
		mainFrame.Visible = false
	end
end
-- Подключаем иконку меню
menuIcon.MouseButton1Click:Connect(toggleMenu)
-- Подключаем кнопку свернуть
minimizeButton.MouseButton1Click:Connect(toggleMenu)
-- Создаём диалоговое окно закрытия (как в оригинале)
local closeDialog = Instance.new("Frame")
closeDialog.Name = "CloseDialog"
closeDialog.Size = UDim2.new(0, 300, 0, 150)
closeDialog.Position = UDim2.new(0.5, -150, 0.5, -68)
closeDialog.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
closeDialog.BackgroundTransparency = 0
closeDialog.BorderSizePixel = 1
closeDialog.BorderColor3 = Color3.fromRGB(20, 20, 20)
closeDialog.Visible = false
closeDialog.ZIndex = 100
closeDialog.Parent = mainFrame
-- UICorner для диалога
local dialogCorner = Instance.new("UICorner")
dialogCorner.CornerRadius = UDim.new(0, 12)
dialogCorner.Parent = closeDialog
-- UIStroke для диалога
local dialogStroke = Instance.new("UIStroke")
dialogStroke.Color = Color3.fromRGB(20, 20, 20)
dialogStroke.Thickness = 1
dialogStroke.Parent = closeDialog
-- Заголовок диалога
local dialogTitle = Instance.new("TextLabel")
dialogTitle.Name = "Title"
dialogTitle.Size = UDim2.new(1, 0, 0, 40)
dialogTitle.Position = UDim2.new(0, 0, 0, 10)
dialogTitle.BackgroundTransparency = 1
dialogTitle.Text = "Close Window"
dialogTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
dialogTitle.TextSize = 20
dialogTitle.Font = Enum.Font.GothamBold
dialogTitle.TextXAlignment = Enum.TextXAlignment.Left
dialogTitle.Parent = closeDialog
-- UIPadding для заголовка диалога
local dialogTitlePadding = Instance.new("UIPadding")
dialogTitlePadding.PaddingLeft = UDim.new(0, 15)
dialogTitlePadding.Parent = dialogTitle
-- Вопрос диалога
local dialogQuestion = Instance.new("TextLabel")
dialogQuestion.Name = "Question"
dialogQuestion.Size = UDim2.new(1, 0, 0, 30)
dialogQuestion.Position = UDim2.new(0, 0, 0, 55)
dialogQuestion.BackgroundTransparency = 1
dialogQuestion.Text = "Do you want to close this window?"
dialogQuestion.TextColor3 = Color3.fromRGB(220, 220, 220)
dialogQuestion.TextSize = 14
dialogQuestion.Font = Enum.Font.Gotham
dialogQuestion.TextXAlignment = Enum.TextXAlignment.Left
dialogQuestion.Parent = closeDialog
-- UIPadding для вопроса диалога
local dialogQuestionPadding = Instance.new("UIPadding")
dialogQuestionPadding.PaddingLeft = UDim.new(0, 15)
dialogQuestionPadding.Parent = dialogQuestion
-- Предупреждение диалога
local dialogWarning = Instance.new("TextLabel")
dialogWarning.Name = "Warning"
dialogWarning.Size = UDim2.new(1, 0, 0, 30)
dialogWarning.Position = UDim2.new(0, 0, 0, 85)
dialogWarning.BackgroundTransparency = 1
dialogWarning.Text = "You will not be able to open it again."
dialogWarning.TextColor3 = Color3.fromRGB(220, 220, 220)
dialogWarning.TextSize = 12
dialogWarning.Font = Enum.Font.Gotham
dialogWarning.TextXAlignment = Enum.TextXAlignment.Left
dialogWarning.Parent = closeDialog
-- UIPadding для предупреждения диалога
local dialogWarningPadding = Instance.new("UIPadding")
dialogWarningPadding.PaddingLeft = UDim.new(0, 15)
dialogWarningPadding.Parent = dialogWarning
-- Контейнер кнопок диалога
local dialogButtonContainer = Instance.new("Frame")
dialogButtonContainer.Name = "ButtonContainer"
dialogButtonContainer.Size = UDim2.new(1, 0, 0, 40)
dialogButtonContainer.Position = UDim2.new(0, 0, 1, -50)
dialogButtonContainer.BackgroundTransparency = 1
dialogButtonContainer.Parent = closeDialog
-- Кнопка Cancel
local cancelButton = Instance.new("TextButton")
cancelButton.Name = "CancelButton"
cancelButton.Size = UDim2.new(0, 100, 0, 30)
cancelButton.Position = UDim2.new(0.5, -110, 0, 5)
cancelButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
cancelButton.BackgroundTransparency = 0
cancelButton.BorderSizePixel = 0
cancelButton.Text = "Cancel"
cancelButton.TextColor3 = Color3.fromRGB(180, 180, 180)
cancelButton.TextSize = 14
cancelButton.Font = Enum.Font.Gotham
cancelButton.Parent = dialogButtonContainer
-- UICorner для Cancel
local cancelCorner = Instance.new("UICorner")
cancelCorner.CornerRadius = UDim.new(0, 8)
cancelCorner.Parent = cancelButton
-- Hover эффект для Cancel
cancelButton.MouseEnter:Connect(function()
	TweenService:Create(cancelButton, TweenInfo.new(0.2), {
		BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	}):Play()
end)
cancelButton.MouseLeave:Connect(function()
	TweenService:Create(cancelButton, TweenInfo.new(0.2), {
		BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	}):Play()
end)
-- Кнопка Close Window
local confirmCloseButton = Instance.new("TextButton")
confirmCloseButton.Name = "ConfirmCloseButton"
confirmCloseButton.Size = UDim2.new(0, 100, 0, 30)
confirmCloseButton.Position = UDim2.new(0.5, 10, 0, 5)
confirmCloseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
confirmCloseButton.BackgroundTransparency = 0
confirmCloseButton.BorderSizePixel = 0
confirmCloseButton.Text = "Close Window"
confirmCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
confirmCloseButton.TextSize = 14
confirmCloseButton.Font = Enum.Font.Gotham
confirmCloseButton.Parent = dialogButtonContainer
-- UICorner для Close Window
local confirmCorner = Instance.new("UICorner")
confirmCorner.CornerRadius = UDim.new(0, 8)
confirmCorner.Parent = confirmCloseButton
-- Hover эффект для Close Window
confirmCloseButton.MouseEnter:Connect(function()
	TweenService:Create(confirmCloseButton, TweenInfo.new(0.2), {
		BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	}):Play()
end)
confirmCloseButton.MouseLeave:Connect(function()
	TweenService:Create(confirmCloseButton, TweenInfo.new(0.2), {
		BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	}):Play()
end)
-- Функция закрытия меню
local function closeMenu()
	-- Скрываем иконку
	menuIcon.Visible = false
	-- Удаляем главное меню
	mainFrame:Destroy()
end
-- Подключаем кнопку закрыть - показать диалог
closeButton.MouseButton1Click:Connect(function()
	closeDialog.Visible = true
end)
-- Кнопка Cancel - скрыть диалог
cancelButton.MouseButton1Click:Connect(function()
	closeDialog.Visible = false
end)
-- Кнопка Close Window - закрыть меню
confirmCloseButton.MouseButton1Click:Connect(function()
	closeMenu()
end)
-- Подключаем keybind
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == keybind and not isChangingKeybind then
		toggleMenu()
	end
end)
-- Ping Monitor обновление
RunService.Heartbeat:Connect(function()
	if isPingMonitorEnabled and pingValueLabel then
		local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
		pingValueLabel.Text = "Ping: " .. ping .. " ms"
		
		-- Меняем цвет в зависимости от пинга
		if ping < 100 then
			pingValueLabel.TextColor3 = Color3.fromRGB(100, 255, 100) -- Зеленый
		elseif ping < 200 then
			pingValueLabel.TextColor3 = Color3.fromRGB(255, 200, 100) -- Желтый
		else
			pingValueLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Красный
		end
	end
end)
-- Обработка InfinityJump
UserInputService.JumpRequest:Connect(function()
	if infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		local humanoid = LocalPlayer.Character.Humanoid
		-- Позволяем прыгать в воздухе
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)
-- Обработка Noclip
RunService.Stepped:Connect(function()
	if noclipEnabled and LocalPlayer.Character then
		for _, part in LocalPlayer.Character:GetDescendants() do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)
-- Обработка Airwalk
RunService.RenderStepped:Connect(function()
	if airwalkEnabled and airwalkPart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local hrp = LocalPlayer.Character.HumanoidRootPart
		airwalkPart.Position = Vector3.new(hrp.Position.X, hrp.Position.Y - 3, hrp.Position.Z)
	end
end)
-- Обработка при спавне персонажа
LocalPlayer.CharacterAdded:Connect(function(character)
	-- Применяем настройки
	character:WaitForChild("Humanoid")
	
	-- Применяем Speed
	if character:FindFirstChild("Humanoid") then
		character.Humanoid.WalkSpeed = currentSpeed
		character.Humanoid.JumpPower = currentJump
	end
	
	-- Применяем Noclip
	if noclipEnabled then
		for _, part in character:GetDescendants() do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)
print("NexusHubX - FishIt! activated")
