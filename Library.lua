-- 现代化Roblox UI库
-- 作者：AI助手
-- 版本：2.0

local UI = {}

-- 颜色主题
UI.Themes = {
	Dark = {
		Primary = Color3.fromRGB(0, 120, 215),
		Secondary = Color3.fromRGB(40, 40, 40),
		Background = Color3.fromRGB(30, 30, 30),
		Text = Color3.fromRGB(255, 255, 255),
		Success = Color3.fromRGB(46, 204, 113),
		Warning = Color3.fromRGB(241, 196, 15),
		Error = Color3.fromRGB(231, 76, 60)
	},
	Light = {
		Primary = Color3.fromRGB(0, 120, 215),
		Secondary = Color3.fromRGB(240, 240, 240),
		Background = Color3.fromRGB(255, 255, 255),
		Text = Color3.fromRGB(30, 30, 30),
		Success = Color3.fromRGB(46, 204, 113),
		Warning = Color3.fromRGB(241, 196, 15),
		Error = Color3.fromRGB(231, 76, 60)
	},
	Cyberpunk = {
		Primary = Color3.fromRGB(255, 0, 255),
		Secondary = Color3.fromRGB(0, 255, 255),
		Background = Color3.fromRGB(10, 10, 20),
		Text = Color3.fromRGB(255, 255, 255),
		Success = Color3.fromRGB(0, 255, 127),
		Warning = Color3.fromRGB(255, 215, 0),
		Error = Color3.fromRGB(255, 20, 147)
	}
}

-- 当前主题
UI.CurrentTheme = UI.Themes.Dark

-- 动画服务
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- 创建圆角
function UI.CreateCorner(radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	return corner
end

-- 创建描边
function UI.CreateStroke(thickness, color, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = thickness or 2
	stroke.Color = color or Color3.new(1, 1, 1)
	stroke.Transparency = transparency or 0.5
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	return stroke
end

-- 创建渐变
function UI.CreateGradient(colors, rotation)
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(colors or {
		Color3.new(1, 0, 0),
		Color3.new(0, 1, 0),
		Color3.new(0, 0, 1)
	})
	gradient.Rotation = rotation or 0
	return gradient
end

-- 创建基础框架
function UI.CreateFrame(name, size, position, parent)
	local frame = Instance.new("Frame")
	frame.Name = name or "Frame"
	frame.Size = size or UDim2.new(0, 200, 0, 150)
	frame.Position = position or UDim2.new(0.5, -100, 0.5, -75)
	frame.BackgroundColor3 = UI.CurrentTheme.Background
	frame.BackgroundTransparency = 0.1
	frame.BorderSizePixel = 0
	
	if parent then
		frame.Parent = parent
	end
	
	-- 添加圆角
	frame:FindFirstChildWhichIsA("UICorner") or UI.CreateCorner(8):Clone().Parent = frame
	
	-- 添加描边
	frame:FindFirstChildWhichIsA("UIStroke") or UI.CreateStroke(1, UI.CurrentTheme.Primary, 0.7):Clone().Parent = frame
	
	-- 添加阴影效果
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 10, 1, 10)
	shadow.Position = UDim2.new(0, -5, 0, -5)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://5554237731"
	shadow.ImageColor3 = Color3.new(0, 0, 0)
	shadow.ImageTransparency = 0.8
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(10, 10, 118, 118)
	shadow.ZIndex = frame.ZIndex - 1
	shadow.Parent = frame
	
	return frame
end

-- 创建文本标签
function UI.CreateLabel(text, size, position, parent)
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = size or UDim2.new(1, -20, 0, 30)
	label.Position = position or UDim2.new(0, 10, 0, 10)
	label.BackgroundTransparency = 1
	label.Text = text or "Label"
	label.TextColor3 = UI.CurrentTheme.Text
	label.TextSize = 14
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	
	if parent then
		label.Parent = parent
	end
	
	return label
end

-- 创建按钮
function UI.CreateButton(text, size, position, parent, callback)
	local button = Instance.new("TextButton")
	button.Name = "Button"
	button.Size = size or UDim2.new(1, -20, 0, 40)
	button.Position = position or UDim2.new(0, 10, 0, 50)
	button.BackgroundColor3 = UI.CurrentTheme.Primary
	button.Text = text or "Button"
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextSize = 14
	button.Font = Enum.Font.GothamSemibold
	button.AutoButtonColor = false
	button.ClipsDescendants = true
	
	-- 添加圆角
	UI.CreateCorner(6):Clone().Parent = button
	
	-- 添加描边
	UI.CreateStroke(2, Color3.new(1, 1, 1), 0.8):Clone().Parent = button
	
	-- 悬停效果
	local hoverFrame = Instance.new("Frame")
	hoverFrame.Name = "HoverEffect"
	hoverFrame.Size = UDim2.new(0, 0, 1, 0)
	hoverFrame.Position = UDim2.new(0, 0, 0, 0)
	hoverFrame.BackgroundColor3 = Color3.new(1, 1, 1)
	hoverFrame.BackgroundTransparency = 0.8
	hoverFrame.BorderSizePixel = 0
	hoverFrame.ZIndex = button.ZIndex + 1
	UI.CreateCorner(6):Clone().Parent = hoverFrame
	hoverFrame.Parent = button
	
	-- 点击效果
	local ripple = Instance.new("Frame")
	ripple.Name = "Ripple"
	ripple.Size = UDim2.new(0, 0, 0, 0)
	ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
	ripple.AnchorPoint = Vector2.new(0.5, 0.5)
	ripple.BackgroundColor3 = Color3.new(1, 1, 1)
	ripple.BackgroundTransparency = 0.7
	ripple.BorderSizePixel = 0
	ripple.ZIndex = button.ZIndex + 2
	UI.CreateCorner(100):Clone().Parent = ripple
	ripple.Visible = false
	ripple.Parent = button
	
	if parent then
		button.Parent = parent
	end
	
	-- 鼠标交互
	local isHovering = false
	
	button.MouseEnter:Connect(function()
		isHovering = true
		TweenService:Create(hoverFrame, TweenInfo.new(0.2), {
			Size = UDim2.new(1, 0, 1, 0)
		}):Play()
	end)
	
	button.MouseLeave:Connect(function()
		isHovering = false
		TweenService:Create(hoverFrame, TweenInfo.new(0.2), {
			Size = UDim2.new(0, 0, 1, 0)
		}):Play()
	end)
	
	button.MouseButton1Down:Connect(function()
		ripple.Visible = true
		ripple.Size = UDim2.new(0, 0, 0, 0)
		ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
		
		TweenService:Create(ripple, TweenInfo.new(0.4), {
			Size = UDim2.new(2, 0, 2, 0),
			BackgroundTransparency = 1
		}):Play()
	end)
	
	button.MouseButton1Up:Connect(function()
		task.spawn(function()
			task.wait(0.4)
			ripple.Visible = false
			ripple.BackgroundTransparency = 0.7
		end)
	end)
	
	button.Activated:Connect(function()
		if callback then
			callback()
		end
	end)
	
	return button
end

-- 创建输入框
function UI.CreateTextBox(placeholder, size, position, parent)
	local textBoxFrame = UI.CreateFrame("TextBoxFrame", size, position, nil)
	textBoxFrame.BackgroundTransparency = 0
	
	local textBox = Instance.new("TextBox")
	textBox.Name = "TextBox"
	textBox.Size = UDim2.new(1, -20, 1, -10)
	textBox.Position = UDim2.new(0, 10, 0, 5)
	textBox.BackgroundTransparency = 1
	textBox.Text = ""
	textBox.PlaceholderText = placeholder or "输入文本..."
	textBox.TextColor3 = UI.CurrentTheme.Text
	textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	textBox.TextSize = 14
	textBox.Font = Enum.Font.Gotham
	textBox.TextXAlignment = Enum.TextXAlignment.Left
	textBox.ClipsDescendants = true
	textBox.Parent = textBoxFrame
	
	-- 焦点效果
	textBox.Focused:Connect(function()
		TweenService:Create(textBoxFrame, TweenInfo.new(0.2), {
			BackgroundColor3 = UI.CurrentTheme.Primary:Lerp(Color3.new(1, 1, 1), 0.3)
		}):Play()
	end)
	
	textBox.FocusLost:Connect(function()
		TweenService:Create(textBoxFrame, TweenInfo.new(0.2), {
			BackgroundColor3 = UI.CurrentTheme.Background
		}):Play()
	end)
	
	if parent then
		textBoxFrame.Parent = parent
	end
	
	return textBox
end

-- 创建滑动条
function UI.CreateSlider(min, max, defaultValue, size, position, parent, callback)
	local sliderFrame = UI.CreateFrame("SliderFrame", size, position, nil)
	sliderFrame.BackgroundTransparency = 0.3
	
	local track = Instance.new("Frame")
	track.Name = "Track"
	track.Size = UDim2.new(1, -40, 0, 4)
	track.Position = UDim2.new(0, 20, 0.5, -2)
	track.BackgroundColor3 = UI.CurrentTheme.Secondary
	track.BorderSizePixel = 0
	UI.CreateCorner(2):Clone().Parent = track
	track.Parent = sliderFrame
	
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.Position = UDim2.new(0, 0, 0, 0)
	fill.BackgroundColor3 = UI.CurrentTheme.Primary
	fill.BorderSizePixel = 0
	UI.CreateCorner(2):Clone().Parent = fill
	fill.Parent = track
	
	local thumb = Instance.new("Frame")
	thumb.Name = "Thumb"
	thumb.Size = UDim2.new(0, 20, 0, 20)
	thumb.Position = UDim2.new(0, 0, 0.5, -10)
	thumb.AnchorPoint = Vector2.new(0, 0.5)
	thumb.BackgroundColor3 = Color3.new(1, 1, 1)
	thumb.BorderSizePixel = 0
	UI.CreateCorner(10):Clone().Parent = thumb
	UI.CreateStroke(2, UI.CurrentTheme.Primary):Clone().Parent = thumb
	thumb.Parent = sliderFrame
	
	local valueLabel = UI.CreateLabel(tostring(defaultValue or min), UDim2.new(0, 40, 0, 20), UDim2.new(1, -10, 0.5, -10), sliderFrame)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	
	if parent then
		sliderFrame.Parent = parent
	end
	
	-- 滑动逻辑
	local dragging = false
	local currentValue = defaultValue or min
	
	local function updateValue(xPosition)
		local relativeX = math.clamp((xPosition - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local value = min + (max - min) * relativeX
		currentValue = math.floor(value)
		
		fill.Size = UDim2.new(relativeX, 0, 1, 0)
		thumb.Position = UDim2.new(relativeX, 0, 0.5, -10)
		valueLabel.Text = tostring(currentValue)
		
		if callback then
			callback(currentValue)
		end
	end
	
	thumb.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)
	
	thumb.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	
	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateValue(input.Position.X)
		end
	end)
	
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			updateValue(input.Position.X)
			dragging = true
		end
	end)
	
	return {
		Frame = sliderFrame,
		GetValue = function() return currentValue end,
		SetValue = function(value)
			currentValue = math.clamp(value, min, max)
			local relativeX = (currentValue - min) / (max - min)
			fill.Size = UDim2.new(relativeX, 0, 1, 0)
			thumb.Position = UDim2.new(relativeX, 0, 0.5, -10)
			valueLabel.Text = tostring(currentValue)
		end
	}
end

-- 创建开关
function UI.CreateToggle(defaultState, size, position, parent, callback)
	local toggleFrame = UI.CreateFrame("ToggleFrame", size, position, nil)
	toggleFrame.BackgroundTransparency = 0
	
	local label = UI.CreateLabel("开关", UDim2.new(1, -60, 1, 0), UDim2.new(0, 10, 0, 0), toggleFrame)
	
	local background = Instance.new("Frame")
	background.Name = "Background"
	background.Size = UDim2.new(0, 40, 0, 20)
	background.Position = UDim2.new(1, -50, 0.5, -10)
	background.BackgroundColor3 = UI.CurrentTheme.Secondary
	background.BorderSizePixel = 0
	UI.CreateCorner(10):Clone().Parent = background
	background.Parent = toggleFrame
	
	local thumb = Instance.new("Frame")
	thumb.Name = "Thumb"
	thumb.Size = UDim2.new(0, 16, 0, 16)
	thumb.Position = UDim2.new(0, 2, 0.5, -8)
	thumb.AnchorPoint = Vector2.new(0, 0.5)
	thumb.BackgroundColor3 = Color3.new(1, 1, 1)
	thumb.BorderSizePixel = 0
	UI.CreateCorner(8):Clone().Parent = thumb
	thumb.Parent = background
	
	local state = defaultState or false
	
	local function updateState()
		if state then
			TweenService:Create(thumb, TweenInfo.new(0.2), {
				Position = UDim2.new(1, -18, 0.5, -8),
				BackgroundColor3 = UI.CurrentTheme.Success
			}):Play()
			TweenService:Create(background, TweenInfo.new(0.2), {
				BackgroundColor3 = UI.CurrentTheme.Success:Lerp(Color3.new(1, 1, 1), 0.7)
			}):Play()
		else
			TweenService:Create(thumb, TweenInfo.new(0.2), {
				Position = UDim2.new(0, 2, 0.5, -8),
				BackgroundColor3 = Color3.new(1, 1, 1)
			}):Play()
			TweenService:Create(background, TweenInfo.new(0.2), {
				BackgroundColor3 = UI.CurrentTheme.Secondary
			}):Play()
		end
		
		if callback then
			callback(state)
		end
	end
	
	toggleFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			state = not state
			updateState()
		end
	end)
	
	if parent then
		toggleFrame.Parent = parent
	end
	
	updateState()
	
	return {
		Frame = toggleFrame,
		GetState = function() return state end,
		SetState = function(newState)
			state = newState
			updateState()
		end
	}
end

-- 创建下拉菜单
function UI.CreateDropdown(options, defaultIndex, size, position, parent, callback)
	local dropdownFrame = UI.CreateFrame("DropdownFrame", size, position, nil)
	dropdownFrame.BackgroundTransparency = 0
	dropdownFrame.ClipsDescendants = true
	
	local selectedLabel = UI.CreateLabel(options[defaultIndex] or "选择...", UDim2.new(1, -40, 1, 0), UDim2.new(0, 10, 0, 0), dropdownFrame)
	
	local arrow = Instance.new("ImageLabel")
	arrow.Name = "Arrow"
	arrow.Size = UDim2.new(0, 20, 0, 20)
	arrow.Position = UDim2.new(1, -30, 0.5, -10)
	arrow.BackgroundTransparency = 1
	arrow.Image = "rbxassetid://6031068423"
	arrow.ImageColor3 = UI.CurrentTheme.Text
	arrow.Rotation = 0
	arrow.Parent = dropdownFrame
	
	local optionsFrame = UI.CreateFrame("OptionsFrame", UDim2.new(1, 0, 0, 0), UDim2.new(0, 0, 1, 5), dropdownFrame)
	optionsFrame.BackgroundTransparency = 0.1
	optionsFrame.Visible = false
	
	local optionsList = Instance.new("UIListLayout")
	optionsList.Parent = optionsFrame
	
	local isOpen = false
	local selectedIndex = defaultIndex or 1
	
	for i, option in ipairs(options) do
		local optionButton = UI.CreateButton(option, UDim2.new(1, -10, 0, 30), UDim2.new(0, 5, 0, 5 + (i-1)*35), optionsFrame, function()
			selectedIndex = i
			selectedLabel.Text = option
			if callback then
				callback(option, i)
			end
			dropdownFrame.InputBegan:Fire({UserInputType = Enum.UserInputType.MouseButton1})
		end)
		optionButton.BackgroundTransparency = 0.5
		optionButton.TextColor3 = UI.CurrentTheme.Text
	end
	
	dropdownFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isOpen = not isOpen
			
			if isOpen then
				optionsFrame.Visible = true
				TweenService:Create(optionsFrame, TweenInfo.new(0.3), {
					Size = UDim2.new(1, 0, 0, math.min(#options * 35 + 10, 200))
				}):Play()
				TweenService:Create(arrow, TweenInfo.new(0.3), {
					Rotation = 180
				}):Play()
			else
				TweenService:Create(optionsFrame, TweenInfo.new(0.3), {
					Size = UDim2.new(1, 0, 0, 0)
				}):Play()
				TweenService:Create(arrow, TweenInfo.new(0.3), {
					Rotation = 0
				}):Play()
				task.wait(0.3)
				optionsFrame.Visible = false
			end
		end
	end)
	
	if parent then
		dropdownFrame.Parent = parent
	end
	
	return {
		Frame = dropdownFrame,
		GetSelected = function() return options[selectedIndex], selectedIndex end,
		SetSelected = function(index)
			if options[index] then
				selectedIndex = index
				selectedLabel.Text = options[index]
			end
		end
	}
end

-- 创建进度条
function UI.CreateProgressBar(min, max, current, size, position, parent)
	local progressFrame = UI.CreateFrame("ProgressFrame", size, position, nil)
	progressFrame.BackgroundTransparency = 0.3
	
	local track = Instance.new("Frame")
	track.Name = "Track"
	track.Size = UDim2.new(1, -20, 0, 20)
	track.Position = UDim2.new(0, 10, 0.5, -10)
	track.BackgroundColor3 = UI.CurrentTheme.Secondary
	track.BorderSizePixel = 0
	UI.CreateCorner(10):Clone().Parent = track
	track.Parent = progressFrame
	
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.Position = UDim2.new(0, 0, 0, 0)
	fill.BackgroundColor3 = UI.CurrentTheme.Primary
	fill.BorderSizePixel = 0
	UI.CreateCorner(10):Clone().Parent = fill
	fill.Parent = track
	
	local label = UI.CreateLabel("0%", UDim2.new(1, -20, 1, 0), UDim2.new(0, 10, 0, 0), progressFrame)
	label.TextXAlignment = Enum.TextXAlignment.Center
	
	if parent then
		progressFrame.Parent = parent
	end
	
	local function updateProgress(value)
		local percentage = math.clamp((value - min) / (max - min), 0, 1)
		fill.Size = UDim2.new(percentage, 0, 1, 0)
		label.Text = math.floor(percentage * 100) .. "%"
		
		-- 根据百分比改变颜色
		if percentage < 0.3 then
			fill.BackgroundColor3 = UI.CurrentTheme.Error
		elseif percentage < 0.7 then
			fill.BackgroundColor3 = UI.CurrentTheme.Warning
		else
			fill.BackgroundColor3 = UI.CurrentTheme.Success
		end
	end
	
	updateProgress(current or min)
	
	return {
		Frame = progressFrame,
		SetProgress = updateProgress,
		GetProgress = function()
			return min + (max - min) * fill.Size.X.Scale
		end
	}
end

-- 创建通知
function UI.CreateNotification(title, message, duration, parent)
	local screenGui = parent or game.Players.LocalPlayer:WaitForChild("PlayerGui")
	
	local notification = Instance.new("Frame")
	notification.Name = "Notification"
	notification.Size = UDim2.new(0, 300, 0, 80)
	notification.Position = UDim2.new(1, 320, 0, 20)
	notification.BackgroundColor3 = UI.CurrentTheme.Background
	notification.BackgroundTransparency = 0.1
	notification.BorderSizePixel = 0
	notification.AnchorPoint = Vector2.new(1, 0)
	UI.CreateCorner(8):Clone().Parent = notification
	UI.CreateStroke(1, UI.CurrentTheme.Primary, 0.5):Clone().Parent = notification
	
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 10, 1, 10)
	shadow.Position = UDim2.new(0, -5, 0, -5)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://5554237731"
	shadow.ImageColor3 = Color3.new(0, 0, 0)
	shadow.ImageTransparency = 0.8
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(10, 10, 118, 118)
	shadow.ZIndex = notification.ZIndex - 1
	shadow.Parent = notification
	
	local titleLabel = UI.CreateLabel(title, UDim2.new(1, -20, 0, 25), UDim2.new(0, 10, 0, 10), notification)
	titleLabel.Text = title
	titleLabel.Font = Enum.Font.GothamSemibold
	titleLabel.TextSize = 16
	
	local messageLabel = UI.CreateLabel(message, UDim2.new(1, -20, 1, -40), UDim2.new(0, 10, 0, 40), notification)
	messageLabel.Text = message
	messageLabel.TextSize = 12
	messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	
	local closeButton = Instance.new("ImageButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 20, 0, 20)
	closeButton.Position = UDim2.new(1, -25, 0, 10)
	closeButton.BackgroundTransparency = 1
	closeButton.Image = "rbxassetid://6031097223"
	closeButton.ImageColor3 = UI.CurrentTheme.Text
	closeButton.Parent = notification
	
	local progressBar = Instance.new("Frame")
	progressBar.Name = "ProgressBar"
	progressBar.Size = UDim2.new(1, 0, 0, 3)
	progressBar.Position = UDim2.new(0, 0, 1, -3)
	progressBar.BackgroundColor3 = UI.CurrentTheme.Primary
	progressBar.BorderSizePixel = 0
	progressBar.Parent = notification
	
	notification.Parent = screenGui
	
	-- 动画显示
	TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(1, -20, 0, 20)
	}):Play()
	
	-- 进度条动画
	TweenService:Create(progressBar, TweenInfo.new(duration or 5), {
		Size = UDim2.new(0, 0, 0, 3)
	}):Play()
	
	-- 关闭功能
	local function close()
		TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Position = UDim2.new(1, 320, 0, 20)
		}):Play()
		task.wait(0.3)
		notification:Destroy()
	end
	
	closeButton.MouseButton1Click:Connect(close)
	
	task.wait(duration or 5)
	if notification then
		close()
	end
	
	return {
		Close = close,
		Frame = notification
	}
end

-- 创建模态窗口
function UI.CreateModal(title, content, size, parent)
	local screenGui = parent or game.Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- 遮罩层
	local overlay = Instance.new("Frame")
	overlay.Name = "ModalOverlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.Position = UDim2.new(0, 0, 0, 0)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.5
	overlay.BorderSizePixel = 0
	overlay.ZIndex = 100
	overlay.Parent = screenGui
	
	-- 模态窗口
	local modal = UI.CreateFrame("Modal", size or UDim2.new(0, 400, 0, 300), UDim2.new(0.5, -200, 0.5, -150), overlay)
	modal.ZIndex = 101
	modal.BackgroundTransparency = 0.05
	
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 40)
	titleBar.Position = UDim2.new(0, 0, 0, 0)
	titleBar.BackgroundColor3 = UI.CurrentTheme.Primary
	titleBar.BackgroundTransparency = 0.2
	titleBar.BorderSizePixel = 0
	titleBar.ZIndex = 102
	UI.CreateCorner(8, 8, 0, 0):Clone().Parent = titleBar
	titleBar.Parent = modal
	
	local titleLabel = UI.CreateLabel(title, UDim2.new(1, -50, 1, 0), UDim2.new(0, 15, 0, 0), titleBar)
	titleLabel.Text = title
	titleLabel.Font = Enum.Font.GothamSemibold
	titleLabel.TextSize = 18
	titleLabel.ZIndex = 103
	
	local closeButton = Instance.new("ImageButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -35, 0.5, -15)
	closeButton.BackgroundTransparency = 1
	closeButton.Image = "rbxassetid://6031097223"
	closeButton.ImageColor3 = Color3.new(1, 1, 1)
	closeButton.ZIndex = 103
	closeButton.Parent = titleBar
	
	local contentFrame = Instance.new("ScrollingFrame")
	contentFrame.Name = "Content"
	contentFrame.Size = UDim2.new(1, -20, 1, -60)
	contentFrame.Position = UDim2.new(0, 10, 0, 50)
	contentFrame.BackgroundTransparency = 1
	contentFrame.BorderSizePixel = 0
	contentFrame.ScrollingEnabled = true
	contentFrame.ScrollBarThickness = 6
	contentFrame.ZIndex = 102
	contentFrame.Parent = modal
	
	local contentLayout = Instance.new("UIListLayout")
	contentLayout.Parent = contentFrame
	
	if type(content) == "string" then
		local textLabel = UI.CreateLabel(content, UDim2.new(1, 0, 0, 0), UDim2.new(0, 0, 0, 0), contentFrame)
		textLabel.TextWrapped = true
		textLabel.AutomaticSize = Enum.AutomaticSize.Y
	elseif type(content) == "table" then
		for _, element in ipairs(content) do
			if element then
				element.Parent = contentFrame
			end
		end
	end
	
	-- 动画显示
	modal.Size = UDim2.new(0, 0, 0, 0)
	modal.Position = UDim2.new(0.5, 0, 0.5, 0)
	modal.AnchorPoint = Vector2.new(0.5, 0.5)
	
	TweenService:Create(modal, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = size or UDim2.new(0, 400, 0, 300)
	}):Play()
	
	-- 关闭功能
	local function close()
		TweenService:Create(modal, TweenInfo.new(0.3), {
			Size = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1
		}):Play()
		TweenService:Create(overlay, TweenInfo.new(0.3), {
			BackgroundTransparency = 1
		}):Play()
		task.wait(0.3)
		overlay:Destroy()
	end
	
	closeButton.MouseButton1Click:Connect(close)
	overlay.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if not modal:IsDescendantOf(screenGui) then return end
			local mousePos = input.Position
			local modalPos = modal.AbsolutePosition
			local modalSize = modal.AbsoluteSize
			
			if mousePos.X < modalPos.X or mousePos.X > modalPos.X + modalSize.X or
			   mousePos.Y < modalPos.Y or mousePos.Y > modalPos.Y + modalSize.Y then
				close()
			end
		end
	end)
	
	return {
		Close = close,
		Frame = modal,
		Overlay = overlay
	}
end

-- 设置主题
function UI.SetTheme(themeName)
	if UI.Themes[themeName] then
		UI.CurrentTheme = UI.Themes[themeName]
	end
end

-- 工具函数：创建卡片
function UI.CreateCard(title, content, size, position, parent)
	local card = UI.CreateFrame("Card", size or UDim2.new(0, 250, 0, 200), position, parent)
	
	local titleLabel = UI.CreateLabel(title, UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 10), card)
	titleLabel.Text = title
	titleLabel.Font = Enum.Font.GothamSemibold
	titleLabel.TextSize = 16
	
	local divider = Instance.new("Frame")
	divider.Name = "Divider"
	divider.Size = UDim2.new(1, -20, 0, 1)
	divider.Position = UDim2.new(0, 10, 0, 45)
	divider.BackgroundColor3 = UI.CurrentTheme.Primary
	divider.BackgroundTransparency = 0.5
	divider.BorderSizePixel = 0
	divider.Parent = card
	
	if type(content) == "string" then
		local contentLabel = UI.CreateLabel(content, UDim2.new(1, -20, 1, -60), UDim2.new(0, 10, 0, 55), card)
		contentLabel.Text = content
		contentLabel.TextWrapped = true
	elseif type(content) == "table" then
		local contentFrame = Instance.new("Frame")
		contentFrame.Size = UDim2.new(1, -20, 1, -60)
		contentFrame.Position = UDim2.new(0, 10, 0, 55)
		contentFrame.BackgroundTransparency = 1
		contentFrame.Parent = card
		
		for _, element in ipairs(content) do
			if element then
				element.Parent = contentFrame
			end
		end
	end
	
	return card
end

-- 工具函数：创建网格布局
function UI.CreateGrid(cellSize, cellPadding, parent)
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = cellSize or UDim2.new(0, 100, 0, 100)
	grid.CellPadding = cellPadding or UDim2.new(0, 5, 0, 5)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	
	if parent then
		grid.Parent = parent
	end
	
	return grid
end

return UI
