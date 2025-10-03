-- MEGA DOMINATOR v5.1 - 99 NIGHTS FIXED
-- Исправленное определение монстров + отдельный бринг предметов

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- МЕГА ПЕРЕМЕННЫЕ
local MegaStates = {
    Flying = false,
    BringAllItems = false,
    BringWood = false,
    BringStone = false,
    BringOre = false,
    BringFood = false,
    BringMoney = false,
    AutoFarm = false,
    ESP = false,
    GodMode = false,
    Noclip = false,
    SpeedHack = false,
    AutoClick = false,
    InfJump = false
}

local MegaConnections = {}
local ESPHighlights = {}

-- Умное определение монстров
local function IsMonster(npc)
    if not npc:FindFirstChild("Humanoid") then return false end
    if npc:FindFirstChild("Humanoid").Health <= 0 then return false end
    
    -- Игроки - не монстры
    if Players:GetPlayerFromCharacter(npc) then return false end
    
    -- Черный список имен игроков/дружественных NPC
    local blacklistNames = {
        "Player", "Friend", "Villager", "Trader", "Merchant", "NPC", "Civilian"
    }
    
    local npcName = npc.Name:lower()
    for _, blackName in pairs(blacklistNames) do
        if npcName:find(blackName:lower()) then
            return false
        end
    end
    
    -- Белый список монстров (добавь названия монстров из игры)
    local monsterKeywords = {
        "monster", "enemy", "zombie", "skeleton", "creature", "beast",
        "wolf", "bear", "spider", "goblin", "orc", "demon", "ghost"
    }
    
    for _, keyword in pairs(monsterKeywords) do
        if npcName:find(keyword) then
            return true
        end
    end
    
    -- Если не игрок и не в черном списке - считаем монстром
    return true
end

-- Определение типов предметов
local ItemTypes = {
    Wood = {"wood", "log", "lumber", "tree", "timber"},
    Stone = {"stone", "rock", "boulder", "pebble"},
    Ore = {"ore", "metal", "iron", "gold", "copper", "crystal", "gem"},
    Food = {"berry", "mushroom", "apple", "food", "meat", "fish", "bread"},
    Money = {"coin", "cash", "money", "gold", "treasure", "reward"}
}

local function GetItemType(itemName)
    local name = itemName:lower()
    for itemType, keywords in pairs(ItemTypes) do
        for _, keyword in pairs(keywords) do
            if name:find(keyword) then
                return itemType
            end
        end
    end
    return "Other"
end

-- МЕГА GUI
local function CreateMegaGUI()
    local MegaGUI = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local Top = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local CloseBtn = Instance.new("TextButton")
    local Tabs = Instance.new("Frame")
    local Content = Instance.new("ScrollingFrame")
    local UIList = Instance.new("UIListLayout")

    MegaGUI.Name = "MegaDominator"
    MegaGUI.Parent = game.CoreGui

    Main.Name = "Main"
    Main.Parent = MegaGUI
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Main.BorderSizePixel = 1
    Main.BorderColor3 = Color3.fromRGB(60, 60, 60)
    Main.Position = UDim2.new(0.2, 0, 0.2, 0)
    Main.Size = UDim2.new(0, 600, 0, 500)
    Main.Active = true
    Main.Draggable = true

    Top.Name = "Top"
    Top.Parent = Main
    Top.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Top.BorderSizePixel = 0
    Top.Size = UDim2.new(1, 0, 0, 40)

    Title.Name = "Title"
    Title.Parent = Top
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(0.8, 0, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🔥 MEGA DOMINATOR v5.1 | 99 NIGHTS"
    Title.TextColor3 = Color3.fromRGB(0, 255, 255)
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Position = UDim2.new(0.02, 0, 0, 0)

    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = Top
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Position = UDim2.new(0.95, 0, 0.2, 0)
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 14
    CloseBtn.MouseButton1Click:Connect(function()
        MegaGUI:Destroy()
    end)

    Tabs.Name = "Tabs"
    Tabs.Parent = Main
    Tabs.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Tabs.BorderSizePixel = 0
    Tabs.Position = UDim2.new(0, 0, 0, 45)
    Tabs.Size = UDim2.new(1, 0, 0, 50)

    Content.Name = "Content"
    Content.Parent = Main
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, 0, 0, 100)
    Content.Size = UDim2.new(1, 0, 1, -100)
    Content.ScrollBarThickness = 5
    Content.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)

    UIList.Parent = Content
    UIList.Padding = UDim.new(0, 5)
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Создаем вкладки
    local TabButtons = {}
    local TabNames = {"COMBAT", "ITEMS", "MOVEMENT", "VISUALS", "PLAYER"}

    for i, name in pairs(TabNames) do
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = name
        TabBtn.Parent = Tabs
        TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TabBtn.BorderSizePixel = 0
        TabBtn.Size = UDim2.new(0.18, 0, 0.8, 0)
        TabBtn.Position = UDim2.new(0.02 + (i-1)*0.19, 0, 0.1, 0)
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabBtn.TextSize = 10
        TabBtn.MouseButton1Click:Connect(function()
            UpdateMegaContent(name)
        end)
        table.insert(TabButtons, TabBtn)
    end

    -- Функции создания элементов
    local function CreateMegaToggle(config)
        local ToggleFrame = Instance.new("Frame")
        local ToggleLabel = Instance.new("TextLabel")
        local ToggleBtn = Instance.new("TextButton")

        ToggleFrame.Name = config.Name
        ToggleFrame.Parent = Content
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Size = UDim2.new(0.95, 0, 0, 30)

        ToggleLabel.Name = "Label"
        ToggleLabel.Parent = ToggleFrame
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Size = UDim2.new(0.8, 0, 1, 0)
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.Text = config.Name
        ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleLabel.TextSize = 12
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

        ToggleBtn.Name = "Toggle"
        ToggleBtn.Parent = ToggleFrame
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ToggleBtn.BorderSizePixel = 0
        ToggleBtn.Position = UDim2.new(0.85, 0, 0.1, 0)
        ToggleBtn.Size = UDim2.new(0, 50, 0, 20)
        ToggleBtn.Font = Enum.Font.Gotham
        ToggleBtn.Text = "OFF"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleBtn.TextSize = 10

        local state = config.CurrentValue or false

        local function UpdateToggle()
            if state then
                ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                ToggleBtn.Text = "ON"
            else
                ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                ToggleBtn.Text = "OFF"
            end
            config.Callback(state)
        end

        ToggleBtn.MouseButton1Click:Connect(function()
            state = not state
            UpdateToggle()
        end)

        UpdateToggle()

        return {Set = function(v) state = v UpdateToggle() end}
    end

    local function CreateMegaButton(config)
        local Button = Instance.new("TextButton")
        Button.Name = config.Name
        Button.Parent = Content
        Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(0.95, 0, 0, 35)
        Button.Font = Enum.Font.Gotham
        Button.Text = config.Name
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 12
        
        Button.MouseButton1Click:Connect(config.Callback)
        
        return Button
    end

    -- Функция обновления контента
    function UpdateMegaContent(tab)
        for _, child in pairs(Content:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then
                child:Destroy()
            end
        end

        if tab == "COMBAT" then
            CreateMegaToggle({
                Name = "🎯 Auto Farm Monsters", 
                Callback = function(v) 
                    MegaStates.AutoFarm = v 
                    if v then 
                        StartAutoFarm() 
                    else 
                        StopAutoFarm() 
                    end 
                end 
            })
            
            CreateMegaToggle({
                Name = "⚡ Instant Kill", 
                Callback = function(v) 
                    if v then 
                        EnableInstantKill() 
                    end 
                end 
            })
            
            CreateMegaButton({
                Name = "📊 Scan Monsters", 
                Callback = function() 
                    ScanMonsters() 
                end 
            })

        elseif tab == "ITEMS" then
            CreateMegaToggle({
                Name = "🌀 Bring ALL Items", 
                Callback = function(v) 
                    MegaStates.BringAllItems = v 
                    if v then 
                        StartBringAllItems() 
                    else 
                        StopBringAllItems() 
                    end 
                end 
            })
            
            CreateMegaToggle({
                Name = "🪵 Bring Wood Only", 
                Callback = function(v) 
                    MegaStates.BringWood = v 
                    if v then 
                        StartBringWood() 
                    else 
                        StopBringWood() 
                    end 
                end 
            })
            
            CreateMegaToggle({
                Name = "🪨 Bring Stone Only", 
                Callback = function(v) 
                    MegaStates.BringStone = v 
                    if v then 
                        StartBringStone() 
                    else 
                        StopBringStone() 
                    end 
                end 
            })
            
            CreateMegaToggle({
                Name = "💎 Bring Ore Only", 
                Callback = function(v) 
                    MegaStates.BringOre = v 
                    if v then 
                        StartBringOre() 
                    else 
                        StopBringOre() 
                    end 
                end 
            })
            
            CreateMegaToggle({
                Name = "🍎 Bring Food Only", 
                Callback = function(v) 
                    MegaStates.BringFood = v 
                    if v then 
                        StartBringFood() 
                    else 
                        StopBringFood() 
                    end 
                end 
            })
            
            CreateMegaToggle({
                Name = "💰 Bring Money Only", 
                Callback = function(v) 
                    MegaStates.BringMoney = v 
                    if v then 
                        StartBringMoney() 
                    else 
                        StopBringMoney() 
                    end 
                end 
            })
            
            CreateMegaButton({
                Name = "📦 Collect All Nearby", 
                Callback = function() 
                    CollectAllNearby() 
                end 
            })

        elseif tab == "MOVEMENT" then
            CreateMegaToggle({
                Name = "🪽 Fly Mode", 
                Callback = function(v) 
                    MegaStates.Flying = v 
                    if v then 
                        StartFlying() 
                    else 
                        StopFlying() 
                    end 
                end 
            })
            
            CreateMegaToggle({
                Name = "👻 No Clip", 
                Callback = function(v) 
                    MegaStates.Noclip = v 
                    if v then 
                        StartNoclip() 
                    else 
                        StopNoclip() 
                    end 
                end 
            })
            
            CreateMegaToggle({
                Name = "🏃 Speed Hack", 
                Callback = function(v) 
                    MegaStates.SpeedHack = v 
                    if v then 
                        SetSpeed(50) 
                    else 
                        SetSpeed(16) 
                    end 
                end 
            })
            
            CreateMegaToggle({
                Name = "🦘 Inf Jump", 
                Callback = function(v) 
                    MegaStates.InfJump = v 
                    if v then 
                        EnableInfJump() 
                    else 
                        DisableInfJump() 
                    end 
                end 
            })

        elseif tab == "VISUALS" then
            CreateMegaToggle({
                Name = "👁️ ESP Monsters", 
                Callback = function(v) 
                    MegaStates.ESP = v 
                    if v then 
                        StartESP() 
                    else 
                        StopESP() 
                    end 
                end 
            })
            
            CreateMegaToggle({
                Name = "💡 Full Bright", 
                Callback = function(v) 
                    if v then 
                        EnableFullBright() 
                    else 
                        DisableFullBright() 
                    end 
                end 
            })

        elseif tab == "PLAYER" then
            CreateMegaToggle({
                Name = "🛡️ God Mode", 
                Callback = function(v) 
                    MegaStates.GodMode = v 
                    if v then 
                        EnableGodMode() 
                    else 
                        DisableGodMode() 
                    end 
                end 
            })
            
            CreateMegaButton({
                Name = "📍 TP to Mouse", 
                Callback = function() 
                    TeleportToMouse() 
                end 
            })
        end
    end

    UpdateMegaContent("COMBAT")
    return MegaGUI
end

-- ОСНОВНЫЕ ФУНКЦИИ
function StartAutoFarm()
    MegaConnections.Farm = RunService.Heartbeat:Connect(function()
        if not MegaStates.AutoFarm then return end
        local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        for _, npc in pairs(Workspace:GetChildren()) do
            if IsMonster(npc) then
                local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                if npcRoot then
                    local dist = (root.Position - npcRoot.Position).Magnitude
                    if dist < 50 then
                        -- Телепорт к монстру
                        root.CFrame = npcRoot.CFrame + Vector3.new(0, 0, -3)
                        
                        -- Авто-атака
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
    end)
end

function StopAutoFarm()
    if MegaConnections.Farm then
        MegaConnections.Farm:Disconnect()
        MegaConnections.Farm = nil
    end
end

-- ФУНКЦИИ БРИНГА ПРЕДМЕТОВ
function StartBringAllItems()
    MegaConnections.BringAll = RunService.Heartbeat:Connect(function()
        if not MegaStates.BringAllItems then return end
        BringItemsByType(nil) -- Все предметы
    end)
end

function StopBringAllItems()
    if MegaConnections.BringAll then
        MegaConnections.BringAll:Disconnect()
        MegaConnections.BringAll = nil
    end
end

function StartBringWood()
    MegaConnections.BringWood = RunService.Heartbeat:Connect(function()
        if not MegaStates.BringWood then return end
        BringItemsByType("Wood")
    end)
end

function StopBringWood()
    if MegaConnections.BringWood then
        MegaConnections.BringWood:Disconnect()
        MegaConnections.BringWood = nil
    end
end

function StartBringStone()
    MegaConnections.BringStone = RunService.Heartbeat:Connect(function()
        if not MegaStates.BringStone then return end
        BringItemsByType("Stone")
    end)
end

function StopBringStone()
    if MegaConnections.BringStone then
        MegaConnections.BringStone:Disconnect()
        MegaConnections.BringStone = nil
    end
end

function StartBringOre()
    MegaConnections.BringOre = RunService.Heartbeat:Connect(function()
        if not MegaStates.BringOre then return end
        BringItemsByType("Ore")
    end)
end

function StopBringOre()
    if MegaConnections.BringOre then
        MegaConnections.BringOre:Disconnect()
        MegaConnections.BringOre = nil
    end
end

function StartBringFood()
    MegaConnections.BringFood = RunService.Heartbeat:Connect(function()
        if not MegaStates.BringFood then return end
        BringItemsByType("Food")
    end)
end

function StopBringFood()
    if MegaConnections.BringFood then
        MegaConnections.BringFood:Disconnect()
        MegaConnections.BringFood = nil
    end
end

function StartBringMoney()
    MegaConnections.BringMoney = RunService.Heartbeat:Connect(function()
        if not MegaStates.BringMoney then return end
        BringItemsByType("Money")
    end)
end

function StopBringMoney()
    if MegaConnections.BringMoney then
        MegaConnections.BringMoney:Disconnect()
        MegaConnections.BringMoney = nil
    end
end

-- УНИВЕРСАЛЬНАЯ ФУНКЦИЯ БРИНГА
function BringItemsByType(itemType)
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            local objItemType = GetItemType(obj.Name)
            
            -- Если тип указан - берем только его, иначе все
            if itemType == nil or objItemType == itemType then
                local dist = (root.Position - obj.Position).Magnitude
                if dist < 100 then
                    -- Плавный бринг
                    local tween = TweenService:Create(obj, TweenInfo.new(0.3), {
                        CFrame = root.CFrame + Vector3.new(
                            math.random(-3, 3),
                            3,
                            math.random(-3, 3)
                        )
                    })
                    tween:Play()
                end
            end
        end
    end
end

function CollectAllNearby()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            local dist = (root.Position - obj.Position).Magnitude
            if dist < 30 then
                obj.CFrame = root.CFrame + Vector3.new(0, 3, 0)
                firetouchinterest(root, obj, 0)
                wait(0.05)
                firetouchinterest(root, obj, 1)
            end
        end
    end
end

function ScanMonsters()
    local monsterCount = 0
    for _, npc in pairs(Workspace:GetChildren()) do
        if IsMonster(npc) then
            monsterCount = monsterCount + 1
            print("🎯 Monster found: " .. npc.Name)
        end
    end
    print("📊 Total monsters: " .. monsterCount)
end

-- ОСТАЛЬНЫЕ ФУНКЦИИ (летание, ноклип, ESP и т.д.)
function StartFlying()
    MegaConnections.Fly = RunService.Heartbeat:Connect(function()
        if not MegaStates.Flying or not Player.Character then return end
        local root = Player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local cam = Workspace.CurrentCamera
        local move = Vector3.new(0,0,0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move + Vector3.new(0,-1,0) end
        
        if move.Magnitude > 0 then
            root.Velocity = move.Unit * 100
        else
            root.Velocity = Vector3.new(0,0,0)
        end
    end)
end

function StopFlying()
    if MegaConnections.Fly then
        MegaConnections.Fly:Disconnect()
        MegaConnections.Fly = nil
    end
end

function StartNoclip()
    MegaConnections.Noclip = RunService.Stepped:Connect(function()
        if not MegaStates.Noclip then return end
        if Player.Character then
            for _, part in pairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

function StopNoclip()
    if MegaConnections.Noclip then
        MegaConnections.Noclip:Disconnect()
        MegaConnections.Noclip = nil
    end
end

function StartESP()
    for _, npc in pairs(Workspace:GetChildren()) do
        if IsMonster(npc) then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = npc
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.Parent = npc
            ESPHighlights[npc] = highlight
        end
    end
end

function StopESP()
    for _, highlight in pairs(ESPHighlights) do
        highlight:Destroy()
    end
    ESPHighlights = {}
end

function SetSpeed(value)
    if Player.Character then
        local humanoid = Player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
end

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

function EnableInfJump()
    MegaConnections.Jump = UserInputService.JumpRequest:Connect(function()
        if Player.Character then
            local humanoid = Player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

function DisableInfJump()
    if MegaConnections.Jump then
        MegaConnections.Jump:Disconnect()
        MegaConnections.Jump = nil
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

function EnableInstantKill()
    -- Увеличиваем урон оружия
    for _, tool in pairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local handle = tool:FindFirstChild("Handle")
            if handle then
                local bodyForce = Instance.new("BodyForce")
                bodyForce.Force = Vector3.new(0, 196.2, 0) * 10
                bodyForce.Parent = handle
            end
        end
    end
end

function EnableFullBright()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
end

function DisableFullBright()
    Lighting.Brightness = 1
    Lighting.ClockTime = 12
end

-- ЗАГРУЗКА
wait(1)
CreateMegaGUI()

print("🔥 MEGA DOMINATOR v5.1 - 99 NIGHTS")
print("✅ SMART MONSTER DETECTION")
print("🎯 SEPARATE ITEM BRINGING")
print("🚀 READY FOR DOMINATION!")
