local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or CoreGui

if PlayerGui:FindFirstChild("VDCheatHub") then
    PlayerGui.VDCheatHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VDCheatHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 360)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(45, 50, 65)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 25, 33)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1, 0, 0, 10)
TopFix.Position = UDim2.new(0, 0, 1, -10)
TopFix.BackgroundColor3 = Color3.fromRGB(22, 25, 33)
TopFix.BorderSizePixel = 0
TopFix.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "VD • CHEAT HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(19, 21, 28)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -140, 1, -40)
ContentArea.Position = UDim2.new(0, 140, 0, 40)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local TabsContainer = Instance.new("UIListLayout")
TabsContainer.SortOrder = Enum.SortOrder.LayoutOrder
TabsContainer.Padding = UDim.new(0, 5)
TabsContainer.Parent = Sidebar

local TabsPadding = Instance.new("UIPadding")
TabsPadding.PaddingTop = UDim.new(0, 10)
TabsPadding.PaddingLeft = UDim.new(0, 10)
TabsPadding.PaddingRight = UDim.new(0, 10)
TabsPadding.Parent = Sidebar

local Pages = {}
local TabButtons = {}

local function CreateTab(name, id)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 34)
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 29, 38)
    TabBtn.BorderSizePixel = 0
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(130, 140, 160)
    TabBtn.TextSize = 13
    TabBtn.Parent = Sidebar

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = TabBtn

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Color3.fromRGB(60, 70, 90)
    Page.Visible = false
    Page.Parent = ContentArea

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 10)
    PageLayout.Parent = Page

    local PagePadding = Instance.new("UIPadding")
    PagePadding.PaddingTop = UDim.new(0, 15)
    PagePadding.PaddingLeft = UDim.new(0, 15)
    PagePadding.PaddingRight = UDim.new(0, 15)
    PagePadding.Parent = Page

    Pages[id] = Page
    table.insert(TabButtons, {Btn = TabBtn, ID = id})

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in ipairs(TabButtons) do
            TweenService:Create(t.Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 29, 38), TextColor3 = Color3.fromRGB(130, 140, 160)}):Play()
            Pages[t.ID].Visible = false
        end
        TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 80, 255), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        Page.Visible = true
    end)

    return Page
end

local function CreateToggle(parent, text, callback)
    local Toggle = Instance.new("Frame")
    Toggle.Size = UDim2.new(1, 0, 0, 38)
    Toggle.BackgroundColor3 = Color3.fromRGB(22, 25, 33)
    Toggle.BorderSizePixel = 0
    Toggle.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Toggle

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamMedium
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 220, 235)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Toggle

    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 36, 0, 20)
    Switch.Position = UDim2.new(1, -46, 0.5, -10)
    Switch.BackgroundColor3 = Color3.fromRGB(35, 40, 52)
    Switch.Text = ""
    Switch.Parent = Toggle

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = Switch

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 14, 0, 14)
    Circle.Position = UDim2.new(0, 3, 0.5, -7)
    Circle.BackgroundColor3 = Color3.fromRGB(160, 170, 190)
    Circle.Parent = Switch

    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle

    local enabled = false
    Switch.MouseButton1Click:Connect(function()
        enabled = not enabled
        local goalSwitchColor = enabled and Color3.fromRGB(40, 80, 255) or Color3.fromRGB(35, 40, 52)
        local goalCircleColor = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 170, 190)
        local goalCirclePos = enabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)

        TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = goalSwitchColor}):Play()
        TweenService:Create(Circle, TweenInfo.new(0.2), {BackgroundColor3 = goalCircleColor, Position = goalCirclePos}):Play()

        pcall(function() callback(enabled) end)
    end)
end

-- Создаем вкладки
local espPage = CreateTab("Visuals (ESP)", "esp")
local killerPage = CreateTab("Next Killer", "killer")
local autoPage = CreateTab("Auto Dagger", "auto")

-- Наполняем вкладку ESP
CreateToggle(espPage, "Player ESP Box", function(state)
    local esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/luaexedll/VD-by-SKV/refs/heads/main/esp.lua"))()
    if esp and esp.ToggleBox then esp.ToggleBox(state) end
end)

CreateToggle(espPage, "Player Names", function(state)
    local esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/luaexedll/VD-by-SKV/refs/heads/main/esp.lua"))()
    if esp and esp.ToggleNames then esp.ToggleNames(state) end
end)

-- Наполняем вкладку Next Killer
CreateToggle(killerPage, "Detect Killer", function(state)
    local killer = loadstring(game:HttpGet("https://raw.githubusercontent.com/luaexedll/VD-by-SKV/refs/heads/main/nextKiller.lua"))()
    if killer and killer.Toggle then killer.Toggle(state) end
end)

-- Наполняем вкладку Auto Dagger
CreateToggle(autoPage, "Auto Throw Dagger", function(state)
    local auto = loadstring(game:HttpGet("https://raw.githubusercontent.com/luaexedll/VD-by-SKV/refs/heads/main/autoDagger.lua"))()
    if auto and auto.Toggle then auto.Toggle(state) end
end)

-- Выделяем первую вкладку по умолчанию
if TabButtons[1] then
    TweenService:Create(TabButtons[1].Btn, TweenInfo.new(0), {BackgroundColor3 = Color3.fromRGB(40, 80, 255), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    Pages[TabButtons[1].ID].Visible = true
end

-- Перетаскивание окна мышкой
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
