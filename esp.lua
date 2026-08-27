local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local ESP = {
    ChamsEnabled = false,
    NamesEnabled = false,
    GeneratorsEnabled = false,
    PalletsEnabled = false,
    ZombiesEnabled = false,
    KillerColor = Color3.fromRGB(255, 50, 50),
    SurvivorColor = Color3.fromRGB(50, 255, 50),
}

local highlights = {}
local drawings = {}
local trackedObjects = {}

-- Очистка при выключении
local function clearPlayer(player)
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end
    if drawings[player] then
        for _, obj in pairs(drawings[player]) do
            pcall(function() obj:Remove() end)
        end
        drawings[player] = nil
    end
end

-- Логика игроков (Chams + Ники)
local function setupPlayer(player)
    if player == LocalPlayer then return end
    
    drawings[player] = {
        NameText = Drawing.new("Text")
    }
    drawings[player].NameText.Size = 13
    drawings[player].NameText.Center = true
    drawings[player].NameText.Outline = true
    drawings[player].NameText.Font = 2
    drawings[player].NameText.Visible = false

    RunService.RenderStepped:Connect(function()
        local char = player.Character
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local textObj = drawings[player] and drawings[player].NameText

        -- Chams
        if ESP.ChamsEnabled and char and humanoid and humanoid.Health > 0 then
            if not highlights[player] then
                local hl = Instance.new("Highlight")
                hl.Adornee = char
                hl.Parent = CoreGui
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlights[player] = hl
            end
            local isKiller = char:GetAttribute("IsKiller") or false
            highlights[player].FillColor = isKiller and ESP.KillerColor or ESP.SurvivorColor
            highlights[player].OutlineColor = Color3.new(1, 1, 1)
            highlights[player].Enabled = true
        else
            if highlights[player] then
                highlights[player].Enabled = false
            end
        end

        -- Ники и Дистанция
        if ESP.NamesEnabled and char and rootPart and humanoid and humanoid.Health > 0 then
            local pos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 3, 0))
            if onScreen then
                local isKiller = char:GetAttribute("IsKiller") or false
                local col = isKiller and ESP.KillerColor or ESP.SurvivorColor
                local dist = math.floor((Workspace.CurrentCamera.CFrame.Position - rootPart.Position).Magnitude)
                
                textObj.Text = string.format("%s [%dm]", player.Name, dist)
                textObj.Position = Vector2.new(pos.X, pos.Y)
                textObj.Color = col
                textObj.Visible = true
            else
                textObj.Visible = false
            end
        else
            if textObj then textObj.Visible = false end
        end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(clearPlayer)

-- Универсальный сканер мира (Генераторы, Паллеты, Зомби)
local function trackWorldObjects(filterName, color, textFunc)
    local list = {}
    
    local conn = RunService.RenderStepped:Connect(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if not list[obj] and obj.Name:lower():find(filterName) then
                local hl = Instance.new("Highlight")
                hl.Adornee = obj
                hl.Parent = CoreGui
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillColor = color
                hl.OutlineColor = Color3.new(1, 1, 1)
                
                local txt = Drawing.new("Text")
                txt.Size = 12
                txt.Center = true
                txt.Outline = true
                txt.Font = 2
                txt.Color = color
                
                list[obj] = {Highlight = hl, Text = txt}
            end
        end
        
        for obj, data in pairs(list) do
            if not obj.Parent then
                data.Highlight:Destroy()
                data.Text:Remove()
                list[obj] = nil
            else
                local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                if part then
                    local pos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        data.Highlight.Enabled = true
                        data.Text.Text = textFunc(obj)
                        data.Text.Position = Vector2.new(pos.X, pos.Y)
                        data.Text.Visible = true
                    else
                        data.Highlight.Enabled = false
                        data.Text.Visible = false
                    end
                end
            end
        end
    end)
    
    return {
        Connection = conn,
        Objects = list
    }
end

local gensTracker, palletsTracker, zombiesTracker

function ESP.ToggleChams(state) ESP.ChamsEnabled = state end
function ESP.ToggleNames(state) ESP.NamesEnabled = state end
function ESP.SetKillerColor(col) ESP.KillerColor = col end
function ESP.SetSurvivorColor(col) ESP.SurvivorColor = col end

function ESP.ToggleGenerators(state)
    ESP.GeneratorsEnabled = state
    if state then
        gensTracker = trackWorldObjects("generator", Color3.fromRGB(255, 165, 0), function(obj)
            local progress = obj:GetAttribute("Progress") or obj:GetAttribute("RepairProgress") or 0
            local percent = math.clamp(math.floor(progress), 0, 100)
            local left = math.max(0, 100 - percent)
            return string.format("Generator\n[%d%% | Осталось: %d%%]", percent, left)
        end)
    else
        if gensTracker then
            gensTracker.Connection:Disconnect()
            for _, data in pairs(gensTracker.Objects) do
                data.Highlight:Destroy()
                data.Text:Remove()
            end
            gensTracker = nil
        end
    end
end

function ESP.TogglePallets(state)
    ESP.PalletsEnabled = state
    if state then
        palletsTracker = trackWorldObjects("pallet", Color3.fromRGB(0, 255, 255), function()
            return "Pallet"
        end)
    else
        if palletsTracker then
            palletsTracker.Connection:Disconnect()
            for _, data in pairs(palletsTracker.Objects) do
                data.Highlight:Destroy()
                data.Text:Remove()
            end
            palletsTracker = nil
        end
    end
end

function ESP.ToggleZombies(state)
    ESP.ZombiesEnabled = state
    if state then
        zombiesTracker = trackWorldObjects("zombie", Color3.fromRGB(150, 0, 255), function()
            return "Doctor Zombie"
        end)
    else
        if zombiesTracker then
            zombiesTracker.Connection:Disconnect()
            for _, data in pairs(zombiesTracker.Objects) do
                data.Highlight:Destroy()
                data.Text:Remove()
            end
            zombiesTracker = nil
        end
    end
end

return ESP
