-- NIGHTS DOMINATOR ULTIMATE v7.0
-- Полностью автономный рабочий скрипт

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Удаляем старые GUI чтобы не было конфликтов
for _, gui in pairs(CoreGui:GetChildren()) do
    if gui.Name == "NightsDominator" or gui.Name == "Vape" or gui.Name:find("Dominator") then
        gui:Destroy()
    end
end

-- ОСНОВНЫЕ ПЕРЕМЕННЫЕ
local Dominator = {
    Enabled = {
        BringAll = false,
        InstantKill = false,
        AutoFarm = false,
        Fly = false,
        ESP = false,
        GodMode = false,
        Speed = false,
        Noclip = false
    },
    Connections = {},
    Highlights = {}
}

-- ПРОСТОЙ И НАДЕЖНЫЙ GUI
local function CreateDominatorGUI()
    -- Удаляем старые GUI
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui.Name == "NightsDominator" then
            gui:Destroy()
        end
    end

    local DominatorGUI = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local TopBar = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local CloseBtn = Instance.new("TextButton")
    local TabButtons = Instance.new("Frame")
    local ContentFrame = Instance.new("ScrollingFrame")
    local UIListLayout = Instance.new("UIListLayout")

    DominatorGUI.Name = "NightsDominator"
    DominatorGUI.Parent = CoreGui
    DominatorGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    DominatorGUI.ResetOnSpawn = false

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = DominatorGUI
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.BorderSizePixel = 1
    MainFrame.BorderColor3 = Color3.fromRGB(50, 50, 60)
    MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
    MainFrame.Size = UDim2.new(0, 450, 0, 500)
    MainFrame.Active = true
    MainFrame.Draggable = true

    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 40)

    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0.05, 0, 0, 0)
    Title.Size = UDim2.new(0.8, 0, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🌙 NIGHTS DOMINATOR v7.0"
    Title.TextColor3 = Color3.fromRGB(0, 200, 255)
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left

    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = TopBar
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Position = UDim2.new(0.92, 0, 0.2, 0)
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 14
    CloseBtn.MouseButton1Click:Connect(function()
        DominatorGUI:Destroy()
    end)

    TabButtons.Name = "TabButtons"
    TabButtons.Parent = MainFrame
    TabButtons.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    TabButtons.BorderSizePixel = 0
    TabButtons.Position = UDim2.new(0, 0, 0, 45)
    TabButtons.Size = UDim2.new(1, 0, 0, 40)

    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainFrame
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Position = UDim2.new(0, 0, 0, 90)
    ContentFrame.Size = UDim2.new(1, 0, 1, -90)
    ContentFrame.ScrollBarThickness = 6
    ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)

    UIListLayout.Parent = ContentFrame
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Создаем вкладки
    local Tabs = {"MAIN", "COMBAT", "MOVEMENT", "VISUALS"}
    local CurrentTab = "MAIN"

    for i, tabName in pairs(Tabs) do
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tabName
        TabBtn.Parent = TabButtons
        TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        TabBtn.BorderSizePixel = 0
        TabBtn.Size = UDim2.new(0.23, 0, 0.7, 0)
        TabBtn.Position = UDim2.new(0.02 + (i-1)*0.24, 0, 0.15, 0)
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.Text = tabName
        TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabBtn.TextSize = 12
        
        TabBtn.MouseButton1Click:Connect(function()
            CurrentTab = tabName
            UpdateContent(ContentFrame, CurrentTab)
        end)
    end

    -- Функции создания элементов
    local function CreateButton(parent, config)
        local Button = Instance.new("TextButton")
        Button.Name = config.Name
        Button.Parent = parent
        Button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(0.9, 0, 0, 40)
        Button.Font = Enum.Font.Gotham
        Button.Text = config.Name
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 13
        
        Button.MouseButton1Click:Connect(config.Callback)
        
        return Button
    end

    local function CreateToggle(parent, config)
        local ToggleFrame = Instance.new("Frame")
        local ToggleLabel = Instance.new("TextLabel")
        local ToggleBtn = Instance.new("TextButton")
        
        ToggleFrame.Name = config.Name
        ToggleFrame.Parent = parent
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Size = UDim2.new(0.9, 0, 0, 35)
        
        ToggleLabel.Name = "Label"
        ToggleLabel.Parent = ToggleFrame
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.Text = config.Name
        ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleLabel.TextSize = 13
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        ToggleBtn.Name = "Toggle"
        ToggleBtn.Parent = ToggleFrame
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        ToggleBtn.BorderSizePixel = 0
        ToggleBtn.Position = UDim2.new(0.8, 0, 0.2, 0)
        ToggleBtn.Size = UDim2.new(0, 50, 0, 20)
        ToggleBtn.Font = Enum.Font.Gotham
        ToggleBtn.Text = "OFF"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleBtn.TextSize = 10
        
        local state = config.CurrentValue or false
        
        local function UpdateToggle()
            if state then
                ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
                ToggleBtn.Text = "ON"
            else
                ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                ToggleBtn.Text = "OFF"
            end
            config.Callback(state)
        end
        
        ToggleBtn.MouseButton1Click:Connect(function()
            state = not state
            UpdateToggle()
        end)
        
        UpdateToggle()
        
        return {
            Set = function(value)
                state = value
                UpdateToggle()
            end
        }
    end

    -- Функция обновления контента
    function UpdateContent(contentFrame, tab)
        -- Очищаем контент
        for _, child in pairs(contentFrame:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then
                child:Destroy()
            end
        end

        if tab == "MAIN" then
            CreateToggle(contentFrame, {
                Name = "🌀 BRING ALL ITEMS",
                CurrentValue = Dominator.Enabled.BringAll,
                Callback = function(value)
                    Dominator.Enabled.BringAll = value
                    if value then
                        StartBringAll()
                    else
                        StopBringAll()
                    end
                end
            })
            
            CreateToggle(contentFrame, {
                Name = "💀 INSTANT KILL",
                CurrentValue = Dominator.Enabled.InstantKill,
                Callback = function(value)
                    Dominator.Enabled.InstantKill = value
                    if value then
                        StartInstantKill()
                    else
                        StopInstantKill()
                    end
                end
            })
            
            CreateToggle(contentFrame, {
                Name = "🎯 AUTO FARM",
                CurrentValue = Dominator.Enabled.AutoFarm,
                Callback = function(value)
                    Dominator.Enabled.AutoFarm = value
                    if value then
                        StartAutoFarm()
                    else
                        StopAutoFarm()
                    end
                end
            })
            
            CreateButton(contentFrame, {
                Name = "🛡️ ENABLE GOD MODE",
                Callback = function()
                    EnableGodMode()
                end
            })

        elseif tab == "COMBAT" then
            CreateButton(contentFrame, {
                Name = "⚡ KILL ALL NEARBY",
                Callback = function()
                    KillAllNearby()
                end
            })
            
            CreateButton(contentFrame, {
                Name = "🎯 TP TO NEAREST ENEMY",
                Callback = function()
                    TeleportToNearestEnemy()
                end
            })
            
            CreateToggle(contentFrame, {
                Name = "👁️ ESP MONSTERS",
                CurrentValue = Dominator.Enabled.ESP,
                Callback = function(value)
                    Dominator.Enabled.ESP = value
                    if value then
                        StartESP()
                    else
                        StopESP()
                    end
                end
            })

        elseif tab == "MOVEMENT" then
            CreateToggle(contentFrame, {
                Name = "🪽 FLY MODE",
                CurrentValue = Dominator.Enabled.Fly,
                Callback = function(value)
                    Dominator.Enabled.Fly = value
                    if value then
                        StartFly()
                    else
                        StopFly()
                    end
                end
            })
            
            CreateToggle(contentFrame, {
                Name = "👻 NO CLIP",
                CurrentValue = Dominator.Enabled.Noclip,
                Callback = function(value)
                    Dominator.Enabled.Noclip = value
                    if value then
                        StartNoclip()
                    else
                        StopNoclip()
                    end
                end
            })
            
            CreateButton(contentFrame, {
                Name = "⚡ SPEED 50",
                Callback = function()
                    SetSpeed(50)
                end
            })
            
            CreateButton(contentFrame, {
                Name = "⚡ SPEED 100", 
                Callback = function()
                    SetSpeed(100)
                end
            })

        elseif tab == "VISUALS" then
            CreateButton(contentFrame, {
                Name = "💡 FULL BRIGHT",
                Callback = function()
                    EnableFullBright()
                end
            })
            
            CreateButton(contentFrame, {
                Name = "📍 TP TO MOUSE",
                Callback = function()
                    TeleportToMouse()
                end
            })
            
            CreateButton(contentFrame, {
                Name = "📊 SERVER INFO",
                Callback = function()
                    PrintServerInfo()
                end
            })
        end
    end

    -- Инициализируем первую вкладку
    UpdateContent(ContentFrame, "MAIN")
    
    return DominatorGUI
end

-- ОСНОВНЫЕ ФУНКЦИИ
function StartBringAll()
    Dominator.Connections.BringAll = RunService.Heartbeat:Connect(function()
        if not Dominator.Enabled.BringAll then return end
        
        local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Part") or obj:IsA("MeshPart") then
                local name = obj.Name:lower()
                if name:find("wood") or name:find("stone") or name:find("ore") or 
                   name:find("berry") or name:find("coin") or name:find("money") or
                   name:find("mushroom") or name:find("food") or name:find("resource") then
                   
                    local distance = (root.Position - obj.Position).Magnitude
                    if distance < 100 then
                        obj.CFrame = root.CFrame + Vector3.new(
                            math.random(-5, 5),
                            3,
                            math.random(-5, 5)
                        )
                    end
                end
            end
        end
    end)
end

function StopBringAll()
    if Dominator.Connections.BringAll then
        Dominator.Connections.BringAll:Disconnect()
        Dominator.Connections.BringAll = nil
    end
end

function StartInstantKill()
    Dominator.Connections.InstantKill = RunService.Heartbeat:Connect(function()
        if not Dominator.Enabled.InstantKill then return end
        
        local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        for _, npc in pairs(Workspace:GetChildren()) do
            if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                if npc ~= Player.Character and not Players:GetPlayerFromCharacter(npc) then
                    local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                    if npcRoot then
                        local distance = (root.Position - npcRoot.Position).Magnitude
                        if distance < 50 then
                            npc.Humanoid.Health = 0
                        end
                    end
                end
            end
        end
    end)
end

function StopInstantKill()
    if Dominator.Connections.InstantKill then
        Dominator.Connections.InstantKill:Disconnect()
        Dominator.Connections.InstantKill = nil
    end
end

function StartAutoFarm()
    Dominator.Connections.AutoFarm = RunService.Heartbeat:Connect(function()
        if not Dominator.Enabled.AutoFarm then return end
        
        local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        -- Авто-сбор предметов
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Part") or obj:IsA("MeshPart") then
                local name = obj.Name:lower()
                if name:find("wood") or name:find("stone") or name:find("ore") or 
                   name:find("berry") or name:find("coin") then
                   
                    local distance = (root.Position - obj.Position).Magnitude
                    if distance < 20 then
                        obj.CFrame = root.CFrame + Vector3.new(0, 3, 0)
                        firetouchinterest(root, obj, 0)
                        wait(0.05)
                        firetouchinterest(root, obj, 1)
                    end
                end
            end
        end
        
        -- Авто-убийство врагов
        for _, npc in pairs(Workspace:GetChildren()) do
            if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                if npc ~= Player.Character and not Players:GetPlayerFromCharacter(npc) then
                    local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                    if npcRoot then
                        local distance = (root.Position - npcRoot.Position).Magnitude
                        if distance < 30 then
                            root.CFrame = npcRoot.CFrame + Vector3.new(0, 0, -3)
                            local tool = Player.Character:FindFirstChildOfClass("Tool")
                            if tool then
                                firetouchinterest(tool.Handle, npcRoot, 0)
                                wait(0.1)
                                firetouchinterest(tool.Handle, npcRoot, 1)
                            end
                        end
                    end
                end
            end
        end
    end)
end

function StopAutoFarm()
    if Dominator.Connections.AutoFarm then
        Dominator.Connections.AutoFarm:Disconnect()
        Dominator.Connections.AutoFarm = nil
    end
end

function StartFly()
    Dominator.Connections.Fly = RunService.Heartbeat:Connect(function()
        if not Dominator.Enabled.Fly or not Player.Character then return end
        
        local root = Player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = Player.Character:FindFirstChild("Humanoid")
        if not root or not humanoid then return end
        
        humanoid.PlatformStand = true
        
        local camera = Workspace.CurrentCamera
        local moveDirection = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection = moveDirection + Vector3.new(0, -1, 0)
        end
        
        if moveDirection.Magnitude > 0 then
            root.Velocity = moveDirection.Unit * 100
        else
            root.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

function StopFly()
    if Dominator.Connections.Fly then
        Dominator.Connections.Fly:Disconnect()
        Dominator.Connections.Fly = nil
    end
    
    if Player.Character then
        local humanoid = Player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

function StartNoclip()
    Dominator.Connections.Noclip = RunService.Stepped:Connect(function()
        if not Dominator.Enabled.Noclip or not Player.Character then return end
        
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

function StopNoclip()
    if Dominator.Connections.Noclip then
        Dominator.Connections.Noclip:Disconnect()
        Dominator.Connections.Noclip = nil
    end
end

function StartESP()
    for _, npc in pairs(Workspace:GetChildren()) do
        if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
            if npc ~= Player.Character and not Players:GetPlayerFromCharacter(npc) then
                local highlight = Instance.new("Highlight")
                highlight.Adornee = npc
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.Parent = npc
                Dominator.Highlights[npc] = highlight
            end
        end
    end
end

function StopESP()
    for _, highlight in pairs(Dominator.Highlights) do
        highlight:Destroy()
    end
    Dominator.Highlights = {}
end

-- ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ
function EnableGodMode()
    if Player.Character then
        local humanoid = Player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
        end
    end
end

function SetSpeed(value)
    if Player.Character then
        local humanoid = Player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
end

function KillAllNearby()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    for _, npc in pairs(Workspace:GetChildren()) do
        if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
            if npc ~= Player.Character and not Players:GetPlayerFromCharacter(npc) then
                local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                if npcRoot then
                    local distance = (root.Position - npcRoot.Position).Magnitude
                    if distance < 100 then
                        npc.Humanoid.Health = 0
                    end
                end
            end
        end
    end
end

function TeleportToNearestEnemy()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local nearest = nil
    local nearestDist = math.huge
    
    for _, npc in pairs(Workspace:GetChildren()) do
        if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
            if npc ~= Player.Character and not Players:GetPlayerFromCharacter(npc) then
                local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                if npcRoot then
                    local distance = (root.Position - npcRoot.Position).Magnitude
                    if distance < nearestDist then
                        nearestDist = distance
                        nearest = npcRoot
                    end
                end
            end
        end
    end
    
    if nearest then
        root.CFrame = nearest.CFrame + Vector3.new(0, 0, -5)
    end
end

function TeleportToMouse()
    if Player.Character and Mouse.Target then
        local root = Player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 5, 0))
        end
    end
end

function EnableFullBright()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.Ambient = Color3.new(1, 1, 1)
end

function PrintServerInfo()
    local playerCount = #Players:GetPlayers()
    local monsterCount = 0
    
    for _, npc in pairs(Workspace:GetChildren()) do
        if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
            if npc ~= Player.Character and not Players:GetPlayerFromCharacter(npc) then
                monsterCount = monsterCount + 1
            end
        end
    end
    
    print("=== SERVER INFO ===")
    print("Players: " .. playerCount)
    print("Monsters: " .. monsterCount)
    print("Time: " .. Lighting.ClockTime)
end

-- ЗАГРУЗКА СКРИПТА
wait(1)

-- Создаем GUI
local GUI = CreateDominatorGUI()

-- Уведомление о загрузке
local notify = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
local label = Instance.new("TextLabel")

notify.Name = "LoadNotify"
notify.Parent = CoreGui

frame.Parent = notify
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderSizePixel = 0
frame.Position = UDim2.new(0.35, 0, 0.45, 0)
frame.Size = UDim2.new(0, 300, 0, 80)

label.Parent = frame
label.BackgroundTransparency = 1
label.Size = UDim2.new(1, 0, 1, 0)
label.Text = "🌙 NIGHTS DOMINATOR v7.0\nУСПЕШНО ЗАГРУЖЕН!"
label.TextColor3 = Color3.fromRGB(0, 255, 255)
label.TextSize = 16
label.Font = Enum.Font.GothamBold

-- Авто-удаление уведомления
spawn(function()
    wait(3)
    for i = 1, 10 do
        frame.BackgroundTransparency = i/10
        label.TextTransparency = i/10
        wait(0.1)
    end
    notify:Destroy()
end)

print("🔥 NIGHTS DOMINATOR v7.0 - АКТИВИРОВАН!")
print("🌀 Bring All Items - Притягивает ВСЕ ресурсы")
print("💀 Instant Kill - Мгновенно убивает врагов")
print("🎯 Auto Farm - Полный авто-фарм")
print("🪽 Fly Mode - Полёт на WASD + Space/Ctrl")
print("👁️ ESP - Подсветка монстров")
