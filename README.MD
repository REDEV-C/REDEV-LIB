Usage:

local Redev = loadstring(game:HttpGet("https://raw.githubusercontent.com/REDEV-C/REDEV-LIB/Lib.lua"))()

-- Create main window
local Window = Redev:CreateWindow({
    Title = "Redev Hub",
    Width = 650,
    Height = 500
})

-- Create tabs
local Main = Window:CreateTab("Main")
local Player = Window:CreateTab("Player")
local Visuals = Window:CreateTab("Visuals")

-- Button
Main:CreateButton({
    Name = "Actions",
    Text = "Print Hello",
    Callback = function()
        print("Hello from Redev Hub!")
        Redev:Notify({
            Title = "Success",
            Content = "Printed hello!",
            Type = "success"
        })
    end
})

-- Toggle
local Fly = Main:CreateToggle({
    Name = "Fly Mode",
    Default = false
})

Fly:OnChanged(function(value)
    print("Fly mode:", value)
    if value then
        Redev:Notify({
            Title = "Fly Mode",
            Content = "Fly mode enabled!",
            Type = "info"
        })
    end
end)

-- Slider
local Speed = Player:CreateSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = 16
})

Speed:OnChanged(function(value)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = value
    end
end)

-- Textbox
Player:CreateTextbox({
    Name = "Username",
    Placeholder = "Enter username...",
    Default = "Player"
})

-- Dropdown
Visuals:CreateDropdown({
    Name = "Theme",
    Options = {"Dark", "Light", "Blue", "Purple"},
    Default = "Dark"
})

-- Notifications
Redev:Notify({
    Title = "Loaded",
    Content = "Redev Hub loaded successfully!",
    Duration = 3
})
