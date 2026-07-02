-- Redev Lib v5.0 - Advanced UI Library
-- Author: REDEV-C
-- Features: Windows, Tabs, Sections, Toggle, Slider, Button, Textbox, Keybind,
--           Dropdown (searchable), Multi-Dropdown, ColorPicker (HSV/Alpha/Hex),
--           Label, Paragraph, Divider, Notifications, Config System, Theming,
--           Watermark, Ripple Animations, Connection Safety, Drag & Minimize.
--
-- Documentation: https://github.com/REDEV-C/REDEV-LIB (or contact the author)
--
-- Usage:
--   local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/REDEV-C/REDEV-LIB/main/Lib.lua"))()
--   local Window = Library:CreateWindow({ Title = "My Script" })
--   local Tab = Window:CreateTab("Main")
--   local Section = Window:CreateSection(Tab, "Combat")
--   Section:CreateToggle({ Name = "Aimbot", Flag = "aimbot" })
--   Library:Notify({ Title = "Welcome", Content = "Library loaded!", Duration = 3, Type = "success" })

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
	error("[Redev Lib] This library must be run on the client.")
end

local Library = {
	Version = "5.0.0",
	Windows = {},
	Theme = {
		-- Core colors
		Background = Color3.fromRGB(15, 15, 15),
		Secondary = Color3.fromRGB(24, 24, 24),
		Tertiary = Color3.fromRGB(32, 32, 32),
		Hover = Color3.fromRGB(50, 50, 50),
		Accent = Color3.fromRGB(85, 145, 255),
		AccentHover = Color3.fromRGB(105, 165, 255),
		Text = Color3.fromRGB(240, 240, 240),
		TextDim = Color3.fromRGB(180, 180, 180),
		TextDark = Color3.fromRGB(110, 110, 110),
		Success = Color3.fromRGB(46, 204, 113),
		Warning = Color3.fromRGB(241, 196, 15),
		Error = Color3.fromRGB(231, 76, 60),
		Border = Color3.fromRGB(40, 40, 40),
		BorderLight = Color3.fromRGB(55, 55, 55),

		-- UI properties
		WindowRadius = 12,
		ElementRadius = 8,
		Shadow = true,
		Font = Enum.Font.Gotham,
		FontBold = Enum.Font.GothamBold,
		TextSize = 14,
	},
	NotificationQueue = {},
	ActiveNotifications = {},
	MaxNotifications = 5,
	NotificationSpacing = 10,
	NotificationContainer = nil,
}

-- Utility functions
local function CreateRounded(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = instance
	return corner
end

local function CreateStroke(instance, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Library.Theme.Border
	stroke.Thickness = thickness or 1
	stroke.Parent = instance
	return stroke
end

local function CreateShadow(instance)
	if not Library.Theme.Shadow then return end
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.Parent = instance
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://1316045217"
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.7
	shadow.Size = UDim2.new(1, 20, 1, 20)
	shadow.Position = UDim2.new(0, -10, 0, -10)
	shadow.ZIndex = 0
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(10, 10, 20, 20)
	return shadow
end

local function SafeCallback(callback, ...)
	if callback then
		local success, err = pcall(callback, ...)
		if not success then
			warn("[Redev Lib] Callback error:", err)
		end
	end
end

-- Notification System
local function GetNotificationContainer()
	if not Library.NotificationContainer then
		local playerGui = LocalPlayer:WaitForChild("PlayerGui")
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "RedevNotifications"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.Parent = playerGui

		local container = Instance.new("Frame")
		container.Name = "Container"
		container.Size = UDim2.new(0, 380, 0, 0)
		container.Position = UDim2.new(1, -400, 0, 10)
		container.BackgroundTransparency = 1
		container.ClipsDescendants = true
		container.Parent = screenGui

		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, Library.NotificationSpacing)
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		layout.VerticalAlignment = Enum.VerticalAlignment.Top
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = container

		Library.NotificationContainer = container
	end
	return Library.NotificationContainer
end

function Library:Notify(data)
	data = data or {}
	local title = data.Title or "Notification"
	local content = data.Content or ""
	local duration = data.Duration or 4
	local notifType = data.Type or "info"

	local icons = {
		info = "ℹ",
		success = "✔",
		warning = "⚠",
		error = "✖"
	}

	local colors = {
		info = self.Theme.Accent,
		success = self.Theme.Success,
		warning = self.Theme.Warning,
		error = self.Theme.Error
	}

	local container = GetNotificationContainer()

	-- Main notification frame
	local notification = Instance.new("Frame")
	notification.Size = UDim2.new(1, 0, 0, 0)
	notification.BackgroundColor3 = self.Theme.Secondary
	notification.BackgroundTransparency = 1
	notification.ClipsDescendants = true
	notification.AutomaticSize = Enum.AutomaticSize.Y
	notification.ZIndex = 2
	notification.Parent = container

	CreateRounded(notification, 10)
	CreateStroke(notification, colors[notifType] or self.Theme.Accent, 1.5)

	-- Color stripe
	local stripe = Instance.new("Frame")
	stripe.Size = UDim2.new(0, 4, 1, -2)
	stripe.Position = UDim2.new(0, 1, 0, 1)
	stripe.BackgroundColor3 = colors[notifType] or self.Theme.Accent
	stripe.BorderSizePixel = 0
	stripe.Parent = notification
	CreateRounded(stripe, 2)

	-- Icon
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(0, 30, 0, 30)
	iconLabel.Position = UDim2.new(0, 10, 0, 8)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = icons[notifType] or "ℹ"
	iconLabel.TextColor3 = colors[notifType] or self.Theme.Accent
	iconLabel.TextSize = 18
	iconLabel.Font = self.Theme.FontBold
	iconLabel.TextXAlignment = Enum.TextXAlignment.Center
	iconLabel.Parent = notification

	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -60, 0, 25)
	titleLabel.Position = UDim2.new(0, 45, 0, 5)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = self.Theme.Text
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Font = self.Theme.FontBold
	titleLabel.TextSize = 15
	titleLabel.AutomaticSize = Enum.AutomaticSize.Y
	titleLabel.Parent = notification

	-- Content
	local contentLabel = Instance.new("TextLabel")
	contentLabel.Size = UDim2.new(1, -55, 0, 20)
	contentLabel.Position = UDim2.new(0, 45, 0, 30)
	contentLabel.BackgroundTransparency = 1
	contentLabel.Text = content
	contentLabel.TextColor3 = self.Theme.TextDim
	contentLabel.TextXAlignment = Enum.TextXAlignment.Left
	contentLabel.TextWrapped = true
	contentLabel.Font = self.Theme.Font
	contentLabel.TextSize = 13
	contentLabel.AutomaticSize = Enum.AutomaticSize.Y
	contentLabel.Parent = notification

	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 25, 0, 25)
	closeBtn.Position = UDim2.new(1, -30, 0, 5)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = self.Theme.TextDark
	closeBtn.TextSize = 13
	closeBtn.Font = self.Theme.Font
	closeBtn.ZIndex = 3
	closeBtn.Parent = notification

	local progress = Instance.new("Frame")
	progress.Size = UDim2.new(1, 0, 0, 2)
	progress.Position = UDim2.new(0, 0, 1, -2)
	progress.BackgroundColor3 = colors[notifType] or self.Theme.Accent
	progress.BorderSizePixel = 0
	progress.Parent = notification
	CreateRounded(progress, 1)

	local notificationData = {
		Frame = notification,
		Progress = progress,
		Duration = duration,
		IsClosed = false
	}
	table.insert(self.ActiveNotifications, notificationData)

	-- Close handler
	local closed = false
	closeBtn.MouseButton1Click:Connect(function()
		if not closed then
			closed = true
			self:CloseNotification(notification)
		end
	end)

	-- Animate in
	task.spawn(function()
		notification.Size = UDim2.new(1, 0, 0, 0)
		notification.BackgroundTransparency = 1
		task.wait(0.05)
		if not notification.Parent then return end

		local targetHeight = titleLabel.AbsoluteSize.Y + contentLabel.AbsoluteSize.Y + 25
		TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, 0, 0, targetHeight),
			BackgroundTransparency = 0
		}):Play()

		if duration > 0 then
			TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
				Size = UDim2.new(0, 0, 0, 2)
			}):Play()
			task.wait(duration)
			if not closed and notification.Parent then
				closed = true
				self:CloseNotification(notification)
			end
		end
	end)

	-- Limit maximum visible notifications
	while #self.ActiveNotifications > self.MaxNotifications do
		local oldest = self.ActiveNotifications[1]
		if oldest and not oldest.IsClosed then
			oldest.IsClosed = true
			self:CloseNotification(oldest.Frame)
		else
			table.remove(self.ActiveNotifications, 1)
		end
	end

	return notificationData
end

function Library:CloseNotification(notification)
	if not notification then return end

	-- Remove from active list
	for i = #self.ActiveNotifications, 1, -1 do
		if self.ActiveNotifications[i].Frame == notification then
			self.ActiveNotifications[i].IsClosed = true
			table.remove(self.ActiveNotifications, i)
			break
		end
	end

	-- Animate out
	TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1
	}):Play()

	task.wait(0.3)
	if notification and notification.Parent then
		notification:Destroy()
	end
end

function Library:ClearNotifications()
	for i = #self.ActiveNotifications, 1, -1 do
		local data = self.ActiveNotifications[i]
		if data and data.Frame and not data.IsClosed then
			data.IsClosed = true
			self:CloseNotification(data.Frame)
		end
	end
	self.ActiveNotifications = {}
end

-- Watermark (simple)
function Library:CreateWatermark(text)
	text = text or "Redev Lib | fps: ..."
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	local gui = Instance.new("ScreenGui", playerGui)
	gui.Name = "RedevWatermark"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true

	local label = Instance.new("TextLabel", gui)
	label.Size = UDim2.new(0, 0, 0, 20)
	label.Position = UDim2.new(0, 10, 0, 10)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = self.Theme.Text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = self.Theme.Font
	label.TextSize = 13
	label.AutomaticSize = Enum.AutomaticSize.X
	label.ZIndex = 0

	-- Update FPS
	task.spawn(function()
		while gui and gui.Parent do
			local fps = math.floor(1 / task.wait())
			label.Text = string.gsub(text, "fps: ...", "fps: " .. fps)
		end
	end)
end

-- Window Class
local Window = {}
Window.__index = Window

function Window.new(title, properties)
	properties = properties or {}
	local self = setmetatable({}, Window)
	self.Title = title or "Redev Lib"
	self.Width = properties.Width or 650
	self.Height = properties.Height or 500
	self.Theme = properties.Theme or Library.Theme
	self.Tabs = {}
	self.CurrentTab = nil
	self.Minimized = false
	self.Connections = {}
	self.Destroyed = false

	local playerGui = LocalPlayer:WaitForChild("PlayerGui")

	-- ScreenGui
	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "RedevUI"
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.ScreenGui.IgnoreGuiInset = true
	self.ScreenGui.Parent = playerGui

	-- Main frame
	self.Main = Instance.new("Frame")
	self.Main.Size = UDim2.fromOffset(self.Width, self.Height)
	self.Main.Position = UDim2.fromScale(0.5, 0.5)
	self.Main.AnchorPoint = Vector2.new(0.5, 0.5)
	self.Main.BackgroundColor3 = self.Theme.Background
	self.Main.BorderSizePixel = 0
	self.Main.ClipsDescendants = true
	self.Main.ZIndex = 1
	self.Main.Parent = self.ScreenGui

	-- Opening animation
	self.UIScale = Instance.new("UIScale")
	self.UIScale.Scale = 0.9
	self.UIScale.Parent = self.Main
	self.Main.BackgroundTransparency = 1

	CreateShadow(self.Main)
	CreateRounded(self.Main, self.Theme.WindowRadius)
	CreateStroke(self.Main, self.Theme.Border, 1)

	-- Title bar
	self.TitleBar = Instance.new("Frame")
	self.TitleBar.Size = UDim2.new(1, 0, 0, 44)
	self.TitleBar.BackgroundColor3 = self.Theme.Tertiary
	self.TitleBar.BorderSizePixel = 0
	self.TitleBar.ZIndex = 2
	self.TitleBar.Parent = self.Main
	CreateRounded(self.TitleBar, self.Theme.WindowRadius)

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, self.Theme.Tertiary),
		ColorSequenceKeypoint.new(1, self.Theme.Secondary)
	})
	gradient.Parent = self.TitleBar

	-- Titlebar divider
	local divider = Instance.new("Frame")
	divider.AnchorPoint = Vector2.new(0, 1)
	divider.Position = UDim2.new(0, 0, 1, 0)
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.BackgroundColor3 = self.Theme.Border
	divider.BorderSizePixel = 0
	divider.ZIndex = 3
	divider.Parent = self.TitleBar

	-- Title text
	self.TitleLabel = Instance.new("TextLabel")
	self.TitleLabel.Size = UDim2.new(1, -70, 1, 0)
	self.TitleLabel.Position = UDim2.new(0, 15, 0, 0)
	self.TitleLabel.BackgroundTransparency = 1
	self.TitleLabel.Text = self.Title
	self.TitleLabel.TextColor3 = self.Theme.Text
	self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	self.TitleLabel.Font = self.Theme.FontBold
	self.TitleLabel.TextSize = 17
	self.TitleLabel.ZIndex = 4
	self.TitleLabel.Parent = self.TitleBar

	-- Minimize button
	self.MinBtn = Instance.new("TextButton")
	self.MinBtn.Size = UDim2.new(0, 28, 0, 28)
	self.MinBtn.Position = UDim2.new(1, -75, 0.5, -14)
	self.MinBtn.BackgroundTransparency = 1
	self.MinBtn.Text = "─"
	self.MinBtn.TextColor3 = self.Theme.TextDim
	self.MinBtn.TextSize = 18
	self.MinBtn.Font = self.Theme.Font
	self.MinBtn.BorderSizePixel = 0
	self.MinBtn.ZIndex = 4
	self.MinBtn.AutoButtonColor = false
	self.MinBtn.Parent = self.TitleBar

	-- Close button
	self.CloseBtn = Instance.new("TextButton")
	self.CloseBtn.Size = UDim2.new(0, 28, 0, 28)
	self.CloseBtn.Position = UDim2.new(1, -38, 0.5, -14)
	self.CloseBtn.BackgroundTransparency = 1
	self.CloseBtn.Text = "✕"
	self.CloseBtn.TextColor3 = self.Theme.Error
	self.CloseBtn.TextSize = 16
	self.CloseBtn.Font = self.Theme.Font
	self.CloseBtn.BorderSizePixel = 0
	self.CloseBtn.ZIndex = 4
	self.CloseBtn.AutoButtonColor = false
	self.CloseBtn.Parent = self.TitleBar

	-- Tab container
	self.TabContainer = Instance.new("Frame")
	self.TabContainer.Size = UDim2.new(0, 160, 1, -44)
	self.TabContainer.Position = UDim2.new(0, 0, 0, 44)
	self.TabContainer.BackgroundColor3 = self.Theme.Secondary
	self.TabContainer.BorderSizePixel = 0
	self.TabContainer.ClipsDescendants = true
	self.TabContainer.ZIndex = 1
	self.TabContainer.Parent = self.Main
	CreateRounded(self.TabContainer, self.Theme.WindowRadius)

	local tabPadding = Instance.new("UIPadding")
	tabPadding.PaddingLeft = UDim.new(0, 8)
	tabPadding.PaddingRight = UDim.new(0, 8)
	tabPadding.PaddingTop = UDim.new(0, 8)
	tabPadding.PaddingBottom = UDim.new(0, 8)
	tabPadding.Parent = self.TabContainer

	self.TabScroll = Instance.new("ScrollingFrame")
	self.TabScroll.Size = UDim2.new(1, 0, 1, 0)
	self.TabScroll.BackgroundTransparency = 1
	self.TabScroll.BorderSizePixel = 0
	self.TabScroll.ScrollBarThickness = 3
	self.TabScroll.ScrollBarImageColor3 = self.Theme.Accent
	self.TabScroll.ScrollBarImageTransparency = 0.6
	self.TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	self.TabScroll.ZIndex = 2
	self.TabScroll.Parent = self.TabContainer

	self.TabLayout = Instance.new("UIListLayout")
	self.TabLayout.Padding = UDim.new(0, 4)
	self.TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	self.TabLayout.Parent = self.TabScroll

	-- Content area
	self.Content = Instance.new("Frame")
	self.Content.Size = UDim2.new(1, -160, 1, -44)
	self.Content.Position = UDim2.new(0, 160, 0, 44)
	self.Content.BackgroundTransparency = 1
	self.Content.ZIndex = 1
	self.Content.Parent = self.Main

	local contentPadding = Instance.new("UIPadding")
	contentPadding.PaddingLeft = UDim.new(0, 12)
	contentPadding.PaddingRight = UDim.new(0, 12)
	contentPadding.PaddingTop = UDim.new(0, 12)
	contentPadding.PaddingBottom = UDim.new(0, 12)
	contentPadding.Parent = self.Content

	-- Dragging functionality
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil

	self.TitleBar.InputBegan:Connect(function(input)
		if self.Destroyed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = self.Main.Position
		end
	end)

	self.TitleBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	local dragMoveConn = UserInputService.InputChanged:Connect(function(input)
		if self.Destroyed then return end
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			self.Main.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
	table.insert(self.Connections, dragMoveConn)

	local dragEndConn = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	table.insert(self.Connections, dragEndConn)

	-- Minimize/Close button actions
	self.MinBtn.MouseButton1Click:Connect(function()
		self:ToggleMinimize()
	end)

	self.CloseBtn.MouseButton1Click:Connect(function()
		self:Destroy()
	end)

	-- Opening animation
	TweenService:Create(self.UIScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()

	TweenService:Create(self.Main, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0
	}):Play()

	return self
end

function Window:CreateTab(name)
	local tab = {
		Name = name,
		Window = self,
		Sections = {}
	}

	-- Tab button
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 36)
	btn.BackgroundTransparency = 1
	btn.Text = "  " .. name
	btn.TextColor3 = self.Theme.TextDim
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.TextSize = 14
	btn.Font = self.Theme.Font
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.ZIndex = 3
	btn.Parent = self.TabScroll
	CreateRounded(btn, 8)

	btn.MouseEnter:Connect(function()
		if self.CurrentTab and btn ~= self.CurrentTab.Button then
			TweenService:Create(btn, TweenInfo.new(0.15), {
				BackgroundTransparency = 0.9,
				BackgroundColor3 = self.Theme.Tertiary
			}):Play()
		end
	end)

	btn.MouseLeave:Connect(function()
		if self.CurrentTab and btn ~= self.CurrentTab.Button then
			TweenService:Create(btn, TweenInfo.new(0.15), {
				BackgroundTransparency = 1
			}):Play()
		end
	end)

	-- Tab content
	local content = Instance.new("ScrollingFrame")
	content.Size = UDim2.new(1, 0, 1, 0)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.ScrollBarThickness = 3
	content.ScrollBarImageColor3 = self.Theme.Accent
	content.ScrollBarImageTransparency = 0.6
	content.AutomaticCanvasSize = Enum.AutomaticSize.Y
	content.Visible = false
	content.ZIndex = 1
	content.Parent = self.Content

	local contentLayout = Instance.new("UIListLayout")
	contentLayout.Padding = UDim.new(0, 10)
	contentLayout.Parent = content

	tab.Button = btn
	tab.Content = content

	btn.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end)

	table.insert(self.Tabs, tab)

	if not self.CurrentTab then
		self:SelectTab(tab)
	end

	return tab
end

function Window:SelectTab(tab)
	if self.CurrentTab then
		self.CurrentTab.Content.Visible = false
		TweenService:Create(self.CurrentTab.Button, TweenInfo.new(0.15), {
			BackgroundTransparency = 1,
			TextColor3 = self.Theme.TextDim
		}):Play()
	end

	self.CurrentTab = tab
	tab.Content.Visible = true

	TweenService:Create(tab.Button, TweenInfo.new(0.15), {
		BackgroundTransparency = 0.2,
		BackgroundColor3 = self.Theme.Accent,
		TextColor3 = self.Theme.Text
	}):Play()
end

function Window:ToggleMinimize()
	self.Minimized = not self.Minimized
	local targetHeight = self.Minimized and 44 or self.Height

	TweenService:Create(self.Main, TweenInfo.new(0.2), {
		Size = UDim2.fromOffset(self.Width, targetHeight)
	}):Play()

	self.TabContainer.Visible = not self.Minimized
	self.Content.Visible = not self.Minimized

	for _, t in ipairs(self.Tabs) do
		t.Content.Visible = not self.Minimized and t == self.CurrentTab
	end
end

function Window:Destroy()
	if self.Destroyed then return end
	self.Destroyed = true

	-- Disconnect all connections
	for _, conn in ipairs(self.Connections) do
		if conn.Connected then
			conn:Disconnect()
		end
	end
	self.Connections = {}

	-- Remove from library table
	for i = #Library.Windows, 1, -1 do
		if Library.Windows[i] == self then
			table.remove(Library.Windows, i)
			break
		end
	end

	-- Animate out and destroy
	TweenService:Create(self.UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Scale = 0.9
	}):Play()

	TweenService:Create(self.Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		BackgroundTransparency = 1
	}):Play()

	task.wait(0.3)
	if self.ScreenGui then
		self.ScreenGui:Destroy()
	end
end

-- Section (collapsible)
function Window:CreateSection(tab, name)
	local section = {
		Name = name,
		Tab = tab,
		Window = self,
		Elements = {},
		Open = true
	}

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 0)
	frame.BackgroundColor3 = self.Theme.Secondary
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.ZIndex = 1
	frame.Parent = tab.Content
	CreateRounded(frame, 10)

	local header = Instance.new("TextButton")
	header.Size = UDim2.new(1, 0, 0, 36)
	header.BackgroundTransparency = 1
	header.Text = "  " .. name
	header.TextColor3 = self.Theme.Text
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.TextSize = 15
	header.Font = self.Theme.FontBold
	header.BorderSizePixel = 0
	header.ZIndex = 2
	header.Parent = frame

	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.new(0, 20, 1, 0)
	arrow.Position = UDim2.new(1, -20, 0, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text = "▼"
	arrow.TextColor3 = self.Theme.TextDim
	arrow.TextSize = 12
	arrow.Font = self.Theme.Font
	arrow.ZIndex = 3
	arrow.Parent = header

	local elementsFrame = Instance.new("Frame")
	elementsFrame.Size = UDim2.new(1, 0, 0, 0)
	elementsFrame.BackgroundTransparency = 1
	elementsFrame.BorderSizePixel = 0
	elementsFrame.AutomaticSize = Enum.AutomaticSize.Y
	elementsFrame.ZIndex = 1
	elementsFrame.Parent = frame

	local elList = Instance.new("UIListLayout")
	elList.Padding = UDim.new(0, 8)
	elList.Parent = elementsFrame

	local elPad = Instance.new("UIPadding")
	elPad.PaddingLeft = UDim.new(0, 8)
	elPad.PaddingRight = UDim.new(0, 8)
	elPad.PaddingTop = UDim.new(0, 8)
	elPad.PaddingBottom = UDim.new(0, 8)
	elPad.Parent = elementsFrame

	section.Frame = frame
	section.Header = header
	section.Arrow = arrow
	section.ElementsFrame = elementsFrame

	header.MouseButton1Click:Connect(function()
		section.Open = not section.Open
		elementsFrame.Visible = section.Open
		TweenService:Create(arrow, TweenInfo.new(0.2), {
			Rotation = section.Open and 0 or -90
		}):Play()
	end)

	table.insert(tab.Sections, section)
	return section
end

-- Base Element Factory
function Window:CreateElement(section, elementType, data)
	data = data or {}

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, data.Height or 38)
	frame.BackgroundColor3 = self.Theme.Tertiary
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true
	frame.AutomaticSize = data.Auto or Enum.AutomaticSize.None
	frame.ZIndex = 1
	frame.Parent = section.ElementsFrame
	CreateRounded(frame, self.Theme.ElementRadius)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 120, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = data.Name or ""
	label.TextColor3 = self.Theme.Text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextSize = self.Theme.TextSize
	label.Font = self.Theme.Font
	label.ZIndex = 2
	label.Parent = frame

	local element = {
		Frame = frame,
		Label = label,
		Type = elementType,
		Data = data,
		Section = section,
		Window = self
	}
	table.insert(section.Elements, element)
	return element
end

-- Toggle
function Window:CreateToggle(section, data)
	local el = self:CreateElement(section, "Toggle", data)
	el.Value = data.Default or false
	el.Flag = data.Flag

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(0, 54, 0, 28)
	toggle.Position = UDim2.new(1, -64, 0.5, -14)
	toggle.BackgroundColor3 = self.Theme.Tertiary
	toggle.BackgroundTransparency = 0.5
	toggle.Text = ""
	toggle.BorderSizePixel = 0
	toggle.AutoButtonColor = false
	toggle.ZIndex = 3
	toggle.Parent = el.Frame
	CreateRounded(toggle, 14)
	CreateStroke(toggle, self.Theme.BorderLight, 1)

	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0, 22, 0, 22)
	indicator.Position = UDim2.new(0, 3, 0.5, -11)
	indicator.BackgroundColor3 = self.Theme.TextDim
	indicator.BackgroundTransparency = 0.5
	indicator.BorderSizePixel = 0
	indicator.ZIndex = 4
	indicator.Parent = toggle
	CreateRounded(indicator, 11)

	local function updateToggle(value)
		el.Value = value
		local targetColor = value and self.Theme.Accent or self.Theme.Tertiary
		local targetPos = value and UDim2.new(0, 29, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
		local targetTrans = value and 0 or 0.5
		local indColor = value and Color3.fromRGB(255, 255, 255) or self.Theme.TextDim

		TweenService:Create(toggle, TweenInfo.new(0.2), {
			BackgroundColor3 = targetColor,
			BackgroundTransparency = targetTrans
		}):Play()

		TweenService:Create(indicator, TweenInfo.new(0.2), {
			Position = targetPos,
			BackgroundTransparency = value and 0.1 or 0.5,
			BackgroundColor3 = indColor
		}):Play()
	end

	toggle.MouseButton1Click:Connect(function()
		updateToggle(not el.Value)
		SafeCallback(data.Callback, el.Value)
	end)

	updateToggle(el.Value)

	el.Get = function() return el.Value end
	el.Set = function(value)
		updateToggle(value)
		SafeCallback(data.Callback, value)
	end
	el.OnChanged = function(callback)
		local old = data.Callback
		data.Callback = function(v)
			if old then old(v) end
			callback(v)
		end
	end
	return el
end

-- Slider
function Window:CreateSlider(section, data)
	local el = self:CreateElement(section, "Slider", data)
	el.Min = data.Min or 0
	el.Max = data.Max or 100
	el.Precision = data.Precision or 0
	el.Value = data.Default or el.Min
	el.Flag = data.Flag

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 50, 1, 0)
	valueLabel.Position = UDim2.new(1, -60, 0, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(el.Value)
	valueLabel.TextColor3 = self.Theme.TextDim
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.TextSize = self.Theme.TextSize
	valueLabel.Font = self.Theme.Font
	valueLabel.ZIndex = 2
	valueLabel.Parent = el.Frame

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, -200, 0, 4)
	bar.Position = UDim2.new(0, 130, 0.5, -2)
	bar.BackgroundColor3 = self.Theme.Tertiary
	bar.BorderSizePixel = 0
	bar.ZIndex = 2
	bar.Parent = el.Frame
	CreateRounded(bar, 2)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = self.Theme.Accent
	fill.BorderSizePixel = 0
	fill.ZIndex = 3
	fill.Parent = bar
	CreateRounded(fill, 2)

	local thumb = Instance.new("Frame")
	thumb.Size = UDim2.new(0, 18, 0, 18)
	thumb.Position = UDim2.new(0, -9, 0.5, -9)
	thumb.BackgroundColor3 = self.Theme.Accent
	thumb.BorderSizePixel = 0
	thumb.ZIndex = 4
	thumb.Parent = bar
	CreateRounded(thumb, 9)
	CreateStroke(thumb, Color3.fromRGB(255, 255, 255), 2)

	local function updateSlider(value)
		value = math.clamp(value, el.Min, el.Max)
		if el.Precision > 0 then
			value = math.round(value / el.Precision) * el.Precision
		end
		el.Value = value

		local percent = (value - el.Min) / (el.Max - el.Min)
		fill.Size = UDim2.new(percent, 0, 1, 0)
		thumb.Position = UDim2.new(percent, -9, 0.5, -9)
		valueLabel.Text = tostring(value)
	end

	updateSlider(el.Value)

	local dragging = false
	local function handleSliderInput(input)
		if bar.AbsoluteSize.X <= 0 then return end
		local relX = input.Position.X - bar.AbsolutePosition.X
		local percent = math.clamp(relX / bar.AbsoluteSize.X, 0, 1)
		local value = el.Min + (el.Max - el.Min) * percent
		updateSlider(value)
		SafeCallback(data.Callback, el.Value)
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			handleSliderInput(input)
		end
	end)

	thumb.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			handleSliderInput(input)
		end
	end)

	local moveConn = UserInputService.InputChanged:Connect(function(input)
		if self.Destroyed then return end
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			handleSliderInput(input)
		end
	end)
	table.insert(self.Connections, moveConn)

	local endConn = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	table.insert(self.Connections, endConn)

	el.Get = function() return el.Value end
	el.Set = function(value)
		updateSlider(value)
		SafeCallback(data.Callback, value)
	end
	el.OnChanged = function(callback)
		local old = data.Callback
		data.Callback = function(v)
			if old then old(v) end
			callback(v)
		end
	end
	return el
end

-- Button
function Window:CreateButton(section, data)
	local el = self:CreateElement(section, "Button", data)

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 110, 1, -12)
	button.Position = UDim2.new(1, -120, 0, 6)
	button.BackgroundColor3 = self.Theme.Accent
	button.Text = data.Text or "Click"
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = self.Theme.TextSize
	button.Font = self.Theme.FontBold
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.ZIndex = 3
	button.Parent = el.Frame
	CreateRounded(button, self.Theme.ElementRadius)

	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), {
			BackgroundColor3 = self.Theme.AccentHover
		}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), {
			BackgroundColor3 = self.Theme.Accent
		}):Play()
	end)

	button.MouseButton1Click:Connect(function()
		SafeCallback(data.Callback)

		-- Ripple effect
		local mousePos = UserInputService:GetMouseLocation()
		local relPos = Vector2.new(mousePos.X - button.AbsolutePosition.X, mousePos.Y - button.AbsolutePosition.Y)
		local ripple = Instance.new("Frame")
		ripple.Size = UDim2.new(0, 10, 0, 10)
		ripple.Position = UDim2.new(0, relPos.X - 5, 0, relPos.Y - 5)
		ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ripple.BackgroundTransparency = 0.8
		ripple.BorderSizePixel = 0
		ripple.ZIndex = 10
		ripple.Parent = button
		CreateRounded(ripple, 5)

		TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 60, 0, 60),
			Position = UDim2.new(0, relPos.X - 30, 0, relPos.Y - 30),
			BackgroundTransparency = 1
		}):Play()

		task.delay(0.5, function()
			if ripple and ripple.Parent then
				ripple:Destroy()
			end
		end)
	end)

	el.SetText = function(text) button.Text = text end
	el.Fire = function() SafeCallback(data.Callback) end
	return el
end

-- Textbox
function Window:CreateTextbox(section, data)
	local el = self:CreateElement(section, "Textbox", data)
	el.Value = data.Default or ""
	el.Placeholder = data.Placeholder or "Enter text..."
	el.Flag = data.Flag

	local textbox = Instance.new("TextBox")
	textbox.Size = UDim2.new(1, -140, 1, -12)
	textbox.Position = UDim2.new(0, 130, 0, 6)
	textbox.BackgroundColor3 = self.Theme.Tertiary
	textbox.BackgroundTransparency = 0.5
	textbox.Text = el.Value
	textbox.PlaceholderText = el.Placeholder
	textbox.TextColor3 = self.Theme.Text
	textbox.PlaceholderColor3 = self.Theme.TextDark
	textbox.TextSize = self.Theme.TextSize
	textbox.Font = self.Theme.Font
	textbox.TextXAlignment = Enum.TextXAlignment.Left
	textbox.BorderSizePixel = 0
	textbox.ZIndex = 3
	textbox.Parent = el.Frame
	CreateRounded(textbox, self.Theme.ElementRadius)

	local stroke = CreateStroke(textbox, self.Theme.BorderLight, 1)

	textbox.Focused:Connect(function()
		TweenService:Create(stroke, TweenInfo.new(0.15), {
			Color = self.Theme.Accent,
			Thickness = 1.5
		}):Play()
	end)

	textbox.FocusLost:Connect(function()
		TweenService:Create(stroke, TweenInfo.new(0.15), {
			Color = self.Theme.BorderLight,
			Thickness = 1
		}):Play()
		el.Value = textbox.Text
		SafeCallback(data.Callback, textbox.Text)
	end)

	textbox:GetPropertyChangedSignal("Text"):Connect(function()
		el.Value = textbox.Text
	end)

	el.Get = function() return el.Value end
	el.Set = function(value)
		textbox.Text = value
		el.Value = value
		SafeCallback(data.Callback, value)
	end
	el.OnChanged = function(callback)
		local old = data.Callback
		data.Callback = function(v)
			if old then old(v) end
			callback(v)
		end
	end
	return el
end

-- Dropdown (with search)
function Window:CreateDropdown(section, data)
	local el = self:CreateElement(section, "Dropdown", data)
	el.Options = data.Options or {}
	el.Value = data.Default or el.Options[1] or ""
	el.Open = false
	el.Flag = data.Flag

	local dropdownBtn = Instance.new("TextButton")
	dropdownBtn.Size = UDim2.new(1, -140, 1, -12)
	dropdownBtn.Position = UDim2.new(0, 130, 0, 6)
	dropdownBtn.BackgroundColor3 = self.Theme.Tertiary
	dropdownBtn.BackgroundTransparency = 0.5
	dropdownBtn.Text = el.Value
	dropdownBtn.TextColor3 = self.Theme.Text
	dropdownBtn.TextSize = self.Theme.TextSize
	dropdownBtn.Font = self.Theme.Font
	dropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
	dropdownBtn.BorderSizePixel = 0
	dropdownBtn.AutoButtonColor = false
	dropdownBtn.ZIndex = 3
	dropdownBtn.Parent = el.Frame
	CreateRounded(dropdownBtn, self.Theme.ElementRadius)
	CreateStroke(dropdownBtn, self.Theme.BorderLight, 1)

	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.new(0, 25, 1, 0)
	arrow.Position = UDim2.new(1, -30, 0, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text = "▼"
	arrow.TextColor3 = self.Theme.TextDim
	arrow.TextSize = 12
	arrow.Font = self.Theme.Font
	arrow.ZIndex = 4
	arrow.Parent = dropdownBtn

	local menu = Instance.new("Frame")
	menu.Size = UDim2.new(1, -140, 0, 0)
	menu.Position = UDim2.new(0, 130, 1, 4)
	menu.BackgroundColor3 = self.Theme.Secondary
	menu.BorderSizePixel = 0
	menu.ClipsDescendants = true
	menu.Visible = false
	menu.ZIndex = 10
	menu.Parent = el.Frame
	CreateRounded(menu, self.Theme.ElementRadius)
	CreateStroke(menu, self.Theme.Border, 1)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 3
	scroll.ScrollBarImageColor3 = self.Theme.Accent
	scroll.ScrollBarImageTransparency = 0.6
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ZIndex = 11
	scroll.Parent = menu

	Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 2)

	local searchBox = nil

	local function updateDropdown(value)
		el.Value = value
		dropdownBtn.Text = value
		for _, child in ipairs(scroll:GetChildren()) do
			if child:IsA("TextButton") then
				child.TextColor3 = child.Text == value and self.Theme.Accent or self.Theme.TextDim
			end
		end
		SafeCallback(data.Callback, value)
	end

	local function buildOptions()
		-- Clear existing
		for _, child in ipairs(scroll:GetChildren()) do
			if child:IsA("TextButton") or child:IsA("TextBox") then
				child:Destroy()
			end
		end

		local options = el.Options
		if searchBox then
			local filter = searchBox.Text:lower()
			if filter ~= "" then
				options = {}
				for _, opt in ipairs(el.Options) do
					if opt:lower():find(filter) then
						table.insert(options, opt)
					end
				end
			end
		end

		for _, option in ipairs(options) do
			local optionBtn = Instance.new("TextButton")
			optionBtn.Size = UDim2.new(1, 0, 0, 32)
			optionBtn.BackgroundTransparency = 1
			optionBtn.Text = option
			optionBtn.TextColor3 = option == el.Value and self.Theme.Accent or self.Theme.TextDim
			optionBtn.TextSize = self.Theme.TextSize
			optionBtn.Font = self.Theme.Font
			optionBtn.TextXAlignment = Enum.TextXAlignment.Left
			optionBtn.BorderSizePixel = 0
			optionBtn.AutoButtonColor = false
			optionBtn.ZIndex = 12
			optionBtn.Parent = scroll

			optionBtn.MouseButton1Click:Connect(function()
				updateDropdown(option)
				el.Open = false
				menu.Visible = false
				TweenService:Create(arrow, TweenInfo.new(0.15), {
					Rotation = 0
				}):Play()
			end)
		end

		-- Add search box if many options
		if #el.Options > 10 then
			if not searchBox then
				searchBox = Instance.new("TextBox")
				searchBox.Size = UDim2.new(1, -8, 0, 28)
				searchBox.Position = UDim2.new(0, 4, 0, 2)
				searchBox.BackgroundColor3 = self.Theme.Tertiary
				searchBox.BackgroundTransparency = 0.5
				searchBox.PlaceholderText = "Search..."
				searchBox.TextColor3 = self.Theme.Text
				searchBox.PlaceholderColor3 = self.Theme.TextDark
				searchBox.TextSize = 12
				searchBox.Font = self.Theme.Font
				searchBox.BorderSizePixel = 0
				searchBox.ZIndex = 13
				searchBox.Parent = scroll
				CreateRounded(searchBox, 6)

				searchBox:GetPropertyChangedSignal("Text"):Connect(buildOptions)
			end
		else
			if searchBox then
				searchBox:Destroy()
				searchBox = nil
			end
		end
		scroll.CanvasSize = UDim2.new(0, 0, 0, (searchBox and 34 or 0) + #options * 34)
	end

	buildOptions()

	dropdownBtn.MouseButton1Click:Connect(function()
		el.Open = not el.Open
		menu.Visible = el.Open
		if el.Open then
			buildOptions()
			menu.Size = UDim2.new(1, -140, 0, math.min(200, scroll.CanvasSize.Y.Offset))
			TweenService:Create(arrow, TweenInfo.new(0.15), {
				Rotation = 180
			}):Play()
		else
			menu.Visible = false
			TweenService:Create(arrow, TweenInfo.new(0.15), {
				Rotation = 0
			}):Play()
		end
	end)

	el.Get = function() return el.Value end
	el.Set = function(value)
		if table.find(el.Options, value) then
			updateDropdown(value)
		end
	end
	el.OnChanged = function(callback)
		local old = data.Callback
		data.Callback = function(v)
			if old then old(v) end
			callback(v)
		end
	end
	el.SetOptions = function(options)
		el.Options = options
		buildOptions()
		if not table.find(options, el.Value) then
			updateDropdown(options[1] or "")
		end
	end
	return el
end

-- Multi-Dropdown
function Window:CreateMultiDropdown(section, data)
	local el = self:CreateElement(section, "MultiDropdown", data)
	el.Options = data.Options or {}
	el.Values = data.Default or {}
	el.Open = false
	el.Flag = data.Flag

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -140, 1, -12)
	button.Position = UDim2.new(0, 130, 0, 6)
	button.BackgroundColor3 = self.Theme.Tertiary
	button.BackgroundTransparency = 0.5
	button.Text = (#el.Values == 0 and "None" or table.concat(el.Values, ", "))
	button.TextColor3 = self.Theme.Text
	button.TextSize = self.Theme.TextSize
	button.Font = self.Theme.Font
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.ZIndex = 3
	button.Parent = el.Frame
	CreateRounded(button, self.Theme.ElementRadius)
	CreateStroke(button, self.Theme.BorderLight, 1)

	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.new(0, 25, 1, 0)
	arrow.Position = UDim2.new(1, -30, 0, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text = "▼"
	arrow.TextColor3 = self.Theme.TextDim
	arrow.TextSize = 12
	arrow.Font = self.Theme.Font
	arrow.ZIndex = 4
	arrow.Parent = button

	local menu = Instance.new("Frame")
	menu.Size = UDim2.new(1, -140, 0, 0)
	menu.Position = UDim2.new(0, 130, 1, 4)
	menu.BackgroundColor3 = self.Theme.Secondary
	menu.BorderSizePixel = 0
	menu.ClipsDescendants = true
	menu.Visible = false
	menu.ZIndex = 10
	menu.Parent = el.Frame
	CreateRounded(menu, self.Theme.ElementRadius)
	CreateStroke(menu, self.Theme.Border, 1)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 3
	scroll.ScrollBarImageColor3 = self.Theme.Accent
	scroll.ScrollBarImageTransparency = 0.6
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ZIndex = 11
	scroll.Parent = menu

	Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 2)

	local function updateMultiDropdown()
		if #el.Values == 0 then
			button.Text = "None"
		else
			button.Text = table.concat(el.Values, ", ")
		end
		for _, child in ipairs(scroll:GetChildren()) do
			if child:IsA("TextButton") then
				child.TextColor3 = table.find(el.Values, child.Text) and self.Theme.Accent or self.Theme.TextDim
			end
		end
		SafeCallback(data.Callback, el.Values)
	end

	local function buildOptions()
		for _, child in ipairs(scroll:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		for _, option in ipairs(el.Options) do
			local optBtn = Instance.new("TextButton")
			optBtn.Size = UDim2.new(1, 0, 0, 32)
			optBtn.BackgroundTransparency = 1
			optBtn.Text = option
			optBtn.TextColor3 = table.find(el.Values, option) and self.Theme.Accent or self.Theme.TextDim
			optBtn.TextSize = self.Theme.TextSize
			optBtn.Font = self.Theme.Font
			optBtn.TextXAlignment = Enum.TextXAlignment.Left
			optBtn.BorderSizePixel = 0
			optBtn.AutoButtonColor = false
			optBtn.ZIndex = 12
			optBtn.Parent = scroll

			optBtn.MouseButton1Click:Connect(function()
				local idx = table.find(el.Values, option)
				if idx then
					table.remove(el.Values, idx)
				else
					table.insert(el.Values, option)
				end
				updateMultiDropdown()
			end)
		end
		scroll.CanvasSize = UDim2.new(0, 0, 0, #el.Options * 34)
	end

	buildOptions()

	button.MouseButton1Click:Connect(function()
		el.Open = not el.Open
		menu.Visible = el.Open
		if el.Open then
			menu.Size = UDim2.new(1, -140, 0, math.min(200, scroll.CanvasSize.Y.Offset))
			TweenService:Create(arrow, TweenInfo.new(0.15), { Rotation = 180 }):Play()
		else
			menu.Visible = false
			TweenService:Create(arrow, TweenInfo.new(0.15), { Rotation = 0 }):Play()
		end
	end)

	el.Get = function() return el.Values end
	el.Set = function(values)
		el.Values = values or {}
		updateMultiDropdown()
	end
	el.OnChanged = function(callback)
		local old = data.Callback
		data.Callback = function(v)
			if old then old(v) end
			callback(v)
		end
	end
	el.SetOptions = function(options)
		el.Options = options
		el.Values = {}
		buildOptions()
		updateMultiDropdown()
	end
	return el
end

-- Keybind
function Window:CreateKeybind(section, data)
	local el = self:CreateElement(section, "Keybind", data)
	el.Value = data.Default or Enum.KeyCode.E
	el.Mode = data.Mode or "Toggle"  -- Toggle, Hold, Always
	el.Holding = false
	el.Flag = data.Flag

	local keyBtn = Instance.new("TextButton")
	keyBtn.Size = UDim2.new(0, 80, 1, -12)
	keyBtn.Position = UDim2.new(1, -90, 0, 6)
	keyBtn.BackgroundColor3 = self.Theme.Tertiary
	keyBtn.BackgroundTransparency = 0.5
	keyBtn.Text = el.Value.Name
	keyBtn.TextColor3 = self.Theme.Text
	keyBtn.TextSize = self.Theme.TextSize
	keyBtn.Font = self.Theme.Font
	keyBtn.BorderSizePixel = 0
	keyBtn.AutoButtonColor = false
	keyBtn.ZIndex = 3
	keyBtn.Parent = el.Frame
	CreateRounded(keyBtn, self.Theme.ElementRadius)
	CreateStroke(keyBtn, self.Theme.BorderLight, 1)

	local listening = false
	local function setKey(key)
		if typeof(key) == "EnumItem" then
			el.Value = key
			keyBtn.Text = key.Name
		else
			el.Value = key
			keyBtn.Text = "MB1"
		end
	end

	keyBtn.MouseButton1Click:Connect(function()
		listening = true
		keyBtn.Text = "..."
		local conn
		conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then return end
			if input.UserInputType == Enum.UserInputType.Keyboard then
				setKey(input.KeyCode)
				listening = false
				conn:Disconnect()
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
				setKey(input.UserInputType)
				listening = false
				conn:Disconnect()
			end
		end)
		task.delay(10, function()
			if listening then
				listening = false
				conn:Disconnect()
				keyBtn.Text = el.Value.Name
			end
		end)
	end)

	-- Key handling
	local keyDown = false
	local keyConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or self.Destroyed then return end
		if (input.KeyCode == el.Value) or (input.UserInputType == el.Value) then
			keyDown = true
			if el.Mode == "Hold" then
				el.Holding = true
				SafeCallback(data.Callback, true)
			elseif el.Mode == "Toggle" then
				el.Holding = not el.Holding
				SafeCallback(data.Callback, el.Holding)
			end
		end
	end)
	table.insert(self.Connections, keyConn)

	local keyUpConn = UserInputService.InputEnded:Connect(function(input)
		if (input.KeyCode == el.Value) or (input.UserInputType == el.Value) then
			keyDown = false
			if el.Mode == "Hold" and el.Holding then
				el.Holding = false
				SafeCallback(data.Callback, false)
			end
		end
	end)
	table.insert(self.Connections, keyUpConn)

	el.Get = function() return el.Value end
	el.Set = function(key) setKey(key) end
	el.OnChanged = function(callback)
		local old = data.Callback
		data.Callback = function(v)
			if old then old(v) end
			callback(v)
		end
	end
	return el
end

-- ColorPicker (HSV, Alpha, Hex)
function Window:CreateColorPicker(section, data)
	local el = self:CreateElement(section, "ColorPicker", data)
	el.Value = data.Default or Color3.fromRGB(255, 255, 255)
	el.Alpha = 1
	el.Flag = data.Flag

	local preview = Instance.new("TextButton")
	preview.Size = UDim2.new(0, 40, 0, 28)
	preview.Position = UDim2.new(1, -60, 0.5, -14)
	preview.BackgroundColor3 = el.Value
	preview.Text = ""
	preview.BorderSizePixel = 0
	preview.AutoButtonColor = false
	preview.ZIndex = 3
	preview.Parent = el.Frame
	CreateRounded(preview, self.Theme.ElementRadius)
	CreateStroke(preview, self.Theme.BorderLight, 1)
	preview.BackgroundTransparency = 1 - el.Alpha

	-- Popup color picker
	local popup = Instance.new("Frame")
	popup.Size = UDim2.fromOffset(220, 260)
	popup.Position = UDim2.new(0, 0, 0, 0)
	popup.Visible = false
	popup.BackgroundColor3 = self.Theme.Secondary
	popup.BorderSizePixel = 0
	popup.ZIndex = 50
	popup.Parent = self.ScreenGui
	CreateRounded(popup, 10)
	CreateStroke(popup, self.Theme.Border, 1)

	local hsvCanvas = Instance.new("Frame")
	hsvCanvas.Size = UDim2.new(1, -20, 0, 160)
	hsvCanvas.Position = UDim2.new(0, 10, 0, 10)
	hsvCanvas.BackgroundColor3 = Color3.fromHSV(0, 1, 1)
	hsvCanvas.BorderSizePixel = 0
	hsvCanvas.ZIndex = 51
	hsvCanvas.Parent = popup
	CreateRounded(hsvCanvas, 6)

	local hueBar = Instance.new("Frame")
	hueBar.Size = UDim2.new(1, -20, 0, 16)
	hueBar.Position = UDim2.new(0, 10, 0, 180)
	hueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	hueBar.BorderSizePixel = 0
	hueBar.ZIndex = 51
	hueBar.Parent = popup
	CreateRounded(hueBar, 8)

	local alphaBar = Instance.new("Frame")
	alphaBar.Size = UDim2.new(1, -20, 0, 16)
	alphaBar.Position = UDim2.new(0, 10, 0, 205)
	alphaBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	alphaBar.BorderSizePixel = 0
	alphaBar.ZIndex = 51
	alphaBar.Parent = popup
	CreateRounded(alphaBar, 8)

	local hexInput = Instance.new("TextBox")
	hexInput.Size = UDim2.new(1, -20, 0, 24)
	hexInput.Position = UDim2.new(0, 10, 1, -30)
	hexInput.BackgroundColor3 = self.Theme.Tertiary
	hexInput.BackgroundTransparency = 0.5
	hexInput.Text = "#FFFFFF"
	hexInput.TextColor3 = self.Theme.Text
	hexInput.PlaceholderText = "#FFFFFF"
	hexInput.TextSize = 12
	hexInput.Font = self.Theme.Font
	hexInput.BorderSizePixel = 0
	hexInput.ZIndex = 52
	hexInput.Parent = popup
	CreateRounded(hexInput, 6)

	-- HSV canvas gradient
	local hsvGrad = Instance.new("UIGradient")
	hsvGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
	})
	hsvGrad.Parent = hsvCanvas

	-- Hue gradient
	local hueGrad = Instance.new("UIGradient")
	hueGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
		ColorSequenceKeypoint.new(0.166, Color3.fromHSV(0.166, 1, 1)),
		ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
		ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
		ColorSequenceKeypoint.new(0.666, Color3.fromHSV(0.666, 1, 1)),
		ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
	})
	hueGrad.Parent = hueBar

	-- Alpha gradient
	local alphaGrad = Instance.new("UIGradient")
	alphaGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
	})
	alphaGrad.Parent = alphaBar

	local draggingHue, draggingSatVal, draggingAlpha = false, false, false

	local function pickSatVal(input)
		local absPos = hsvCanvas.AbsolutePosition
		local absSize = hsvCanvas.AbsoluteSize
		local x = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
		local y = 1 - math.clamp((input.Position.Y - absPos.Y) / absSize.Y, 0, 1)
		local h, _, _ = el.Value:ToHSV()
		local c = Color3.fromHSV(h, x, y)
		el.Value = c
		preview.BackgroundColor3 = c
		preview.BackgroundTransparency = 1 - el.Alpha
		hsvCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		hexInput.Text = "#" .. Color3.toHex(c)
		SafeCallback(data.Callback, c, el.Alpha)
	end

	local function pickHue(input)
		local absPos = hueBar.AbsolutePosition
		local absSize = hueBar.AbsoluteSize
		local x = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
		local _, s, v = el.Value:ToHSV()
		local c = Color3.fromHSV(x, s, v)
		el.Value = c
		preview.BackgroundColor3 = c
		hsvCanvas.BackgroundColor3 = Color3.fromHSV(x, 1, 1)
		hexInput.Text = "#" .. Color3.toHex(c)
		SafeCallback(data.Callback, c, el.Alpha)
	end

	local function pickAlpha(input)
		local absPos = alphaBar.AbsolutePosition
		local absSize = alphaBar.AbsoluteSize
		local x = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
		el.Alpha = x
		preview.BackgroundTransparency = 1 - x
		SafeCallback(data.Callback, el.Value, x)
	end

	hsvCanvas.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSatVal = true
			pickSatVal(input)
		end
	end)
	hsvCanvas.InputEnded:Connect(function() draggingSatVal = false end)
	UserInputService.InputChanged:Connect(function(input)
		if draggingSatVal and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			pickSatVal(input)
		end
	end)

	hueBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingHue = true
			pickHue(input)
		end
	end)
	hueBar.InputEnded:Connect(function() draggingHue = false end)
	UserInputService.InputChanged:Connect(function(input)
		if draggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			pickHue(input)
		end
	end)

	alphaBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingAlpha = true
			pickAlpha(input)
		end
	end)
	alphaBar.InputEnded:Connect(function() draggingAlpha = false end)
	UserInputService.InputChanged:Connect(function(input)
		if draggingAlpha and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			pickAlpha(input)
		end
	end)

	hexInput.FocusLost:Connect(function()
		local hex = hexInput.Text:gsub("#", "")
		local success, color = pcall(Color3.fromHex, hex)
		if success then
			el.Value = color
			preview.BackgroundColor3 = color
			local h, s, v = color:ToHSV()
			hsvCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			SafeCallback(data.Callback, color, el.Alpha)
		end
	end)

	-- Open popup
	preview.MouseButton1Click:Connect(function()
		local pos = preview.AbsolutePosition
		popup.Position = UDim2.fromOffset(pos.X - 220, pos.Y + 30)
		popup.Visible = true
		local h, s, v = el.Value:ToHSV()
		hsvCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		hexInput.Text = "#" .. Color3.toHex(el.Value)
	end)

	-- Close popup when clicking outside
	local popupCloseConn = UserInputService.InputBegan:Connect(function(input)
		if popup.Visible then
			local pos = input.Position
			local abs = popup.AbsolutePosition
			local size = popup.AbsoluteSize
			if pos.X < abs.X or pos.X > abs.X + size.X or pos.Y < abs.Y or pos.Y > abs.Y + size.Y then
				popup.Visible = false
			end
		end
	end)
	table.insert(self.Connections, popupCloseConn)

	el.Get = function() return el.Value, el.Alpha end
	el.Set = function(color, alpha)
		el.Value = color
		el.Alpha = alpha or 1
		preview.BackgroundColor3 = color
		preview.BackgroundTransparency = 1 - el.Alpha
		hexInput.Text = "#" .. Color3.toHex(color)
		local h, s, v = color:ToHSV()
		hsvCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		SafeCallback(data.Callback, color, el.Alpha)
	end
	el.OnChanged = function(callback)
		local old = data.Callback
		data.Callback = function(v, a)
			if old then old(v, a) end
			callback(v, a)
		end
	end
	return el
end

-- Label, Paragraph, Divider
function Window:CreateLabel(section, data)
	local el = self:CreateElement(section, "Label", data)
	el.Frame.BackgroundTransparency = 1
	el.Frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
	el.Label.Size = UDim2.new(1, -24, 1, 0)
	el.Label.Position = UDim2.new(0, 12, 0, 0)
	el.Label.Text = data.Text or ""
	el.Label.TextColor3 = data.TextColor or self.Theme.Text
	el.Label.TextSize = data.TextSize or self.Theme.TextSize
	el.Label.Font = data.Font or self.Theme.Font
	el.SetText = function(text) el.Label.Text = text end
	return el
end

function Window:CreateParagraph(section, data)
	local el = self:CreateElement(section, "Paragraph", { Auto = Enum.AutomaticSize.Y, Height = 30 })
	el.Frame.BackgroundTransparency = 1
	el.Frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
	el.Label.Size = UDim2.new(1, -24, 0, 0)
	el.Label.Position = UDim2.new(0, 12, 0, 5)
	el.Label.Text = data.Text or ""
	el.Label.TextColor3 = data.TextColor or self.Theme.TextDim
	el.Label.TextSize = data.TextSize or 13
	el.Label.Font = data.Font or self.Theme.Font
	el.Label.TextWrapped = true
	el.Label.AutomaticSize = Enum.AutomaticSize.Y
	el.SetText = function(text) el.Label.Text = text end
	return el
end

function Window:CreateDivider(section)
	local el = self:CreateElement(section, "Divider", { Height = 24 })
	el.Frame.BackgroundTransparency = 1
	local line = Instance.new("Frame")
	line.Size = UDim2.new(1, -24, 0, 1)
	line.Position = UDim2.new(0, 12, 0.5, 0)
	line.BackgroundColor3 = self.Theme.Border
	line.BorderSizePixel = 0
	line.ZIndex = 2
	line.Parent = el.Frame
	return el
end

-- Config system
function Library:SaveConfig(fileName)
	local config = {}
	for _, window in ipairs(self.Windows) do
		for _, tab in ipairs(window.Tabs) do
			for _, section in ipairs(tab.Sections) do
				for _, element in ipairs(section.Elements) do
					if element.Flag and element.Get then
						local value = element:Get()
						if element.Type == "ColorPicker" then
							config[element.Flag] = { T = element.Type, V = { value, element.Alpha } }
						else
							config[element.Flag] = { T = element.Type, V = value }
						end
					end
				end
			end
		end
	end
	local json = HttpService:JSONEncode(config)
	if writefile then
		writefile(fileName or "redev_config.json", json)
	else
		warn("[Redev Lib] writefile not available")
	end
end

function Library:LoadConfig(fileName)
	local json
	if readfile then
		json = readfile(fileName or "redev_config.json")
	else
		warn("[Redev Lib] readfile not available")
		return
	end
	local config = HttpService:JSONDecode(json)
	for _, window in ipairs(self.Windows) do
		for _, tab in ipairs(window.Tabs) do
			for _, section in ipairs(tab.Sections) do
				for _, element in ipairs(section.Elements) do
					if element.Flag and config[element.Flag] and element.Set then
						local saved = config[element.Flag]
						if element.Type == "ColorPicker" and type(saved.V) == "table" then
							element:Set(saved.V[1], saved.V[2])
						else
							element:Set(saved.V)
						end
					end
				end
			end
		end
	end
end

-- Library API
function Library:CreateWindow(data)
	local window = Window.new(data.Title or "Redev Lib", {
		Width = data.Width or 650,
		Height = data.Height or 500,
		Theme = data.Theme or self.Theme,
	})
	table.insert(self.Windows, window)
	return window
end

function Library:SetTheme(theme)
	for key, value in pairs(theme) do
		if self.Theme[key] then
			self.Theme[key] = value
		end
	end
end

function Library:Destroy()
	for i = #self.Windows, 1, -1 do
		self.Windows[i]:Destroy()
	end
	self.Windows = {}

	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	if playerGui then
		for _, gui in ipairs(playerGui:GetChildren()) do
			if gui:IsA("ScreenGui") and (gui.Name == "RedevUI" or gui.Name == "RedevNotifications" or gui.Name == "RedevWatermark") then
				gui:Destroy()
			end
		end
	end

	if self.NotificationContainer and self.NotificationContainer.Parent then
		self.NotificationContainer.Parent:Destroy()
	end
	self.NotificationContainer = nil
	self.ActiveNotifications = {}
end

return Library
