-- 现代化 UI 库 v4.0 (Google Material 3 风格)
-- 特性：自动布局、标签页系统、BUG修复、Material 3 风格组件
-- 作者：AI助手 | 优化：Gemini

local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- 尝试获取更稳定的父级GUI，兼容不同环境
local Viewport = gethui and gethui() or Player:WaitForChild("PlayerGui")

-- ==============================
-- [Material 3 主题]
-- ==============================

-- 基于 Material 3 规范的浅色主题
Library.Theme = {
	Primary = Color3.fromRGB(103, 80, 164),         -- 主色调，用于关键交互元素
	OnPrimary = Color3.fromRGB(255, 255, 255),       -- 在主色调上的内容颜色 (文本/图标)
	
	PrimaryContainer = Color3.fromRGB(234, 221, 255), -- 轻量的 "药丸" 背景
	OnPrimaryContainer = Color3.fromRGB(33, 0, 93),-- 在 "药丸" 背景上的内容颜色

	Surface = Color3.fromRGB(255, 251, 254),         -- 窗口主背景
	OnSurface = Color3.fromRGB(28, 27, 31),          -- 在主背景上的文本颜色 (主文本)
	OnSurfaceVariant = Color3.fromRGB(73, 69, 79),   -- 在主背景上的次级文本/图标颜色 (副文本)

	SurfaceContainer = Color3.fromRGB(243, 237, 247),   -- 侧边栏/组件背景
	
	Outline = Color3.fromRGB(121, 116, 126),         -- 描边/分割线
	Hover = Color3.fromRGB(235, 230, 240)             -- 悬停状态的叠加颜色
}


-- ==============================
-- [工具函数]
-- ==============================

-- 动画函数，提供默认值
local function Tween(obj, props, time, style, direction)
	local tweenInfo = TweenInfo.new(
		time or 0.25,
		style or Enum.EasingStyle.Quart,
		direction or Enum.EasingDirection.Out
	)
	return TweenService:Create(obj, tweenInfo, props)
end

-- 拖拽函数
local function MakeDraggable(topbar, object)
	local dragging, dragInput, dragStart, startPos
	
	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = object.Position
			
			local connection
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					connection:Disconnect() -- 拖拽结束时断开连接，避免内存泄漏
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- 圆角助手
local function AddCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 12) -- M3 风格使用更大的圆角
	c.Parent = parent
	return c
end

-- 描边助手
local function AddStroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Library.Theme.Outline
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
	local title = options.Title or "Material 3 Library"
	
	-- 1. 主屏幕 GUI
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "Material3Lib_" .. math.random(1000,9999)
	ScreenGui.Parent = Viewport
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	-- 2. 主窗口 Frame
	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0, 600, 0, 400) -- 尺寸调整
	Main.Position = UDim2.new(0.5, -300, 0.5, -200)
	Main.BackgroundColor3 = Library.Theme.Surface
	Main.ClipsDescendants = true
	AddCorner(Main, 28) -- M3 特有的超大圆角
	Main.Parent = ScreenGui
	
	-- 窗口阴影 (可选，但效果更好)
	local Shadow = Instance.new("ImageLabel")
	Shadow.Name = "Shadow"
	Shadow.Image = "rbxassetid://9506889916" -- 9-slice shadow
	Shadow.ImageColor3 = Color3.fromRGB(0,0,0)
	Shadow.ImageTransparency = 0.7
	Shadow.ScaleType = Enum.ScaleType.Slice
	Shadow.SliceCenter = Rect.new(20, 20, 280, 280)
	Shadow.Size = UDim2.new(1, 40, 1, 40)
	Shadow.Position = UDim2.new(0, -20, 0, -20)
	Shadow.ZIndex = -1
	Shadow.Parent = Main


	-- 3. 导航栏 (Navigation Rail)
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 160, 1, 0)
	Sidebar.BackgroundColor3 = Library.Theme.SurfaceContainer
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = Main

	-- 拖拽区域
	local DragArea = Instance.new("Frame")
	DragArea.Size = UDim2.new(1, 0, 0, 56) -- M3 推荐的 Top App Bar 高度
	DragArea.BackgroundTransparency = 1
	DragArea.ZIndex = 2
	DragArea.Parent = Main
	MakeDraggable(DragArea, Main)

	-- 标题
	local TitleLbl = Instance.new("TextLabel")
	TitleLbl.Text = title
	TitleLbl.Font = Enum.Font.GothamBold
	TitleLbl.TextSize = 22
	TitleLbl.TextColor3 = Library.Theme.OnSurface
	TitleLbl.Size = UDim2.new(1, -24, 0, 56)
	TitleLbl.Position = UDim2.new(0, 12, 0, 0)
	TitleLbl.BackgroundTransparency = 1
	TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	TitleLbl.Parent = Sidebar

	-- 标签按钮容器
	local TabBtnContainer = Instance.new("ScrollingFrame")
	TabBtnContainer.Size = UDim2.new(1, 0, 1, -120) -- 预留底部空间
	TabBtnContainer.Position = UDim2.new(0, 0, 0, 70)
	TabBtnContainer.BackgroundTransparency = 1
	TabBtnContainer.ScrollBarThickness = 0
	TabBtnContainer.Padding = UDim.new(0, 12)
	TabBtnContainer.Parent = Sidebar
	
	local TabBtnLayout = Instance.new("UIListLayout", TabBtnContainer)
	TabBtnLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabBtnLayout.Padding = UDim.new(0, 8)
	TabBtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	-- 4. 内容区域 (Content)
	local ContentArea = Instance.new("Frame")
	ContentArea.Name = "Content"
	ContentArea.Size = UDim2.new(1, -172, 1, -12)
	ContentArea.Position = UDim2.new(0, 166, 0, 6)
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
		local TabObj = {}

		-- 1. 创建 Tab 按钮
		local Btn = Instance.new("TextButton")
		Btn.Name = name .. "_Btn"
		Btn.Size = UDim2.new(1, -16, 0, 48)
		Btn.BackgroundColor3 = Library.Theme.PrimaryContainer
		Btn.BackgroundTransparency = 1 -- 默认透明
		Btn.Text = name
		Btn.TextColor3 = Library.Theme.OnSurfaceVariant
		Btn.Font = Enum.Font.GothamMedium
		Btn.TextSize = 15
		Btn.AutoButtonColor = false
		AddCorner(Btn, 24) -- "药丸" 形状
		Btn.Parent = TabBtnContainer

		-- 2. 创建页面容器
		local Page = Instance.new("ScrollingFrame")
		Page.Name = name .. "_Page"
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 4
		Page.ScrollBarColor = Library.Theme.Outline
		Page.Visible = false
		Page.Parent = ContentArea
		
		local PageLayout = Instance.new("UIListLayout", Page)
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.Padding = UDim.new(0, 12)
		
		PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
		end)

		-- 3. 激活逻辑
		local function Activate()
			if WindowObj.ActiveTab == TabObj then return end

			-- 重置所有 Tab 状态
			for _, t in pairs(WindowObj.Tabs) do
				Tween(t.Btn, {BackgroundTransparency = 1, TextColor3 = Library.Theme.OnSurfaceVariant}, 0.2):Play()
				t.Page.Visible = false
			end
			-- 激活当前
			Tween(Btn, {BackgroundTransparency = 0, TextColor3 = Library.Theme.OnPrimaryContainer}, 0.2):Play()
			Page.Visible = true
			WindowObj.ActiveTab = TabObj
		end

		Btn.MouseButton1Click:Connect(Activate)
		
		table.insert(WindowObj.Tabs, {Btn = Btn, Page = Page})

		-- 如果是第一个，默认激活
		if #WindowObj.Tabs == 1 then
			Activate()
		end

		-- ==============================
		-- [组件 API]
		-- ==============================
		
		-- 1. 填充按钮 (Filled Button)
		function TabObj:Button(text, callback)
			local BtnFrame = Instance.new("TextButton")
			BtnFrame.Size = UDim2.new(1, 0, 0, 40)
			BtnFrame.BackgroundColor3 = Library.Theme.Primary
			BtnFrame.Text = text
			BtnFrame.TextColor3 = Library.Theme.OnPrimary
			BtnFrame.Font = Enum.Font.GothamBold
			BtnFrame.TextSize = 14
			BtnFrame.AutoButtonColor = false
			AddCorner(BtnFrame, 20) -- 全圆角
			BtnFrame.Parent = Page

			-- 交互动画
			BtnFrame.MouseEnter:Connect(function() 
				Tween(BtnFrame, {BackgroundColor3 = Color3.new(Library.Theme.Primary.r * 0.9, Library.Theme.Primary.g * 0.9, Library.Theme.Primary.b * 0.9)}, 0.2):Play()
			end)
			BtnFrame.MouseLeave:Connect(function() 
				Tween(BtnFrame, {BackgroundColor3 = Library.Theme.Primary}, 0.2):Play()
			end)
			BtnFrame.MouseButton1Click:Connect(function()
				if callback then task.spawn(callback) end
			end)
			return BtnFrame
		end

		-- 2. 开关 (Switch)
		function TabObj:Toggle(text, default, callback)
			local state = default or false
			
			local TglFrame = Instance.new("TextButton")
			TglFrame.Size = UDim2.new(1, 0, 0, 48)
			TglFrame.BackgroundColor3 = Library.Theme.SurfaceContainer
			TglFrame.Text = ""
			TglFrame.AutoButtonColor = false
			AddCorner(TglFrame, 12)
			TglFrame.Parent = Page

			local Lbl = Instance.new("TextLabel", TglFrame)
			Lbl.Size = UDim2.new(1, -70, 1, 0)
			Lbl.Position = UDim2.new(0, 16, 0, 0)
			Lbl.BackgroundTransparency = 1
			Lbl.Text = text
			Lbl.Font = Enum.Font.Gotham
			Lbl.TextColor3 = Library.Theme.OnSurface
			Lbl.TextSize = 15
			Lbl.TextXAlignment = Enum.TextXAlignment.Left

			-- 开关轨道
			local Track = Instance.new("Frame", TglFrame)
			Track.Size = UDim2.new(0, 52, 0, 32)
			Track.Position = UDim2.new(1, -64, 0.5, -16)
			Track.BackgroundColor3 = state and Library.Theme.Primary or Library.Theme.Outline
			AddCorner(Track, 16)

			-- 开关滑块
			local Thumb = Instance.new("Frame", Track)
			Thumb.Size = UDim2.new(0, state and 24 or 16, 0, state and 24 or 16)
			Thumb.Position = state and UDim2.new(1, -28, 0.5, -12) or UDim2.new(0, 4, 0.5, -8)
			Thumb.BackgroundColor3 = state and Library.Theme.OnPrimary or Library.Theme.Surface
			AddCorner(Thumb, 12)

			local function UpdateVisuals(newState)
				local trackColor = newState and Library.Theme.Primary or Library.Theme.Outline
				local thumbColor = newState and Library.Theme.OnPrimary or Library.Theme.Surface
				local thumbSize = newState and UDim2.new(0, 24, 0, 24) or UDim2.new(0, 16, 0, 16)
				local thumbPos = newState and UDim2.new(1, -28, 0.5, -12) or UDim2.new(0, 4, 0.5, -8)

				Tween(Track, {BackgroundColor3 = trackColor}, 0.2):Play()
				Tween(Thumb, {BackgroundColor3 = thumbColor, Size = thumbSize, Position = thumbPos}, 0.2):Play()
			end

			local function ToggleState()
				state = not state
				UpdateVisuals(state)
				if callback then task.spawn(callback, state) end
			end

			TglFrame.MouseButton1Click:Connect(ToggleState)
			
			-- [[BUG修复]] Set 函数逻辑更清晰
			return {
				Set = function(s)
					s = not not s -- 确保是布尔值
					if s ~= state then
						ToggleState()
					end
				end
			}
		end

		-- 3. 滑动条 (Slider)
		function TabObj:Slider(text, min, max, default, callback)
			local value = default or min
			
			local SldFrame = Instance.new("Frame")
			SldFrame.Size = UDim2.new(1, 0, 0, 60)
			SldFrame.BackgroundColor3 = Library.Theme.SurfaceContainer
			AddCorner(SldFrame, 12)
			SldFrame.Parent = Page

			local Lbl = Instance.new("TextLabel", SldFrame)
			Lbl.Size = UDim2.new(1, -70, 1, -30)
			Lbl.Position = UDim2.new(0, 16, 0, 0)
			Lbl.BackgroundTransparency = 1
			Lbl.Text = text
			Lbl.Font = Enum.Font.Gotham
			Lbl.TextColor3 = Library.Theme.OnSurface
			Lbl.TextSize = 15
			Lbl.TextXAlignment = Enum.TextXAlignment.Left

			local ValLbl = Instance.new("TextLabel", SldFrame)
			ValLbl.Size = UDim2.new(0, 50, 1, -30)
			ValLbl.Position = UDim2.new(1, -66, 0, 0)
			ValLbl.BackgroundTransparency = 1
			ValLbl.Text = tostring(math.floor(value))
			ValLbl.Font = Enum.Font.GothamMedium
			ValLbl.TextColor3 = Library.Theme.OnSurfaceVariant
			ValLbl.TextSize = 15
			ValLbl.TextXAlignment = Enum.TextXAlignment.Right

			local Track = Instance.new("Frame")
			Track.Size = UDim2.new(1, -32, 0, 4)
			Track.Position = UDim2.new(0.5, -Track.AbsoluteSize.X/2, 1, -24)
			Track.BackgroundColor3 = Library.Theme.Outline
			AddCorner(Track, 2)
			Track.Parent = SldFrame

			local Fill = Instance.new("Frame", Track)
			Fill.Size = UDim2.new((value - min)/(max - min), 0, 1, 0)
			Fill.BackgroundColor3 = Library.Theme.Primary
			AddCorner(Fill, 2)
			
			local Thumb = Instance.new("TextButton") -- 用 TextButton 方便检测输入
			Thumb.Size = UDim2.new(0, 20, 0, 20)
			Thumb.Position = UDim2.fromScale(Fill.Size.X.Scale, 0.5)
			Thumb.AnchorPoint = Vector2.new(0.5, 0.5)
			Thumb.BackgroundColor3 = Library.Theme.Primary
			Thumb.Text = ""
			Thumb.ZIndex = 2
			AddCorner(Thumb, 10)
			Thumb.Parent = Track
			
			-- [[BUG修复]] 拖拽逻辑改为局部，避免全局冲突
			local dragging = false
			local function Update(input)
				local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
				local newValue = math.floor(min + (max - min) * pos + 0.5) -- 加0.5以四舍五入
				
				if newValue ~= value then
					value = newValue
					ValLbl.Text = tostring(value)
					local newSize = UDim2.fromScale(pos, 1)
					Tween(Fill, {Size = newSize}, 0.05):Play()
					Tween(Thumb, {Position = UDim2.fromScale(pos, 0.5)}, 0.05):Play()
					if callback then task.spawn(callback, value) end
				end
			end

			Thumb.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					local moveConn, endConn
					moveConn = UserInputService.InputChanged:Connect(function(i)
						if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end
					end)
					endConn = UserInputService.InputEnded:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 then
							dragging = false
							moveConn:Disconnect()
							endConn:Disconnect()
						end
					end)
				end
			end)
		end
		
		-- 4. 文本框 (Filled Input)
		function TabObj:Input(placeholder, callback)
			local BoxFrame = Instance.new("Frame")
			BoxFrame.Size = UDim2.new(1, 0, 0, 56)
			BoxFrame.BackgroundColor3 = Library.Theme.SurfaceContainer
			AddCorner(BoxFrame, 8)
			BoxFrame.Parent = Page
			
			local Box = Instance.new("TextBox")
			Box.Size = UDim2.new(1, -32, 1, -16)
			Box.Position = UDim2.new(0, 16, 0, 8)
			Box.BackgroundTransparency = 1
			Box.Text = ""
			Box.PlaceholderText = placeholder or ""
			Box.PlaceholderColor3 = Library.Theme.OnSurfaceVariant
			Box.TextColor3 = Library.Theme.OnSurface
			Box.Font = Enum.Font.Gotham
			Box.TextSize = 16
			Box.TextXAlignment = Enum.TextXAlignment.Left
			Box.Parent = BoxFrame
			
			Box.FocusLost:Connect(function(enterPressed)
				if enterPressed and callback then
					task.spawn(callback, Box.Text)
				end
			end)
		end

		return TabObj
	end

	-- ==============================
	-- [内置设置页]
	-- ==============================
	
	local SettingsTab = WindowObj:Tab("设置")
	
	SettingsTab:Button("卸载 UI (Destroy)", function()
		pcall(function() ScreenGui:Destroy() end)
	end)
	
	SettingsTab:Button("复制项目链接", function()
		-- [[BUG修复]] 使用 pcall 避免在不支持的环境中报错
		local success, err = pcall(function()
			setclipboard("https://github.com/notmicrover/UI") -- 假设的链接
		end)
		if not success then
			warn("setclipboard is not available in this environment.")
		end
	end)

	-- 自动选中第一个标签
	if WindowObj.Tabs[1] then
		WindowObj.Tabs[1].Btn:MouseButton1Click()
	end
	
	return WindowObj
end

return Library
