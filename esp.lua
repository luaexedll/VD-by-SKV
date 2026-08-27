local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local ESP = {
    BoxEnabled = false,
    NamesEnabled = false,
    KillerColor = Color3.fromRGB(255, 50, 50),
    SurvivorColor = Color3.fromRGB(50, 255, 50),
    GeneratorsEnabled = false,
    PalletsEnabled = false,
    ZombiesEnabled = false,
    Connections = {}
}

local activeDrawings = {}

local function createDrawing(class, properties)
    local obj = Drawing.new(class)
    for k, v in pairs(properties) do
        obj[k] = v
    end
    return obj
end

local function removeESP(target)
    if activeDrawings[target] then
        for _, obj in pairs(activeDrawings[target]) do
            pcall(function() obj:Remove() end)
        end
        activeDrawings[target] = nil
    end
end

-- Функция для работы с игроками (Боксы, Ники, Дистанция, Роли)
local function setupPlayer(player)
    if player == LocalPlayer then return end
    
    activeDrawings[player] = {
        Box = createDrawing("Square", {Visible = false, Thickness = 1.5, Filled = false}),
        NameText = createDrawing("Text", {Visible = false, Size = 13, Center = true, Outline = true, Font = 2})
    }

    local function update()
        local char = player.Character
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local drawings = activeDrawings[player]

        if not char or not rootPart or not humanoid or humanoid.Health <= 0 or not (ESP.BoxEnabled or ESP.NamesEnabled) then
            if drawings then
                drawings.Box.Visible = false
                drawings.NameText.Visible = false
            end
            return
        end

        local pos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
        if onScreen then
            -- Определение цвета (маньяк или выживший — можно настроить логику под переменные игры, пока берем по команде или атрибуту)
            local isKiller = char:GetAttribute("IsKiller") or false
            local col = isKiller and ESP.KillerColor or ESP.SurvivorColor

            -- Бокс
            if ESP.BoxEnabled then
                local size = (Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 3, 0)).Y - Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0)).Y)
                local h = math.abs(size)
                local w = h / 2
                drawings.Box.Size = Vector2.new(w, h)
                drawings.Box.Position = Vector2.new(pos.X - w / 2, pos.Y - h / 2)
                drawings.Box.Color = col
                drawings.Box.Visible = true
            else
                drawings.Box.Visible = false
            end

            -- Ник и дистанция
            if ESP.NamesEnabled then
                local dist = math.floor((Workspace.CurrentCamera.CFrame.Position - rootPart.Position).Magnitude)
                drawings.NameText.Text = string.format("%s [%dm]", player.Name, dist)
                drawings.NameText.Position = Vector2.new(pos.X, pos.Y - (drawings.Box.Size.Y / 2) - 18)
                drawings.NameText.Color = col
                drawings.NameText.Visible = true
            else
                drawings.NameText.Visible = false
            end
        else
            drawings.Box.Visible = false
            drawings.NameText.Visible = false
        end
    end

    table.insert(ESP.Connections, RunService.RenderStepped:Connect(update))
end

for _, p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
table.insert(ESP.Connections, Players.PlayerAdded:Connect(setupPlayer))
table.insert(ESP.Connections, Players.PlayerRemoving:Connect(removeESP))

-- Переключатели для GUI
function ESP.ToggleBox(state)
    ESP.BoxEnabled = state
end

function ESP.ToggleNames(state)
    ESP.NamesEnabled = state
end

function ESP.SetKillerColor(color)
    ESP.KillerColor = color
end

function ESP.SetSurvivorColor(color)
    ESP.SurvivorColor = color
end

return ESP
