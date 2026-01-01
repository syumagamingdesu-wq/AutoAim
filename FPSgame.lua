local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 設定変数
local Aiming = false
local TeamCheck = true 

-- --- UI作成 (微調整した位置) ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainBtn = Instance.new("TextButton", ScreenGui)
local TeamBtn = Instance.new("TextButton", ScreenGui)

-- メインボタン (LOCK ON/OFF)
MainBtn.Name = "MiniLock"
MainBtn.Size = UDim2.new(0, 80, 0, 30)
-- 位置を -180 から -150 に戻して若干右へ
MainBtn.Position = UDim2.new(1, -150, 0, 0) 
MainBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
MainBtn.Text = "LOCK: OFF"
MainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MainBtn.Font = Enum.Font.SourceSansBold
MainBtn.TextSize = 14
Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 8)

-- チーム切り替えボタン (メインボタンのすぐ下)
TeamBtn.Name = "TeamSwitch"
TeamBtn.Size = UDim2.new(0, 80, 0, 30)
TeamBtn.Position = UDim2.new(1, -150, 0, 32)
TeamBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 255)
TeamBtn.Text = "TEAM: ON"
TeamBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TeamBtn.Font = Enum.Font.SourceSansBold
TeamBtn.TextSize = 14
Instance.new("UICorner", TeamBtn).CornerRadius = UDim.new(0, 8)

-- ボタン操作
MainBtn.MouseButton1Click:Connect(function()
    Aiming = not Aiming
    MainBtn.BackgroundColor3 = Aiming and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    MainBtn.Text = Aiming and "LOCK: ON" or "LOCK: OFF"
end)

TeamBtn.MouseButton1Click:Connect(function()
    TeamCheck = not TeamCheck
    TeamBtn.BackgroundColor3 = TeamCheck and Color3.fromRGB(50, 50, 255) or Color3.fromRGB(150, 150, 150)
    TeamBtn.Text = TeamCheck and "TEAM: ON" or "TEAM: OFF"
end)

-- --- ターゲット判定 (360°対応) ---
local function isTargetValid(v)
    if v and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") then
        if v.Character.Humanoid.Health > 0 and v ~= LocalPlayer then
            if not TeamCheck or v.Team ~= LocalPlayer.Team then
                return true
            end
        end
    end
    return false
end

-- --- 360°全方位から「自分に物理的に最も近い」人を探す ---
local function getClosestPlayer360()
    local closest, shortestDistance = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if isTargetValid(v) then
            local actualDist = (v.Character.Head.Position - LocalPlayer.Character.Head.Position).Magnitude
            if actualDist < shortestDistance then
                shortestDistance = actualDist
                closest = v
            end
        end
    end
    return closest
end

-- --- メインループ ---
RunService.RenderStepped:Connect(function()
    if Aiming then
        local currentTarget = getClosestPlayer360()
        if currentTarget then
            -- 360°全方位認識＋常に一番近いプレイヤーへ吸い付き
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, currentTarget.Character.Head.Position)
        end
    end
end)
