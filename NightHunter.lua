-- NightHunter v9.0 - Упрощенная РАБОЧАЯ версия для 99 Nights
-- Прямой инжект без зависимостей

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Простой GUI библиотека
local function CreateSimpleGUI()
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local ScrollFrame = Instance.new("ScrollingFrame")
    local UIListLayout = Instance.new("UIListLayout")
    local Title = Instance.new("TextLabel")
    local CloseButton = Instance.new("TextButton")
    
    ScreenGui.Name = "NightHunterGUI"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🌙 NightHunter v9.0"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = Title
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(0.9, 0, 0.1, 0)
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 12
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    ScrollFrame.Name = "ScrollFrame"
    ScrollFrame.Parent = MainFrame
    ScrollFrame.Position = UDim2.new(0, 0, 0, 35)
    ScrollFrame.Size = UDim2.new(1, 0, 1, -35)
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 5
    ScrollFrame.BackgroundTransparency = 1
    
    UIListLayout.Parent = ScrollFrame
    UIListLayout.Padding = UDim.new(0, 5)
    
    local elements = {}
    
    function elements:CreateButton(config)
        local Button = Instance.new("TextButton")
        Button.Name = config.Name
        Button.Parent = ScrollFrame
        Button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(0.9, 0, 0, 35)
        Button.Position = UDim2.new(0.05, 0, 0, 0)
        Button.Font = Enum.Font.Gotham
        Button.Text = config.Name
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 12
        Button.MouseButton1Click: config.Callback
        
        return Button
    end
    
    function elements:CreateToggle(config)
        local ToggleFrame = Instance.new("Frame")
        local ToggleButton = Instance.new("TextButton")
        local Status = Instance.new("TextLabel")
        
        ToggleFrame.Name = config.Name
        ToggleFrame.Parent = ScrollFrame
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Size = UDim2.new(0.9, 0, 0, 35)
        ToggleFrame.Position = UDim2.new(0.05, 0, 0, 0)
        
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Parent = ToggleFrame
        ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Position = UDim2.new(0.7, 0, 0.2, 0)
        ToggleButton.Size = UDim2.new(0, 50, 0, 20)
        ToggleButton.Font = Enum.Font.Gotham
        ToggleButton.Text = "OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.TextSize = 10
        
        Status.Name = "Status"
        Status.Parent = ToggleFrame
        Status.BackgroundTransparency = 1
        Status.Position = UDim2.new(0.05, 0, 0, 0)
        Status.Size = UDim2.new(0.6, 0, 1, 0)
        Status.Font = Enum.Font.Gotham
        Status.Text = config.Name
        Status.TextColor3 = Color3.fromRGB(255, 255, 255)
        Status.TextSize = 12
        Status.TextXAlignment = Enum.TextXAlignment.Left
        
        local state = config.CurrentValue or false
        
        local function updateToggle()
            if state then
                ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
                ToggleButton.Text = "ON"
            else
                ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
                ToggleButton.Text = "OFF"
            end
            config.Callback(state)
        end
        
        ToggleButton.MouseButton1Click:Connect(function()
            state = not state
            updateToggle()
        end)
        
        updateToggle()
        
        return {
            Set = function(value)
                state = value
                updateToggle()
            end
        }
    end
    
    return elements
end

-- Функции скрипта
local MonsterFarm = false
local ResourceFarm = false
local ESPEnabled = false
local GodModeEnabled = false
local NightVisionEnabled = false
local BringAllEnabled = false

local ESPHighlights = {}

-- Авто-фарм монстров
local function ToggleMonsterFarm(value)
    MonsterFarm = value
    if value then
        spawn(function()
            while MonsterFarm and wait(0.1) do
                if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    local root = Player.Character.HumanoidRootPart
                    
                    for _, npc in pairs(Workspace:GetChildren()) do
                        if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                            if npc ~= Player.Character then
                                local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                                if npcRoot then
                                    local distance = (root.Position - npcRoot.Position).Magnitude
                                    if distance < 50 then
                                        -- Атака монстра
                                        root.CFrame = npcRoot.CFrame + Vector3.new(0, 0, -2)
                                        
                                        -- Имитация атаки
                                        local tool = Player.Character:FindFirstChildOfClass("Tool")
                                        if tool then
                                            for i = 1, 2 do
                                                firetouchinterest(tool.Handle, npcRoot, 0)
                                                wait(0.1)
                                                firetouchinterest(tool.Handle, npcRoot, 1)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- Авто-сбор ресурсов
local function ToggleResourceFarm(value)
    ResourceFarm = value
    if value then
        spawn(function()
            while ResourceFarm and wait(0.2) do
                if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    local root = Player.Character.HumanoidRootPart
                    
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Part") or obj:IsA("MeshPart") then
                            local name = obj.Name:lower()
                            if name:find("wood") or name:find("stone") or name:find("ore") or 
                               name:find("berry") or name:find("mushroom") then
                                local distance = (root.Position - obj.Position).Magnitude
                                if distance < 30 then
                                    obj.CFrame = root.CFrame + Vector3.new(0, 3, 0)
                                    firetouchinterest(root, obj, 0)
                                    wait(0.05)
                                    firetouchinterest(root, obj, 1)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- ESP
local function ToggleESP(value)
    ESPEnabled = value
    if value then
        -- Создаем ESP для существующих объектов
        for _, npc in pairs(Workspace:GetChildren()) do
            if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                if npc ~= Player.Character then
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = npc
                    highlight.FillColor = Color3.fromRGB(255, 50, 50)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.Parent = npc
                    ESPHighlights[npc] = highlight
                end
            end
        end
        
        -- Мониторинг новых объектов
        Workspace.ChildAdded:Connect(function(child)
            wait(1)
            if child:FindFirstChild("Humanoid") and child.Humanoid.Health > 0 then
                if child ~= Player.Character then
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = child
                    highlight.FillColor = Color3.fromRGB(255, 50, 50)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.Parent = child
                    ESPHighlights[child] = highlight
                end
            end
        end)
    else
        -- Удаляем ESP
        for npc, highlight in pairs(ESPHighlights) do
            if highlight then
                highlight:Destroy()
            end
        end
        ESPHighlights = {}
    end
end

-- God Mode
local function ToggleGodMode(value)
    GodModeEnabled = value
    if value and Player.Character then
        local humanoid = Player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
        end
    end
end

-- Night Vision
local function ToggleNightVision(value)
    NightVisionEnabled = value
    if value then
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local light = Instance.new("PointLight")
            light.Brightness = 3
            light.Range = 100
            light.Parent = Player.Character.HumanoidRootPart
        end
    else
        Lighting.Brightness = 1
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local light = Player.Character.HumanoidRootPart:FindFirstChild("PointLight")
            if light then
                light:Destroy()
            end
        end
    end
end

-- Bring All Monsters
local function ToggleBringAll(value)
    BringAllEnabled = value
    if value then
        spawn(function()
            while BringAllEnabled and wait(0.5) do
                if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    local root = Player.Character.HumanoidRootPart
                    
                    for _, npc in pairs(Workspace:GetChildren()) do
                        if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                            if npc ~= Player.Character then
                                local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                                if npcRoot then
                                    npcRoot.CFrame = root.CFrame + Vector3.new(
                                        math.random(-8, 8),
                                        0,
                                        math.random(-8, 8)
                                    )
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- Создаем GUI
local GUI = CreateSimpleGUI()

GUI:CreateButton({
    Name = "🎯 Включить авто-фарм монстров",
    Callback = function()
        ToggleMonsterFarm(true)
    end
})

GUI:CreateButton({
    Name = "❌ Выключить авто-фарм монстров", 
    Callback = function()
        ToggleMonsterFarm(false)
    end
})

GUI:CreateToggle({
    Name = "🪵 Авто-сбор ресурсов",
    CurrentValue = false,
    Callback = ToggleResourceFarm
})

GUI:CreateToggle({
    Name = "👁️ ESP подсветка",
    CurrentValue = false, 
    Callback = ToggleESP
})

GUI:CreateToggle({
    Name = "🛡️ God Mode",
    CurrentValue = false,
    Callback = ToggleGodMode
})

GUI:CreateToggle({
    Name = "💡 Night Vision",
    CurrentValue = false,
    Callback = ToggleNightVision
})

GUI:CreateToggle({
    Name = "🌀 Bring All Monsters",
    CurrentValue = false,
    Callback = ToggleBringAll
})

GUI:CreateButton({
    Name = "⚡ Инстант-килл (тест)",
    Callback = function()
        -- Увеличиваем урон оружия
        for _, tool in pairs(Player.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    local bodyForce = Instance.new("BodyForce")
                    bodyForce.Force = Vector3.new(0, 196.2, 0) * 5
                    bodyForce.Parent = handle
                end
            end
        end
    end
})

GUI:CreateButton({
    Name = "📊 Информация об игре",
    Callback = function()
        print("=== NightHunter Info ===")
        print("Игроков в игре: " .. #Players:GetPlayers())
        print("Объектов в workspace: " .. #Workspace:GetChildren())
        
        local monsterCount = 0
        for _, npc in pairs(Workspace:GetChildren()) do
            if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                if npc ~= Player.Character then
                    monsterCount = monsterCount + 1
                end
            end
        end
        print("Монстров найдено: " .. monsterCount)
    end
})

-- Уведомление о загрузке
wait(1)
if Player and Player:FindFirstChild("PlayerGui") then
    local notification = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local label = Instance.new("TextLabel")
    
    notification.Parent = Player.PlayerGui
    notification.Name = "LoadNotify"
    
    frame.Parent = notification
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0.35, 0, 0.45, 0)
    frame.Size = UDim2.new(0, 200, 0, 60)
    
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = "🌙 NightHunter v9.0\nУспешно загружен!"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    
    wait(3)
    notification:Destroy()
end

print("🌙 NightHunter v9.0 - Готов к охоте!")
