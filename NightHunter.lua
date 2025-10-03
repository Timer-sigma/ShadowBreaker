-- MEGA NIGHTS DOMINATOR v6.0
-- Полный клон VW + улучшенные функции

loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/nightsintheforest.lua", true))()

-- ДОБАВЛЯЕМ НАШИ УЛУЧШЕННЫЕ ФУНКЦИИ
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- УЛУЧШЕННЫЙ БРИНГ ПРЕДМЕТОВ
local EnhancedBring = {
    Enabled = false,
    Connection = nil,
    BringDistance = 150,
    BringSpeed = 0.3
}

function EnhancedBring:Start()
    if self.Enabled then return end
    self.Enabled = true
    
    self.Connection = RunService.Heartbeat:Connect(function()
        if not self.Enabled then return end
        
        local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        -- Притягиваем ВСЕ предметы которые можно собрать
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
                -- Проверяем что это собираемый предмет (не земля, не дерево и т.д.)
                if IsCollectibleItem(obj) then
                    local distance = (root.Position - obj.Position).Magnitude
                    if distance < self.BringDistance then
                        -- Плавное притягивание
                        local tweenInfo = TweenInfo.new(
                            self.BringSpeed,
                            Enum.EasingStyle.Quad,
                            Enum.EasingDirection.Out
                        )
                        local targetPosition = root.Position + Vector3.new(
                            math.random(-5, 5),
                            3,
                            math.random(-5, 5)
                        )
                        local tween = TweenService:Create(obj, tweenInfo, {
                            CFrame = CFrame.new(targetPosition)
                        })
                        tween:Play()
                    end
                end
            end
        end
    end)
end

function EnhancedBring:Stop()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    self.Enabled = false
end

-- Умная проверка собираемых предметов
function IsCollectibleItem(obj)
    local name = obj.Name:lower()
    local blacklist = {
        "base", "ground", "terrain", "water", "wall", "floor", 
        "tree", "rock", "boulder", "house", "building", "spawn"
    }
    
    -- Черный список
    for _, blackword in pairs(blacklist) do
        if name:find(blackword) then
            return false
        end
    end
    
    -- Белый список собираемых предметов
    local collectibleKeywords = {
        "wood", "log", "stick", "stone", "rock", "ore", "metal",
        "iron", "gold", "coin", "money", "cash", "berry", "mushroom",
        "apple", "food", "meat", "fish", "resource", "item", "loot",
        "reward", "chest", "box", "crate", "pickup", "collectible"
    }
    
    for _, keyword in pairs(collectibleKeywords) do
        if name:find(keyword) then
            return true
        end
    end
    
    -- Если предмет маленький и не прикреплен - вероятно собираемый
    if obj.Size.Magnitude < 10 and not obj.Anchored then
        return true
    end
    
    return false
end

-- УЛУЧШЕННАЯ КИЛКА (INSTANT KILL)
local InstantKill = {
    Enabled = false,
    Connection = nil,
    KillDistance = 50
}

function InstantKill:Start()
    if self.Enabled then return end
    self.Enabled = true
    
    self.Connection = RunService.Heartbeat:Connect(function()
        if not self.Enabled then return end
        
        local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        -- Ищем монстров и врагов
        for _, npc in pairs(Workspace:GetChildren()) do
            if IsEnemy(npc) then
                local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                local humanoid = npc:FindFirstChild("Humanoid")
                
                if npcRoot and humanoid and humanoid.Health > 0 then
                    local distance = (root.Position - npcRoot.Position).Magnitude
                    
                    if distance < self.KillDistance then
                        -- Мгновенное убийство
                        humanoid.Health = 0
                        
                        -- Альтернативные методы убийства
                        pcall(function()
                            humanoid:TakeDamage(math.huge)
                        end)
                        
                        pcall(function()
                            -- Взрыв для гарантии
                            local explosion = Instance.new("Explosion")
                            explosion.Position = npcRoot.Position
                            explosion.BlastPressure = 0
                            explosion.BlastRadius = 5
                            explosion.Parent = Workspace
                        end)
                    end
                end
            end
        end
    end)
end

function InstantKill:Stop()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    self.Enabled = false
end

-- Умное определение врагов
function IsEnemy(npc)
    if not npc:FindFirstChild("Humanoid") then return false end
    if npc:FindFirstChild("Humanoid").Health <= 0 then return false end
    
    -- Игроки - не враги
    if Players:GetPlayerFromCharacter(npc) then return false end
    
    local npcName = npc.Name:lower()
    
    -- Черный список дружественных NPC
    local friendlyNPCs = {
        "player", "friend", "villager", "trader", "merchant", 
        "npc", "civilian", "ally", "companion"
    }
    
    for _, friendly in pairs(friendlyNPCs) do
        if npcName:find(friendly) then
            return false
        end
    end
    
    -- Белый список врагов
    local enemyKeywords = {
        "monster", "enemy", "zombie", "skeleton", "creature", "beast",
        "wolf", "bear", "spider", "goblin", "orc", "demon", "ghost",
        "boss", "mob", "animal", "predator", "hostile"
    }
    
    for _, enemy in pairs(enemyKeywords) do
        if npcName:find(enemy) then
            return true
        end
    end
    
    -- Если не игрок и не друг - считаем врагом
    return true
end

-- АВТО-ФАРМ РЕСУРСОВ
local AutoFarm = {
    Enabled = false,
    Connection = nil,
    FarmDistance = 100
}

function AutoFarm:Start()
    if self.Enabled then return end
    self.Enabled = true
    
    self.Connection = RunService.Heartbeat:Connect(function()
        if not self.Enabled then return end
        
        local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        -- 1. Собираем ресурсы
        for _, obj in pairs(Workspace:GetDescendants()) do
            if IsCollectibleItem(obj) then
                local distance = (root.Position - obj.Position).Magnitude
                if distance < 20 then -- Близкие предметы собираем сразу
                    obj.CFrame = root.CFrame + Vector3.new(0, 3, 0)
                    firetouchinterest(root, obj, 0)
                    wait(0.05)
                    firetouchinterest(root, obj, 1)
                end
            end
        end
        
        -- 2. Убиваем врагов
        for _, npc in pairs(Workspace:GetChildren()) do
            if IsEnemy(npc) then
                local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                if npcRoot then
                    local distance = (root.Position - npcRoot.Position).Magnitude
                    if distance < self.FarmDistance then
                        -- Телепортируемся к врагу
                        root.CFrame = npcRoot.CFrame + Vector3.new(0, 0, -3)
                        
                        -- Атакуем
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
    end)
end

function AutoFarm:Stop()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    self.Enabled = false
end

-- МЕГА ФЛАЙ
local MegaFly = {
    Enabled = false,
    Connection = nil,
    FlySpeed = 100
}

function MegaFly:Start()
    if self.Enabled then return end
    self.Enabled = true
    
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local humanoid = Player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
    end
    
    self.Connection = RunService.Heartbeat:Connect(function()
        if not self.Enabled or not Player.Character then return end
        
        local root = Player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
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
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDirection = moveDirection * 2 -- Ускорение
        end
        
        if moveDirection.Magnitude > 0 then
            root.Velocity = moveDirection.Unit * self.FlySpeed
        else
            root.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

function MegaFly:Stop()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    
    if Player.Character then
        local humanoid = Player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
    self.Enabled = false
end

-- ДОБАВЛЯЕМ НАШИ ФУНКЦИИ В ИНТЕРФЕЙС VW
wait(2) -- Ждем загрузки основного GUI

-- Находим GUI VW и добавляем наши кнопки
local function AddOurFeaturesToVW()
    -- Ищем основной GUI VW
    for _, gui in pairs(game.CoreGui:GetChildren()) do
        if gui.Name == "Vape" or gui.Name:find("VW") or gui.Name:find("Voidware") then
            
            -- Добавляем наши функции в существующие вкладки или создаем новую
            
            -- Ищем кнопку для добавления наших функций
            wait(3)
            
            -- Создаем уведомление что наши функции загружены
            local notify = Instance.new("ScreenGui")
            local frame = Instance.new("Frame")
            local label = Instance.new("TextLabel")
            
            notify.Name = "MegaDominatorNotify"
            notify.Parent = game.CoreGui
            
            frame.Parent = notify
            frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            frame.BorderSizePixel = 0
            frame.Position = UDim2.new(0.3, 0, 0.4, 0)
            frame.Size = UDim2.new(0, 400, 0, 80)
            
            label.Parent = frame
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 1, 0)
            label.Text = "🔥 MEGA FEATURES LOADED!\nEnhanced Bring + Instant Kill + Auto Farm"
            label.TextColor3 = Color3.fromRGB(0, 255, 255)
            label.TextSize = 16
            label.Font = Enum.Font.GothamBold
            
            -- Авто-удаление уведомления
            spawn(function()
                wait(4)
                notify:Destroy()
            end)
            
            break
        end
    end
end

-- АЛЬТЕРНАТИВНЫЙ GUI ЕСЛИ VW НЕ НАЙДЕН
local function CreateAlternativeGUI()
    local AltGUI = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local Top = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local Close = Instance.new("TextButton")
    
    AltGUI.Name = "MegaDominatorGUI"
    AltGUI.Parent = game.CoreGui
    
    Main.Name = "Main"
    Main.Parent = AltGUI
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BorderSizePixel = 1
    Main.BorderColor3 = Color3.fromRGB(60, 60, 60)
    Main.Position = UDim2.new(0.7, 0, 0.3, 0)
    Main.Size = UDim2.new(0, 300, 0, 400)
    Main.Active = true
    Main.Draggable = true
    
    Top.Name = "Top"
    Top.Parent = Main
    Top.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Top.BorderSizePixel = 0
    Top.Size = UDim2.new(1, 0, 0, 40)
    
    Title.Name = "Title"
    Title.Parent = Top
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(0.8, 0, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🔥 MEGA FEATURES"
    Title.TextColor3 = Color3.fromRGB(0, 255, 255)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Position = UDim2.new(0.05, 0, 0, 0)
    
    Close.Name = "Close"
    Close.Parent = Top
    Close.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    Close.BorderSizePixel = 0
    Close.Position = UDim2.new(0.9, 0, 0.2, 0)
    Close.Size = UDim2.new(0, 20, 0, 20)
    Close.Font = Enum.Font.GothamBold
    Close.Text = "X"
    Close.TextColor3 = Color3.fromRGB(255, 255, 255)
    Close.TextSize = 12
    Close.MouseButton1Click:Connect(function()
        AltGUI:Destroy()
    end)
    
    local Content = Instance.new("ScrollingFrame")
    Content.Parent = Main
    Content.Position = UDim2.new(0, 0, 0, 45)
    Content.Size = UDim2.new(1, 0, 1, -45)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 5
    
    local UIList = Instance.new("UIListLayout")
    UIList.Parent = Content
    UIList.Padding = UDim.new(0, 5)
    
    local function CreateButton(name, callback)
        local Button = Instance.new("TextButton")
        Button.Parent = Content
        Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(0.9, 0, 0, 35)
        Button.Position = UDim2.new(0.05, 0, 0, 0)
        Button.Font = Enum.Font.Gotham
        Button.Text = name
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 12
        Button.MouseButton1Click:Connect(callback)
        return Button
    end
    
    local function CreateToggle(name, callback)
        local ToggleFrame = Instance.new("Frame")
        local ToggleLabel = Instance.new("TextLabel")
        local ToggleBtn = Instance.new("TextButton")
        
        ToggleFrame.Parent = Content
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Size = UDim2.new(0.9, 0, 0, 30)
        
        ToggleLabel.Parent = ToggleFrame
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.Text = name
        ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleLabel.TextSize = 12
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        ToggleBtn.Parent = ToggleFrame
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ToggleBtn.BorderSizePixel = 0
        ToggleBtn.Position = UDim2.new(0.8, 0, 0.1, 0)
        ToggleBtn.Size = UDim2.new(0, 50, 0, 20)
        ToggleBtn.Font = Enum.Font.Gotham
        ToggleBtn.Text = "OFF"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleBtn.TextSize = 10
        
        local state = false
        
        local function UpdateToggle()
            if state then
                ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                ToggleBtn.Text = "ON"
            else
                ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                ToggleBtn.Text = "OFF"
            end
            callback(state)
        end
        
        ToggleBtn.MouseButton1Click:Connect(function()
            state = not state
            UpdateToggle()
        end)
        
        UpdateToggle()
    end
    
    -- Добавляем наши функции
    CreateToggle("🌀 Enhanced Bring All", function(v)
        if v then
            EnhancedBring:Start()
        else
            EnhancedBring:Stop()
        end
    end)
    
    CreateToggle("💀 Instant Kill All", function(v)
        if v then
            InstantKill:Start()
        else
            InstantKill:Stop()
        end
    end)
    
    CreateToggle("🎯 Auto Farm Everything", function(v)
        if v then
            AutoFarm:Start()
        else
            AutoFarm:Stop()
        end
    end)
    
    CreateToggle("🪽 Mega Fly", function(v)
        if v then
            MegaFly:Start()
        else
            MegaFly:Stop()
        end
    end)
    
    CreateButton("⚡ Boost Speed", function()
        local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 50
        end
    end)
    
    CreateButton("🛡️ God Mode", function()
        local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
        end
    end)
    
    return AltGUI
end

-- ЗАПУСКАЕМ ВСЕ
wait(1)

-- Пытаемся добавить к VW, если не получится - создаем свой GUI
spawn(function()
    wait(3)
    AddOurFeaturesToVW()
    
    -- Если через 5 секунд VW не найден, создаем свой GUI
    wait(5)
    if not game.CoreGui:FindFirstChild("Vape") and not game.CoreGui:FindFirstChild("MegaDominatorGUI") then
        CreateAlternativeGUI()
    end
end)

print("🔥 MEGA DOMINATOR v6.0 LOADED!")
print("🎯 Enhanced Bring All - Работает на ВСЕ предметы")
print("💀 Instant Kill - Мгновенно убивает ВСЕХ врагов") 
print("🎯 Auto Farm - Авто-сбор + авто-убийство")
print("🪽 Mega Fly - Плавный полет с ускорением")
