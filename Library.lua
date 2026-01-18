-- 现代化Roblox UI库 (v2.3)
-- 优化：移除Create前缀，修复内存泄漏，增强拖拽
-- 变量习惯：Standard (Library, Window)

local UI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)

-- ==============================
-- [配置]
-- ==============================

UI.Themes = {
	Dark = {
		Primary = Color3.fromRGB(0, 120, 215),
		Secondary = Color3.fromRGB(40, 40, 40),
		Background = Color3.fromRGB(30, 30, 30),
		Text = Color3.fromRGB(255, 255, 255),
		Success = Color3.fromRGB(46, 204, 113),
		Warning = Color3.fromRGB(241, 196, 15),
		Error = Color3.fromRGB(231, 76, 60),
		Shadow = Color3.fromRGB(0, 0, 0)
	},
	Light = {
		Primary = Color3.fromRGB(0, 120, 215),
		Secondary = Color3.fromRGB(240, 240, 240),
		Background = Color3.fromRGB(255, 255, 255),
		Text = Color3.fromRGB(30, 30, 30),
		Success = Color3.fromRGB(46, 204, 113),
		Warning = Color3.fromRGB(241, 196, 15),
		Error = Color3.fromRGB(231, 76, 60),
		Shadow = Color3.fromRGB(150, 150, 150)
	}
}

UI.CurrentTheme = UI.Themes.Dark

-- 内部工具：动画
function UI.Tween(instance, properties, duration, style, direction)
	if not instance then return end
	TweenService:Create(instance, TweenInfo.new(
		duration or 0.2, 
		style or Enum.EasingStyle.Quad, 
		direction or Enum.EasingDirection.Out
	), properties):Play()
end

-- 内部工具：拖拽
function UI.Draggable(topbarObject, objectToMove)
	local dragging, dragInput, dragStart, startPos
	objectToMove = objectToMove or topbarObject

	topbarObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = objectToMove.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	topbarObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			UI.Tween(objectToMove, {
				Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			}, 0.05)
		end
	end)
end

-- ==============================
-- [装饰组件]
-- ==============================

function UI.Corner(radius, parent)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	if parent then corner.Parent = parent end
	return corner
end

function UI.Stroke(thickness, color, transparency, parent)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = thickness or 2
	stroke.Color = color or Color3.new(1, 1, 1)
	stroke.Transparency = transparency or 0.5
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	if parent then stroke.Parent = parent end
	return stroke
end

function UI.Shadow(parent)
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	shadow.Size = UDim2.new(1, 12, 1, 12)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://5554237731"
	shadow.ImageColor3 = UI.CurrentTheme.Shadow
	shadow.ImageTransparency = 0.6
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(10, 10, 118, 118)
	shadow.ZIndex = math.max((parent.ZIndex or 1) - 1, 0)
	shadow.Parent = parent
	return shadow
end

-- ==============================
-- [核心控件]
-- ==============================

function UI.Frame(name, size, position, parent)
	local frame = Instance.new("Frame")
	frame.Name = name or "Frame"
	frame.Size = size or UDim2.new(0, 200, 0, 150)
	frame.Position = position or UDim2.new(0.5, -100, 0.5, -75)
	frame.BackgroundColor3 = UI.CurrentTheme.Background
	frame.BackgroundTransparency = 0.1
	frame.BorderSizePixel = 0
	
	UI.Corner(8, frame)
	UI.Stroke(1, UI.CurrentTheme.Primary, 0.7, frame)
	UI.Shadow(frame)
	
	if parent then frame.Parent = parent end
	return frame
end

function UI.Label(text, size, position, parent)
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
	
	if parent then label.Parent = parent end
	return label
end

function UI.Button(text, size, position, parent, callback)
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
	
	UI.Corner(6, button)
	UI.Stroke(2, Color3.new(1, 1, 1), 0.8, button)
	
	-- 交互效果
	local hover = Instance.new("Frame")
	hover.Size = UDim2.new(0, 0, 1, 0)
	hover.BackgroundColor3 = Color3.new(1, 1, 1)
	hover.BackgroundTransparency = 0.9
	hover.ZIndex = button.ZIndex + 1
	UI.Corner(6, hover)
	hover.Parent = button

	local ripple = Instance.new("Frame")
	ripple.AnchorPoint = Vector2.new(0.5, 0.5)
	ripple.BackgroundColor3 = Color3.new(1, 1, 1)
	ripple.BackgroundTransparency = 0.7
	ripple.ZIndex = button.ZIndex + 2
	UI.Corner(100, ripple)
	ripple.Visible = false
	ripple.Parent = button

	button.MouseEnter:Connect(function() UI.Tween(hover, {Size = UDim2.new(1, 0, 1, 0)}, 0.2) end)
	button.MouseLeave:Connect(function() UI.Tween(hover, {Size = UDim2.new(0, 0, 1, 0)}, 0.2) end)
	
	button.MouseButton1Down:Connect(function(x, y)
		ripple.Visible = true
		ripple.Size = UDim2.new(0, 0, 0, 0)
		ripple.Position = UDim2.new(0, x - button.AbsolutePosition.X, 0, y - button.AbsolutePosition.Y)
		UI.Tween(ripple, {Size = UDim2.new(2.5, 0, 2.5, 0), BackgroundTransparency = 1}, 0.4)
		task.delay(0.4, function() ripple.Visible = false ripple.BackgroundTransparency = 0.7 end)
	end)
	
	button.Activated:Connect(function() if callback then callback() end end)
	if parent then button.Parent = parent end
	return button
end

function UI.Slider(min, max, defaultValue, size, position, parent, callback)
	local frame = UI.Frame("SliderFrame", size, position, parent)
	frame.BackgroundTransparency = 0.3
	
	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -50, 0, 4)
	track.Position = UDim2.new(0, 10, 0.5, -2)
	track.BackgroundColor3 = UI.CurrentTheme.Secondary
	UI.Corner(2, track)
	track.Parent = frame
	
	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = UI.CurrentTheme.Primary
	UI.Corner(2, fill)
	fill.Parent = track
	
	local thumb = Instance.new("Frame")
	thumb.Size = UDim2.new(0, 16, 0, 16)
	thumb.AnchorPoint = Vector2.new(0.5, 0.5)
	thumb.BackgroundColor3 = Color3.new(1, 1, 1)
	UI.Corner(8, thumb)
	UI.Stroke(2, UI.CurrentTheme.Primary, 0, thumb)
	thumb.Parent = track
	
	local label = UI.Label(tostring(defaultValue or min), UDim2.new(0, 30, 1, 0), UDim2.new(1, -35, 0, 0), frame)
	label.TextXAlignment = Enum.TextXAlignment.Right
	
	local val = defaultValue or min
	local dragging, conn
	
	local function set(v)
		val = math.clamp(v, min, max)
		local pct = (val - min) / (max - min)
		fill.Size = UDim2.new(pct, 0, 1, 0)
		thumb.Position = UDim2.new(pct, 0, 0.5, 0)
		label.Text = string.format("%.1f", val)
		if callback then callback(val) end
	end
	
	thumb.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			conn = UserInputService.InputChanged:Connect(function(move)
				if dragging and move.UserInputType == Enum.UserInputType.MouseMovement then
					local pct = math.clamp((move.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					set(min + (max - min) * pct)
				end
			end)
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			if conn then conn:Disconnect() conn = nil end
		end
	end)
	
	frame.Destroying:Connect(function() if conn then conn:Disconnect() end end)
	set(val)
	
	return { Frame = frame, Set = set, Get = function() return val end }
end

function UI.Dropdown(options, defaultIndex, size, position, parent, callback)
	local frame = UI.Frame("Dropdown", size, position, parent)
	frame.ZIndex = 10
	
	local label = UI.Label(options[defaultIndex] or "选择...", UDim2.new(1, -40, 1, 0), UDim2.new(0, 10, 0, 0), frame)
	local arrow = Instance.new("ImageLabel", frame)
	arrow.Size = UDim2.new(0, 20, 0, 20)
	arrow.Position = UDim2.new(1, -30, 0.5, -10)
	arrow.BackgroundTransparency = 1
	arrow.Image = "rbxassetid://6031068423"
	arrow.ImageColor3 = UI.CurrentTheme.Text
	
	local list = Instance.new("Frame", frame)
	list.Size = UDim2.new(1, 0, 0, 0)
	list.Position = UDim2.new(0, 0, 1, 5)
	list.BackgroundColor3 = UI.CurrentTheme.Secondary
	list.Visible = false
	list.ZIndex = 20
	list.ClipsDescendants = true
	UI.Corner(6, list)
	
	local layout = Instance.new("UIListLayout", list)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	
	for i, opt in ipairs(options) do
		local btn = Instance.new("TextButton", list)
		btn.Size = UDim2.new(1, 0, 0, 30)
		btn.BackgroundTransparency = 1
		btn.Text = "  " .. opt
		btn.TextColor3 = UI.CurrentTheme.Text
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.Font = Enum.Font.Gotham
		btn.ZIndex = 21
		
		btn.MouseButton1Click:Connect(function()
			label.Text = opt
			if callback then callback(opt, i) end
			frame.InputBegan:Fire({UserInputType = Enum.UserInputType.MouseButton1})
		end)
	end
	
	local open = false
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			open = not open
			UI.Tween(list, {Size = UDim2.new(1, 0, 0, open and math.min(#options * 30, 200) or 0)})
			UI.Tween(arrow, {Rotation = open and 180 or 0})
			list.Visible = true
			if not open then task.delay(0.2, function() list.Visible = false end) end
		end
	end)
	
	return { Frame = frame }
end

-- ==============================
-- [高级窗口/通知]
-- ==============================

function UI.Notify(title, message, duration)
	local gui = PlayerGui:FindFirstChild("ScreenGui") or Instance.new("ScreenGui", PlayerGui)
	
	local frame = UI.Frame("Notify", UDim2.new(0, 250, 0, 70), UDim2.new(1, 270, 0, 20), gui)
	frame.BackgroundTransparency = 0.05
	
	local tLabel = UI.Label(title, UDim2.new(1, -10, 0, 20), UDim2.new(0, 10, 0, 5), frame)
	tLabel.Font = Enum.Font.GothamBold
	
	local mLabel = UI.Label(message, UDim2.new(1, -10, 1, -25), UDim2.new(0, 10, 0, 25), frame)
	mLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	mLabel.TextWrapped = true
	mLabel.TextYAlignment = Enum.TextYAlignment.Top
	
	local bar = Instance.new("Frame", frame)
	bar.Size = UDim2.new(1, 0, 0, 3)
	bar.Position = UDim2.new(0, 0, 1, -3)
	bar.BackgroundColor3 = UI.CurrentTheme.Primary
	bar.BorderSizePixel = 0
	
	UI.Tween(frame, {Position = UDim2.new(1, -270, 0, 20)}, 0.5, Enum.EasingStyle.Back)
	UI.Tween(bar, {Size = UDim2.new(0, 0, 0, 3)}, duration or 3, Enum.EasingStyle.Linear)
	
	task.delay(duration or 3, function()
		if frame then
			UI.Tween(frame, {Position = UDim2.new(1, 270, 0, 20)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
			task.wait(0.5)
			frame:Destroy()
		end
	end)
end

function UI.Window(title, size)
	local gui = Instance.new("ScreenGui", PlayerGui)
	gui.Name = "UIWindow"
	gui.ResetOnSpawn = false
	
	local main = UI.Frame("Main", size or UDim2.new(0, 500, 0, 350), UDim2.new(0.5, -250, 0.5, -175), gui)
	main.ClipsDescendants = true
	
	local top = Instance.new("Frame", main)
	top.Size = UDim2.new(1, 0, 0, 40)
	top.BackgroundColor3 = UI.CurrentTheme.Secondary
	top.BorderSizePixel = 0
	UI.Corner(8, top)
	
	-- 修复顶部圆角与主体连接
	local cover = Instance.new("Frame", top)
	cover.Size = UDim2.new(1, 0, 0, 10)
	cover.Position = UDim2.new(0, 0, 1, -10)
	cover.BackgroundColor3 = UI.CurrentTheme.Secondary
	cover.BorderSizePixel = 0
	
	UI.Label(title or "UI", UDim2.new(1, -20, 1, 0), UDim2.new(0, 15, 0, 0), top).Font = Enum.Font.GothamBold
	
	local container = Instance.new("ScrollingFrame", main)
	container.Size = UDim2.new(1, -20, 1, -50)
	container.Position = UDim2.new(0, 10, 0, 45)
	container.BackgroundTransparency = 1
	container.ScrollBarThickness = 4
	
	local layout = Instance.new("UIListLayout", container)
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	
	UI.Draggable(top, main)
	
	return { Gui = gui, Main = main, Container = container }
end

return UI
