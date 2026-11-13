--[[
    NXT | made by Waleed
    ESP, Speed, Noclip, Fly, Invisibility, Aimbot
]]

-- GUI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("NXT | made by Waleed", "DarkTheme")

-- Main Tab
local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Movement & Visuals")
local CombatSection = MainTab:NewSection("Combat")

-- ESP Toggle
local ESPEnabled = false
local ESPBoxes = {}

local function CreateESP(player)
    if player == game.Players.LocalPlayer then return end
    
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 6, 4)
    box.Adornee = player.Character
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Transparency = 0.5
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.Parent = player.Character
    
    local nameTag = Instance.new("BillboardGui")
    nameTag.Name = "ESPName"
    nameTag.Size = UDim2.new(0, 200, 0, 50)
    nameTag.StudsOffset = Vector3.new(0, 3.5, 0)
    nameTag.AlwaysOnTop = true
    nameTag.Parent = player.Character
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = player.Name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = nameTag
    
    ESPBoxes[player] = {box, nameTag}
end

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if ESPEnabled then
            CreateESP(player)
        end
    end)
end)

MainSection:NewToggle("ESP Players", "Show player boxes", function(state)
    ESPEnabled = state
    if state then
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player.Character then
                CreateESP(player)
            end
        end
    else
        for _, esp in pairs(ESPBoxes) do
            esp[1]:Destroy()
            esp[2]:Destroy()
        end
        ESPBoxes = {}
    end
end)

-- Speed Slider
local speedValue = 16
MainSection:NewSlider("Speed", "Walk speed", 16, 100, function(value)
    speedValue = value
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

-- Noclip Toggle
local noclipEnabled = false
MainSection:NewToggle("Noclip", "Walk through walls", function(state)
    noclipEnabled = state
    if state then
        game:GetService("RunService").Stepped:Connect(function()
            if noclipEnabled then
                for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end)

-- Fly Toggle
local flyEnabled = false
local flySpeed = 50

MainSection:NewToggle("Fly", "Fly around", function(state)
    flyEnabled = state
    if state then
        local char = game.Players.LocalPlayer.Character
        local humanoid = char:WaitForChild("Humanoid")
        humanoid.PlatformStand = true
        
        game:GetService("RunService").RenderStepped:Connect(function()
            if flyEnabled then
                local camera = workspace.CurrentCamera
                local moveDirection = Vector3.new()
                
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + camera.CFrame.LookVector
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - camera.CFrame.LookVector
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - camera.CFrame.RightVector
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + camera.CFrame.RightVector
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end
                
                if moveDirection.Magnitude > 0 then
                    char:SetPrimaryPartCFrame(char.PrimaryPart.CFrame + moveDirection.Unit * flySpeed * 0.1)
                end
            else
                humanoid.PlatformStand = false
            end
        end)
    end
end)

-- Fly Speed Slider
MainSection:NewSlider("Fly Speed", "Fly movement speed", 10, 200, function(value)
    flySpeed = value
end)

-- Invisibility Toggle
local invisEnabled = false
MainSection:NewToggle("Invisibility", "Become invisible", function(state)
    invisEnabled = state
    local char = game.Players.LocalPlayer.Character
    
    if state then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 1
            end
        end
        char.Humanoid:FindFirstChild("Health"):WaitForChild("BillboardGui").Enabled = false
    else
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 0
            end
        end
        char.Humanoid:FindFirstChild("Health"):WaitForChild("BillboardGui").Enabled = true
    end
end)

-- Aimbot System
local aimbotEnabled = false
local currentTarget = nil
local targetIndex = 1

local function GetAlivePlayers()
    local players = {}
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            table.insert(players, player)
        end
    end
    return players
end

local function FindClosestPlayer()
    local localChar = game.Players.LocalPlayer.Character
    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end
    
    local closestDist = math.huge
    local closestPlayer = nil
    
    for _, player in ipairs(GetAlivePlayers()) do
        local char = player.Character
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local dist = (root.Position - localRoot.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestPlayer = player
            end
        end
    end
    return closestPlayer
end

-- Aimbot Button (cycles through players)
CombatSection:NewButton("Aimbot (Click to switch target)", "Targets nearest player, click again to switch", function()
    if not aimbotEnabled then
        aimbotEnabled = true
        currentTarget = FindClosestPlayer()
        if currentTarget then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Aimbot",
                Text = "Targeting: " .. currentTarget.Name,
                Duration = 3
            })
        end
    else
        -- Switch to next player
        local players = GetAlivePlayers()
        if #players > 0 then
            targetIndex = targetIndex + 1
            if targetIndex > #players then targetIndex = 1 end
            currentTarget = players[targetIndex]
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Aimbot",
                Text = "Switched to: " .. currentTarget.Name,
                Duration = 3
            })
        end
    end
end)

-- Aimbot Toggle (enable/disable)
CombatSection:NewToggle("Aimbot Enabled", "Toggle aimbot on/off", function(state)
    aimbotEnabled = state
    if not state then
        currentTarget = nil
    else
        currentTarget = FindClosestPlayer()
        if currentTarget then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Aimbot",
                Text = "Targeting: " .. currentTarget.Name,
                Duration = 3
            })
        end
    end
end)

-- Aimbot Connection
game:GetService("RunService").RenderStepped:Connect(function()
    if aimbotEnabled and currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
        local localChar = game.Players.LocalPlayer.Character
        local camera = workspace.CurrentCamera
        local targetPos = currentTarget.Character.HumanoidRootPart.Position + Vector3.new(0, 2, 0) -- Head level
        
        -- Smooth aim
        local currentLook = camera.CFrame.LookVector
        local targetLook = (targetPos - camera.CFrame.Position).Unit
        local smoothedLook = currentLook:Lerp(targetLook, 0.3)
        
        camera.CFrame = CFrame.lookAt(camera.CFrame.Position, camera.CFrame.Position + smoothedLook)
    end
end)

-- Custom Black Circle Button
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local CircleButton = Instance.new("TextButton")
CircleButton.Size = UDim2.new(0, 60, 0, 60)
CircleButton.Position = UDim2.new(0, 20, 0, 20)
CircleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CircleButton.BackgroundTransparency = 0.3
CircleButton.Text = "NXT"
CircleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CircleButton.TextScaled = true
CircleButton.Font = Enum.Font.GothamBold
CircleButton.Parent = ScreenGui

-- Make it circular
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = CircleButton

-- Labels on top
local Label1 = Instance.new("TextLabel")
Label1.Size = UDim2.new(0, 200, 0, 30)
Label1.Position = UDim2.new(0.5, -100, 0, -40)
Label1.BackgroundTransparency = 1
Label1.Text = "hi عراب hi m7m"
Label1.TextColor3 = Color3.fromRGB(255, 255, 255)
Label1.TextScaled = true
Label1.Font = Enum.Font.GothamBold
Label1.Parent = CircleButton

local Label2 = Instance.new("TextLabel")
Label2.Size = UDim2.new(0, 250, 0, 30)
Label2.Position = UDim2.new(0.5, -125, 0, 65)
Label2.BackgroundTransparency = 1
Label2.Text = "(مو قلت اني خطير؟)"
Label2.TextColor3 = Color3.fromRGB(255, 255, 255)
Label2.TextScaled = true
Label2.Font = Enum.Font.GothamBold
Label2.Parent = CircleButton

-- Toggle GUI on click
local isOpen = true
CircleButton.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    Window:Toggle()
end)

-- Credits
local CreditTab = Window:NewTab("Credits")
local CreditSection = CreditTab:NewSection("NXT | made by Waleed")
CreditSection:NewLabel("Script by Waleed")
CreditSection:NewLabel("Enjoy!")
