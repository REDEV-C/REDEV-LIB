--[[
    Redev Lib v3.0 - Fixed for Roblox Lua
    A premium, lightweight UI library for Roblox
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Library = {}
Library.Version = "3.0.0"

-- Theme colors
Library.Theme = {
    Background = Color3.fromRGB(10, 10, 10),
    Secondary = Color3.fromRGB(18, 18, 18),
    Tertiary = Color3.fromRGB(26, 26, 26),
    Hover = Color3.fromRGB(35, 35, 35),
    Accent = Color3.fromRGB(0, 170, 255),
    AccentHover = Color3.fromRGB(35, 190, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(190, 190, 190),
    TextDark = Color3.fromRGB(130, 130, 130),
    Success = Color3.fromRGB(46, 204, 113),
    Warning = Color3.fromRGB(241, 196, 15),
    Error = Color3.fromRGB(231, 76, 60),
    Border = Color3.fromRGB(40, 40, 40),
    BorderLight = Color3.fromRGB(55, 55, 55),
}

local TweenInfoStandard = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TweenInfoStandardFast = TweenInfoStandard.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

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

local function CreateRipple(parent, position)
    local ripple = Instance.new("Frame")
    ripple.Parent = parent
    ripple.Size = UDim2.new(0, 10, 0, 10)
    ripple.Position = UDim2.new(0, position.X - 5, 0, position.Y - 5)
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.8
    ripple.BorderSizePixel = 0
    ripple.ZIndex = 10
    CreateRounded(ripple, 5)
    
    TweenService:Create(ripple, TweenInfoStandard.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 60, 0, 60),
        Position = UDim2.new(0, position.X - 30, 0, position.Y - 30),
        BackgroundTransparency = 1
    }):Play()
    
    task.wait(0.5)
    ripple:Destroy()
end

-- Notification system
local NotificationContainer = nil

local function CreateNotificationContainer()
    if NotificationContainer then return NotificationContainer end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RedevNotifications"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer.PlayerGui
    
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Parent = screenGui
    container.Size = UDim2.new(0, 380, 0, 0)
    container.Position = UDim2.new(1, -400, 0, 10)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = container
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    NotificationContainer = container
    return container
end

function Library:Notify(data)
    data = data or {}
    local title = data.Title or "Notification"
    local content = data.Content or ""
    local duration = data.Duration or 4
    local type = data.Type or "info"
    
    local icons = {
        info = "ℹ",
        success = "✔",
        warning = "⚠",
        error = "✖"
    }
    
    local colors = {
        info = Library.Theme.Accent,
        success = Library.Theme.Success,
        warning = Library.Theme.Warning,
        error = Library.Theme.Error
    }
    
    local container = CreateNotificationContainer()
    
    local notification = Instance.new("Frame")
    notification.Parent = container
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.BackgroundColor3 = Library.Theme.Secondary
    notification.BackgroundTransparency = 1
    notification.ClipsDescendants = true
    notification.AutomaticSize = Enum.AutomaticSize.Y
    
    CreateRounded(notification, 10)
    CreateStroke(notification, colors[type] or Library.Theme.Accent, 1.5)
    
    -- Color stripe
    local stripe = Instance.new("Frame")
    stripe.Parent = notification
    stripe.Size = UDim2.new(0, 4, 1, -2)
    stripe.Position = UDim2.new(0, 1, 0, 1)
    stripe.BackgroundColor3 = colors[type] or Library.Theme.Accent
    stripe.BorderSizePixel = 0
    CreateRounded(stripe, 2)
    
    -- Icon
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Parent = notification
    iconLabel.Size = UDim2.new(0, 30, 0, 30)
    iconLabel.Position = UDim2.new(0, 10, 0, 8)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icons[type] or "ℹ"
    iconLabel.TextColor3 = colors[type] or Library.Theme.Accent
    iconLabel.TextSize = 18
    iconLabel.Font = Enum.Font.GothamBold
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = notification
    titleLabel.Size = UDim2.new(1, -60, 0, 25)
    titleLabel.Position = UDim2.new(0, 45, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Library.Theme.Text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 15
    titleLabel.AutomaticSize = Enum.AutomaticSize.Y
    
    -- Content
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Parent = notification
    contentLabel.Size = UDim2.new(1, -55, 0, 20)
    contentLabel.Position = UDim2.new(0, 45, 0, 30)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = Library.Theme.TextDim
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextWrapped = true
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextSize = 13
    contentLabel.AutomaticSize = Enum.AutomaticSize.Y
    contentLabel.LayoutOrder = 1
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = notification
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Library.Theme.TextDark
    closeBtn.TextSize = 13
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.BorderSizePixel = 0
    
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfoStandardFast, {
            TextColor3 = Library.Theme.Text
        }):Play()
    end)
    
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfoStandardFast, {
            TextColor3 = Library.Theme.TextDark
        }):Play()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        Library:CloseNotification(notification)
    end)
    
    -- Progress bar
    local progress = Instance.new("Frame")
    progress.Parent = notification
    progress.Size = UDim2.new(1, 0, 0, 2)
    progress.Position = UDim2.new(0, 0, 1, -2)
    progress.BackgroundColor3 = colors[type] or Library.Theme.Accent
    progress.BorderSizePixel = 0
    CreateRounded(progress, 1)
    
    -- Animate in
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.BackgroundTransparency = 1
    
    task.wait(0.1)
    
    local targetHeight = titleLabel.AbsoluteSize.Y + contentLabel.AbsoluteSize.Y + 25
    TweenService:Create(notification, TweenInfoStandard, {
        Size = UDim2.new(1, 0, 0, targetHeight),
        BackgroundTransparency = 0
    }):Play()
    
    -- Animate progress bar
    if duration > 0 then
        TweenService:Create(progress, TweenInfoStandard.new(duration, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 0, 2)
        }):Play()
        
        task.wait(duration)
        if notification.Parent then
            Library:CloseNotification(notification)
        end
    end
    
    return notification
end

function Library:CloseNotification(notification)
    if not notification then return end
    
    TweenService:Create(notification, TweenInfoStandard.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    
    task.wait(0.3)
    notification:Destroy()
end

-- Window class
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
    
    -- Create GUI
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "RedevUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = Players.LocalPlayer.PlayerGui
    
    -- Main frame
    self.Main = Instance.new("Frame")
    self.Main.Parent = self.ScreenGui
    self.Main.Size = UDim2.fromOffset(self.Width, self.Height)
    self.Main.Position = UDim2.fromScale(0.5, 0.5)
    self.Main.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Main.BackgroundColor3 = self.Theme.Background
    self.Main.BorderSizePixel = 0
    self.Main.ClipsDescendants = true
    
    -- Opening animation
    self.Main.Scale = UDim2.new(0.9, 0, 0.9, 0)
    self.Main.BackgroundTransparency = 1
    
    CreateShadow(self.Main)
    CreateRounded(self.Main, 14)
    CreateStroke(self.Main, self.Theme.Border, 1)
    
    -- Title bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Parent = self.Main
    self.TitleBar.Size = UDim2.new(1, 0, 0, 44)
    self.TitleBar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    self.TitleBar.BorderSizePixel = 0
    CreateRounded(self.TitleBar, 14)
    
    -- Title bar gradient
    local gradient = Instance.new("UIGradient")
    gradient.Parent = self.TitleBar
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 14, 14)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
    })
    
    -- Title bar divider
    local divider = Instance.new("Frame")
    divider.Parent = self.TitleBar
    divider.AnchorPoint = Vector2.new(0, 1)
    divider.Position = UDim2.new(0, 0, 1, 0)
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.BackgroundColor3 = self.Theme.Border
    divider.BorderSizePixel = 0
    
    -- Title text
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Parent = self.TitleBar
    self.TitleLabel.Size = UDim2.new(1, -70, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = self.Theme.Text
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextSize = 17
    
    -- Min/Max buttons
    local btnSize = UDim2.new(0, 28, 0, 28)
    
    self.MinimizeBtn = Instance.new("TextButton")
    self.MinimizeBtn.Parent = self.TitleBar
    self.MinimizeBtn.Size = btnSize
    self.MinimizeBtn.Position = UDim2.new(1, -75, 0.5, -14)
    self.MinimizeBtn.BackgroundTransparency = 1
    self.MinimizeBtn.Text = "─"
    self.MinimizeBtn.TextColor3 = self.Theme.TextDim
    self.MinimizeBtn.TextSize = 18
    self.MinimizeBtn.Font = Enum.Font.Gotham
    self.MinimizeBtn.BorderSizePixel = 0
    
    self.MinimizeBtn.MouseEnter:Connect(function()
        TweenService:Create(self.MinimizeBtn, TweenInfoStandardFast, {
            BackgroundTransparency = 0.9
        }):Play()
    end)
    
    self.MinimizeBtn.MouseLeave:Connect(function()
        TweenService:Create(self.MinimizeBtn, TweenInfoStandardFast, {
            BackgroundTransparency = 1
        }):Play()
    end)
    
    self.CloseBtn = Instance.new("TextButton")
    self.CloseBtn.Parent = self.TitleBar
    self.CloseBtn.Size = btnSize
    self.CloseBtn.Position = UDim2.new(1, -38, 0.5, -14)
    self.CloseBtn.BackgroundTransparency = 1
    self.CloseBtn.Text = "✕"
    self.CloseBtn.TextColor3 = self.Theme.Error
    self.CloseBtn.TextSize = 16
    self.CloseBtn.Font = Enum.Font.Gotham
    self.CloseBtn.BorderSizePixel = 0
    
    self.CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(self.CloseBtn, TweenInfoStandardFast, {
            BackgroundTransparency = 0.9,
            BackgroundColor3 = self.Theme.Error
        }):Play()
        TweenService:Create(self.CloseBtn, TweenInfoStandardFast, {
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)
    
    self.CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(self.CloseBtn, TweenInfoStandardFast, {
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        TweenService:Create(self.CloseBtn, TweenInfoStandardFast, {
            TextColor3 = self.Theme.Error
        }):Play()
    end)
    
    -- Tabs container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Parent = self.Main
    self.TabContainer.Size = UDim2.new(0, 160, 1, -44)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 44)
    self.TabContainer.BackgroundColor3 = self.Theme.Secondary
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.ClipsDescendants = true
    CreateRounded(self.TabContainer, 14)
    
    -- Padding for tabs
    local padding = Instance.new("UIPadding")
    padding.Parent = self.TabContainer
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    
    -- Tab scroll frame
    self.TabScroll = Instance.new("ScrollingFrame")
    self.TabScroll.Parent = self.TabContainer
    self.TabScroll.Size = UDim2.new(1, 0, 1, 0)
    self.TabScroll.BackgroundTransparency = 1
    self.TabScroll.BorderSizePixel = 0
    self.TabScroll.ScrollBarThickness = 3
    self.TabScroll.ScrollBarImageColor3 = self.Theme.Accent
    self.TabScroll.ScrollBarImageTransparency = 0.6
    self.TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    self.TabLayout = Instance.new("UIListLayout")
    self.TabLayout.Parent = self.TabScroll
    self.TabLayout.Padding = UDim.new(0, 4)
    self.TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Content container with padding
    self.Content = Instance.new("Frame")
    self.Content.Parent = self.Main
    self.Content.Size = UDim2.new(1, -160, 1, -44)
    self.Content.Position = UDim2.new(0, 160, 0, 44)
    self.Content.BackgroundTransparency = 1
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.Parent = self.Content
    contentPadding.PaddingLeft = UDim.new(0, 16)
    contentPadding.PaddingRight = UDim.new(0, 16)
    contentPadding.PaddingTop = UDim.new(0, 16)
    contentPadding.PaddingBottom = UDim.new(0, 16)
    
    -- Dragging
    self.Dragging = false
    self.DragInput = nil
    self.DragStart = nil
    self.StartPos = nil
    
    -- Events
    self.MinimizeBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    self.CloseBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Dragging logic
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.Dragging = true
            self.DragStart = input.Position
            self.StartPos = self.Main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    self.Dragging = false
                end
            end)
        end
    end)
    
    self.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            self.DragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == self.DragInput and self.Dragging then
            local delta = input.Position - self.DragStart
            self.Main.Position = UDim2.new(
                self.StartPos.X.Scale,
                self.StartPos.X.Offset + delta.X,
                self.StartPos.Y.Scale,
                self.StartPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Opening animation
    TweenService:Create(self.Main, TweenInfoStandard.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Scale = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 0
    }):Play()
    
    return self
end

function Window:CreateTab(name)
    local tab = {}
    tab.Name = name
    tab.Window = self
    tab.Elements = {}
    
    -- Tab button
    local button = Instance.new("TextButton")
    button.Parent = self.TabScroll
    button.Size = UDim2.new(1, 0, 0, 36)
    button.BackgroundTransparency = 1
    button.Text = "  " .. name
    button.TextColor3 = self.Theme.TextDim
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.TextSize = 14
    button.Font = Enum.Font.GothamMedium
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    CreateRounded(button, 8)
    
    -- Hover effect - FIXED: Removed optional chaining
    button.MouseEnter:Connect(function()
        if self.CurrentTab and button ~= self.CurrentTab.Button then
            TweenService:Create(button, TweenInfoStandardFast, {
                BackgroundTransparency = 0.9,
                BackgroundColor3 = self.Theme.Tertiary
            }):Play()
        end
    end)
    
    button.MouseLeave:Connect(function()
        if self.CurrentTab and button ~= self.CurrentTab.Button then
            TweenService:Create(button, TweenInfoStandardFast, {
                BackgroundTransparency = 1,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        end
    end)
    
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Parent = self.Content
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 3
    tabContent.ScrollBarImageColor3 = self.Theme.Accent
    tabContent.ScrollBarImageTransparency = 0.6
    tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabContent.Visible = false
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = tabContent
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    tab.Content = tabContent
    tab.Button = button
    tab.Layout = layout
    
    -- Select tab
    button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Auto select first tab
    if not self.CurrentTab then
        self:SelectTab(tab)
    end
    
    return tab
end

function Window:SelectTab(tab)
    if self.CurrentTab then
        self.CurrentTab.Content.Visible = false
        TweenService:Create(self.CurrentTab.Button, TweenInfoStandardFast, {
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            TextColor3 = self.Theme.TextDim
        }):Play()
    end
    
    self.CurrentTab = tab
    tab.Content.Visible = true
    TweenService:Create(tab.Button, TweenInfoStandardFast, {
        BackgroundTransparency = 0.2,
        BackgroundColor3 = self.Theme.Accent,
        TextColor3 = self.Theme.Text
    }):Play()
end

function Window:ToggleMinimize()
    self.Minimized = not self.Minimized
    
    local targetHeight = self.Minimized and 44 or self.Height
    local targetTransparency = self.Minimized and 1 or 0
    
    TweenService:Create(self.Main, TweenInfoStandard, {
        Size = UDim2.fromOffset(self.Width, targetHeight),
    }):Play()
    
    for _, tab in ipairs(self.Tabs) do
        if tab.Content then
            TweenService:Create(tab.Content, TweenInfoStandard, {
                BackgroundTransparency = targetTransparency
            }):Play()
        end
    end
    
    TweenService:Create(self.TabContainer, TweenInfoStandard, {
        BackgroundTransparency = targetTransparency
    }):Play()
end

function Window:Destroy()
    TweenService:Create(self.Main, TweenInfoStandard.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Scale = UDim2.new(0.9, 0, 0.9, 0),
        BackgroundTransparency = 1
    }):Play()
    
    task.wait(0.3)
    self.ScreenGui:Destroy()
end

-- Element creation functions
function Window:CreateElement(tab, elementType, data)
    data = data or {}
    
    local frame = Instance.new("Frame")
    frame.Parent = tab.Content
    frame.Size = UDim2.new(1, 0, 0, data.Height or 38)
    frame.BackgroundColor3 = self.Theme.Secondary
    frame.BorderSizePixel = 0
    frame.AutomaticSize = data.AutomaticSize or Enum.AutomaticSize.None
    frame.ClipsDescendants = true
    
    if data.Rounded ~= false then
        CreateRounded(frame, 10)
    end
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0, 120, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = data.Name or ""
    label.TextColor3 = self.Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    
    local element = {
        Frame = frame,
        Label = label,
        Type = elementType,
        Data = data,
        Tab = tab,
        Window = self
    }
    
    table.insert(tab.Elements, element)
    
    return element
end

function Window:CreateButton(tab, data)
    local element = self:CreateElement(tab, "Button", data)
    
    local button = Instance.new("TextButton")
    button.Parent = element.Frame
    button.Size = UDim2.new(0, 110, 1, -12)
    button.Position = UDim2.new(1, -120, 0, 6)
    button.BackgroundColor3 = self.Theme.Accent
    button.Text = data.Text or "Click"
    button.TextColor3 = self.Theme.Text
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    CreateRounded(button, 8)
    
    button.MouseButton1Click:Connect(function()
        if data.Callback then
            data.Callback()
        end
        
        local mousePos = UserInputService:GetMouseLocation()
        local relativePos = button.AbsolutePosition
        CreateRipple(button, Vector2.new(mousePos.X - relativePos.X, mousePos.Y - relativePos.Y))
    end)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfoStandardFast, {
            BackgroundColor3 = self.Theme.AccentHover,
            Size = UDim2.new(0, 114, 1, -10)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfoStandardFast, {
            BackgroundColor3 = self.Theme.Accent,
            Size = UDim2.new(0, 110, 1, -12)
        }):Play()
    end)
    
    element.Button = button
    
    function element:SetText(text)
        button.Text = text
    end
    
    function element:Fire()
        if data.Callback then
            data.Callback()
        end
    end
    
    return element
end

function Window:CreateToggle(tab, data)
    local element = self:CreateElement(tab, "Toggle", data)
    element.Value = data.Default or false
    
    local toggle = Instance.new("TextButton")
    toggle.Parent = element.Frame
    toggle.Size = UDim2.new(0, 54, 0, 28)
    toggle.Position = UDim2.new(1, -64, 0.5, -14)
    toggle.BackgroundColor3 = self.Theme.Tertiary
    toggle.BackgroundTransparency = 0.5
    toggle.Text = ""
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false
    CreateRounded(toggle, 14)
    
    local indicator = Instance.new("Frame")
    indicator.Parent = toggle
    indicator.Size = UDim2.new(0, 22, 0, 22)
    indicator.Position = UDim2.new(0, 3, 0.5, -11)
    indicator.BackgroundColor3 = self.Theme.TextDim
    indicator.BackgroundTransparency = 0.5
    indicator.BorderSizePixel = 0
    CreateRounded(indicator, 11)
    
    CreateStroke(toggle, self.Theme.BorderLight, 1)
    
    local function UpdateToggle(value)
        element.Value = value
        
        local targetColor = value and self.Theme.Accent or self.Theme.Tertiary
        local targetPos = value and UDim2.new(0, 29, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
        local targetTransparency = value and 0 or 0.5
        local indicatorColor = value and Color3.fromRGB(255, 255, 255) or self.Theme.TextDim
        
        TweenService:Create(toggle, TweenInfoStandard, {
            BackgroundColor3 = targetColor,
            BackgroundTransparency = targetTransparency
        }):Play()
        
        TweenService:Create(indicator, TweenInfoStandard, {
            Position = targetPos,
            BackgroundTransparency = value and 0.1 or 0.5,
            BackgroundColor3 = indicatorColor
        }):Play()
    end
    
    toggle.MouseButton1Click:Connect(function()
        UpdateToggle(not element.Value)
        if data.Callback then
            data.Callback(element.Value)
        end
    end)
    
    UpdateToggle(element.Value)
    
    function element:Get()
        return element.Value
    end
    
    function element:Set(value)
        UpdateToggle(value)
        if data.Callback then
            data.Callback(value)
        end
    end
    
    function element:Toggle()
        self:Set(not element.Value)
    end
    
    function element:OnChanged(callback)
        local oldCallback = data.Callback
        data.Callback = function(value)
            if oldCallback then oldCallback(value) end
            callback(value)
        end
    end
    
    return element
end

function Window:CreateSlider(tab, data)
    local element = self:CreateElement(tab, "Slider", data)
    element.Value = data.Default or data.Min or 0
    element.Min = data.Min or 0
    element.Max = data.Max or 100
    element.Precision = data.Precision or 0
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = element.Frame
    valueLabel.Size = UDim2.new(0, 50, 1, 0)
    valueLabel.Position = UDim2.new(1, -60, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(element.Value)
    valueLabel.TextColor3 = self.Theme.TextDim
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamMedium
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Parent = element.Frame
    sliderFrame.Size = UDim2.new(1, -200, 0, 4)
    sliderFrame.Position = UDim2.new(0, 130, 0.5, -2)
    sliderFrame.BackgroundColor3 = self.Theme.Tertiary
    sliderFrame.BorderSizePixel = 0
    CreateRounded(sliderFrame, 2)
    
    local fill = Instance.new("Frame")
    fill.Parent = sliderFrame
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = self.Theme.Accent
    fill.BorderSizePixel = 0
    CreateRounded(fill, 2)
    
    -- Slider thumb
    local thumb = Instance.new("Frame")
    thumb.Parent = sliderFrame
    thumb.Size = UDim2.new(0, 18, 0, 18)
    thumb.Position = UDim2.new(0, -9, 0.5, -9)
    thumb.BackgroundColor3 = self.Theme.Accent
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 2
    CreateRounded(thumb, 9)
    CreateStroke(thumb, Color3.fromRGB(255, 255, 255), 2)
    
    local function UpdateSlider(value)
        value = math.clamp(value, element.Min, element.Max)
        if element.Precision > 0 then
            value = math.round(value / element.Precision) * element.Precision
        end
        element.Value = value
        
        local percent = (value - element.Min) / (element.Max - element.Min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        thumb.Position = UDim2.new(percent, -9, 0.5, -9)
        valueLabel.Text = tostring(value)
    end
    
    UpdateSlider(element.Value)
    
    local dragging = false
    
    local function HandleSliderInput(input)
        if not sliderFrame.AbsoluteSize then return end
        local relativeX = input.Position.X - sliderFrame.AbsolutePosition.X
        local percent = math.clamp(relativeX / sliderFrame.AbsoluteSize.X, 0, 1)
        local value = element.Min + (element.Max - element.Min) * percent
        UpdateSlider(value)
        if data.Callback then data.Callback(element.Value) end
    end
    
    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            HandleSliderInput(input)
        end
    end)
    
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            HandleSliderInput(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            HandleSliderInput(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    function element:Get()
        return element.Value
    end
    
    function element:Set(value)
        UpdateSlider(value)
        if data.Callback then data.Callback(element.Value) end
    end
    
    function element:OnChanged(callback)
        local oldCallback = data.Callback
        data.Callback = function(value)
            if oldCallback then oldCallback(value) end
            callback(value)
        end
    end
    
    return element
end

function Window:CreateTextbox(tab, data)
    local element = self:CreateElement(tab, "Textbox", data)
    element.Value = data.Default or ""
    element.Placeholder = data.Placeholder or "Enter text..."
    
    local textbox = Instance.new("TextBox")
    textbox.Parent = element.Frame
    textbox.Size = UDim2.new(1, -140, 1, -12)
    textbox.Position = UDim2.new(0, 130, 0, 6)
    textbox.BackgroundColor3 = self.Theme.Tertiary
    textbox.BackgroundTransparency = 0.5
    textbox.Text = element.Value
    textbox.PlaceholderText = element.Placeholder
    textbox.TextColor3 = self.Theme.Text
    textbox.PlaceholderColor3 = self.Theme.TextDark
    textbox.TextSize = 14
    textbox.Font = Enum.Font.Gotham
    textbox.TextXAlignment = Enum.TextXAlignment.Left
    textbox.BorderSizePixel = 0
    CreateRounded(textbox, 8)
    
    local stroke = CreateStroke(textbox, self.Theme.BorderLight, 1)
    
    textbox.Focused:Connect(function()
        TweenService:Create(stroke, TweenInfoStandardFast, {
            Color = self.Theme.Accent,
            Thickness = 1.5
        }):Play()
    end)
    
    textbox.FocusLost:Connect(function()
        TweenService:Create(stroke, TweenInfoStandardFast, {
            Color = self.Theme.BorderLight,
            Thickness = 1
        }):Play()
        
        element.Value = textbox.Text
        if data.Callback then data.Callback(textbox.Text) end
    end)
    
    textbox:GetPropertyChangedSignal("Text"):Connect(function()
        element.Value = textbox.Text
    end)
    
    function element:Get()
        return element.Value
    end
    
    function element:Set(value)
        textbox.Text = value
        element.Value = value
        if data.Callback then data.Callback(value) end
    end
    
    function element:OnChanged(callback)
        local oldCallback = data.Callback
        data.Callback = function(value)
            if oldCallback then oldCallback(value) end
            callback(value)
        end
    end
    
    return element
end

function Window:CreateDropdown(tab, data)
    local element = self:CreateElement(tab, "Dropdown", data)
    element.Options = data.Options or {}
    element.Value = data.Default or element.Options[1] or ""
    element.Open = false
    
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Parent = element.Frame
    dropdownBtn.Size = UDim2.new(1, -140, 1, -12)
    dropdownBtn.Position = UDim2.new(0, 130, 0, 6)
    dropdownBtn.BackgroundColor3 = self.Theme.Tertiary
    dropdownBtn.BackgroundTransparency = 0.5
    dropdownBtn.Text = element.Value
    dropdownBtn.TextColor3 = self.Theme.Text
    dropdownBtn.TextSize = 14
    dropdownBtn.Font = Enum.Font.Gotham
    dropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
    dropdownBtn.BorderSizePixel = 0
    dropdownBtn.AutoButtonColor = false
    CreateRounded(dropdownBtn, 8)
    CreateStroke(dropdownBtn, self.Theme.BorderLight, 1)
    
    local dropdownArrow = Instance.new("TextLabel")
    dropdownArrow.Parent = dropdownBtn
    dropdownArrow.Size = UDim2.new(0, 25, 1, 0)
    dropdownArrow.Position = UDim2.new(1, -30, 0, 0)
    dropdownArrow.BackgroundTransparency = 1
    dropdownArrow.Text = "▼"
    dropdownArrow.TextColor3 = self.Theme.TextDim
    dropdownArrow.TextSize = 12
    dropdownArrow.Font = Enum.Font.Gotham
    
    local dropdownMenu = Instance.new("Frame")
    dropdownMenu.Parent = element.Frame
    dropdownMenu.Size = UDim2.new(1, -140, 0, 0)
    dropdownMenu.Position = UDim2.new(0, 130, 1, 4)
    dropdownMenu.BackgroundColor3 = self.Theme.Secondary
    dropdownMenu.BorderSizePixel = 0
    dropdownMenu.ClipsDescendants = true
    dropdownMenu.Visible = false
    dropdownMenu.ZIndex = 5
    CreateRounded(dropdownMenu, 8)
    CreateStroke(dropdownMenu, self.Theme.Border, 1)
    
    local dropdownList = Instance.new("UIListLayout")
    dropdownList.Parent = dropdownMenu
    dropdownList.Padding = UDim.new(0, 2)
    
    local function UpdateDropdown(value)
        element.Value = value
        dropdownBtn.Text = value
        
        for _, child in ipairs(dropdownMenu:GetChildren()) do
            if child:IsA("TextButton") then
                child.TextColor3 = child.Text == value and self.Theme.Accent or self.Theme.TextDim
            end
        end
        
        if data.Callback then data.Callback(value) end
    end
    
    local function BuildDropdown()
        for _, child in ipairs(dropdownMenu:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        for _, option in ipairs(element.Options) do
            local btn = Instance.new("TextButton")
            btn.Parent = dropdownMenu
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.BackgroundTransparency = 1
            btn.Text = option
            btn.TextColor3 = option == element.Value and self.Theme.Accent or self.Theme.TextDim
            btn.TextSize = 14
            btn.Font = Enum.Font.Gotham
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = false
            
            btn.MouseEnter:Connect(function()
                if btn.Text ~= element.Value then
                    TweenService:Create(btn, TweenInfoStandardFast, {
                        BackgroundTransparency = 0.9,
                        BackgroundColor3 = self.Theme.Tertiary
                    }):Play()
                end
            end)
            
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfoStandardFast, {
                    BackgroundTransparency = 1,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                }):Play()
            end)
            
            btn.MouseButton1Click:Connect(function()
                UpdateDropdown(option)
                element.Open = false
                dropdownMenu.Visible = false
                TweenService:Create(dropdownArrow, TweenInfoStandardFast, {
                    Rotation = 0
                }):Play()
            end)
        end
        
        dropdownMenu.Size = UDim2.new(1, -140, 0, #element.Options * 34)
    end
    
    BuildDropdown()
    
    dropdownBtn.MouseButton1Click:Connect(function()
        element.Open = not element.Open
        dropdownMenu.Visible = element.Open
        
        if element.Open then
            dropdownMenu.Size = UDim2.new(1, -140, 0, 0)
            TweenService:Create(dropdownMenu, TweenInfoStandard, {
                Size = UDim2.new(1, -140, 0, #element.Options * 34)
            }):Play()
            TweenService:Create(dropdownArrow, TweenInfoStandardFast, {
                Rotation = 180
            }):Play()
        else
            TweenService:Create(dropdownArrow, TweenInfoStandardFast, {
                Rotation = 0
            }):Play()
        end
    end)
    
    function element:Get()
        return element.Value
    end
    
    function element:Set(value)
        if table.find(element.Options, value) then
            UpdateDropdown(value)
        end
    end
    
    function element:OnChanged(callback)
        local oldCallback = data.Callback
        data.Callback = function(value)
            if oldCallback then oldCallback(value) end
            callback(value)
        end
    end
    
    function element:SetOptions(options)
        element.Options = options
        BuildDropdown()
        if not table.find(options, element.Value) then
            UpdateDropdown(options[1] or "")
        end
    end
    
    return element
end

function Window:CreateLabel(tab, data)
    local element = self:CreateElement(tab, "Label", data)
    element.Frame.BackgroundTransparency = 1
    
    local label = element.Label
    label.Size = UDim2.new(1, -24, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Text = data.Text or ""
    label.TextColor3 = data.TextColor or self.Theme.Text
    label.TextSize = data.TextSize or 14
    label.Font = data.Font or Enum.Font.Gotham
    
    function element:SetText(text)
        label.Text = text
    end
    
    return element
end

function Window:CreateDivider(tab)
    local element = self:CreateElement(tab, "Divider", {Height = 24, Rounded = false})
    element.Frame.BackgroundTransparency = 1
    
    local line = Instance.new("Frame")
    line.Parent = element.Frame
    line.Size = UDim2.new(1, -24, 0, 1)
    line.Position = UDim2.new(0, 12, 0.5, 0)
    line.BackgroundColor3 = self.Theme.Border
    line.BorderSizePixel = 0
    
    return element
end

-- Library functions
function Library:CreateWindow(data)
    data = data or {}
    local window = Window.new(data.Title or "Redev Lib", {
        Width = data.Width or 650,
        Height = data.Height or 500,
        Theme = data.Theme or self.Theme
    })
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
    for _, gui in ipairs(Players.LocalPlayer.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name == "RedevUI" then
            gui:Destroy()
        end
    end
    if NotificationContainer then
        NotificationContainer.Parent:Destroy()
        NotificationContainer = nil
    end
end

return Library
