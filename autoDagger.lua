local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local lp = Players.LocalPlayer

local blockAnims = {
    ["rbxassetid://110355011987939"] = true,
    ["rbxassetid://121216847022485"] = true,
    ["rbxassetid://139369275981139"] = true,
    ["rbxassetid://117042998468241"] = true,
    ["rbxassetid://133963973694098"] = true,
    ["rbxassetid://113255068724446"] = true,
    ["rbxassetid://74968262036854"]  = true,
    ["rbxassetid://118907603246885"] = true,
    ["rbxassetid://78432063483146"]  = true,
    ["rbxassetid://122812055447896"] = true,
    ["rbxassetid://78935059863801"] = true,
    ["rbxassetid://105374834496520"] = true,
    ["rbxassetid://129784271201071"] = true,
    ["rbxassetid://132817836308238"] = true,
    ["rbxassetid://111920872708571"] = true,
    ["rbxassetid://138720291317243"] = true,
    ["rbxassetid://115244153053858"] = true,
    ["rbxassetid://117070354890871"] = true,
    ["rbxassetid://106871536134254"] = true,
}

local RANGE = 10
local enabled = false
local spamActive = false

local function isBlockingInRange()
    local myChar = lp.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return false end
    local myPos = myChar.HumanoidRootPart.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == lp then continue end
        local char = plr.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        if (myPos - char.HumanoidRootPart.Position).Magnitude > RANGE then continue end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                if blockAnims[track.Animation.AnimationId] then
                    return true
                end
            end
        end
    end
    return false
end

RunService.Heartbeat:Connect(function()
    if not enabled then
        if spamActive then
            spamActive = false
            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
        end
        return
    end

    if isBlockingInRange() then
        spamActive = true
        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
    else
        if spamActive then
            spamActive = false
            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
        end
    end
end)

local AutoDagger = {}
function AutoDagger.Toggle(state)
    enabled = state
end

return AutoDagger
