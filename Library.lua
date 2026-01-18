-- 现代化 UI 库 v3.0 (Fluent 风格)
-- 特性：自动布局、标签页系统、极简语法、默认设置页
-- 作者：AI助手 | 优化：Gemini

local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- 保护 GUI 不被检测 (如果支持)
local Viewport = Player:WaitForChild("PlayerGui")
if gethui then Viewport = gethui() end

-- ==============================
-- [配置与主题]
-- ==============================

Library.Theme = {
	Main = Color3.fromRGB(25, 25, 25),       -- 主背景
	Secondary = Color3.fromRGB(35, 35, 35),  -- 侧边栏/容器背景
	Accent = Color3.fromRGB(0, 120, 215),    -- 强调色
	Text = Color3.fromRGB(240, 240, 240),    -- 主文本
	SubText = Color3.fromRGB(150, 150, 150), -- 副文本
	Hover = Color3.fromRGB(45, 45, 45),      -- 悬停颜色
	Stroke = Color3.fromRGB(60, 60, 60)      -- 描边颜色
}

-- ==============================
-- [工具函数]
-- ==============================

local function Tween(obj, props, time)
	TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local function MakeDraggable(topbar, object)
	local dragging, dragInput, dragStart, startPos
	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = object.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			Tween(object, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
		end
	end)
end

-- 圆角助手
local function AddCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 6)
	c.Parent = parent
	return c
end

-- 描边助手
local function AddStroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Library.Theme.Stroke
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

-- ==============================
-- [核心逻辑]
-- ==============================

function Library:Window(options)
	options = options or {}
	local title = options.Title or "UI Library v3"
	
	-- 1. 主屏幕 GUI
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "FluentLib_" .. math.random(1000,9999)
	ScreenGui.Parent = Viewport
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	-- 2. 主窗口 Frame
	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0, 550, 0, 350)
	Main.Position = UDim2.new(0.5, -275, 0.5, -175)
	Main.BackgroundColor3 = Library.Theme.Main
	Main.ClipsDescendants = true
	AddCorner(Main, 8)
	AddStroke(Main, Library.Theme.Stroke, 2)
	Main.Parent = ScreenGui

	-- 拖拽区域 (侧边栏顶部)
	local DragArea = Instance.new("Frame")
	DragArea.Size = UDim2.new(1, 0, 0, 40)
	DragArea.BackgroundTransparency = 1
	DragArea.Parent = Main
	MakeDraggable(DragArea, Main)

	-- 3. 侧边栏 (Sidebar)
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 140, 1, 0)
	Sidebar.BackgroundColor3 = Library.Theme.Secondary
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = Main
	AddCorner(Sidebar, 8) -- 左侧圆角
	
	-- 修复右边直角
	local SideCover = Instance.new("Frame", Sidebar)
	SideCover.BorderSizePixel = 0
	SideCover.BackgroundColor3 = Library.Theme.Secondary
	SideCover.Size = UDim2.new(0, 10, 1, 0)
	SideCover.Position = UDim2.new(1, -10, 0, 0)

	-- 标题
	local TitleLbl = Instance.new("TextLabel")
	TitleLbl.Text = title
	TitleLbl.Font = Enum.Font.GothamBold
	TitleLbl.TextSize = 18
	TitleLbl.TextColor3 = Library.Theme.Accent
	TitleLbl.Size = UDim2.new(1, -20, 0, 50)
	TitleLbl.Position = UDim2.new(0, 10, 0, 0)
	TitleLbl.BackgroundTransparency = 1
	TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	TitleLbl.Parent = Sidebar

	-- 标签按钮容器
	local TabBtnContainer = Instance.new("ScrollingFrame")
	TabBtnContainer.Size = UDim2.new(1, 0, 1, -100) -- 预留底部
	TabBtnContainer.Position = UDim2.new(0, 0, 0, 50)
	TabBtnContainer.BackgroundTransparency = 1
	TabBtnContainer.ScrollBarThickness = 0
	TabBtnContainer.Parent = Sidebar
	
	local TabBtnLayout = Instance.new("UIListLayout", TabBtnContainer)
	TabBtnLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabBtnLayout.Padding = UDim.new(0, 5)

	-- 4. 内容区域 (Content)
	local ContentArea = Instance.new("Frame")
	ContentArea.Name = "Content"
	ContentArea.Size = UDim2.new(1, -150, 1, -20)
	ContentArea.Position = UDim2.new(0, 145, 0, 10)
	ContentArea.BackgroundTransparency = 1
	ContentArea.Parent = Main

	local WindowObj = {
		Gui = ScreenGui,
		Main = Main,
		Tabs = {},
		ActiveTab = nil
	}

	-- ==============================
	-- [Tab 系统]
	-- ==============================
	
	function WindowObj:Tab(name)
		local TabObj = {
			Name = name,
			Elements = {}
		}

		-- 1. 创建 Tab 按钮 (Sidebar Item)
		local Btn = Instance.new("TextButton")
		Btn.Name = name .. "_Btn"
		Btn.Size = UDim2.new(1, -10, 0, 32)
		Btn.Position = UDim2.new(0, 5, 0, 0)
		Btn.BackgroundColor3 = Library.Theme.Main
		Btn.BackgroundTransparency = 1
		Btn.Text = "  " .. name
		Btn.TextColor3 = Library.Theme.SubText
		Btn.Font = Enum.Font.GothamMedium
		Btn.TextSize = 14
		Btn.TextXAlignment = Enum.TextXAlignment.Left
		Btn.AutoButtonColor = false
		AddCorner(Btn, 6)
		Btn.Parent = TabBtnContainer

		-- 选中指示器
		local Indicator = Instance.new("Frame", Btn)
		Indicator.Size = UDim2.new(0, 4, 0, 16)
		Indicator.Position = UDim2.new(0, 0, 0.5, -8)
		Indicator.BackgroundColor3 = Library.Theme.Accent
		Indicator.BackgroundTransparency = 1 -- 默认隐藏
		AddCorner(Indicator, 4)

		-- 2. 创建页面容器
		local Page = Instance.new("ScrollingFrame")
		Page.Name = name .. "_Page"
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 2
		Page.Visible = false
		Page.Parent = ContentArea
		
		local PageLayout = Instance.new("UIListLayout", Page)
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.Padding = UDim.new(0, 6)
		PageLayout.Padding = UDim.new(0, 8)
		
		-- 自动调整画布高度
		PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
		end)

		-- 3. 激活逻辑
		local function Activate()
			-- 重置所有 Tab 状态
			for _, t in pairs(WindowObj.Tabs) do
				Tween(t.Btn, {BackgroundTransparency = 1, TextColor3 = Library.Theme.SubText}, 0.2)
				Tween(t.Indicator, {BackgroundTransparency = 1}, 0.2)
				t.Page.Visible = false
			end
			-- 激活当前
			Tween(Btn, {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(40,40,40), TextColor3 = Library.Theme.Text}, 0.2)
			Tween(Indicator, {BackgroundTransparency = 0}, 0.2)
			Page.Visible = true
			WindowObj.ActiveTab = TabObj
		end

		Btn.MouseButton1Click:Connect(Activate)

		-- 存储引用
		TabObj.Btn = Btn
		TabObj.Indicator = Indicator
		TabObj.Page = Page
		table.insert(WindowObj.Tabs, TabObj)

		-- 如果是第一个，默认激活
		if #WindowObj.Tabs == 1 then
			Activate()
		end

		-- ==============================
		-- [组件 API] (极简语法)
		-- ==============================

		-- 1. 按钮 (Button)
		function TabObj:Button(text, callback)
			local BtnFrame = Instance.new("TextButton")
			BtnFrame.Size = UDim2.new(1, -5, 0, 36)
			BtnFrame.BackgroundColor3 = Library.Theme.Secondary
			BtnFrame.Text = ""
			BtnFrame.AutoButtonColor = false
			AddCorner(BtnFrame, 6)
			AddStroke(BtnFrame)
			BtnFrame.Parent = Page

			local Lbl = Instance.new("TextLabel", BtnFrame)
			Lbl.Size = UDim2.new(1, -10, 1, 0)
			Lbl.Position = UDim2.new(0, 10, 0, 0)
			Lbl.BackgroundTransparency = 1
			Lbl.Text = text
			Lbl.Font = Enum.Font.Gotham
			Lbl.TextColor3 = Library.Theme.Text
			Lbl.TextSize = 14
			Lbl.TextXAlignment = Enum.TextXAlignment.Left

			local Icon = Instance.new("ImageLabel", BtnFrame)
			Icon.Size = UDim2.new(0, 16, 0, 16)
			Icon.Position = UDim2.new(1, -26, 0.5, -8)
			Icon.BackgroundTransparency = 1
			Icon.Image = "rbxassetid://6031094678" -- 点击图标
			Icon.ImageColor3 = Library.Theme.SubText

			-- 交互动画
			BtnFrame.MouseEnter:Connect(function() 
				Tween(BtnFrame, {BackgroundColor3 = Library.Theme.Hover}, 0.2) 
			end)
			BtnFrame.MouseLeave:Connect(function() 
				Tween(BtnFrame, {BackgroundColor3 = Library.Theme.Secondary}, 0.2) 
			end)
			BtnFrame.MouseButton1Click:Connect(function()
				Tween(BtnFrame, {Size = UDim2.new(1, -8, 0, 34)}, 0.05)
				task.wait(0.05)
				Tween(BtnFrame, {Size = UDim2.new(1, -5, 0, 36)}, 0.05)
				if callback then callback() end
			end)
			return BtnFrame
		end

		-- 2. 开关 (Toggle)
		function TabObj:Toggle(text, default, callback)
			local state = default or false
			
			local TglFrame = Instance.new("TextButton")
			TglFrame.Size = UDim2.new(1, -5, 0, 36)
			TglFrame.BackgroundColor3 = Library.Theme.Secondary
			TglFrame.Text = ""
			TglFrame.AutoButtonColor = false
			AddCorner(TglFrame, 6)
			AddStroke(TglFrame)
			TglFrame.Parent = Page

			local Lbl = Instance.new("TextLabel", TglFrame)
			Lbl.Size = UDim2.new(1, -50, 1, 0)
			Lbl.Position = UDim2.new(0, 10, 0, 0)
			Lbl.BackgroundTransparency = 1
			Lbl.Text = text
			Lbl.Font = Enum.Font.Gotham
			Lbl.TextColor3 = Library.Theme.Text
			Lbl.TextSize = 14
			Lbl.TextXAlignment = Enum.TextXAlignment.Left

			-- 开关槽
			local Slot = Instance.new("Frame", TglFrame)
			Slot.Size = UDim2.new(0, 36, 0, 18)
			Slot.Position = UDim2.new(1, -46, 0.5, -9)
			Slot.BackgroundColor3 = state and Library.Theme.Accent or Color3.fromRGB(60,60,60)
			AddCorner(Slot, 9)

			local Circle = Instance.new("Frame", Slot)
			Circle.Size = UDim2.new(0, 14, 0, 14)
			Circle.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
			Circle.BackgroundColor3 = Color3.new(1,1,1)
			AddCorner(Circle, 7)

			local function Update()
				state = not state
				local targetColor = state and Library.Theme.Accent or Color3.fromRGB(60,60,60)
				local targetPos = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
				
				Tween(Slot, {BackgroundColor3 = targetColor}, 0.2)
				Tween(Circle, {Position = targetPos}, 0.2)
				if callback then callback(state) end
			end

			TglFrame.MouseButton1Click:Connect(Update)
			return {
				Set = function(s) state = not s; Update() end
			}
		end

		-- 3. 滑动条 (Slider)
		function TabObj:Slider(text, min, max, default, callback)
			local value = default or min
			
			local SldFrame = Instance.new("Frame")
			SldFrame.Size = UDim2.new(1, -5, 0, 50) -- 稍微高一点
			SldFrame.BackgroundColor3 = Library.Theme.Secondary
			AddCorner(SldFrame, 6)
			AddStroke(SldFrame)
			SldFrame.Parent = Page

			local Lbl = Instance.new("TextLabel", SldFrame)
			Lbl.Size = UDim2.new(1, -10, 0, 20)
			Lbl.Position = UDim2.new(0, 10, 0, 5)
			Lbl.BackgroundTransparency = 1
			Lbl.Text = text
			Lbl.Font = Enum.Font.Gotham
			Lbl.TextColor3 = Library.Theme.Text
			Lbl.TextSize = 14
			Lbl.TextXAlignment = Enum.TextXAlignment.Left

			local ValLbl = Instance.new("TextLabel", SldFrame)
			ValLbl.Size = UDim2.new(0, 50, 0, 20)
			ValLbl.Position = UDim2.new(1, -60, 0, 5)
			ValLbl.BackgroundTransparency = 1
			ValLbl.Text = tostring(value)
			ValLbl.Font = Enum.Font.Gotham
			ValLbl.TextColor3 = Library.Theme.SubText
			ValLbl.TextSize = 14
			ValLbl.TextXAlignment = Enum.TextXAlignment.Right

			local Track = Instance.new("TextButton") -- 使用Button以便点击
			Track.Size = UDim2.new(1, -20, 0, 4)
			Track.Position = UDim2.new(0, 10, 0, 35)
			Track.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			Track.Text = ""
			Track.AutoButtonColor = false
			AddCorner(Track, 2)
			Track.Parent = SldFrame

			local Fill = Instance.new("Frame", Track)
			Fill.Size = UDim2.new((value - min)/(max - min), 0, 1, 0)
			Fill.BackgroundColor3 = Library.Theme.Accent
			Fill.BorderSizePixel = 0
			AddCorner(Fill, 2)

			local dragging = false
			
			local function Update(input)
				local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
				local newValue = math.floor(min + (max - min) * pos)
				
				if newValue ~= value then
					value = newValue
					ValLbl.Text = tostring(value)
					Tween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
					if callback then callback(value) end
				end
			end

			Track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					Update(input)
				end
			end)
			
			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					Update(input)
				end
			end)
			
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
			end)
		end
		
		-- 4. 文本框 (Input) - 极简
		function TabObj:Input(text, placeholder, callback)
			local BoxFrame = Instance.new("Frame")
			BoxFrame.Size = UDim2.new(1, -5, 0, 36)
			BoxFrame.BackgroundColor3 = Library.Theme.Secondary
			AddCorner(BoxFrame, 6)
			AddStroke(BoxFrame)
			BoxFrame.Parent = Page
			
			local Box = Instance.new("TextBox")
			Box.Size = UDim2.new(1, -20, 1, 0)
			Box.Position = UDim2.new(0, 10, 0, 0)
			Box.BackgroundTransparency = 1
			Box.Text = ""
			Box.PlaceholderText = placeholder or text
			Box.PlaceholderColor3 = Color3.fromRGB(100,100,100)
			Box.TextColor3 = Library.Theme.Text
			Box.Font = Enum.Font.Gotham
			Box.TextSize = 14
			Box.TextXAlignment = Enum.TextXAlignment.Left
			Box.Parent = BoxFrame
			
			Box.FocusLost:Connect(function(enter)
				if callback then callback(Box.Text) end
			end)
		end

		return TabObj
	end

	-- ==============================
	-- [内置设置页]
	-- ==============================
	
	local SettingsTab = WindowObj:Tab("设置")
	
	SettingsTab:Button("卸载 UI (Destory)", function()
		ScreenGui:Destroy()
	end)
	
	SettingsTab:Toggle("深色模式 (默认)", true, function(val)
		-- 简单的切换逻辑示例
		if not val then
			Main.BackgroundColor3 = Color3.fromRGB(230,230,230)
			-- 这里需要更复杂的遍历来改变所有已创建元素的颜色，
			-- 为了脚本简洁，此处仅演示背景变色。
		else
			Main.BackgroundColor3 = Library.Theme.Main
		end
	end)
	
	SettingsTab:Button("复制 GitHub 链接", function()
		if setclipboard then
			setclipboard("https://github.com/notmicrover/UI")
		end
	end)

	-- 自动选中第一个标签
	return WindowObj
end

return Library
