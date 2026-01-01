local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion"))()
local Window = OrionLib:MakeWindow({Name = "AvS 2: FULL AUTO", HidePremium = true, SaveConfig = false})

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 設定
local Aiming = false
local FOV_Radius = 400 -- スマホだと広めがおすすめ
local LockedTarget = nil

-- ターゲット確認（生存・チーム・距離）
local function isTargetValid(target)
    if target and target.Character and target.Character:FindFirstChild("Head") and target.Character:FindFirstChild("Humanoid") then
        if target.Character.Humanoid.Health > 0 then
            -- 距離チェック（遠すぎると外す設定も可能）
            local dist = (target.Character.Head.Position - Camera.CFrame.Position).Magnitude
            if dist < 500 then 
                return true
            end
        end
    end
    return false
end

-- ターゲット取得（画面中央からの距離で判定）
local function getNewTarget()
    local closest = nil
    local shortestDist = FOV_Radius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and isTargetValid(v) then
            if v.Team ~= LocalPlayer.Team then
                local pos, onScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
                if onScreen then
                    local magnitude = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if magnitude < shortestDist then
                        shortestDist = magnitude
                        closest = v
                    end
                end
            end
        end
    end
    return closest
end

-- UI
local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998"})

MainTab:AddToggle({
    Name = "Full Auto Lock (No Touch)",
    Default = false,
    Callback = function(Value) 
        Aiming = Value 
        if not Value then LockedTarget = nil end
    end    
})

-- 【核心】指を離していても強制的にカメラを回すループ
RunService.RenderStepped:Connect(function()
    if Aiming then
        -- ロック対象の更新
        if not isTargetValid(LockedTarget) then
            LockedTarget = getNewTarget()
        end

        if LockedTarget then
            -- 敵の頭の位置を計算
            local targetPos = LockedTarget.Character.Head.Position
            
            -- 現在のカメラ位置を維持しつつ、向きだけを敵に固定
            -- これを RenderStepped で行うことで指の入力を無視して回ります
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        end
    end
end)

OrionLib:Init()
