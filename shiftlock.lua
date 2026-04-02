local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local active = false
local shiftLockEnabled = false
local shiftLockKey = Enum.KeyCode.X
local mouseSensitivity = 0.3

local CUSTOM_LOGO_ID = "rbxassetid://121655015965144"

if PlayerGui:FindFirstChild("ShiftLockGui") then
    PlayerGui.ShiftLockGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShiftLockGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 310)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -220)
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
TitleLabel.Size = UDim2.new(0, 100, 0, 38)
TitleLabel.Position = UDim2.new(0.5, -50, 0, 14)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "ShiftLock"
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
Content.Name = "Content"
Content.Size = UDim2.new(1, -32, 1, -80)
Content.Position = UDim2.new(0, 16, 0, 72)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 14)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function makeSlider(parent, label, minV, maxV, defV, decimals, color, callback)
    local Block = Instance.new("Frame")
    Block.Size = UDim2.new(1, 0, 0, 52)
    Block.BackgroundTransparency = 1
    Block.Parent = parent

    local Lbl = Instance.new("TextLabel", Block)
    Lbl.Size = UDim2.new(0.5, 0, 0, 18)
    Lbl.Position = UDim2.new(0, 0, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(190, 205, 215)
    Lbl.TextSize = 13
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local fmt = decimals > 0 and ("%."..decimals.."f") or "%d"

    local ValLbl = Instance.new("TextLabel", Block)
    ValLbl.Size = UDim2.new(0.28, 0, 0, 18)
    ValLbl.Position = UDim2.new(0.52, 0, 0, 0)
    ValLbl.BackgroundTransparency = 1
    ValLbl.Text = string.format(fmt, defV)
    ValLbl.TextColor3 = color
    ValLbl.TextSize = 13
    ValLbl.Font = Enum.Font.GothamBold
    ValLbl.TextXAlignment = Enum.TextXAlignment.Right

    local ResetBtn = Instance.new("TextButton", Block)
    ResetBtn.Size = UDim2.new(0, 36, 0, 16)
    ResetBtn.Position = UDim2.new(1, -36, 0, 1)
    ResetBtn.BackgroundColor3 = Color3.fromRGB(25, 40, 52)
    ResetBtn.BorderSizePixel = 0
    ResetBtn.Text = "reset"
    ResetBtn.TextColor3 = Color3.fromRGB(120, 150, 170)
    ResetBtn.TextSize = 9
    ResetBtn.Font = Enum.Font.GothamSemibold
    ResetBtn.ZIndex = 5
    Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 4)

    local Track = Instance.new("Frame", Block)
    Track.Size = UDim2.new(1, 0, 0, 7)
    Track.Position = UDim2.new(0, 0, 0, 30)
    Track.BackgroundColor3 = Color3.fromRGB(10, 20, 28)
    Track.BorderSizePixel = 0
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local pct = (defV - minV) / (maxV - minV)

    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new(pct, 0, 1, 0)
    Fill.BackgroundColor3 = color
    Fill.BorderSizePixel = 0
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local Thumb = Instance.new("Frame", Track)
    Thumb.Size = UDim2.new(0, 18, 0, 18)
    Thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    Thumb.Position = UDim2.new(pct, 0, 0.5, 0)
    Thumb.BackgroundColor3 = Color3.fromRGB(235, 242, 255)
    Thumb.BorderSizePixel = 0
    Thumb.ZIndex = 4
    Instance.new("UICorner", Thumb).CornerRadius = UDim.new(1, 0)

    local ts = Instance.new("UIStroke", Thumb)
    ts.Color = color
    ts.Thickness = 2

    local sliding = false

    local function setValue(v)
        local r = math.clamp((v - minV) / (maxV - minV), 0, 1)
        Fill.Size = UDim2.new(r, 0, 1, 0)
        Thumb.Position = UDim2.new(r, 0, 0.5, 0)
        ValLbl.Text = string.format(fmt, v)
        callback(v)
    end

    local function update(ix)
        local tp = Track.AbsolutePosition.X
        local ts2 = Track.AbsoluteSize.X
        local r = math.clamp((ix - tp) / ts2, 0, 1)
        local raw = minV + (maxV - minV) * r
        local step = math.pow(10, decimals)
        local v = math.floor(raw * step + 0.5) / step
        setValue(v)
    end

    ResetBtn.MouseButton1Click:Connect(function() setValue(defV) end)
    ResetBtn.MouseEnter:Connect(function() ResetBtn.TextColor3 = color end)
    ResetBtn.MouseLeave:Connect(function() ResetBtn.TextColor3 = Color3.fromRGB(120, 150, 170) end)

    Track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            sliding = true; update(i.Position.X)
        end
    end)
    Track.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
    Thumb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            sliding = true
        end
    end)
    Thumb.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)
end

local toggleRef = nil

local function makeToggle(parent, label, color, initialState, callback)
    local Block = Instance.new("Frame")
    Block.Size = UDim2.new(1, 0, 0, 36)
    Block.BackgroundTransparency = 1
    Block.Parent = parent

    local Lbl = Instance.new("TextLabel", Block)
    Lbl.Size = UDim2.new(0.65, 0, 1, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(190, 205, 215)
    Lbl.TextSize = 13
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local Bg = Instance.new("Frame", Block)
    Bg.Size = UDim2.new(0, 44, 0, 24)
    Bg.Position = UDim2.new(1, -44, 0.5, -12)
    Bg.BackgroundColor3 = initialState and color or Color3.fromRGB(10, 20, 28)
    Bg.BorderSizePixel = 0
    Instance.new("UICorner", Bg).CornerRadius = UDim.new(1, 0)

    local Circle = Instance.new("Frame", Bg)
    Circle.Size = UDim2.new(0, 18, 0, 18)
    Circle.Position = initialState and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    Circle.BackgroundColor3 = initialState and Color3.fromRGB(240, 245, 255) or Color3.fromRGB(70, 90, 105)
    Circle.BorderSizePixel = 0
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

    local on = initialState

    local Btn = Instance.new("TextButton", Block)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.ZIndex = 3

    toggleRef = {Bg = Bg, Circle = Circle, on = function() return on end, color = color}

    Btn.MouseButton1Click:Connect(function()
        on = not on
        if on then
            Bg.BackgroundColor3 = color
            Circle.BackgroundColor3 = Color3.fromRGB(240, 245, 255)
            Circle:TweenPosition(UDim2.new(1, -21, 0.5, -9), "Out", "Quad", 0.15, true)
        else
            Bg.BackgroundColor3 = Color3.fromRGB(10, 20, 28)
            Circle.BackgroundColor3 = Color3.fromRGB(70, 90, 105)
            Circle:TweenPosition(UDim2.new(0, 3, 0.5, -9), "Out", "Quad", 0.15, true)
        end
        callback(on)
    end)

    return {
        setOn = function(val)
            on = val
            if val then
                Bg.BackgroundColor3 = color
                Circle.BackgroundColor3 = Color3.fromRGB(240, 245, 255)
                Circle:TweenPosition(UDim2.new(1, -21, 0.5, -9), "Out", "Quad", 0.15, true)
            else
                Bg.BackgroundColor3 = Color3.fromRGB(10, 20, 28)
                Circle.BackgroundColor3 = Color3.fromRGB(70, 90, 105)
                Circle:TweenPosition(UDim2.new(0, 3, 0.5, -9), "Out", "Quad", 0.15, true)
            end
        end
    }
end

local function makeKeybindRow(parent, label, defaultKey, color, onChange)
    local Block = Instance.new("Frame")
    Block.Size = UDim2.new(1, 0, 0, 36)
    Block.BackgroundTransparency = 1
    Block.Parent = parent

    local Lbl = Instance.new("TextLabel", Block)
    Lbl.Size = UDim2.new(0.5, 0, 1, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(190, 205, 215)
    Lbl.TextSize = 13
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local KeyBtn = Instance.new("TextButton", Block)
    KeyBtn.Size = UDim2.new(0, 90, 0, 24)
    KeyBtn.Position = UDim2.new(1, -90, 0.5, -12)
    KeyBtn.BackgroundColor3 = Color3.fromRGB(25, 40, 52)
    KeyBtn.BorderSizePixel = 0
    KeyBtn.Text = defaultKey.Name
    KeyBtn.TextColor3 = color
    KeyBtn.TextSize = 12
    KeyBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 6)
    local ks = Instance.new("UIStroke", KeyBtn)
    ks.Color = color
    ks.Thickness = 1
    ks.Transparency = 0.6

    local listening = false

    KeyBtn.MouseButton1Click:Connect(function()
        if not listening then
            listening = true
            KeyBtn.Text = "..."
            KeyBtn.TextColor3 = Color3.fromRGB(255, 220, 80)
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            shiftLockKey = input.KeyCode
            KeyBtn.Text = shiftLockKey.Name
            KeyBtn.TextColor3 = color
            if onChange then onChange(shiftLockKey) end
        end
    end)
end

makeSlider(Content, "Sensitivity", 0.1, 1, 0.3, 1, Color3.fromRGB(100, 180, 255), function(v)
    mouseSensitivity = v
end)

local toggleRef
toggleRef = makeToggle(Content, "Active", Color3.fromRGB(72, 200, 130), false, function(on)
    active = on
    if not on and shiftLockEnabled then
        shiftLockEnabled = false
    end
end)

local shiftLockToggle = makeToggle(Content, "ShiftLock", Color3.fromRGB(72, 200, 130), false, function(on)
    shiftLockEnabled = on
    if on and active then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end)

makeKeybindRow(Content, "Toggle Key", shiftLockKey, Color3.fromRGB(72, 200, 130), function(newKey)
    shiftLockKey = newKey
    updateKeyListeners()
end)

local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

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
        MainFrame:TweenSize(UDim2.new(0, 280, 0, 66), "Out", "Quad", 0.18, true)
        MinBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 280, 0, 310), "Out", "Quad", 0.18, true)
        MinBtn.Text = "–"
    end
end)

local userGameSettings = nil
local OFFSET_VAL = 1.75
local smoothOffset = 0
local LERP_SPEED = 0.25

local Crosshair = Instance.new("ImageLabel")
Crosshair.Name = "ShiftLockCrosshair"
Crosshair.Parent = ScreenGui
Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
Crosshair.Position = UDim2.new(0.5, 0, 0.5, -29)
Crosshair.Size = UDim2.new(0, 32, 0, 32)
Crosshair.BackgroundTransparency = 1
Crosshair.Image = "rbxasset://textures/MouseLockedCursor.png"
Crosshair.Visible = false
Crosshair.ZIndex = 10

local CrossAspect = Instance.new("UIAspectRatioConstraint")
CrossAspect.AspectRatio = 1
CrossAspect.Parent = Crosshair

local function enforceOfficialSync(dt)
    if not shiftLockEnabled and smoothOffset < 0.01 then
        RunService:UnbindFromRenderStep("FinalNailSync")
        return
    end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local cam = workspace.CurrentCamera
    if not hum or not hrp then return end

    if shiftLockEnabled then
        if not userGameSettings then
            pcall(function() userGameSettings = UserSettings():GetService("UserGameSettings") end)
        end
        if userGameSettings and userGameSettings.RotationType ~= Enum.RotationType.CameraRelative then
            pcall(function() userGameSettings.RotationType = Enum.RotationType.CameraRelative end)
        end
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

        local moveDirection = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + cam.CFrame.RightVector
        end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = Vector3.new(moveDirection.X, 0, moveDirection.Z).Unit
            hum:Move(moveDirection, false)
        else
            hum:Move(Vector3.new(0, 0, 0), false)
        end
    end

    local dist = (cam.Focus.Position - cam.CFrame.Position).Magnitude
    local target = (shiftLockEnabled and dist > 0.80) and OFFSET_VAL or 0
    smoothOffset = smoothOffset + (target - smoothOffset) * math.clamp(LERP_SPEED * (dt * 60), 0, 1)

    if smoothOffset > 0.001 then
        local rawCFrame = cam.CFrame
        cam.CFrame = rawCFrame * CFrame.new(smoothOffset, 0, 0)
        cam.Focus = cam.CFrame * CFrame.new(0, 0, -dist)
    end
end

local function ToggleShiftLock(enabled)
    shiftLockEnabled = enabled
    Crosshair.Visible = enabled
    shiftLockToggle.setOn(enabled)

    RunService:UnbindFromRenderStep("FinalNailSync")

    if enabled then
        RunService:BindToRenderStep("FinalNailSync", Enum.RenderPriority.Camera.Value + 1, enforceOfficialSync)
    else
        if userGameSettings then
            pcall(function() userGameSettings.RotationType = Enum.RotationType.MovementRelative end)
        end
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        RunService:BindToRenderStep("FinalNailSync", Enum.RenderPriority.Camera.Value + 1, enforceOfficialSync)
    end
end

local shiftLockKeyConn

local function updateKeyListeners()
    if shiftLockKeyConn then shiftLockKeyConn:Disconnect() end

    shiftLockKeyConn = UserInputService.InputBegan:Connect(function(input, gp)
        if gp or input.KeyCode ~= shiftLockKey or not active then return end
        ToggleShiftLock(not shiftLockEnabled)
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    RunService:UnbindFromRenderStep("FinalNailSync")
    RunService.RenderStepped:Wait()

    smoothOffset = 0
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default

    if shiftLockEnabled then
        RunService:BindToRenderStep("FinalNailSync", Enum.RenderPriority.Camera.Value + 1, enforceOfficialSync)
    end
end)

updateKeyListeners()
