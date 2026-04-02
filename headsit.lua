-- KiroAttach UI - Fixed headsit positioning
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local CUSTOM_LOGO_ID = "rbxassetid://121655015965144"

if PlayerGui:FindFirstChild("KiroAttachUI") then
    PlayerGui.KiroAttachUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KiroAttachUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

local FULL_HEIGHT = 460
local MINI_HEIGHT = 66

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, FULL_HEIGHT)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -230)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 20)

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(35, 55, 70)
Stroke.Thickness = 1

local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 38, 0, 38)
Logo.Position = UDim2.new(0, 14, 0, 14)
Logo.BackgroundTransparency = 1
Logo.Image = CUSTOM_LOGO_ID
Logo.ScaleType = Enum.ScaleType.Fit
Logo.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 160, 0, 38)
TitleLabel.Position = UDim2.new(0.5, -80, 0, 14)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Headsit + FuckMode"
TitleLabel.TextColor3 = Color3.fromRGB(190, 205, 215)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.Parent = MainFrame

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 26, 0, 26)
MinBtn.Position = UDim2.new(1, -40, 0, 16)
MinBtn.BackgroundColor3 = Color3.fromRGB(25, 40, 52)
MinBtn.BorderSizePixel = 0
MinBtn.Text = "–"
MinBtn.TextColor3 = Color3.fromRGB(160, 185, 200)
MinBtn.TextSize = 15
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = MainFrame
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 7)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -32, 1, -70)
Content.Position = UDim2.new(0, 16, 0, 60)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 14)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local attachEnabled = false
local currentMode = nil
local TargetedPlayer = nil
local attachThread = nil
local BreakVelocity = nil

local function GetRoot(plr)
    local char = plr.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    end
end

local function PlayAnim(id, timePos, speed)
    pcall(function()
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://" .. id
            local track = hum:LoadAnimation(anim)
            track.TimePosition = timePos
            track:AdjustSpeed(speed)
            track:Play()
        end
    end)
end

local function StopAnim()
    pcall(function()
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            for _, track in pairs(hum:GetPlayingAnimationTracks()) do
                track:Stop()
            end
        end
    end)
end

local function startAttachLoop()
    if attachThread then task.cancel(attachThread) end
    attachThread = task.spawn(function()
        while attachEnabled and currentMode and TargetedPlayer and TargetedPlayer.Character do
            pcall(function()
                local myRoot = GetRoot(LocalPlayer)
                if not myRoot then return end

                -- Create BreakVelocity if missing
                if not myRoot:FindFirstChild("BreakVelocity") then
                    BreakVelocity = Instance.new("BodyAngularVelocity")
                    BreakVelocity.Name = "BreakVelocity"
                    BreakVelocity.Parent = myRoot
                end

                local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum then hum.Sit = true end

                if currentMode == "headsit" then
                    local targetHead = TargetedPlayer.Character:FindFirstChild("Head")
                    if targetHead then
                        myRoot.CFrame = targetHead.CFrame * CFrame.new(0, 2, 0)
                    end

                elseif currentMode == "backpack" then
                    PlayAnim(10714360343, 0.5, 0)
                    local targetRoot = GetRoot(TargetedPlayer)
                    if targetRoot then
                        -- Sit on their back: behind them, raised up, facing same direction
                        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0.2, -1.0)
                    end
                end

                myRoot.Velocity = Vector3.new(0, 0, 0)
            end)
            task.wait()
        end
    end)
end

local function stopAttachLoop()
    attachEnabled = false
    if attachThread then
        task.cancel(attachThread)
        attachThread = nil
    end
    if BreakVelocity then
        BreakVelocity:Destroy()
        BreakVelocity = nil
    end
    StopAnim()
end

local function createToggleButton(parent, labelOn, labelOff, onClick)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 38)
    Container.BackgroundTransparency = 1
    Container.Parent = parent
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 0, 32)
    Btn.Position = UDim2.new(0, 10, 0, 3)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 60, 80)
    Btn.Text = labelOff
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.GothamBold
    Btn.BorderSizePixel = 0
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    Btn.Parent = Container
    local btnStroke = Instance.new("UIStroke", Btn)
    btnStroke.Color = Color3.fromRGB(60, 100, 160)
    btnStroke.Thickness = 1
    local isOn = false
    Btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        onClick(isOn)
        local targetColor = isOn and Color3.fromRGB(60, 200, 110) or Color3.fromRGB(50, 60, 80)
        local targetStroke = isOn and Color3.fromRGB(60, 200, 110) or Color3.fromRGB(60, 100, 160)
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.2), {Color = targetStroke}):Play()
        Btn.Text = isOn and labelOn or labelOff
    end)
    return Container
end

local function createSwitch(parent, label, defaultState, onChange)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 34)
    Container.BackgroundTransparency = 1
    Container.Parent = parent
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.6, 0, 1, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(190, 205, 215)
    Lbl.TextSize = 13
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Container
    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(0, 46, 0, 22)
    Track.Position = UDim2.new(1, -46, 0.5, -11)
    Track.BackgroundColor3 = defaultState and Color3.fromRGB(60, 200, 110) or Color3.fromRGB(40, 55, 70)
    Track.BorderSizePixel = 0
    Track.Parent = Container
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = defaultState and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Track
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    local state = defaultState
    local TrackBtn = Instance.new("TextButton")
    TrackBtn.Size = UDim2.new(1, 0, 1, 0)
    TrackBtn.BackgroundTransparency = 1
    TrackBtn.Text = ""
    TrackBtn.Parent = Track
    TrackBtn.MouseButton1Click:Connect(function()
        state = not state
        local targetPos   = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local targetColor = state and Color3.fromRGB(60, 200, 110) or Color3.fromRGB(40, 55, 70)
        TweenService:Create(Knob, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(Track, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        onChange(state)
    end)
    local function forceOff()
        state = false
        TweenService:Create(Knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -8)}):Play()
        TweenService:Create(Track, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 55, 70)}):Play()
    end
    return Container, forceOff
end

local function createDivider(parent)
    local D = Instance.new("Frame")
    D.Size = UDim2.new(1, 0, 0, 1)
    D.BackgroundColor3 = Color3.fromRGB(35, 55, 70)
    D.BorderSizePixel = 0
    D.Parent = parent
end

createToggleButton(Content, "● Attach ON", "● Attach OFF", function(on)
    attachEnabled = on
    if on and currentMode and TargetedPlayer then
        startAttachLoop()
    else
        stopAttachLoop()
    end
end)
createDivider(Content)

local forceBackpackOff
local forceHeadsitOff

local _, _forceBackpackOff = createSwitch(Content, "Fuck Mode", false, function(on)
    if on then
        forceHeadsitOff()
        currentMode = "backpack"
        if attachEnabled and TargetedPlayer then startAttachLoop() end
    else
        if currentMode == "backpack" then
            currentMode = nil
            if attachEnabled then stopAttachLoop() end
        end
    end
end)
forceBackpackOff = _forceBackpackOff
createDivider(Content)

local _, _forceHeadsitOff = createSwitch(Content, "Headsit Mode", false, function(on)
    if on then
        forceBackpackOff()
        currentMode = "headsit"
        if attachEnabled and TargetedPlayer then startAttachLoop() end
    else
        if currentMode == "headsit" then
            currentMode = nil
            if attachEnabled then stopAttachLoop() end
        end
    end
end)
forceHeadsitOff = _forceHeadsitOff
createDivider(Content)

local PlayerListContainer = Instance.new("Frame")
PlayerListContainer.Size = UDim2.new(1, 0, 0, 180)
PlayerListContainer.BackgroundTransparency = 1
PlayerListContainer.Parent = Content

local ListLabel = Instance.new("TextLabel")
ListLabel.Size = UDim2.new(1, 0, 0, 20)
ListLabel.BackgroundTransparency = 1
ListLabel.Text = "Select Target Player"
ListLabel.TextColor3 = Color3.fromRGB(190, 205, 215)
ListLabel.TextSize = 13
ListLabel.Font = Enum.Font.GothamSemibold
ListLabel.TextXAlignment = Enum.TextXAlignment.Left
ListLabel.Parent = PlayerListContainer

local PlayerScroll = Instance.new("ScrollingFrame")
PlayerScroll.Size = UDim2.new(1, 0, 1, -24)
PlayerScroll.Position = UDim2.new(0, 0, 0, 24)
PlayerScroll.BackgroundColor3 = Color3.fromRGB(25, 40, 52)
PlayerScroll.BackgroundTransparency = 0.7
PlayerScroll.ScrollBarThickness = 4
PlayerScroll.Parent = PlayerListContainer
Instance.new("UICorner", PlayerScroll).CornerRadius = UDim.new(0, 8)

local PlayerLayout = Instance.new("UIListLayout", PlayerScroll)
PlayerLayout.Padding = UDim.new(0, 4)
PlayerLayout.SortOrder = Enum.SortOrder.Name

local playerButtons = {}

local function highlightSelected()
    for _, btn in pairs(playerButtons) do
        btn.BackgroundColor3 = Color3.fromRGB(40, 55, 70)
    end
end

local function createPlayerButton(player)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 32)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 55, 70)
    Btn.Text = player.DisplayName .. " (@" .. player.Name .. ")"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.GothamSemibold
    Btn.BorderSizePixel = 0
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.Parent = PlayerScroll
    Btn.MouseButton1Click:Connect(function()
        TargetedPlayer = player
        highlightSelected()
        Btn.BackgroundColor3 = Color3.fromRGB(60, 200, 110)
        if attachEnabled and currentMode then
            startAttachLoop()
        end
    end)
    table.insert(playerButtons, Btn)
    return Btn
end

local function refreshPlayerList()
    for _, btn in pairs(playerButtons) do btn:Destroy() end
    playerButtons = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            createPlayerButton(plr)
        end
    end
    PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, PlayerLayout.AbsoluteContentSize.Y)
end

refreshPlayerList()
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(function(plr)
    if TargetedPlayer == plr then
        TargetedPlayer = nil
        stopAttachLoop()
    end
    refreshPlayerList()
end)

local dragging, dragStart, dragInput, startPos = false, nil, nil, nil
local DragZone = Instance.new("TextButton")
DragZone.Size = UDim2.new(1, 0, 0, 62)
DragZone.Position = UDim2.new(0, 0, 0, 0)
DragZone.BackgroundTransparency = 1
DragZone.Text = ""
DragZone.ZIndex = 0
DragZone.Parent = MainFrame
DragZone.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = i.Position
        startPos = MainFrame.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
DragZone.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
        dragInput = i
    end
end)
RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local d = dragInput.Position - dragStart
        local ss = ScreenGui.AbsoluteSize
        local fs = MainFrame.AbsoluteSize
        local nx = math.clamp(startPos.X.Offset + d.X, 0, ss.X - fs.X)
        local ny = math.clamp(startPos.Y.Offset + d.Y, 0, ss.Y - fs.Y)
        MainFrame.Position = UDim2.new(0, nx, 0, ny)
        startPos = UDim2.new(0, nx, 0, ny)
        dragStart = dragInput.Position
    end
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Content.Visible = not minimized
    if minimized then
        MainFrame:TweenSize(UDim2.new(0, 280, 0, MINI_HEIGHT), "Out", "Quad", 0.18, true)
        MinBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 280, 0, FULL_HEIGHT), "Out", "Quad", 0.18, true)
        MinBtn.Text = "–"
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if attachEnabled and currentMode and TargetedPlayer then
        startAttachLoop()
    end
end)
