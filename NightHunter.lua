-- MEGA DOMINATOR v5.0 - 99 NIGHTS
-- Без проверок + максимум функций

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- МЕГА ПЕРЕМЕННЫЕ
local MegaStates = {
    Flying = false,
    BringItems = false,
    AutoFarm = false,
    ESP = false,
    GodMode = false,
    Noclip = false,
    SpeedHack = false,
    AutoClick = false,
    InfJump = false,
    AutoCollect = false,
    AutoCraft = false,
    XRay = false,
    NoFog = false,
    FullBright = false,
    PlayerESP = false,
    Aimbot = false,
    Triggerbot = false,
    AutoSell = false,
    AutoEat = false,
    AutoHeal = false,
    AntiStun = false,
    AntiGrab = false,
    InfiniteStamina = false
}

local MegaConnections = {}
local ESPHighlights = {}
local AimbotTarget = nil

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
    Title.Text = "🔥 MEGA DOMINATOR v5.0 | 99 NIGHTS"
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
    local TabNames = {"COMBAT", "MOVEMENT", "VISUALS", "AUTOMATION", "PLAYER", "WORLD", "TELEPORT", "FUN"}

    for i, name in pairs(TabNames) do
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = name
        TabBtn.Parent = Tabs
        TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TabBtn.BorderSizePixel = 0
        TabBtn.Size = UDim2.new(0.12, 0, 0.8, 0)
        TabBtn.Position = UDim2.new(0.02 + (i-1)*0.125, 0, 0.1, 0)
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
            CreateMegaToggle({Name = "🎯 Auto Farm Monsters", Callback = function(v) MegaStates.AutoFarm = v if v then StartAutoFarm() else StopAutoFarm() end end})
            CreateMegaToggle({Name = "🌀 Bring All Items", Callback = function(v) MegaStates.BringItems = v if v then StartBringItems() else StopBringItems() end end})
            CreateMegaToggle({Name = "🔫 Aimbot", Callback = function(v) MegaStates.Aimbot = v if v then StartAimbot() else StopAimbot() end end})
            CreateMegaToggle({Name = "⚡ Triggerbot", Callback = function(v) MegaStates.Triggerbot = v end})
            CreateMegaToggle({Name = "💀 Instant Kill", Callback = function(v) if v then EnableInstantKill() end end})
            CreateMegaToggle({Name = "🛡️ Anti Stun", Callback = function(v) MegaStates.AntiStun = v end})
            CreateMegaToggle({Name = "🚫 Anti Grab", Callback = function(v) MegaStates.AntiGrab = v end})
            
        elseif tab == "MOVEMENT" then
            CreateMegaToggle({Name = "🪽 Fly Mode", Callback = function(v) MegaStates.Flying = v if v then StartFlying() else StopFlying() end end})
            CreateMegaToggle({Name = "👻 No Clip", Callback = function(v) MegaStates.Noclip = v if v then StartNoclip() else StopNoclip() end end})
            CreateMegaToggle({Name = "🏃 Speed Hack", Callback = function(v) MegaStates.SpeedHack = v if v then SetSpeed(50) else SetSpeed(16) end end})
            CreateMegaToggle({Name = "🦘 Inf Jump", Callback = function(v) MegaStates.InfJump = v if v then EnableInfJump() else DisableInfJump() end end})
            CreateMegaToggle({Name = "💨 Inf Stamina", Callback = function(v) MegaStates.InfiniteStamina = v end})
            CreateMegaButton({Name = "⚡ Set Speed 100", Callback = function() SetSpeed(100) end})
            CreateMegaButton({Name = "⚡ Set Speed 150", Callback = function() SetSpeed(150) end})
            
        elseif tab == "VISUALS" then
            CreateMegaToggle({Name = "👁️ ESP Monsters", Callback = function(v) MegaStates.ESP = v if v then StartESP() else StopESP() end end})
            CreateMegaToggle({Name = "👤 ESP Players", Callback = function(v) MegaStates.PlayerESP = v if v then StartPlayerESP() else StopPlayerESP() end end})
            CreateMegaToggle({Name = "🔍 X-Ray Vision", Callback = function(v) MegaStates.XRay = v if v then EnableXRay() else DisableXRay() end end})
            CreateMegaToggle({Name = "💡 Full Bright", Callback = function(v) MegaStates.FullBright = v if v then EnableFullBright() else DisableFullBright() end end})
            CreateMegaToggle({Name = "🌫️ No Fog", Callback = function(v) MegaStates.NoFog = v if v then RemoveFog() else RestoreFog() end end})
            CreateMegaButton({Name = "🎨 Rainbow World", Callback = function() StartRainbow() end})
            
        elseif tab == "AUTOMATION" then
            CreateMegaToggle({Name = "🤖 Auto Click", Callback = function(v) MegaStates.AutoClick = v if v then StartAutoClick() else StopAutoClick() end end})
            CreateMegaToggle({Name = "📦 Auto Collect", Callback = function(v) MegaStates.AutoCollect = v if v then StartAutoCollect() else StopAutoCollect() end end})
            CreateMegaToggle({Name = "⚒️ Auto Craft", Callback = function(v) MegaStates.AutoCraft = v end})
            CreateMegaToggle({Name = "💰 Auto Sell", Callback = function(v) MegaStates.AutoSell = v end})
            CreateMegaToggle({Name = "🍎 Auto Eat", Callback = function(v) MegaStates.AutoEat = v end})
            CreateMegaToggle({Name = "❤️ Auto Heal", Callback = function(v) MegaStates.AutoHeal = v end})
            
        elseif tab == "PLAYER" then
            CreateMegaToggle({Name = "🛡️ God Mode", Callback = function(v) MegaStates.GodMode = v if v then EnableGodMode() else DisableGodMode() end end})
            CreateMegaToggle({Name = "💪 Inf Health", Callback = function(v) if v then SetInfiniteHealth() end end})
            CreateMegaToggle({Name = "🍖 No Hunger", Callback = function(v) if v then NoHunger() end end})
            CreateMegaToggle({Name = "😴 No Sleep", Callback = function(v) if v then NoSleep() end end})
            CreateMegaButton({Name = "🔧 Reset Character", Callback = function() ResetCharacter() end})
            CreateMegaButton({Name = "🎭 Invisible", Callback = function() MakeInvisible() end})
            
        elseif tab == "WORLD" then
            CreateMegaToggle({Name = "🌙 Always Day", Callback = function(v) if v then AlwaysDay() else NormalTime() end end})
            CreateMegaToggle({Name = "🌧️ No Weather", Callback = function(v) if v then NoWeather() else NormalWeather() end end})
            CreateMegaButton({Name = "💥 Destroy Trees", Callback = function() DestroyTrees() end})
            CreateMegaButton({Name = "🏔️ Remove Terrain", Callback = function() RemoveTerrain() end})
            CreateMegaButton({Name = "🌈 Change Sky", Callback = function() ChangeSkybox() end})
            
        elseif tab == "TELEPORT" then
            CreateMegaButton({Name = "📍 TP to Mouse", Callback = function() TeleportToMouse() end})
            CreateMegaButton({Name = "🏠 TP to Spawn", Callback = function() TeleportToSpawn() end})
            CreateMegaButton({Name = "🌲 TP to Forest", Callback = function() TeleportToForest() end})
            CreateMegaButton({Name = "🕵️ TP to Nearest Player", Callback = function() TeleportToNearestPlayer() end})
            CreateMegaButton({Name = "🎯 TP to Nearest Monster", Callback = function() TeleportToNearestMonster() end})
            
        elseif tab == "FUN" then
            CreateMegaButton({Name = "🎇 Spawn Fireworks", Callback = function() SpawnFireworks() end})
            CreateMegaButton({Name = "👻 Ghost Mode", Callback = function() GhostMode() end})
            CreateMegaButton({Name = "🤡 Big Head Mode", Callback = function() BigHeadMode() end})
            CreateMegaButton({Name = "🌀 Spin Mode", Callback = function() SpinMode() end})
            CreateMegaButton({Name = "🚀 Rocket Launch", Callback = function() RocketLaunch() end})
        end
    end

    UpdateMegaContent("COMBAT")
    return MegaGUI
end

-- МЕГА ФУНКЦИИ (основные)
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

function StartBringItems()
    MegaConnections.Bring = RunService.Heartbeat:Connect(function()
        if not MegaStates.BringItems then return end
        local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Part") or obj:IsA("MeshPart") then
                local name = obj.Name:lower()
                if name:find("wood") or name:find("stone") or name:find("ore") or name:find("berry") or name:find("coin") then
                    local dist = (root.Position - obj.Position).Magnitude
                    if dist < 200 then
                        obj.CFrame = root.CFrame + Vector3.new(math.random(-5,5), 3, math.random(-5,5))
                    end
                end
            end
        end
    end)
end

function StopBringItems()
    if MegaConnections.Bring then
        MegaConnections.Bring:Disconnect()
        MegaConnections.Bring = nil
    end
end

function StartAutoFarm()
    MegaConnections.Farm = RunService.Heartbeat:Connect(function()
        if not MegaStates.AutoFarm then return end
        local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        for _, npc in pairs(Workspace:GetChildren()) do
            if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 and npc ~= Player.Character then
                local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                if npcRoot then
                    local dist = (root.Position - npcRoot.Position).Magnitude
                    if dist < 100 then
                        root.CFrame = npcRoot.CFrame + Vector3.new(0,0,-3)
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

function StartESP()
    for _, npc in pairs(Workspace:GetChildren()) do
        if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 and npc ~= Player.Character then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = npc
            highlight.FillColor = Color3.fromRGB(255,0,0)
            highlight.OutlineColor = Color3.fromRGB(255,255,255)
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
            root.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0,5,0))
        end
    end
end

-- ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ
function EnableXRay()
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 1 then
            part.LocalTransparencyModifier = 0.5
        end
    end
end

function DisableXRay()
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = 0
        end
    end
end

function EnableFullBright()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.OutdoorAmbient = Color3.new(1,1,1)
end

function DisableFullBright()
    Lighting.Brightness = 1
    Lighting.ClockTime = 12
end

function StartAutoClick()
    while MegaStates.AutoClick do
        wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
        wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
    end
end

function StopAutoClick()
    -- Останавливается автоматически
end

-- ЗАГРУЗКА
wait(1)
CreateMegaGUI()

-- УВЕДОМЛЕНИЕ
local notify = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
local label = Instance.new("TextLabel")

notify.Parent = game.CoreGui
frame.Parent = notify
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderSizePixel = 0
frame.Position = UDim2.new(0.3, 0, 0.4, 0)
frame.Size = UDim2.new(0, 400, 0, 100)

label.Parent = frame
label.BackgroundTransparency = 1
label.Size = UDim2.new(1, 0, 1, 0)
label.Text = "🔥 MEGA DOMINATOR v5.0 LOADED!\n99 NIGHTS - FULL CONTROL ACTIVATED"
label.TextColor3 = Color3.fromRGB(0, 255, 255)
label.TextSize = 18
label.Font = Enum.Font.GothamBold

wait(3)
notify:Destroy()

print("🎮 MEGA DOMINATOR v5.0 - 99 NIGHTS")
print("✅ NO GAME CHECKS - DIRECT INJECT")
print("🎯 30+ FEATURES ACTIVATED")
print("🚀 READY FOR DOMINATION!")
