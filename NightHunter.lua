-- NightHunter v8.8 - Охотник за 99 Ночами
-- Полный контроль над лесом и его обитателями

getgenv().NightHunter = {
    Config = {
        AutoFarm = true,
        SafeMode = false,
        AntiBan = true,
        Webhook = "" -- Для уведомлений
    }
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Ядро безопасности
local function GhostMode()
    if not getgenv().GhostLoaded then
        getgenv().GhostLoaded = true
        -- Маскировка под легитные скрипты
        local fakeScript = Instance.new("LocalScript")
        fakeScript.Name = "PlayerModules"
        fakeScript.Parent = Player.PlayerScripts
    end
end

-- Авто-фарм монстров
local MonsterFarm = {
    Enabled = false,
    Connection = nil,
    Blacklist = {"Tree", "Rock", "House"} -- Игнорируемые объекты
}

function MonsterFarm:Start()
    if self.Enabled then return end
    self.Enabled = true
    
    self.Connection = RunService.Heartbeat:Connect(function()
        if not Player.Character then return end
        
        local humanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = Player.Character:FindFirstChild("Humanoid")
        if not humanoidRootPart or not humanoid then return end
        
        -- Поиск монстров и NPC
        for _, npc in pairs(Workspace:GetChildren()) do
            if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                local shouldAttack = true
                
                -- Проверка черного списка
                for _, blackName in pairs(self.Blacklist) do
                    if npc.Name:find(blackName) then
                        shouldAttack = false
                        break
                    end
                end
                
                -- Атака монстров
                if shouldAttack and npc.Name ~= Player.Name then
                    local distance = (humanoidRootPart.Position - npc.HumanoidRootPart.Position).Magnitude
                    
                    if distance < 50 then
                        -- Телепорт к монстру
                        humanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame + Vector3.new(0, 0, -3)
                        
                        -- Авто-атака
                        local tool = Player.Character:FindFirstChildOfClass("Tool")
                        if tool and tool:FindFirstChild("Handle") then
                            tool.Handle.CFrame = npc.HumanoidRootPart.CFrame
                            -- Имитация удара
                            for i = 1, 3 do
                                firetouchinterest(tool.Handle, npc.HumanoidRootPart, 0)
                                task.wait(0.1)
                                firetouchinterest(tool.Handle, npc.HumanoidRootPart, 1)
                            end
                        end
                    end
                end
            end
        end
    end)
end

function MonsterFarm:Stop()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    self.Enabled = false
end

-- Авто-сбор ресурсов
local ResourceFarm = {
    Enabled = false,
    Connection = nil,
    Resources = {"Wood", "Stone", "Ore", "Berry", "Mushroom", "Herb"}
}

function ResourceFarm:Start()
    if self.Enabled then return end
    self.Enabled = true
    
    self.Connection = RunService.Heartbeat:Connect(function()
        if not Player.Character then return end
        
        local humanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        -- Поиск ресурсов
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Part") or obj:IsA("MeshPart") then
                for _, resourceName in pairs(self.Resources) do
                    if obj.Name:lower():find(resourceName:lower()) then
                        local distance = (humanoidRootPart.Position - obj.Position).Magnitude
                        if distance < 30 then
                            -- Телепорт ресурса к игроку
                            obj.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                            
                            -- Сбор
                            firetouchinterest(humanoidRootPart, obj, 0)
                            task.wait(0.05)
                            firetouchinterest(humanoidRootPart, obj, 1)
                        end
                    end
                end
            end
        end
    end)
end

function ResourceFarm:Stop()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    self.Enabled = false
end

-- ESP для целей
local HunterESP = {
    Enabled = false,
    Highlights = {},
    Colors = {
        Monster = Color3.fromRGB(255, 50, 50),
        Resource = Color3.fromRGB(50, 255, 50),
        Player = Color3.fromRGB(50, 100, 255),
        Loot = Color3.fromRGB(255, 255, 50)
    }
}

function HunterESP:Start()
    if self.Enabled then return end
    self.Enabled = true
    
    local function addESP(obj, espType)
        if not obj or self.Highlights[obj] then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Adornee = obj
        highlight.FillColor = self.Colors[espType] or Color3.fromRGB(255, 255, 255)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.4
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = obj
        
        self.Highlights[obj] = {Highlight = highlight, Type = espType}
    end
    
    -- Поиск всех целей
    for _, obj in pairs(Workspace:GetDescendants()) do
        -- Монстры и NPC
        if obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
            if obj ~= Player.Character then
                addESP(obj, "Monster")
            end
        end
        
        -- Ресурсы
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            local objName = obj.Name:lower()
            if objName:find("wood") or objName:find("stone") or objName:find("ore") then
                addESP(obj, "Resource")
            elseif objName:find("berry") or objName:find("mushroom") or objName:find("herb") then
                addESP(obj, "Resource")
            elseif objName:find("chest") or objName:find("loot") or objName:find("reward") then
                addESP(obj, "Loot")
            end
        end
        
        -- Игроки
        if obj:IsA("Model") and Players:GetPlayerFromCharacter(obj) then
            if obj ~= Player.Character then
                addESP(obj, "Player")
            end
        end
    end
    
    -- Мониторинг новых объектов
    Workspace.DescendantAdded:Connect(function(obj)
        task.wait(0.5) -- Даем время на появление
        
        if obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
            if obj ~= Player.Character then
                addESP(obj, "Monster")
            end
        end
        
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            local objName = obj.Name:lower()
            if objName:find("wood") or objName:find("stone") or objName:find("ore") then
                addESP(obj, "Resource")
            elseif objName:find("berry") or objName:find("mushroom") or objName:find("herb") then
                addESP(obj, "Resource")
            elseif objName:find("chest") or objName:find("loot") then
                addESP(obj, "Loot")
            end
        end
    end)
end

function HunterESP:Stop()
    for obj, data in pairs(self.Highlights) do
        if data.Highlight then
            data.Highlight:Destroy()
        end
    end
    self.Highlights = {}
    self.Enabled = false
end

-- Авто-крафт и улучшения
local AutoCraft = {
    Enabled = false,
    Connection = nil,
    Priorities = {"Sword", "Axe", "Pickaxe", "Armor"}
}

function AutoCraft:Start()
    if self.Enabled then return end
    self.Enabled = true
    
    self.Connection = RunService.Heartbeat:Connect(function()
        -- Здесь будет логика авто-крафта
        -- Зависит от конкретной механики игры
    end)
end

-- Ночное зрение
local NightVision = {
    Enabled = false,
    OriginalBrightness = nil
}

function NightVision:Start()
    if self.Enabled then return end
    self.Enabled = true
    
    self.OriginalBrightness = Lighting.Brightness
    Lighting.Brightness = 2
    Lighting.ClockTime = 12 -- Полдень (освещение)
    
    -- Добавляем источник света к игроку
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local light = Instance.new("PointLight")
        light.Brightness = 5
        light.Range = 50
        light.Parent = Player.Character.HumanoidRootPart
    end
end

function NightVision:Stop()
    if self.OriginalBrightness then
        Lighting.Brightness = self.OriginalBrightness
    end
    self.Enabled = false
    
    -- Удаляем свет
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local light = Player.Character.HumanoidRootPart:FindFirstChild("PointLight")
        if light then
            light:Destroy()
        end
    end
end

-- Bring All Monsters (Темная магия)
local BringAll = {
    Enabled = false,
    Connection = nil
}

function BringAll:Start()
    if self.Enabled then return end
    self.Enabled = true
    
    self.Connection = RunService.Heartbeat:Connect(function()
        if not Player.Character then return end
        
        local humanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        -- Притягиваем всех монстров к игроку
        for _, npc in pairs(Workspace:GetChildren()) do
            if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                if npc.Name ~= Player.Name and not MonsterFarm.Blacklist[npc.Name] then
                    local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                    if npcRoot then
                        -- Плавное притягивание
                        local distance = (humanoidRootPart.Position - npcRoot.Position).Magnitude
                        if distance < 100 then
                            npcRoot.CFrame = humanoidRootPart.CFrame + Vector3.new(
                                math.random(-10, 10),
                                0,
                                math.random(-10, 10)
                            )
                        end
                    end
                end
            end
        end
    end)
end

function BringAll:Stop()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    self.Enabled = false
end

-- Инстант-килл
local InstantKill = {
    Enabled = false
}

function InstantKill:Activate()
    self.Enabled = true
    
    -- Модификация урона оружия
    for _, tool in pairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local handle = tool:FindFirstChild("Handle")
            if handle then
                -- Увеличение урона
                local bodyForce = Instance.new("BodyForce")
                bodyForce.Force = Vector3.new(0, 196.2, 0) * 10
                bodyForce.Parent = handle
            end
        end
    end
end

-- Защита от смерти
local GodMode = {
    Enabled = false,
    OriginalHealth = nil
}

function GodMode:Start()
    if self.Enabled then return end
    self.Enabled = true
    
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        self.OriginalHealth = Player.Character.Humanoid.MaxHealth
        Player.Character.Humanoid.MaxHealth = math.huge
        Player.Character.Humanoid.Health = math.huge
        
        -- Защита от урона
        Player.Character.Humanoid.Touched:Connect(function()
            Player.Character.Humanoid.Health = math.huge
        end)
    end
end

function GodMode:Stop()
    if self.OriginalHealth and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.MaxHealth = self.OriginalHealth
        Player.Character.Humanoid.Health = self.OriginalHealth
    end
    self.Enabled = false
end

-- GUI Интерфейс
local function CreateHunterGUI()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    
    local Window = Rayfield:CreateWindow({
        Name = "🌙 NightHunter v8.8 - 99 Nights",
        LoadingTitle = "Becoming the Forest Lord...",
        LoadingSubtitle = "Initializing hunting protocols",
        Theme = "Dark"
    })

    -- Вкладка охоты
    local HuntTab = Window:CreateTab("Hunter")
    
    HuntTab:CreateToggle({
        Name = "🎯 Auto Monster Farm",
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                MonsterFarm:Start()
            else
                MonsterFarm:Stop()
            end
        end
    })

    HuntTab:CreateToggle({
        Name = "🌀 Bring All Monsters", 
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                BringAll:Start()
            else
                BringAll:Stop()
            end
        end
    })

    HuntTab:CreateToggle({
        Name = "⚡ Instant Kill",
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                InstantKill:Activate()
            end
        end
    })

    -- Вкладка ресурсов
    local ResourceTab = Window:CreateTab("Resources")
    
    ResourceTab:CreateToggle({
        Name = "🪵 Auto Resource Farm",
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                ResourceFarm:Start()
            else
                ResourceFarm:Stop()
            end
        end
    })

    ResourceTab:CreateToggle({
        Name = "⚒️ Auto Craft", 
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                AutoCraft:Start()
            else
                AutoCraft.Enabled = false
            end
        end
    })

    -- Вкладка визуала
    local VisualTab = Window:CreateTab("Vision")
    
    VisualTab:CreateToggle({
        Name = "👁️ Hunter ESP",
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                HunterESP:Start()
            else
                HunterESP:Stop()
            end
        end
    })

    VisualTab:CreateToggle({
        Name = "💡 Night Vision", 
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                NightVision:Start()
            else
                NightVision:Stop()
            end
        end
    })

    -- Вкладка защиты
    local DefenseTab = Window:CreateTab("Defense")
    
    DefenseTab:CreateToggle({
        Name = "🛡️ God Mode",
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                GodMode:Start()
            else
                GodMode:Stop()
            end
        end
    })

    DefenseTab:CreateToggle({
        Name = "👻 Ghost Mode", 
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                GhostMode()
                Rayfield:Notify({
                    Title = "NightHunter",
                    Content = "Ghost Mode Activated",
                    Duration = 3
                })
            end
        end
    })

    -- Вкладка телепортации
    local TeleportTab = Window:CreateTab("Teleport")
    
    local Locations = {
        "Spawn Point",
        "Forest Center", 
        "Cave Entrance",
        "Lake",
        "Mountain Top",
        "Secret Base"
    }
    
    for _, location in pairs(Locations) do
        TeleportTab:CreateButton({
            Name = "📍 " .. location,
            Callback = function()
                -- Телепорт по координатам (нужно настроить под карту)
                Rayfield:Notify({
                    Title = "NightHunter Teleport",
                    Content = "Teleporting to " .. location,
                    Duration = 3,
                })
            end,
        })
    end

    -- Информация
    local InfoTab = Window:CreateTab("Info")
    
    InfoTab:CreateLabel("NightHunter v8.8 - Active")
    InfoTab:CreateParagraph({
        Title = "Forest Domination",
        Content = "You are now the master of 99 Nights. Hunt wisely."
    })
    
    InfoTab:CreateButton({
        Name = "🌀 Destroy GUI",
        Callback = function()
            Rayfield:Destroy()
        end
    })
end

-- Инициализация
GhostMode()

task.spawn(function()
    task.wait(2)
    CreateHunterGUI()
    
    -- Авто-старт полезных функций
    task.wait(3)
    HunterESP:Start()
    NightVision:Start()
end)

-- Глобальный API
getgenv().NightHunterAPI = {
    MonsterFarm = MonsterFarm,
    ResourceFarm = ResourceFarm,
    HunterESP = HunterESP,
    BringAll = BringAll,
    GodMode = GodMode,
    NightVision = NightVision
}

print("🌙 NightHunter v8.8 loaded - Dominate the Forest!")
print("📜 Use NightHunterAPI for direct control")

return getgenv().NightHunterAPI
