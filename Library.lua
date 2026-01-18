-- 现代化 UI 库 v4.1 (Google Material 3 风格)
-- 特性：API 优化、自动布局、标签页系统、BUG修复、Material 3 风格组件
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

Library.Theme = {
	Primary = Color3.fromRGB(103, 80, 164), 
	OnPrimary = Color3.fromRGB(255, 255, 255),
	PrimaryContainer = Color3.fromRGB(234, 221, 255),
	OnPrimaryContainer = Color3.fromRGB(33, 0, 93),
	Surface = Color3.fromRGB(255, 251, 254),
	OnSurface = Color3.fromRGB(28, 27, 31),
	OnSurfaceVariant = Color3.fromRGB(73, 69, 79),
	SurfaceContainer = Color3.fromRGB(243, 237, 247),
	Outline = Color3.fromRGB(121, 116, 126),
	Hover = Color3.fromRGB(235, 230, 240)
}

-- ==============================
-- [工具函数]
-- ==============================

local function Tween(obj, props, time, style, direction)
	local tweenInfo = TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out)
	return TweenService:Create(obj, tweenInfo, props)
end

local function MakeDraggable(topbar, object)
	local dragging, dragStart, startPos
	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging, dragStart, startPos = true, input.Position, object.Position
			local conn; conn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					conn:Disconnect()
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

local function AddCorner(parent, radius)
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, radius or 12); c.Parent = parent; return c
end

local function AddStroke(parent, color, thickness)
	local s = Instance.new("UIStroke"); s.Color = color or Library.Theme.Outline; s.Thickness = thickness or 1; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = parent; return s
end

-- ==============================
-- [核心逻辑]
-- ==============================

function Library:Window(options)
	options = options or {}
	local title = options.Title or "Material 3 Library"
	
	local ScreenGui = Instance.new("ScreenGui", Viewport)
	ScreenGui.Name = "Material3Lib_" .. math.random(1000,9999)
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local Main = Instance.new("Frame", ScreenGui)
	Main.Name = "Main"; Main.Size = UDim2.new(0, 600, 0, 420); Main.Position = UDim2.new(0.5, -300, 0.5, -210)
	Main.BackgroundColor3 = Library.Theme.Surface; Main.ClipsDescendants = true; AddCorner(Main, 28)

	local Shadow = Instance.new("ImageLabel", Main)
	Shadow.Name = "Shadow"; Shadow.Image = "rbxassetid://9506889916"; Shadow.ImageColor3 = Color3.new(); Shadow.ImageTransparency = 0.7
	Shadow.ScaleType = Enum.ScaleType.Slice; Shadow.SliceCenter = Rect.new(20, 20, 280, 280)
	Shadow.Size = UDim2.new(1, 40, 1, 40); Shadow.Position = UDim2.new(0, -20, 0, -20); Shadow.ZIndex = -1

	local Sidebar = Instance.new("Frame", Main)
	Sidebar.Name = "Sidebar"; Sidebar.Size = UDim2.new(0, 160, 1, 0); Sidebar.BackgroundColor3 = Library.Theme.SurfaceContainer; Sidebar.BorderSizePixel = 0
	
	local DragArea = Instance.new("Frame", Main); DragArea.Size = UDim2.new(1, 0, 0, 56); DragArea.BackgroundTransparency = 1; DragArea.ZIndex = 2
	MakeDraggable(DragArea, Main)

	local TitleLbl = Instance.new("TextLabel", Sidebar)
	TitleLbl.Text = title; TitleLbl.Font = Enum.Font.GothamBold; TitleLbl.TextSize = 22; TitleLbl.TextColor3 = Library.Theme.OnSurface
	TitleLbl.Size = UDim2.new(1, -24, 0, 56); TitleLbl.Position = UDim2.new(0, 12, 0, 0); TitleLbl.BackgroundTransparency = 1
	TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

	local TabBtnContainer = Instance.new("ScrollingFrame", Sidebar)
	TabBtnContainer.Size = UDim2.new(1, 0, 1, -120); TabBtnContainer.Position = UDim2.new(0, 0, 0, 70)
	TabBtnContainer.BackgroundTransparency = 1; TabBtnContainer.ScrollBarThickness = 0; TabBtnContainer.Padding = UDim.new(0, 12)
	
	local TabBtnLayout = Instance.new("UIListLayout", TabBtnContainer)
	TabBtnLayout.SortOrder = Enum.SortOrder.LayoutOrder; TabBtnLayout.Padding = UDim.new(0, 8); TabBtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local ContentArea = Instance.new("Frame", Main)
	ContentArea.Name = "Content"; ContentArea.Size = UDim2.new(1, -172, 1, -12); ContentArea.Position = UDim2.new(0, 166, 0, 6); ContentArea.BackgroundTransparency = 1

	local WindowObj = { Gui = ScreenGui, Main = Main, Tabs = {}, ActiveTab = nil }

	function WindowObj:Tab(name)
		local TabObj = {}
		local Btn = Instance.new("TextButton", TabBtnContainer)
		Btn.Name = name .. "_Btn"; Btn.Size = UDim2.new(1, -16, 0, 48); Btn.BackgroundColor3 = Library.Theme.PrimaryContainer
		Btn.BackgroundTransparency = 1; Btn.Text = name; Btn.TextColor3 = Library.Theme.OnSurfaceVariant
		Btn.Font = Enum.Font.GothamMedium; Btn.TextSize = 15; Btn.AutoButtonColor = false; AddCorner(Btn, 24)

		local Page = Instance.new("ScrollingFrame", ContentArea)
		Page.Name = name .. "_Page"; Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 4; Page.ScrollBarColor = Library.Theme.Outline; Page.Visible = false
		
		local PageLayout = Instance.new("UIListLayout", Page)
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder; PageLayout.Padding = UDim.new(0, 12)
		PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
		end)

		local function Activate()
			if WindowObj.ActiveTab == TabObj then return end
			for _, t in pairs(WindowObj.Tabs) do
				Tween(t.Btn, {BackgroundTransparency = 1, TextColor3 = Library.Theme.OnSurfaceVariant}, 0.2):Play()
				t.Page.Visible = false
			end
			Tween(Btn, {BackgroundTransparency = 0, TextColor3 = Library.Theme.OnPrimaryContainer}, 0.2):Play()
			Page.Visible = true; WindowObj.ActiveTab = TabObj
		end
		Btn.MouseButton1Click:Connect(Activate)
		table.insert(WindowObj.Tabs, {Btn = Btn, Page = Page, Activate = Activate})

		function TabObj:Button(text, callback)
			local BtnFrame = Instance.new("TextButton", Page)
			BtnFrame.Size = UDim2.new(1, 0, 0, 40); BtnFrame.BackgroundColor3 = Library.Theme.Primary
			BtnFrame.Text = text; BtnFrame.TextColor3 = Library.Theme.OnPrimary; BtnFrame.Font = Enum.Font.GothamBold
			BtnFrame.TextSize = 14; BtnFrame.AutoButtonColor = false; AddCorner(BtnFrame, 20)
			BtnFrame.MouseEnter:Connect(function() Tween(BtnFrame, {BackgroundColor3 = Color3.new(Library.Theme.Primary.r*0.9, Library.Theme.Primary.g*0.9, Library.Theme.Primary.b*0.9)}, 0.2):Play() end)
			BtnFrame.MouseLeave:Connect(function() Tween(BtnFrame, {BackgroundColor3 = Library.Theme.Primary}, 0.2):Play() end)
			BtnFrame.MouseButton1Click:Connect(function() if callback then task.spawn(callback) end end)
			return BtnFrame
		end

		function TabObj:Toggle(text, default, callback)
			local state = default or false
			local TglFrame = Instance.new("TextButton", Page); TglFrame.Size = UDim2.new(1, 0, 0, 48); TglFrame.BackgroundColor3 = Library.Theme.SurfaceContainer
			TglFrame.Text = ""; TglFrame.AutoButtonColor = false; AddCorner(TglFrame, 12)
			local Lbl = Instance.new("TextLabel", TglFrame); Lbl.Size = UDim2.new(1, -70, 1, 0); Lbl.Position = UDim2.new(0, 16, 0, 0)
			Lbl.BackgroundTransparency = 1; Lbl.Text = text; Lbl.Font = Enum.Font.Gotham; Lbl.TextColor3 = Library.Theme.OnSurface
			Lbl.TextSize = 15; Lbl.TextXAlignment = Enum.TextXAlignment.Left
			local Track = Instance.new("Frame", TglFrame); Track.Size = UDim2.new(0, 52, 0, 32); Track.Position = UDim2.new(1, -64, 0.5, -16)
			Track.BackgroundColor3 = state and Library.Theme.Primary or Library.Theme.Outline; AddCorner(Track, 16)
			local Thumb = Instance.new("Frame", Track); Thumb.Size = UDim2.new(0, state and 24 or 16, 0, state and 24 or 16)
			Thumb.Position = state and UDim2.new(1, -28, 0.5, -12) or UDim2.new(0, 4, 0.5, -8)
			Thumb.BackgroundColor3 = state and Library.Theme.OnPrimary or Library.Theme.Surface; AddCorner(Thumb, 12)
			local function UpdateVisuals(newState)
				Tween(Track, {BackgroundColor3 = newState and Library.Theme.Primary or Library.Theme.Outline}, 0.2):Play()
				Tween(Thumb, {BackgroundColor3 = newState and Library.Theme.OnPrimary or Library.Theme.Surface, Size = newState and UDim2.new(0,24,0,24) or UDim2.new(0,16,0,16), Position = newState and UDim2.new(1,-28,0.5,-12) or UDim2.new(0,4,0.5,-8)}, 0.2):Play()
			end
			local function ToggleState() state = not state; UpdateVisuals(state); if callback then task.spawn(callback, state) end end
			TglFrame.MouseButton1Click:Connect(ToggleState)
			return { Set = function(s) s = not not s; if s ~= state then ToggleState() end end }
		end

		function TabObj:Slider(text, min, max, default, callback)
			local value = default or min
			local SldFrame = Instance.new("Frame", Page); SldFrame.Size = UDim2.new(1, 0, 0, 60); SldFrame.BackgroundColor3 = Library.Theme.SurfaceContainer; AddCorner(SldFrame, 12)
			local Lbl = Instance.new("TextLabel", SldFrame); Lbl.Size = UDim2.new(1, -70, 1, -30); Lbl.Position = UDim2.new(0, 16, 0, 0); Lbl.BackgroundTransparency = 1
			Lbl.Text = text; Lbl.Font = Enum.Font.Gotham; Lbl.TextColor3 = Library.Theme.OnSurface; Lbl.TextSize = 15; Lbl.TextXAlignment = Enum.TextXAlignment.Left
			local ValLbl = Instance.new("TextLabel", SldFrame); ValLbl.Size = UDim2.new(0, 50, 1, -30); ValLbl.Position = UDim2.new(1, -66, 0, 0); ValLbl.BackgroundTransparency = 1
			ValLbl.Text = tostring(math.floor(value)); ValLbl.Font = Enum.Font.GothamMedium; ValLbl.TextColor3 = Library.Theme.OnSurfaceVariant; ValLbl.TextSize = 15; ValLbl.TextXAlignment = Enum.TextXAlignment.Right
			local Track = Instance.new("Frame", SldFrame); Track.Size = UDim2.new(1, -32, 0, 4); Track.Position = UDim2.new(0.5, 0, 1, -24); Track.AnchorPoint = Vector2.new(0.5, 0)
			Track.BackgroundColor3 = Library.Theme.Outline; AddCorner(Track, 2)
			local Fill = Instance.new("Frame", Track); Fill.Size = UDim2.new((value - min)/(max-min), 0, 1, 0); Fill.BackgroundColor3 = Library.Theme.Primary; AddCorner(Fill, 2)
			local Thumb = Instance.new("TextButton", Track); Thumb.Size = UDim2.new(0, 20, 0, 20); Thumb.Position = UDim2.fromScale(Fill.Size.X.Scale, 0.5); Thumb.AnchorPoint = Vector2.new(0.5, 0.5)
			Thumb.BackgroundColor3 = Library.Theme.Primary; Thumb.Text = ""; Thumb.ZIndex = 2; AddCorner(Thumb, 10)
			local dragging = false
			local function Update(input)
				local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
				local newValue = math.floor(min + (max - min) * pos + 0.5)
				if newValue ~= value then
					value = newValue; ValLbl.Text = tostring(value)
					local newSize = UDim2.fromScale(pos, 1)
					Tween(Fill, {Size = newSize}, 0.05):Play(); Tween(Thumb, {Position = UDim2.fromScale(pos, 0.5)}, 0.05):Play()
					if callback then task.spawn(callback, value) end
				end
			end
			Thumb.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					local moveConn, endConn
					moveConn = UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end end)
					endConn = UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false; moveConn:Disconnect(); endConn:Disconnect() end end)
				end
			end)
		end
		
		-- [[API 优化]] --
		function TabObj:Input(label, placeholder, callback)
			local FieldFrame = Instance.new("Frame", Page); FieldFrame.Size = UDim2.new(1, 0, 0, 68); FieldFrame.BackgroundTransparency = 1
			local Lbl = Instance.new("TextLabel", FieldFrame); Lbl.Size = UDim2.new(1, -16, 0, 20); Lbl.Position = UDim2.new(0, 8, 0, 0); Lbl.BackgroundTransparency = 1
			Lbl.Text = label; Lbl.Font = Enum.Font.Gotham; Lbl.TextColor3 = Library.Theme.OnSurfaceVariant; Lbl.TextSize = 14; Lbl.TextXAlignment = Enum.TextXAlignment.Left
			local BoxFrame = Instance.new("Frame", FieldFrame); BoxFrame.Size = UDim2.new(1, 0, 0, 40); BoxFrame.Position = UDim2.new(0, 0, 0, 24)
			BoxFrame.BackgroundColor3 = Library.Theme.SurfaceContainer; AddCorner(BoxFrame, 8)
			local Box = Instance.new("TextBox", BoxFrame); Box.Size = UDim2.new(1, -24, 1, 0); Box.Position = UDim2.new(0, 12, 0, 0); Box.BackgroundTransparency = 1
			Box.Text = ""; Box.PlaceholderText = placeholder or ""; Box.PlaceholderColor3 = Library.Theme.OnSurfaceVariant
			Box.TextColor3 = Library.Theme.OnSurface; Box.Font = Enum.Font.Gotham; Box.TextSize = 15; Box.TextXAlignment = Enum.TextXAlignment.Left
			Box.FocusLost:Connect(function(enterPressed) if enterPressed and callback then task.spawn(callback, Box.Text) end end)
		end

		if #WindowObj.Tabs == 1 then Activate() end
		return TabObj
	end

	local SettingsTab = WindowObj:Tab("设置")
	SettingsTab:Button("卸载 UI (Destroy)", function() pcall(function() ScreenGui:Destroy() end) end)
	SettingsTab:Button("复制项目链接", function() local s, e = pcall(function() setclipboard("https://github.com/notmicrover/UI") end) if not s then warn(e) end end)
	
	if WindowObj.Tabs[1] then WindowObj.Tabs[1].Activate() end
	return WindowObj
end

return Library
