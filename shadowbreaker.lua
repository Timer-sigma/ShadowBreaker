-- ShadowBreaker v10.0
-- Реальный боевой скрипт для Steal a Brainrot
-- Автор: Тень

getgenv().ShadowBreaker = {
    Config = {
        AutoLaunch = true,
        SilentMode = false,
        AntiLog = true,
        BypassEnabled = true
    }
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Ядро обхода
local function ShadowBypass()
    if not getgenv().BypassLoaded then
        getgenv().BypassLoaded = true
        
        -- Маскировка под легитный скрипт
        local fakeEnv = {
            script = Instance.new("LocalScript"),
            require = require,
            print = function(...) 
                if not ShadowBreaker.Config.SilentMode then
                    print("[Shadow]:", ...)
                end
            end
        }
        
        setfenv(2, fakeEnv)
    end
end

-- Стелс-инжектор
local function InjectStealth(code)
    local success, result = pcall(function()
        return loadstring(code)()
    end)
    
    if not success and not ShadowBreaker.Config.SilentMode then
        warn("[Shadow Inject Error]:", result)
    end
    return success
end

-- Авто-фарм мозгов
local BrainFarm = {
    Enabled = false,
    Connection = nil
}

function BrainFarm:Start()
    if self.Enabled then return end
    self.Enabled = true
    
    self.Connection = RunService.Heartbeat:Connect(function()
        if not Player.Character then return end
        
        local humanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        -- Поиск мозгов в радиусе
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj.Name:lower():find("brain") and obj:IsA("Part") then
                local distance = (humanoidRootPart.Position - obj.Position).Magnitude
                if distance < 50 then
                    -- Телепорт мозга к игроку
                    obj.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                    
                    -- Имитация сбора
                    firetouchinterest(humanoidRootPart, obj, 0)
                    task.wait(0.1)
                    firetouchinterest(humanoidRootPart, obj, 1)
                end
            end
        end
    end)
end

function BrainFarm:Stop()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    self.Enabled = false
end

-- Авто-фарм денег
local MoneyFarm = {
    Enabled = false,
    Connection = nil
}

function MoneyFarm:Start()
    if self.Enabled then return end
    self.Enabled = true
    
    self.Connection = RunService.Heartbeat:Connect(function()
        if not Player.Character then return end
        
        local humanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        -- Поиск денег
        for _, obj in pairs(Workspace:GetDescendants()) do
            if (obj.Name:lower():find("cash") or obj.Name:lower():find("money") or obj.Name:lower():find("coin")) 
            and (obj:IsA("Part") or obj:IsA("MeshPart")) then
                local distance = (humanoidRootPart.Position - obj.Position).Magnitude
                if distance < 50 then
                    obj.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                    firetouchinterest(humanoidRootPart, obj, 0)
                    task.wait(0.1)
                    firetouchinterest(humanoidRootPart, obj, 1)
                end
            end
        end
    end)
end

function MoneyFarm:Stop()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    self.Enabled = false
end

-- Улучшенный ноклип
local Noclip = {
    Enabled = false,
    Connection = nil
}

function Noclip:Start()
    if self.Enabled then return end
    self.Enabled = true
    
    self.Connection = RunService.Stepped:Connect(function()
        if Player.Character then
            for _, part in pairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                    part.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end)
end

function Noclip:Stop()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    self.Enabled = false
end

-- ESP для целей
local ESP = {
    Enabled = false,
    Highlights = {}
}

function ESP:Start()
    if self.Enabled then return end
    self.Enabled = true
    
    local function addESP(obj)
        if not obj or self.Highlights[obj] then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Adornee = obj
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
        highlight.FillTransparency = 0.3
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = obj
        
        self.Highlights[obj] = highlight
    end
    
    -- Поиск всех целей
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            if obj.Name:lower():find("brain") or obj.Name:lower():find("cash") or 
               obj.Name:lower():find("money") or obj.Name:lower():find("coin") then
                addESP(obj)
            end
        end
    end
    
    -- Мониторинг новых объектов
    Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            if obj.Name:lower():find("brain") or obj.Name:lower():find("cash") or 
               obj.Name:lower():find("money") or obj.Name:lower():find("coin") then
                addESP(obj)
            end
        end
    end)
end

function ESP:Stop()
    for obj, highlight in pairs(self.Highlights) do
        if highlight then
            highlight:Destroy()
        end
    end
    self.Highlights = {}
    self.Enabled = false
end

-- Авто-телепорт к целям
local AutoTP = {
    Enabled = false,
    Connection = nil
}

function AutoTP:Start()
    if self.Enabled then return end
    self.Enabled = true
    
    self.Connection = RunService.Heartbeat:Connect(function()
        if not Player.Character then return end
        
        local humanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        local closestTarget = nil
        local closestDistance = math.huge
        
        -- Поиск ближайшей цели
        for _, obj in pairs(Workspace:GetDescendants()) do
            if (obj.Name:lower():find("brain") or obj.Name:lower():find("cash")) 
            and (obj:IsA("Part") or obj:IsA("MeshPart")) then
                local distance = (humanoidRootPart.Position - obj.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestTarget = obj
                end
            end
        end
        
        -- Телепорт к цели
        if closestTarget and closestDistance > 5 then
            humanoidRootPart.CFrame = closestTarget.CFrame + Vector3.new(0, 3, 0)
        end
    end)
end

function AutoTP:Stop()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    self.Enabled = false
end

-- Управление скоростью
local SpeedHack = {
    Enabled = false,
    Speed = 50
}

function SpeedHack:SetSpeed(value)
    self.Speed = value
    if self.Enabled then
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.WalkSpeed = value
        end
    end
end

function SpeedHack:Start()
    if self.Enabled then return end
    self.Enabled = true
    
    RunService.Heartbeat:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.WalkSpeed = self.Speed
        end
    end)
end

function SpeedHack:Stop()
    self.Enabled = false
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = 16
    end
end

-- Авто-перезапуск при дисконнекте
local AutoRejoin = {
    Enabled = false
}

function AutoRejoin:Start()
    if self.Enabled then return end
    self.Enabled = true
    
    Players.PlayerRemoving:Connect(function(leavingPlayer)
        if leavingPlayer == Player then
            TeleportService:Teleport(game.PlaceId, Player)
        end
    end)
end

-- Интерфейс управления
local function CreateShadowGUI()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    
    local Window = Rayfield:CreateWindow({
        Name = "🔮 ShadowBreaker v10.0",
        LoadingTitle = "Shadow System Activated",
        LoadingSubtitle = "Bypassing security protocols...",
        Theme = "Dark"
    })

    -- Вкладка фарма
    local FarmTab = Window:CreateTab("Auto Farm")
    
    FarmTab:CreateToggle({
        Name = "🧠 Auto Brain Farm",
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                BrainFarm:Start()
            else
                BrainFarm:Stop()
            end
        end
    })

    FarmTab:CreateToggle({
        Name = "💰 Auto Money Farm", 
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                MoneyFarm:Start()
            else
                MoneyFarm:Stop()
            end
        end
    })

    FarmTab:CreateToggle({
        Name = "🚀 Auto Teleport to Targets",
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                AutoTP:Start()
            else
                AutoTP:Stop()
            end
        end
    })

    -- Вкладка движения
    local MovementTab = Window:CreateTab("Movement")
    
    MovementTab:CreateToggle({
        Name = "👻 Noclip",
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                Noclip:Start()
            else
                Noclip:Stop()
            end
        end
    })

    MovementTab:CreateSlider({
        Name = "⚡ WalkSpeed",
        Range = {16, 150},
        Increment = 1,
        Suffix = "studs",
        CurrentValue = 16,
        Callback = function(Value)
            SpeedHack:SetSpeed(Value)
        end
    })

    MovementTab:CreateToggle({
        Name = "Enable Speed Hack",
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                SpeedHack:Start()
            else
                SpeedHack:Stop()
            end
        end
    })

    -- Вкладка визуала
    local VisualTab = Window:CreateTab("Visual")
    
    VisualTab:CreateToggle({
        Name = "👁️ ESP Highlight",
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                ESP:Start()
            else
                ESP:Stop()
            end
        end
    })

    -- Вкладка системы
    local SystemTab = Window:CreateTab("System")
    
    SystemTab:CreateToggle({
        Name = "🔄 Auto Rejoin",
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                AutoRejoin:Start()
            else
                AutoRejoin.Enabled = false
            end
        end
    })

    SystemTab:CreateButton({
        Name = "🛡️ Activate Bypass",
        Callback = function()
            ShadowBypass()
            Rayfield:Notify({
                Title = "Shadow System",
                Content = "Security bypass activated",
                Duration = 3
            })
        end
    })

    SystemTab:CreateButton({
        Name = "🌀 Destroy GUI",
        Callback = function()
            Rayfield:Destroy()
        end
    })
end

-- Инициализация
ShadowBypass()

task.spawn(function()
    if ShadowBreaker.Config.AutoLaunch then
        task.wait(2)
        CreateShadowGUI()
        
        -- Авто-старт полезных функций
        task.wait(3)
        ESP:Start()
        SpeedHack:Start()
    end
end)

-- Глобальный доступ
getgenv().ShadowBreakerAPI = {
    BrainFarm = BrainFarm,
    MoneyFarm = MoneyFarm,
    Noclip = Noclip,
    ESP = ESP,
    AutoTP = AutoTP,
    SpeedHack = SpeedHack,
    AutoRejoin = AutoRejoin
}

if not ShadowBreaker.Config.SilentMode then
    print("🔮 ShadowBreaker v10.0 loaded successfully")
    print("📜 Use ShadowBreakerAPI for direct control")
end

return getgenv().ShadowBreakerAPI
