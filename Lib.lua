--[[
    Redev Lib
    A lightweight, modern UI library for Roblox
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Library = {}
Library.Version = "1.0.0"

-- Theme colors
Library.Theme = {
    Background = Color3.fromRGB(30, 30, 35),
    Secondary = Color3.fromRGB(40, 40, 47),
    Tertiary = Color3.fromRGB(50, 50, 58),
    Accent = Color3.fromRGB(0, 170, 255),
    AccentHover = Color3.fromRGB(30, 190, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 190),
    TextDark = Color3.fromRGB(140, 140, 150),
    Success = Color3.fromRGB(0, 255, 100),
    Warning = Color3.fromRGB(255, 170, 0),
    Error = Color3.fromRGB(255, 75, 75),
    Border = Color3.fromRGB(60, 60, 70),
}

-- Tween info
local TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Utility functions
local function CreateRounded(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
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
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Parent = instance
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.6
    shadow.BorderSizePixel = 0
    shadow.Size = UDim2.new(1, 8, 1, 8)
    shadow.Position = UDim2.new(0, -4, 0, -4)
    shadow.ZIndex = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = shadow
    
    return shadow
end

-- Notification system
local NotificationQueue = {}
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
    container.Size = UDim2.new(0, 350, 0, 0)
    container.Position = UDim2.new(1, -370, 0, 10)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = container
    layout.Padding = UDim.new(0, 8)
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
    local type = data.Type or "info" -- info, success, warning, error
    
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
    
    local corner = CreateRounded(notification, 8)
    local stroke = CreateStroke(notification, colors[type] or Library.Theme.Accent, 2)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = notification
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Library.Theme.Text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.AutomaticSize = Enum.AutomaticSize.Y
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Parent = notification
    contentLabel.Size = UDim2.new(1, -20, 0, 20)
    contentLabel.Position = UDim2.new(0, 10, 0, 35)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = Library.Theme.TextDim
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextWrapped = true
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextSize = 14
    contentLabel.AutomaticSize = Enum.AutomaticSize.Y
    contentLabel.LayoutOrder = 1
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = notification
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Library.Theme.TextDim
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.BorderSizePixel = 0
    
    closeBtn.MouseButton1Click:Connect(function()
        Library:CloseNotification(notification)
    end)
    
    -- Animate in
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.BackgroundTransparency = 1
    
    task.wait(0.1)
    
    local targetHeight = titleLabel.AbsoluteSize.Y + contentLabel.AbsoluteSize.Y + 20
    TweenService:Create(notification, TweenInfo, {
        Size = UDim2.new(1, 0, 0, targetHeight),
        BackgroundTransparency = 0
    }):Play()
    
    -- Auto close
    if duration > 0 then
        task.wait(duration)
        if notification.Parent then
            Library:CloseNotification(notification)
        end
    end
    
    return notification
end

function Library:CloseNotification(notification)
    if not notification then return end
    
    TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
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
    self.Width = properties.Width or 600
    self.Height = properties.Height or 450
    self.Theme = properties.Theme or Library.Theme
    self.Tabs = {}
    self.CurrentTab = nil
    self.Visible = true
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
    
    CreateShadow(self.Main)
    CreateRounded(self.Main, 12)
    CreateStroke(self.Main, self.Theme.Accent, 2)
    
    -- Title bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Parent = self.Main
    self.TitleBar.Size = UDim2.new(1, 0, 0, 40)
    self.TitleBar.BackgroundColor3 = self.Theme.Secondary
    self.TitleBar.BorderSizePixel = 0
    
    CreateRounded(self.TitleBar, 12)
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = self.TitleBar
    titleCorner.CornerRadius = UDim.new(0, 12)
    
    -- Title text
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Parent = self.TitleBar
    self.TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = self.Theme.Text
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextSize = 18
    
    -- Min/Max buttons
    local btnSize = UDim2.new(0, 25, 0, 25)
    
    self.MinimizeBtn = Instance.new("TextButton")
    self.MinimizeBtn.Parent = self.TitleBar
    self.MinimizeBtn.Size = btnSize
    self.MinimizeBtn.Position = UDim2.new(1, -70, 0.5, -12.5)
    self.MinimizeBtn.BackgroundTransparency = 1
    self.MinimizeBtn.Text = "─"
    self.MinimizeBtn.TextColor3 = self.Theme.TextDim
    self.MinimizeBtn.TextSize = 18
    self.MinimizeBtn.Font = Enum.Font.Gotham
    self.MinimizeBtn.BorderSizePixel = 0
    
    self.CloseBtn = Instance.new("TextButton")
    self.CloseBtn.Parent = self.TitleBar
    self.CloseBtn.Size = btnSize
    self.CloseBtn.Position = UDim2.new(1, -35, 0.5, -12.5)
    self.CloseBtn.BackgroundTransparency = 1
    self.CloseBtn.Text = "✕"
    self.CloseBtn.TextColor3 = self.Theme.Error
    self.CloseBtn.TextSize = 16
    self.CloseBtn.Font = Enum.Font.Gotham
    self.CloseBtn.BorderSizePixel = 0
    
    -- Tabs container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Parent = self.Main
    self.TabContainer.Size = UDim2.new(0, 150, 1, -40)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 40)
    self.TabContainer.BackgroundColor3 = self.Theme.Secondary
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.ClipsDescendants = true
    
    CreateRounded(self.TabContainer, 12)
    local tabCorner = Instance.new("UICorner")
    tabCorner.Parent = self.TabContainer
    tabCorner.CornerRadius = UDim.new(0, 12)
    
    -- Tab scroll frame
    self.TabScroll = Instance.new("ScrollingFrame")
    self.TabScroll.Parent = self.TabContainer
    self.TabScroll.Size = UDim2.new(1, 0, 1, 0)
    self.TabScroll.BackgroundTransparency = 1
    self.TabScroll.BorderSizePixel = 0
    self.TabScroll.ScrollBarThickness = 4
    self.TabScroll.ScrollBarImageColor3 = self.Theme.Accent
    self.TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    self.TabLayout = Instance.new("UIListLayout")
    self.TabLayout.Parent = self.TabScroll
    self.TabLayout.Padding = UDim.new(0, 2)
    self.TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Content container
    self.Content = Instance.new("Frame")
    self.Content.Parent = self.Main
    self.Content.Size = UDim2.new(1, -150, 1, -40)
    self.Content.Position = UDim2.new(0, 150, 0, 40)
    self.Content.BackgroundTransparency = 1
    
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
    
    return self
end

function Window:CreateTab(name)
    local tab = {}
    tab.Name = name
    tab.Window = self
    tab.Elements = {}
    tab.Buttons = {}
    
    -- Tab button
    local button = Instance.new("TextButton")
    button.Parent = self.TabScroll
    button.Size = UDim2.new(1, -10, 0, 35)
    button.Position = UDim2.new(0, 5, 0, 0)
    button.BackgroundTransparency = 1
    button.Text = name
    button.TextColor3 = self.Theme.TextDim
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.BorderSizePixel = 0
    
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Parent = self.Content
    tabContent.Size = UDim2.new(1, -20, 1, -20)
    tabContent.Position = UDim2.new(0, 10, 0, 10)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 4
    tabContent.ScrollBarImageColor3 = self.Theme.Accent
    tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabContent.Visible = false
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = tabContent
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    tab.Content = tabContent
    tab.Button = button
    tab.Layout = layout
    
    -- Select tab
    button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    -- Add to tabs
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
        self.CurrentTab.Button.BackgroundTransparency = 1
        self.CurrentTab.Button.TextColor3 = self.Theme.TextDim
    end
    
    self.CurrentTab = tab
    tab.Content.Visible = true
    tab.Button.BackgroundColor3 = self.Theme.Accent
    tab.Button.BackgroundTransparency = 0.2
    tab.Button.TextColor3 = self.Theme.Text
end

function Window:ToggleMinimize()
    self.Minimized = not self.Minimized
    
    local targetHeight = self.Minimized and 40 or self.Height
    local targetTransparency = self.Minimized and 1 or 0
    
    TweenService:Create(self.Main, TweenInfo, {
        Size = UDim2.fromOffset(self.Width, targetHeight),
    }):Play()
    
    -- Hide content when minimized
    for _, tab in ipairs(self.Tabs) do
        if tab.Content then
            TweenService:Create(tab.Content, TweenInfo, {
                BackgroundTransparency = targetTransparency
            }):Play()
        end
    end
    
    TweenService:Create(self.TabContainer, TweenInfo, {
        BackgroundTransparency = targetTransparency
    }):Play()
end

function Window:Destroy()
    self.ScreenGui:Destroy()
end

-- Element creation functions
function Window:CreateElement(tab, elementType, data)
    data = data or {}
    
    local frame = Instance.new("Frame")
    frame.Parent = tab.Content
    frame.Size = UDim2.new(1, 0, 0, data.Height or 35)
    frame.BackgroundColor3 = self.Theme.Secondary
    frame.BorderSizePixel = 0
    frame.AutomaticSize = data.AutomaticSize or Enum.AutomaticSize.None
    
    if data.Rounded ~= false then
        CreateRounded(frame, 6)
    end
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0, 100, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = data.Name or ""
    label.TextColor3 = self.Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    
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
    button.Size = UDim2.new(0, 100, 1, -10)
    button.Position = UDim2.new(1, -110, 0, 5)
    button.BackgroundColor3 = self.Theme.Accent
    button.Text = data.Text or "Click"
    button.TextColor3 = self.Theme.Text
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 0
    
    CreateRounded(button, 6)
    
    button.MouseButton1Click:Connect(function()
        if data.Callback then
            data.Callback()
        end
    end)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo, {
            BackgroundColor3 = self.Theme.AccentHover
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo, {
            BackgroundColor3 = self.Theme.Accent
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
    toggle.Size = UDim2.new(0, 50, 0, 26)
    toggle.Position = UDim2.new(1, -60, 0.5, -13)
    toggle.BackgroundColor3 = self.Theme.Tertiary
    toggle.BackgroundTransparency = 0.5
    toggle.Text = ""
    toggle.BorderSizePixel = 0
    
    CreateRounded(toggle, 13)
    
    local indicator = Instance.new("Frame")
    indicator.Parent = toggle
    indicator.Size = UDim2.new(0, 20, 0, 20)
    indicator.Position = UDim2.new(0, 3, 0.5, -10)
    indicator.BackgroundColor3 = self.Theme.TextDim
    indicator.BackgroundTransparency = 0.5
    indicator.BorderSizePixel = 0
    
    CreateRounded(indicator, 10)
    
    local function UpdateToggle(value)
        element.Value = value
        
        local targetColor = value and self.Theme.Accent or self.Theme.Tertiary
        local targetPos = value and UDim2.new(0, 27, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        local targetTransparency = value and 0 or 0.5
        
        TweenService:Create(toggle, TweenInfo, {
            BackgroundColor3 = targetColor,
            BackgroundTransparency = targetTransparency
        }):Play()
        
        TweenService:Create(indicator, TweenInfo, {
            Position = targetPos,
            BackgroundTransparency = value and 0.2 or 0.5
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
    valueLabel.Font = Enum.Font.Gotham
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Parent = element.Frame
    sliderFrame.Size = UDim2.new(1, -140, 0, 4)
    sliderFrame.Position = UDim2.new(0, 110, 0.5, -2)
    sliderFrame.BackgroundColor3 = self.Theme.Tertiary
    sliderFrame.BorderSizePixel = 0
    
    CreateRounded(sliderFrame, 2)
    
    local fill = Instance.new("Frame")
    fill.Parent = sliderFrame
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = self.Theme.Accent
    fill.BorderSizePixel = 0
    
    CreateRounded(fill, 2)
    
    local function UpdateSlider(value)
        value = math.clamp(value, element.Min, element.Max)
        if element.Precision > 0 then
            value = math.round(value / element.Precision) * element.Precision
        end
        element.Value = value
        
        local percent = (value - element.Min) / (element.Max - element.Min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        valueLabel.Text = tostring(value)
    end
    
    UpdateSlider(element.Value)
    
    local dragging = false
    
    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local percent = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            local value = element.Min + (element.Max - element.Min) * percent
            UpdateSlider(value)
            if data.Callback then data.Callback(element.Value) end
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            local value = element.Min + (element.Max - element.Min) * percent
            UpdateSlider(value)
            if data.Callback then data.Callback(element.Value) end
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
    textbox.Size = UDim2.new(1, -120, 1, -10)
    textbox.Position = UDim2.new(0, 110, 0, 5)
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
    
    CreateRounded(textbox, 6)
    
    textbox:GetPropertyChangedSignal("Text"):Connect(function()
        element.Value = textbox.Text
        if data.Callback then data.Callback(textbox.Text) end
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
    
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Parent = element.Frame
    dropdownBtn.Size = UDim2.new(1, -120, 1, -10)
    dropdownBtn.Position = UDim2.new(0, 110, 0, 5)
    dropdownBtn.BackgroundColor3 = self.Theme.Tertiary
    dropdownBtn.BackgroundTransparency = 0.5
    dropdownBtn.Text = element.Value
    dropdownBtn.TextColor3 = self.Theme.Text
    dropdownBtn.TextSize = 14
    dropdownBtn.Font = Enum.Font.Gotham
    dropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
    dropdownBtn.BorderSizePixel = 0
    
    CreateRounded(dropdownBtn, 6)
    
    local dropdownArrow = Instance.new("TextLabel")
    dropdownArrow.Parent = dropdownBtn
    dropdownArrow.Size = UDim2.new(0, 20, 1, 0)
    dropdownArrow.Position = UDim2.new(1, -25, 0, 0)
    dropdownArrow.BackgroundTransparency = 1
    dropdownArrow.Text = "▼"
    dropdownArrow.TextColor3 = self.Theme.TextDim
    dropdownArrow.TextSize = 12
    dropdownArrow.Font = Enum.Font.Gotham
    
    local dropdownMenu = Instance.new("Frame")
    dropdownMenu.Parent = element.Frame
    dropdownMenu.Size = UDim2.new(1, -120, 0, 0)
    dropdownMenu.Position = UDim2.new(0, 110, 1, 5)
    dropdownMenu.BackgroundColor3 = self.Theme.Secondary
    dropdownMenu.BorderSizePixel = 0
    dropdownMenu.ClipsDescendants = true
    dropdownMenu.Visible = false
    
    CreateRounded(dropdownMenu, 6)
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
        -- Clear old options
        for _, child in ipairs(dropdownMenu:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        for _, option in ipairs(element.Options) do
            local btn = Instance.new("TextButton")
            btn.Parent = dropdownMenu
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.BackgroundTransparency = 1
            btn.Text = option
            btn.TextColor3 = option == element.Value and self.Theme.Accent or self.Theme.TextDim
            btn.TextSize = 14
            btn.Font = Enum.Font.Gotham
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.BorderSizePixel = 0
            
            btn.MouseButton1Click:Connect(function()
                UpdateDropdown(option)
                dropdownMenu.Visible = false
                dropdownBtn.Text = option
            end)
        end
        
        dropdownMenu.Size = UDim2.new(1, -120, 0, #element.Options * 32)
    end
    
    BuildDropdown()
    
    dropdownBtn.MouseButton1Click:Connect(function()
        dropdownMenu.Visible = not dropdownMenu.Visible
        if dropdownMenu.Visible then
            dropdownMenu.Size = UDim2.new(1, -120, 0, 0)
            TweenService:Create(dropdownMenu, TweenInfo, {
                Size = UDim2.new(1, -120, 0, #element.Options * 32)
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
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
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
    local element = self:CreateElement(tab, "Divider", {Height = 20, Rounded = false})
    element.Frame.BackgroundTransparency = 1
    
    local line = Instance.new("Frame")
    line.Parent = element.Frame
    line.Size = UDim2.new(1, -20, 0, 1)
    line.Position = UDim2.new(0, 10, 0.5, 0)
    line.BackgroundColor3 = self.Theme.Border
    line.BorderSizePixel = 0
    
    return element
end

-- Library functions
function Library:CreateWindow(data)
    data = data or {}
    local window = Window.new(data.Title or "Redev Lib", {
        Width = data.Width or 600,
        Height = data.Height or 450,
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
