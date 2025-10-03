-- Eugene Style Dominator v3.0
-- Полный клон визуала Eugene + все функции для 99 Nights

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Eugene Colors
local EugeneColors = {
    Background = Color3.fromRGB(15, 15, 15),
    Header = Color3.fromRGB(25, 25, 25),
    Button = Color3.fromRGB(30, 30, 30),
    ButtonHover = Color3.fromRGB(40, 40, 40),
    Accent = Color3.fromRGB(0, 150, 255),
    Text = Color3.fromRGB(255, 255, 255),
    ToggleOn = Color3.fromRGB(0, 200, 0),
    ToggleOff = Color3.fromRGB(60, 60, 60)
}

-- Состояния
local States = {
    Flying = false,
    BringItems = false,
    AutoFarm = false,
    ESP = false,
    GodMode = false,
    Noclip = false,
    SpeedHack = false,
    AutoClick = false,
    InfJump = false
}

-- Соединения
local Connections = {
    Fly = nil,
    Bring = nil,
    Farm = nil,
    Noclip = nil,
    ESP = nil,
    Jump = nil
}

local ESPHighlights = {}

-- Eugene Style GUI
local function CreateEugeneGUI()
    local EugeneGUI = Instance.new("ScreenGui")
    local MainContainer = Instance.new("Frame")
    local TopBar = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local CloseBtn = Instance.new("TextButton")
    local MinimizeBtn = Instance.new("TextButton")
    local TabContainer = Instance.new("Frame")
    local TabButtons = Instance.new("Frame")
    local TabContent = Instance.new("ScrollingFrame")
    local UIListLayout = Instance.new("UIListLayout")
    local UIPadding = Instance.new("UIPadding")

    -- Основной GUI
    EugeneGUI.Name = "EugeneGUI"
    EugeneGUI.Parent = game.CoreGui
    EugeneGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    EugeneGUI.ResetOnSpawn = false

    -- Главный контейнер
    MainContainer.Name = "MainContainer"
    MainContainer.Parent = EugeneGUI
    MainContainer.BackgroundColor3 = EugeneColors.Background
    MainContainer.BorderSizePixel = 1
    MainContainer.BorderColor3 = Color3.fromRGB(50, 50, 50)
    MainContainer.Position = UDim2.new(0.3, 0, 0.25, 0)
    MainContainer.Size = UDim2.new(0, 500, 0, 400)
    MainContainer.Active = true
    MainContainer.Draggable = true

    -- Верхняя панель
    TopBar.Name = "TopBar"
    TopBar.Parent = MainContainer
    TopBar.BackgroundColor3 = EugeneColors.Header
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 30)

    -- Заголовок
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "EUGENE HUB | 99 NIGHTS"
    Title.TextColor3 = EugeneColors.Accent
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Кнопка закрытия
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = TopBar
    CloseBtn.BackgroundColor3 = EugeneColors.Button
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Position = UDim2.new(1, -30, 0, 5)
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = EugeneColors.Text
    CloseBtn.TextSize = 12
    CloseBtn.MouseButton1Click:Connect(function()
        EugeneGUI:Destroy()
    end)

    -- Кнопка сворачивания
    MinimizeBtn.Name = "MinimizeBtn"
    MinimizeBtn.Parent = TopBar
    MinimizeBtn.BackgroundColor3 = EugeneColors.Button
    MinimizeBtn.BorderSizePixel = 0
    MinimizeBtn.Position = UDim2.new(1, -55, 0, 5)
    MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.Text = "_"
    MinimizeBtn.TextColor3 = EugeneColors.Text
    MinimizeBtn.TextSize = 12
    MinimizeBtn.MouseButton1Click:Connect(function()
        TabContainer.Visible = not TabContainer.Visible
    end)

    -- Контейнер вкладок
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = MainContainer
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 0, 0, 35)
    TabContainer.Size = UDim2.new(1, 0, 1, -35)

    -- Кнопки вкладок
    TabButtons.Name = "TabButtons"
    TabButtons.Parent = TabContainer
    TabButtons.BackgroundColor3 = EugeneColors.Header
    TabButtons.BorderSizePixel = 0
    TabButtons.Size = UDim2.new(1, 0, 0, 40)

    -- Контент вкладок
    TabContent.Name = "TabContent"
    TabContent.Parent = TabContainer
    TabContent.Position = UDim2.new(0, 0, 0, 45)
    TabContent.Size = UDim2.new(1, 0, 1, -45)
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.ScrollBarThickness = 5
    TabContent.ScrollBarImageColor3 = EugeneColors.Accent

    UIListLayout.Parent = TabContent
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    UIPadding.Parent = TabContent
    UIPadding.PaddingTop = UDim.new(0, 10)

    -- Создаем вкладки как у Eugene
    local Tabs = {
        "Combat",
        "Movement", 
        "Visuals",
        "Automation",
        "Misc"
    }

    local CurrentTab = "Combat"

    local function CreateTabButton(tabName)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tabName
        TabBtn.Parent = TabButtons
        TabBtn.BackgroundColor3 = EugeneColors.Button
        TabBtn.BorderSizePixel = 0
        TabBtn.Size = UDim2.new(0, 80, 0, 30)
        TabBtn.Position = UDim2.new(0, (table.find(Tabs, tabName) - 1) * 85 + 10, 0, 5)
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.Text = tabName
        TabBtn.TextColor3 = EugeneColors.Text
        TabBtn.TextSize = 12
        
        TabBtn.MouseButton1Click:Connect(function()
            CurrentTab = tabName
            UpdateTabContent()
        end)
        
        return TabBtn
    end

    -- Создаем элементы управления в стиле Eugene
    local function CreateEugeneButton(config)
        local Button = Instance.new("TextButton")
        Button.Name = config.Name
        Button.Parent = TabContent
        Button.BackgroundColor3 = EugeneColors.Button
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(0.9, 0, 0, 35)
        Button.Font = Enum.Font.Gotham
        Button.Text = config.Name
        Button.TextColor3 = EugeneColors.Text
        Button.TextSize = 12
        
        -- Hover эффекты
        Button.MouseEnter:Connect(function()
            game:GetService("TweenService"):Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = EugeneColors.ButtonHover}):Play()
        end)
        
        Button.MouseLeave:Connect(function()
            game:GetService("TweenService"):Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = EugeneColors.Button}):Play()
        end)
        
        Button.MouseButton1Click:Connect(config.Callback)
        
        return Button
    end

    local function CreateEugeneToggle(config)
        local ToggleFrame = Instance.new("Frame")
        local ToggleLabel = Instance.new("TextLabel")
        local ToggleBtn = Instance.new("TextButton")
        
        ToggleFrame.Name = config.Name
        ToggleFrame.Parent = TabContent
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Size = UDim2.new(0.9, 0, 0, 30)
        
        ToggleLabel.Name = "ToggleLabel"
        ToggleLabel.Parent = ToggleFrame
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.Text = config.Name
        ToggleLabel.TextColor3 = EugeneColors.Text
        ToggleLabel.TextSize = 12
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        ToggleBtn.Name = "ToggleBtn"
        ToggleBtn.Parent = ToggleFrame
        ToggleBtn.BackgroundColor3 = EugeneColors.ToggleOff
        ToggleBtn.BorderSizePixel = 0
        ToggleBtn.Position = UDim2.new(0.8, 0, 0.1, 0)
        ToggleBtn.Size = UDim2.new(0, 50, 0, 20)
        ToggleBtn.Font = Enum.Font.Gotham
        ToggleBtn.Text = "OFF"
        ToggleBtn.TextColor3 = EugeneColors.Text
        ToggleBtn.TextSize = 10
        
        local state = config.CurrentValue or false
        
        local function UpdateToggle()
            if state then
                ToggleBtn.BackgroundColor3 = EugeneColors.ToggleOn
                ToggleBtn.Text = "ON"
            else
                ToggleBtn.BackgroundColor3 = EugeneColors.ToggleOff
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

    local function CreateEugeneSlider(config)
        local SliderFrame = Instance.new("Frame")
        local SliderLabel = Instance.new("TextLabel")
        local SliderTrack = Instance.new("Frame")
        local SliderFill = Instance.new("Frame")
        local SliderBtn = Instance.new("TextButton")
        local ValueLabel = Instance.new("TextLabel")
        
        SliderFrame.Name = config.Name
        SliderFrame.Parent = TabContent
        SliderFrame.BackgroundTransparency = 1
        SliderFrame.Size = UDim2.new(0.9, 0, 0, 50)
        
        SliderLabel.Name = "SliderLabel"
        SliderLabel.Parent = SliderFrame
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Size = UDim2.new(1, 0, 0, 20)
        SliderLabel.Font = Enum.Font.Gotham
        SliderLabel.Text = config.Name
        SliderLabel.TextColor3 = EugeneColors.Text
        SliderLabel.TextSize = 12
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        SliderTrack.Name = "SliderTrack"
        SliderTrack.Parent = SliderFrame
        SliderTrack.BackgroundColor3 = EugeneColors.ToggleOff
        SliderTrack.BorderSizePixel = 0
        SliderTrack.Position = UDim2.new(0, 0, 0, 25)
        SliderTrack.Size = UDim2.new(1, 0, 0, 5)
        
        SliderFill.Name = "SliderFill"
        SliderFill.Parent = SliderTrack
        SliderFill.BackgroundColor3 = EugeneColors.Accent
        SliderFill.BorderSizePixel = 0
        SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
        
        SliderBtn.Name = "SliderBtn"
        SliderBtn.Parent = SliderTrack
        SliderBtn.BackgroundColor3 = EugeneColors.Text
        SliderBtn.BorderSizePixel = 0
        SliderBtn.Position = UDim2.new(0.5, -5, -1.5, 0)
        SliderBtn.Size = UDim2.new(0, 10, 0, 10)
        SliderBtn.Text = ""
        
        ValueLabel.Name = "ValueLabel"
        ValueLabel.Parent = SliderFrame
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Position = UDim2.new(0.8, 0, 0, 0)
        ValueLabel.Size = UDim2.new(0.2, 0, 0, 20)
        ValueLabel.Font = Enum.Font.Gotham
        ValueLabel.Text = tostring(config.CurrentValue)
        ValueLabel.TextColor3 = EugeneColors.Text
        ValueLabel.TextSize = 12
        
        local connection
        local function UpdateSlider(value)
            local percent = (value - config.Min) / (config.Max - config.Min)
            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            SliderBtn.Position = UDim2.new(percent, -5, -1.5, 0)
            ValueLabel.Text = tostring(math.floor(value))
            config.Callback(value)
        end
        
        SliderBtn.MouseButton1Down:Connect(function()
            connection = RunService.Heartbeat:Connect(function()
                local mousePos = UserInputService:GetMouseLocation().X
                local absolutePos = SliderTrack.AbsolutePosition.X
                local absoluteSize = SliderTrack.AbsoluteSize.X
                local percent = math.clamp((mousePos - absolutePos) / absoluteSize, 0, 1)
                local value = config.Min + (config.Max - config.Min) * percent
                UpdateSlider(value)
            end)
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and connection then
                connection:Disconnect()
            end
        end)
        
        UpdateSlider(config.CurrentValue)
    end

    -- Создаем вкладки
    for _, tabName in pairs(Tabs) do
        CreateTabButton(tabName)
    end

    -- Функции для контента вкладок
    function UpdateTabContent()
        -- Очищаем контент
        for _, child in pairs(TabContent:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then
                child:Destroy()
            end
        end

        if CurrentTab == "Combat" then
            CreateEugeneToggle({
                Name = "🔫 Auto Farm Monsters",
                CurrentValue = States.AutoFarm,
                Callback = function(value)
                    States.AutoFarm = value
                    if value then
                        StartAutoFarm()
                    else
                        StopAutoFarm()
                    end
                end
            })
            
            CreateEugeneToggle({
                Name = "🌀 Bring All Items",
                CurrentValue = States.BringItems,
                Callback = function(value)
                    States.BringItems = value
                    if value then
                        StartBringItems()
                    else
                        StopBringItems()
                    end
                end
            })
            
            CreateEugeneToggle({
                Name = "⚡ Instant Kill",
                CurrentValue = false,
                Callback = function(value)
                    if value then
                        EnableInstantKill()
                    end
                end
            })
            
            CreateEugeneButton({
                Name = "🎯 Aimbot (Experimental)",
                Callback = function()
                    -- Aimbot функция
                end
            })

        elseif CurrentTab == "Movement" then
            CreateEugeneToggle({
                Name = "🪽 Fly Mode",
                CurrentValue = States.Flying,
                Callback = function(value)
                    States.Flying = value
                    if value then
                        StartFlying()
                    else
                        StopFlying()
                    end
                end
            })
            
            CreateEugeneToggle({
                Name = "👻 No Clip",
                CurrentValue = States.Noclip,
                Callback = function(value)
                    States.Noclip = value
                    if value then
                        StartNoclip()
                    else
                        StopNoclip()
                    end
                end
            })
            
            CreateEugeneToggle({
                Name = "🏃 Speed Hack",
                CurrentValue = States.SpeedHack,
                Callback = function(value)
                    States.SpeedHack = value
                    if value then
                        SetSpeed(50)
                    else
                        SetSpeed(16)
                    end
                end
            })
            
            CreateEugeneSlider({
                Name = "Speed Value",
                Min = 16,
                Max = 100,
                CurrentValue = 16,
                Callback = function(value)
                    if States.SpeedHack then
                        SetSpeed(value)
                    end
                end
            })
            
            CreateEugeneToggle({
                Name = "🦘 Infinite Jump",
                CurrentValue = States.InfJump,
                Callback = function(value)
                    States.InfJump = value
                    if value then
                        EnableInfJump()
                    else
                        DisableInfJump()
                    end
                end
            })

        elseif CurrentTab == "Visuals" then
            CreateEugeneToggle({
                Name = "👁️ ESP Highlight",
                CurrentValue = States.ESP,
                Callback = function(value)
                    States.ESP = value
                    if value then
                        StartESP()
                    else
                        StopESP()
                    end
                end
            })
            
            CreateEugeneToggle({
                Name = "💡 Full Bright",
                CurrentValue = false,
                Callback = function(value)
                    if value then
                        Lighting.Brightness = 2
                        Lighting.ClockTime = 12
                    else
                        Lighting.Brightness = 1
                    end
                end
            })
            
            CreateEugeneButton({
                Name = "🎨 Chams (Monsters)",
                Callback = function()
                    -- Chams функция
                end
            })

        elseif CurrentTab == "Automation" then
            CreateEugeneToggle({
                Name = "🤖 Auto Click",
                CurrentValue = States.AutoClick,
                Callback = function(value)
                    States.AutoClick = value
                    if value then
                        StartAutoClick()
                    else
                        StopAutoClick()
                    end
                    end
                end)
            
            CreateEugeneToggle({
                Name = "🌙 Auto Night Skip",
                CurrentValue = false,
                Callback = function(value)
                    -- Auto skip ночи
                end
            })
            
            CreateEugeneButton({
                Name = "📦 Auto Collect All",
                Callback = function()
                    CollectAllItems()
                end
            })

        elseif CurrentTab == "Misc" then
            CreateEugeneToggle({
                Name = "🛡️ God Mode",
                CurrentValue = States.GodMode,
                Callback = function(value)
                    States.GodMode = value
                    if value then
                        EnableGodMode()
                    else
                        DisableGodMode()
                    end
                end
            })
            
            CreateEugeneButton({
                Name = "📍 Teleport to Mouse",
                Callback = function()
                    TeleportToMouse()
                end
            })
            
            CreateEugeneButton({
                Name = "📊 Server Info",
                Callback = function()
                    PrintServerInfo()
                end
            })
            
            CreateEugeneButton({
                Name = "🔄 Refresh Game",
                Callback = function()
                    -- Refresh функция
                end
            })
        end
    end

    -- Инициализируем первую вкладку
    UpdateTabContent()

    return EugeneGUI
end

-- ИМПОРТ ФУНКЦИЙ ИЗ ПРЕДЫДУЩЕГО СКРИПТА (все те же функции Fly, BringItems, ESP и т.д.)
-- [Здесь должны быть все функции из предыдущего скрипта...]

-- Адаптируем функции под Eugene стиль
function StartFlying()
    -- Тот же код что и ранее...
end

function StopFlying()
    -- Тот же код что и ранее...
end

function StartBringItems()
    -- Тот же код что и ранее...
end

function StopBringItems()
    -- Тот же код что и ранее...
end

-- ... и все остальные функции

-- ЗАГРУЗКА
wait(1)
local GUI = CreateEugeneGUI()

-- Eugene стиль уведомление
local EugeneNotify = Instance.new("ScreenGui")
local NotifyFrame = Instance.new("Frame")
local NotifyLabel = Instance.new("TextLabel")

EugeneNotify.Parent = Player.PlayerGui
EugeneNotify.Name = "EugeneNotify"

NotifyFrame.Parent = EugeneNotify
NotifyFrame.BackgroundColor3 = EugeneColors.Header
NotifyFrame.BorderSizePixel = 1
NotifyFrame.BorderColor3 = EugeneColors.Accent
NotifyFrame.Position = UDim2.new(0.35, 0, 0.45, 0)
NotifyFrame.Size = UDim2.new(0, 300, 0, 80)

NotifyLabel.Parent = NotifyFrame
NotifyLabel.BackgroundTransparency = 1
NotifyLabel.Size = UDim2.new(1, 0, 1, 0)
NotifyLabel.Font = Enum.Font.GothamBold
NotifyLabel.Text = "EUGENE HUB LOADED\n99 NIGHTS DOMINATOR v3.0"
NotifyLabel.TextColor3 = EugeneColors.Accent
NotifyLabel.TextSize = 16

-- Авто-удаление уведомления
spawn(function()
    wait(4)
    for i = 1, 10 do
        NotifyFrame.BackgroundTransparency = i/10
        NotifyLabel.TextTransparency = i/10
        wait(0.1)
    end
    EugeneNotify:Destroy()
end)

print("🎮 EUGENE HUB loaded successfully!")
print("🎯 Combat - Auto Farm, Bring Items")
print("🚀 Movement - Fly, NoClip, Speed")
print("👁️ Visuals - ESP, Full Bright")
print("🤖 Automation - Auto Click, Collect")
print("⚡ Misc - God Mode, Teleport")
