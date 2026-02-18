local Hive = loadstring(game:HttpGet("https://raw.githubusercontent.com/utility-inc/unity-inc/main/library.lua"))()

local GUI = Hive.new("build_a_boat")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local UserInputService = game:GetService("UserInputService")

local GUIKeybind = Enum.KeyCode.RightShift

local function toggleGUI()
    GUI:Toggle()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local savedKeybind = GUI:Load("GUI Keybind_Keybind")
    if savedKeybind then
        GUIKeybind = Enum.KeyCode[savedKeybind]
    end
    
    if input.KeyCode == GUIKeybind then
        toggleGUI()
    end
end)

local InfiniteJumpConnection = nil

local function enableInfiniteJump()
    if InfiniteJumpConnection then return end
    InfiniteJumpConnection = LocalPlayer.Character.Humanoid.Jumping:Connect(function()
        LocalPlayer.Character.Humanoid.Jump = true
    end)
end

local function disableInfiniteJump()
    if InfiniteJumpConnection then
        InfiniteJumpConnection:Disconnect()
        InfiniteJumpConnection = nil
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    disableInfiniteJump()
end)

local Themes = {
    Default = {
        Background = Color3.fromRGB(25, 25, 35),
        Secondary = Color3.fromRGB(35, 35, 50),
        Accent = Color3.fromRGB(0, 120, 255),
        AccentLight = Color3.fromRGB(60, 150, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(60, 60, 80),
    },
    Green = {
        Background = Color3.fromRGB(20, 30, 25),
        Secondary = Color3.fromRGB(30, 50, 35),
        Accent = Color3.fromRGB(0, 255, 127),
        AccentLight = Color3.fromRGB(80, 255, 160),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 210, 180),
        Border = Color3.fromRGB(50, 80, 60),
    },
    Red = {
        Background = Color3.fromRGB(30, 20, 20),
        Secondary = Color3.fromRGB(45, 30, 30),
        Accent = Color3.fromRGB(255, 50, 50),
        AccentLight = Color3.fromRGB(255, 100, 100),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(210, 180, 180),
        Border = Color3.fromRGB(80, 50, 50),
    },
    Orange = {
        Background = Color3.fromRGB(30, 25, 20),
        Secondary = Color3.fromRGB(45, 35, 25),
        Accent = Color3.fromRGB(255, 140, 0),
        AccentLight = Color3.fromRGB(255, 180, 80),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(210, 200, 180),
        Border = Color3.fromRGB(80, 60, 40),
    },
}

local function applyTheme(themeName)
    local theme = Themes[themeName]
    if not theme then return end
    
    GUI.MainFrame.BackgroundColor3 = theme.Background
    GUI.TitleBar.BackgroundColor3 = theme.Secondary
    GUI.TabContainer.BackgroundColor3 = theme.Secondary
    
    print("Theme applied:", themeName)
end

-- Apply saved theme on startup
local savedTheme = GUI:Load("Theme")
if savedTheme then
    applyTheme(savedTheme)
end

-- // MAIN TAB
GUI:Tab("Main", function()
    GUI:Section("Welcome", function()
        GUI:Label("Welcome to Hive GUI example!")
    end)
end)

GUI:Tab("Settings", function()
    GUI:Section("Themes", function()
        GUI:Dropdown("Theme", {
            options = {"Default", "Green", "Red", "Orange"},
            default = "Default",
            mode = "auto",
            save = true,
        }, function(selected)
            applyTheme(selected)
        end)
    end)
    
    GUI:Section("Credits", function()
        GUI:Label("Scripted by: hive")
        GUI:Label("Library: Hive UI")
    end)
    
    GUI:Section("UI Configuration", function()
        GUI:Button("Unload Script", function()
            GUI:Destroy()
            pcall(function()
                script:Destroy()
            end)
        end)
    end)
end)

GUI:Toggle()