-- 99 Nights Dominator v2.0
-- Полный контроль: Fly, Bring Items, Auto Farm, ESP, God Mode

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Переменные
local Flying = false
local BringItems = false
local AutoFarm = false
local ESPEnabled = false
local GodModeEnabled = false
local SpeedEnabled = false
local NoclipEnabled = false

local ESPHighlights = {}
local FlyConnection = nil
local FarmConnection = nil
local BringConnection = nil
local NoclipConnection = nil

-- Простой GUI
local function CreateDominatorGUI()
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local CloseButton = Instance.new("TextButton")
    local ScrollFrame = Instance.new("ScrollingFrame")
    local UIListLayout = Instance.new("UIListLayout")

    ScreenGui.Name = "DominatorGUI"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.75, 0, 0.25, 0)
    MainFrame.Size = UDim2.new(0, 300, 0, 450)
    MainFrame.Active = true
    MainFrame.Draggable = true

    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🌙 99 Nights Dominator v2.0"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16

    CloseButton.Name = "CloseButton"
    CloseButton.Parent = Title
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(0.9, 0, 0.2, 0)
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    ScrollFrame.Parent = MainFrame
    ScrollFrame.Position = UDim2.new(0, 0, 0, 45)
    ScrollFrame.Size = UDim2.new(1, 0, 1, -45)
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 5
    ScrollFrame.BackgroundTransparency = 1

    UIListLayout.Parent = ScrollFrame
    UIListLayout.Padding = UDim.new(0, 8)

    local function CreateButton(name, callback)
        local Button = Instance.new("TextButton")
        Button.Name = name
        Button.Parent = ScrollFrame
        Button.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(0.9, 0, 0, 40)
        Button.Position = UDim2.new(0.05, 0, 0, 0)
        Button.Font = Enum.Font.Gotham
        Button.Text = name
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 14
        Button.MouseButton1Click:Connect(callback)
        return Button
    end

    local function CreateToggle(name, callback)
        local ToggleFrame = Instance.new("Frame")
        local ToggleButton = Instance.new("TextButton")
        local Status = Instance.new("TextLabel")

        ToggleFrame.Name = name
        ToggleFrame.Parent = ScrollFrame
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Size = UDim2.new(0.9, 0, 0, 40)
        ToggleFrame.Position = UDim2.new(0.05, 0, 0, 0)

        ToggleButton.Name = "ToggleButton"
        ToggleButton.Parent = ToggleFrame
        ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Position = UDim2.new(0.7, 0, 0.2, 0)
        ToggleButton.Size = UDim2.new(0, 60, 0, 25)
        ToggleButton.Font = Enum.Font.Gotham
        ToggleButton.Text = "OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.TextSize = 12

        Status.Name = "Status"
        Status.Parent = ToggleFrame
        Status.BackgroundTransparency = 1
        Status.Position = UDim2.new(0.05, 0, 0, 0)
        Status.Size = UDim2.new(0.6, 0, 1, 0)
        Status.Font = Enum.Font.Gotham
        Status.Text = name
        Status.TextColor3 = Color3.fromRGB(255, 255, 255)
        Status.TextSize = 14
        Status.TextXAlignment = Enum.TextXAlignment.Left

        local state = false

        local function updateToggle()
            if state then
                ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
                ToggleButton.Text = "ON"
            else
                ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
                ToggleButton.Text = "OFF"
            end
            callback(state)
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

    -- ФЛАЙ СИСТЕМА
    CreateToggle("🪽 Fly Mode", function(state)
        Flying = state
        if state then
            StartFlying()
        else
            StopFlying()
        end
    end)

    -- БРИНГ ПРЕДМЕТОВ
    CreateToggle("🌀 Bring All Items", function(state)
        BringItems = state
        if state then
            StartBringItems()
        else
            StopBringItems()
        end
    end)

    -- АВТО-ФАРМ
    CreateToggle("🎯 Auto Farm Monsters", function(state)
        AutoFarm = state
        if state then
            StartAutoFarm()
        else
            StopAutoFarm()
        end
    end)

    -- ESP
    CreateToggle("👁️ ESP Highlight", function(state)
        ESPEnabled = state
        if state then
            StartESP()
        else
            StopESP()
        end
    end)

    -- GOD MODE
    CreateToggle("🛡️ God Mode", function(state)
        GodModeEnabled = state
        if state then
            EnableGodMode()
        else
            DisableGodMode()
        end
    end)

    -- NO CLIP
    CreateToggle("👻 No Clip", function(state)
        NoclipEnabled = state
        if state then
            StartNoclip()
        else
            StopNoclip()
        end
    end)

    -- СКОРОСТЬ
    CreateButton("⚡ Speed Hack (50)", function()
        SetSpeed(50)
    end)

    CreateButton("⚡ Speed Hack (100)", function()
        SetSpeed(100)
    end)

    CreateButton("🔄 Reset Speed", function()
        SetSpeed(16)
    end)

    -- ТЕЛЕПОРТЫ
    CreateButton("📍 TP to Mouse", function()
        TeleportToMouse()
    end)

    -- ИНФО
    CreateButton("📊 Game Info", function()
        PrintGameInfo()
    end)

    return ScreenGui
end

-- ФУНКЦИЯ ФЛАЙ
function StartFlying()
    if not Player.Character then return end
    
    local humanoid = Player.Character:FindFirstChild("Humanoid")
    local root = Player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    humanoid.PlatformStand = true

    FlyConnection = RunService.Heartbeat:Connect(function()
        if not Flying or not Player.Character then
            StopFlying()
            return
        end

        local camera = Workspace.CurrentCamera
        local moveDirection = Vector3.new(0, 0, 0)

        -- Управление WASD
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
            moveDirection = moveDirection.Unit * 50
            root.Velocity = moveDirection
        else
            root.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

function StopFlying()
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    if Player.Character then
        local humanoid = Player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

-- ФУНКЦИЯ БРИНГ ПРЕДМЕТОВ
function StartBringItems()
    BringConnection = RunService.Heartbeat:Connect(function()
        if not BringItems or not Player.Character then return end
        
        local root = Player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        -- Притягиваем ресурсы
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Part") or obj:IsA("MeshPart") then
                local name = obj.Name:lower()
                if name:find("wood") or name:find("stone") or name:find("ore") or 
                   name:find("berry") or name:find("mushroom") or name:find("herb") or
                   name:find("coin") or name:find("cash") or name:find("reward") then
                   
                    local distance = (root.Position - obj.Position).Magnitude
                    if distance < 100 then
                        -- Плавное притягивание
                        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                        local tween = TweenService:Create(obj, tweenInfo, {CFrame = root.CFrame + Vector3.new(0, 3, 0)})
                        tween:Play()
                    end
                end
            end
        end
    end)
end

function StopBringItems()
    if BringConnection then
        BringConnection:Disconnect()
        BringConnection = nil
    end
end

-- ФУНКЦИЯ АВТО-ФАРМ МОНСТРОВ
function StartAutoFarm()
    FarmConnection = RunService.Heartbeat:Connect(function()
        if not AutoFarm or not Player.Character then return end
        
        local root = Player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = Player.Character:FindFirstChild("Humanoid")
        if not root or not humanoid then return end

        for _, npc in pairs(Workspace:GetChildren()) do
            if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                if npc ~= Player.Character and not npc:FindFirstChild("Player") then
                    local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                    if npcRoot then
                        local distance = (root.Position - npcRoot.Position).Magnitude
                        if distance < 50 then
                            -- Телепорт к монстру
                            root.CFrame = npcRoot.CFrame + Vector3.new(0, 0, -3)
                            
                            -- Авто-атака
                            local tool = Player.Character:FindFirstChildOfClass("Tool")
                            if tool then
                                for i = 1, 3 do
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
    end)
end

function StopAutoFarm()
    if FarmConnection then
        FarmConnection:Disconnect()
        FarmConnection = nil
    end
end

-- ФУНКЦИЯ ESP
function StartESP()
    -- Очищаем старые подсветки
    StopESP()

    -- Функция добавления ESP
    local function addESP(obj, color)
        if not obj or ESPHighlights[obj] then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Adornee = obj
        highlight.FillColor = color
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.6
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = obj
        
        ESPHighlights[obj] = highlight
    end

    -- Добавляем ESP для существующих объектов
    for _, npc in pairs(Workspace:GetChildren()) do
        if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
            if npc ~= Player.Character then
                addESP(npc, Color3.fromRGB(255, 50, 50)) -- Красный для монстров
            end
        end
    end

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            if name:find("wood") or name:find("stone") or name:find("ore") then
                addESP(obj, Color3.fromRGB(50, 200, 50)) -- Зеленый для ресурсов
            elseif name:find("berry") or name:find("mushroom") then
                addESP(obj, Color3.fromRGB(200, 200, 50)) -- Желтый для еды
            elseif name:find("coin") or name:find("cash") then
                addESP(obj, Color3.fromRGB(255, 215, 0)) -- Золотой для денег
            end
        end
    end

    -- Мониторинг новых объектов
    Workspace.DescendantAdded:Connect(function(obj)
        wait(0.5)
        if not ESPEnabled then return end
        
        if obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
            if obj ~= Player.Character then
                addESP(obj, Color3.fromRGB(255, 50, 50))
            end
        end
        
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            if name:find("wood") or name:find("stone") or name:find("ore") then
                addESP(obj, Color3.fromRGB(50, 200, 50))
            elseif name:find("berry") or name:find("mushroom") then
                addESP(obj, Color3.fromRGB(200, 200, 50))
            end
        end
    end)
end

function StopESP()
    for obj, highlight in pairs(ESPHighlights) do
        if highlight then
            highlight:Destroy()
        end
    end
    ESPHighlights = {}
end

-- GOD MODE
function EnableGodMode()
    if Player.Character then
        local humanoid = Player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
        end
    end
end

function DisableGodMode()
    if Player.Character then
        local humanoid = Player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.MaxHealth = 100
            humanoid.Health = 100
        end
    end
end

-- NO CLIP
function StartNoclip()
    NoclipConnection = RunService.Stepped:Connect(function()
        if not NoclipEnabled or not Player.Character then return end
        
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end

function StopNoclip()
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
end

-- СКОРОСТЬ
function SetSpeed(value)
    if Player.Character then
        local humanoid = Player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
end

-- ТЕЛЕПОРТ К МЫШКЕ
function TeleportToMouse()
    if Player.Character then
        local root = Player.Character:FindFirstChild("HumanoidRootPart")
        if root and Mouse.Target then
            root.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 5, 0))
        end
    end
end

-- ИНФО ОБ ИГРЕ
function PrintGameInfo()
    local monsterCount = 0
    local resourceCount = 0
    
    for _, npc in pairs(Workspace:GetChildren()) do
        if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
            if npc ~= Player.Character then
                monsterCount = monsterCount + 1
            end
        end
    end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            if name:find("wood") or name:find("stone") or name:find("ore") or 
               name:find("berry") or name:find("mushroom") then
                resourceCount = resourceCount + 1
            end
        end
    end
    
    print("=== 99 Nights Info ===")
    print("Игроков: " .. #Players:GetPlayers())
    print("Монстров: " .. monsterCount)
    print("Ресурсов: " .. resourceCount)
    print("Время: " .. Lighting.ClockTime)
end

-- ЗАГРУЗКА
wait(1)
CreateDominatorGUI()

-- Уведомление
local notify = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
local label = Instance.new("TextLabel")

notify.Parent = Player.PlayerGui
frame.Parent = notify
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
frame.BorderSizePixel = 0
frame.Position = UDim2.new(0.4, 0, 0.45, 0)
frame.Size = UDim2.new(0, 200, 0, 60)

label.Parent = frame
label.BackgroundTransparency = 1
label.Size = UDim2.new(1, 0, 1, 0)
label.Text = "🌙 99 Nights Dominator\nУспешно загружен!"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextSize = 14
label.Font = Enum.Font.GothamBold

wait(3)
notify:Destroy()

print("🎮 99 Nights Dominator v2.0 - Активирован!")
print("🪽 Fly: WASD + Space/Ctrl")
print("🌀 Bring Items: Притягивает все ресурсы")
print("🎯 Auto Farm: Авто-убийство монстров")
print("👁️ ESP: Подсветка всех целей")
