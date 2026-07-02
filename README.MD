# REDEV-LIB

A simple and modern Roblox UI library for creating windows, tabs, buttons, toggles, sliders, dropdowns, textboxes, and notifications.

## Installation

```lua
local Redev = loadstring(game:HttpGet("https://raw.githubusercontent.com/REDEV-C/REDEV-LIB/main/Lib.lua"))()
```

## Basic Example

```lua
local Redev = loadstring(game:HttpGet("https://raw.githubusercontent.com/REDEV-C/REDEV-LIB/main/Lib.lua"))()

-- Create the main window
local Window = Redev:CreateWindow({
    Title = "Redev Hub",
    Width = 650,
    Height = 500
})

-- Create tabs
local Main = Window:CreateTab("Main")
local Player = Window:CreateTab("Player")
local Visuals = Window:CreateTab("Visuals")

-- Create a button
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

-- Create a toggle
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

-- Create a slider
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

-- Create a textbox
Player:CreateTextbox({
    Name = "Username",
    Placeholder = "Enter username...",
    Default = "Player"
})

-- Create a dropdown
Visuals:CreateDropdown({
    Name = "Theme",
    Options = {
        "Dark",
        "Light",
        "Blue",
        "Purple"
    },
    Default = "Dark"
})

-- Show a notification
Redev:Notify({
    Title = "Loaded",
    Content = "Redev Hub loaded successfully!",
    Duration = 3
})
```

---

## Features

- 🪟 Custom Windows
- 📑 Multiple Tabs
- 🔘 Buttons
- ✅ Toggles
- 🎚️ Sliders
- 📝 Textboxes
- 📋 Dropdown Menus
- 🔔 Notifications
- 🎨 Custom Themes *(coming soon)*

## Components

### Window

```lua
local Window = Redev:CreateWindow({
    Title = "My UI",
    Width = 650,
    Height = 500
})
```

### Tab

```lua
local Main = Window:CreateTab("Main")
```

### Button

```lua
Main:CreateButton({
    Name = "Example",
    Text = "Click Me",
    Callback = function()
        print("Button clicked!")
    end
})
```

### Toggle

```lua
local Toggle = Main:CreateToggle({
    Name = "Example Toggle",
    Default = false
})

Toggle:OnChanged(function(value)
    print(value)
end)
```

### Slider

```lua
local Slider = Main:CreateSlider({
    Name = "Speed",
    Min = 0,
    Max = 100,
    Default = 50
})

Slider:OnChanged(function(value)
    print(value)
end)
```

### Textbox

```lua
Main:CreateTextbox({
    Name = "Username",
    Placeholder = "Type here...",
    Default = ""
})
```

### Dropdown

```lua
Main:CreateDropdown({
    Name = "Theme",
    Options = {"Dark", "Light"},
    Default = "Dark"
})
```

### Notification

```lua
Redev:Notify({
    Title = "Success",
    Content = "Everything worked!",
    Type = "success",
    Duration = 3
})
```

## License

This project is licensed under the MIT License.

---

Made with ❤️ by **REDEV-C**
