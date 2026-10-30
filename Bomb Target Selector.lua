-- Delta Bomb Grabber GUI Menu with Auto-Nearest Mode
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local currentTarget = nil
local targetNearest = false

-- Prevent duplicate frames when executing multiple times
if CoreGui:FindFirstChild("BombGrabberMenu") then
    CoreGui.BombGrabberMenu:Destroy()
end

-- Create the GUI Elements safely inside CoreGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BombGrabberMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Main Panel
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 315)
Frame.Position = UDim2.new(0.05, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(80, 80, 90)
UIStroke.Thickness = 1
UIStroke.Parent = Frame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
Title.Text = "⚡ Bomb Target Selector"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.BorderSizePixel = 0
Title.Parent = Frame

-- Target Nearest Player Button
local NearestBtn = Instance.new("TextButton")
NearestBtn.Size = UDim2.new(0.9, 0, 0, 30)
NearestBtn.Position = UDim2.new(0.05, 0, 0.13, 0)
NearestBtn.BackgroundColor3 = Color3.fromRGB(45, 60, 45)
NearestBtn.Text = "🎯 Target Nearest Player"
NearestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NearestBtn.TextSize = 13
NearestBtn.Font = Enum.Font.SourceSansBold
NearestBtn.BorderSizePixel = 0
NearestBtn.Parent = Frame

-- Text Input Box for Typing Names (Resized to make room for Trash Can)
local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(0.72, 0, 0, 30)
TextBox.Position = UDim2.new(0.05, 0, 0.24, 0)
TextBox.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
TextBox.PlaceholderText = "Type player username..."
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextSize = 12
TextBox.Font = Enum.Font.SourceSans
TextBox.BorderSizePixel = 0
TextBox.Parent = Frame

-- Trash Can Button (Clears selection completely)
local TrashBtn = Instance.new("TextButton")
TrashBtn.Size = UDim2.new(0.15, 0, 0, 30)
TrashBtn.Position = UDim2.new(0.8, 0, 0.24, 0)
TrashBtn.BackgroundColor3 = Color3.fromRGB(80, 35, 35)
TrashBtn.Text = "🗑️"
TrashBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TrashBtn.TextSize = 14
TrashBtn.Font = Enum.Font.SourceSansBold
TrashBtn.BorderSizePixel = 0
TrashBtn.Parent = Frame

-- Scrolling List for Clicking Players
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(0.9, 0, 0, 150)
ScrollingFrame.Position = UDim2.new(0.05, 0, 0.35, 0)
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.Parent = Frame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.Parent = ScrollingFrame

-- Current Target Status Bar
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 25)
Status.Position = UDim2.new(0, 0, 0.92, 0)
Status.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
Status.Text = "Target: [ None ]"
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.TextSize = 12
Status.Font = Enum.Font.SourceSansItalic
Status.BorderSizePixel = 0
Status.Parent = Frame

local function resetUIButtons()
    NearestBtn.BackgroundColor3 = Color3.fromRGB(45, 60, 45)
    TextBox.Text = ""
end

-- Function to find the absolute closest player
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if myRoot then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestPlayer = p
                end
            end
        end
    end
    return closestPlayer
end

-- Solid Auto-Refreshing Sync Player List Loop
local function updatePlayerList()
    local savedTargetName = currentTarget and currentTarget.Name
    local activeButtons = {}

    for _, child in ipairs(ScrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then activeButtons[child.Name] = true end
    end

    local serverPopulation = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            serverPopulation[p.Name] = p
            if not activeButtons[p.Name] then
                local btn = Instance.new("TextButton")
                btn.Name = p.Name
                btn.Size = UDim2.new(1, 0, 0, 25)
                btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
                btn.Text = "👆 " .. p.DisplayName .. " (@" .. p.Name .. ")"
                btn.TextColor3 = Color3.fromRGB(230, 230, 230)
                btn.TextSize = 11
                btn.Font = Enum.Font.SourceSans
                btn.BorderSizePixel = 0
                btn.Parent = ScrollingFrame
                
                btn.MouseButton1Click:Connect(function()
                    targetNearest = false
                    currentTarget = p
                    Status.Text = "Target: " .. p.Name
                    Status.TextColor3 = Color3.fromRGB(100, 255, 100)
                    NearestBtn.BackgroundColor3 = Color3.fromRGB(45, 60, 45)
                end)
            end
        end
    end

    for _, child in ipairs(ScrollingFrame:GetChildren()) do
        if child:IsA("TextButton") and not serverPopulation[child.Name] then
            if savedTargetName == child.Name then
                currentTarget = nil
                Status.Text = "Target: [ None ]"
                Status.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            child:Destroy()
        end
    end
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

-- SOLID BACKGROUND HEARTBEAT CLOCK SCANNER
task.spawn(function()
    while true do
        updatePlayerList()
        task.wait(1.0)
    end
end)

-- Hook Auto-Nearest Button
NearestBtn.MouseButton1Click:Connect(function()
    targetNearest = true
    currentTarget = nil
    NearestBtn.BackgroundColor3 = Color3.fromRGB(45, 100, 45) -- Highlighting active state
    Status.Text = "Target: [ 🎯 Nearest Player ]"
    Status.TextColor3 = Color3.fromRGB(100, 255, 255)
end)

-- Hook Trash Can Button (Stops targeting immediately)
TrashBtn.MouseButton1Click:Connect(function()
    resetUIButtons()
    targetNearest = false
    currentTarget = nil
    Status.Text = "Target: [ None ]"
    Status.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

-- Hook Typing Box Input
TextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed or TextBox.Text ~= "" then
        local typed = string.lower(TextBox.Text)
        for _, p in ipairs(Players:GetPlayers()) do
            if string.sub(string.lower(p.Name), 1, string.len(typed)) == typed or string.sub(string.lower(p.DisplayName), 1, string.len(typed)) == typed then
                targetNearest = false
                currentTarget = p
                Status.Text = "Target: " .. p.Name
                Status.TextColor3 = Color3.fromRGB(100, 255, 100)
                NearestBtn.BackgroundColor3 = Color3.fromRGB(45, 60, 45)
                break
            end
        end
    end
end)

-- Scan Game for Bomb Holder
local function getBombHolder(activeTarget)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player ~= activeTarget then
            if player.Character:FindFirstChild("Bomb") or player.Character:FindFirstChild("TimeBomb") or player.Character:FindFirstChild("Handle") then
                return player
            end
        end
    end
    return nil
end

-- Core Farming Loop Integration
task.spawn(function()
    while true do
        task.wait(0.1)
        
        -- Resolve active target based on chosen mode
        local activeTarget = currentTarget
        if targetNearest then
            activeTarget = getClosestPlayer()
        end
        
        local bombHolder = getBombHolder(activeTarget)
        if bombHolder and activeTarget and activeTarget.Character then
            local holderRoot = bombHolder.Character:FindFirstChild("HumanoidRootPart")
            local targetRoot = activeTarget.Character:FindFirstChild("HumanoidRootPart")
            
            if holderRoot and targetRoot then
                local originalPosition = targetRoot.CFrame
                targetRoot.CFrame = holderRoot.CFrame
                task.wait()
                targetRoot.CFrame = originalPosition
                task.wait(1.5)
            end
        end
    end
end)
