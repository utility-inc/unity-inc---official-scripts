local Hive = loadstring(game:HttpGet("https://raw.githubusercontent.com/utility-inc/unity-inc/main/library.lua"))()

local GUI = Hive.new("build_a_raft")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

-- Fly Variables
local flying = false
local flySpeed = 50
local bodyGyro, bodyVelocity
local flyConnection
local directions = {
    Forward = false, Backward = false, Left = false, Right = false, Up = false, Down = false
}

-- NoClip Variables
local noclip = false
local noclipConnection

-- WalkSpeed Variables
local currentWalkSpeed = 16

-- Infinite Jump Variables
local canInfJump = false
local infJumpConnection

-- Auto Win Variables
local autoWin = false
local autoWinConnection

-- Nametag Variables
local nametagEnabled = false
local nametagRadius = 2750
local nametagFolder = Instance.new("Folder")
nametagFolder.Name = "Nametags"
nametagFolder.Parent = workspace
local playerNametags = {}

-- Fly Functions
local function getDirectionVector()
    local cam = workspace.CurrentCamera
    local moveVector = Vector3.new()
    if directions.Forward then moveVector = moveVector + cam.CFrame.LookVector end
    if directions.Backward then moveVector = moveVector - cam.CFrame.LookVector end
    if directions.Right then moveVector = moveVector + cam.CFrame.RightVector end
    if directions.Left then moveVector = moveVector - cam.CFrame.RightVector end
    if directions.Up then moveVector = moveVector + cam.CFrame.UpVector end
    if directions.Down then moveVector = moveVector - cam.CFrame.UpVector end
    return moveVector.Magnitude > 0 and moveVector.Unit * flySpeed or Vector3.new()
end

local function startFly()
    flying = true
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    bodyGyro = Instance.new("BodyGyro", hrp)
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = hrp.CFrame
    bodyVelocity = Instance.new("BodyVelocity", hrp)
    bodyVelocity.Velocity = Vector3.new()
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyConnection = RunService.RenderStepped:Connect(function()
        if flying then
            bodyGyro.CFrame = workspace.CurrentCamera.CFrame
            bodyVelocity.Velocity = getDirectionVector()
        end
    end)
end

local function stopFly()
    flying = false
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    for k in pairs(directions) do directions[k] = false end
end

-- Input handlers for fly
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not flying then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then directions.Forward = true end
    if key == Enum.KeyCode.S then directions.Backward = true end
    if key == Enum.KeyCode.A then directions.Left = true end
    if key == Enum.KeyCode.D then directions.Right = true end
    if key == Enum.KeyCode.Space then directions.Up = true end
    if key == Enum.KeyCode.LeftControl then directions.Down = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if not flying then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then directions.Forward = false end
    if key == Enum.KeyCode.S then directions.Backward = false end
    if key == Enum.KeyCode.A then directions.Left = false end
    if key == Enum.KeyCode.D then directions.Right = false end
    if key == Enum.KeyCode.Space then directions.Up = false end
    if key == Enum.KeyCode.LeftControl then directions.Down = false end
end)

-- WalkSpeed Loop
task.spawn(function()
    while true do
        task.wait(0.01)
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = currentWalkSpeed
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if canInfJump then
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildWhichIsA("Humanoid")
            if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Win Functions
local function touchCheckpoint(part)
    if part and part:IsA("BasePart") then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            pcall(function()
                firetouchinterest(root, part, 0)
                firetouchinterest(root, part, 1)
            end)
        end
    end
end

local function winOnce()
    local checkpoints = workspace:FindFirstChild("Checkpoints")
    if not checkpoints then return end
    
    local parts = {
        checkpoints:GetChildren()[7],
        checkpoints:FindFirstChild("Checkpoint"),
        checkpoints:GetChildren()[4],
        checkpoints:GetChildren()[2],
        checkpoints:GetChildren()[5],
        checkpoints:GetChildren()[6],
        checkpoints:GetChildren()[3],
        workspace:FindFirstChild("resetBlock")
    }
    
    for _, part in ipairs(parts) do
        if part then
            touchCheckpoint(part)
            task.wait(0)
        end
    end
end

local function runAutoWin()
    while autoWin do
        winOnce()
        task.wait(0)
    end
end

-- Nametag Functions
local function createNametag(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NametagGui"
    billboard.Adornee = player.Character.HumanoidRootPart
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = nametagFolder

    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Text = player.Name
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextScaled = true
    textLabel.Parent = billboard

    return billboard
end

local function updateNametags()
    if not nametagEnabled then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local localHRP = LocalPlayer.Character.HumanoidRootPart

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local distance = (char.HumanoidRootPart.Position - localHRP.Position).Magnitude
                if distance <= nametagRadius then
                    if not playerNametags[plr] then
                        playerNametags[plr] = createNametag(plr)
                    end
                    if playerNametags[plr] then
                        playerNametags[plr].Enabled = true
                        playerNametags[plr].Adornee = plr.Character.HumanoidRootPart
                    end
                else
                    if playerNametags[plr] then
                        playerNametags[plr].Enabled = false
                    end
                end
            elseif playerNametags[plr] then
                playerNametags[plr]:Destroy()
                playerNametags[plr] = nil
            end
        end
    end
end

local function clearNametags()
    for _, gui in pairs(playerNametags) do
        if gui then gui:Destroy() end
    end
    playerNametags = {}
end

-- Nametag update loop
RunService.RenderStepped:Connect(updateNametags)

Players.PlayerRemoving:Connect(function(player)
    if playerNametags[player] then
        playerNametags[player]:Destroy()
        playerNametags[player] = nil
    end
end)

-- UI
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
}

-- // MAIN TAB
GUI:Tab("Main", function()
    GUI:Section("Game", function()
        GUI:Button("Win", function()
            winOnce()
        end)
        
        GUI:Button("Toggle Auto Win: OFF", function(btn)
            autoWin = not autoWin
            if autoWin then
                btn.Text = "Toggle Auto Win: ON"
                task.spawn(runAutoWin)
            else
                btn.Text = "Toggle Auto Win: OFF"
            end
        end)
        
        GUI:Button("Remove Damage", function()
            local damageRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("TakeDamage")
            if damageRemote then
                damageRemote:Destroy()
                GUI:Notify("Success", "TakeDamage Disabled")
            else
                GUI:Notify("Error", "Already disabled or not found")
            end
        end)
    end)
end)

-- // MISC TAB
GUI:Tab("Misc", function()
    GUI:Section("Movement", function()
        GUI:Button("Toggle Fly: OFF", function(btn)
            flying = not flying
            if flying then
                btn.Text = "Toggle Fly: ON"
                startFly()
            else
                btn.Text = "Toggle Fly: OFF"
                stopFly()
            end
        end)
        
        GUI:Slider("Fly Speed", {
            min = 50,
            max = 700,
            default = 50,
            save = false,
        }, function(value)
            flySpeed = value
        end)
        
        GUI:Button("Toggle NoClip: OFF", function(btn)
            noclip = not noclip
            if noclip then
                btn.Text = "Toggle NoClip: ON"
                noclipConnection = RunService.Stepped:Connect(function()
                    local char = LocalPlayer.Character
                    if char then
                        for _, v in pairs(char:GetDescendants()) do
                            if v:IsA("BasePart") then v.CanCollide = false end
                        end
                    end
                end)
            else
                btn.Text = "Toggle NoClip: OFF"
                if noclipConnection then
                    noclipConnection:Disconnect()
                    noclipConnection = nil
                end
            end
        end)
        
        GUI:Slider("WalkSpeed", {
            min = 16,
            max = 99,
            default = 16,
            save = false,
        }, function(value)
            currentWalkSpeed = value
        end)
        
        GUI:Button("Toggle Infinite Jump: OFF", function(btn)
            canInfJump = not canInfJump
            if canInfJump then
                btn.Text = "Toggle Infinite Jump: ON"
            else
                btn.Text = "Toggle Infinite Jump: OFF"
            end
        end)
    end)
    
    GUI:Section("Player Teleport", function()
        local playerNames = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(playerNames, player.Name)
            end
        end
        if #playerNames == 0 then
            playerNames = {"No players found"}
        end
        
        local selectedPlayer = playerNames[1]
        
        GUI:Dropdown("Select Player", {
            options = playerNames,
            default = selectedPlayer,
            mode = "auto",
            save = false,
        }, function(selection)
            selectedPlayer = selection
        end)
        
        GUI:Button("Teleport to Player", function()
            if selectedPlayer == "No players found" then
                GUI:Notify("Error", "No valid target player selected")
                return
            end
            
            local targetPlayer = Players:FindFirstChild(selectedPlayer)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                    GUI:Notify("Success", "Teleported to " .. selectedPlayer)
                else
                    GUI:Notify("Error", "Your character not found")
                end
            else
                GUI:Notify("Error", "Target player not found")
            end
        end)
    end)
end)

-- // VISUAL TAB
GUI:Tab("Visual", function()
    GUI:Section("ESP", function()
        GUI:Button("Toggle Nametags: OFF", function(btn)
            nametagEnabled = not nametagEnabled
            if nametagEnabled then
                btn.Text = "Toggle Nametags: ON"
                -- Create nametags for existing players
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        if playerNametags[player] then playerNametags[player]:Destroy() end
                        playerNametags[player] = createNametag(player)
                    end
                end
            else
                btn.Text = "Toggle Nametags: OFF"
                clearNametags()
            end
        end)
        
        GUI:Slider("Nametag Radius", {
            min = 50,
            max = 10000,
            default = 2750,
            save = false,
        }, function(value)
            nametagRadius = value
        end)
    end)
end)

-- // SETTINGS TAB
GUI:Tab("Settings", function()
    GUI:Section("UI Configuration", function()
        GUI:Button("Unload Script", function()
            -- Cleanup
            stopFly()
            if noclipConnection then noclipConnection:Disconnect() end
            autoWin = false
            nametagEnabled = false
            clearNametags()
            nametagFolder:Destroy()
            
            GUI:Destroy()
            pcall(function()
                script:Destroy()
            end)
        end)
    end)
    
    GUI:Section("Credits", function()
        GUI:Label("Scripted by: hive")
        GUI:Label("Original by: Breif")
        GUI:Label("Library: Hive UI")
    end)
end)

GUI:Toggle()
