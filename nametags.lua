-- [[ KIRO Nametag System v2 ]]
-- Redesigned with square-ish rounded nametags

-- =============================================
-- GRADIENT CONFIGURATION
-- =============================================
local GRADIENT_COLOR_A    = Color3.fromRGB(255, 255, 255)
local GRADIENT_COLOR_B    = Color3.fromRGB(0, 0, 0)
local GRADIENT_SPIN_SPEED = 60

-- =============================================
-- ZOOM-OUT SQUARE CONFIGURATION
-- =============================================
local ZOOMOUT_SIZE     = UDim2.new(0, 52, 0, 52)
local ZOOMOUT_RADIUS   = UDim.new(0, 10)
local ZOOMOUT_DISTANCE = 50

-- =============================================

local plrs       = game:GetService("Players")
local txtChat    = game:GetService("TextChatService")
local tweenSvc   = game:GetService("TweenService")
local runSvc     = game:GetService("RunService")
local starterGui = game:GetService("StarterGui")
local lp         = plrs.LocalPlayer

local taggedPlrs    = {}
local respondedPlrs = {}
local mutualPlrs    = {}

local defaultTagSz  = UDim2.new(0, 200, 0, 52)
local tagOff        = Vector3.new(0, 2.2, 0)
local LOGO_ASSET_ID = "rbxassetid://121655015965144"
local TAG_CORNER    = UDim.new(0, 10)

local customPlayers = {
	["Robloxianw3s1j0e2o"] = {
		color      = Color3.fromRGB(255,0,0),
		glowColor  = Color3.fromRGB(255,0,0),
		customName = "KIRO OWNER",
		gradientA  = Color3.fromRGB(255,0,0),
		gradientB  = Color3.fromRGB(0,0,0),
		logoAsset  = "rbxassetid://102073235023063",
	},
	["6vryzx"] = {
		color      = Color3.fromRGB(0,0,255),
		glowColor  = Color3.fromRGB(0,0,255),
		customName = "KIRO CO-OWNER",
		gradientA  = Color3.fromRGB(0,0,255),
		gradientB  = Color3.fromRGB(128,0,128),
		logoAsset  = "rbxassetid://122387801074010",
	},
}

starterGui:SetCore("SendNotification", {
	Title    = "Kiro Nametags";
	Text     = "Nametag system loaded";
	Duration = 5;
})

local function getCustomData(plr)
	if customPlayers[plr.Name]   then return customPlayers[plr.Name]   end
	if customPlayers[plr.UserId] then return customPlayers[plr.UserId] end
	return nil
end

local GLITCH_CHARS = {"#","@","!","$","%","&","?","*","/","\\","|","~","^","X","Z"}

local function glitchString(original)
	local result = {}
	for i = 1, #original do
		if math.random() < 0.4 then
			result[i] = GLITCH_CHARS[math.random(1, #GLITCH_CHARS)]
		else
			result[i] = string.sub(original, i, i)
		end
	end
	return table.concat(result)
end

-- Retry setting an image until it actually loads (not blank/failed)
local function forceLoadImage(imgLabel, assetId)
	imgLabel.Image = assetId
	spawn(function()
		local attempts = 0
		while imgLabel and imgLabel.Parent and attempts < 20 do
			local status = game:GetService("ContentProvider"):GetRequestedAssetStatus(assetId)
			if status == Enum.AssetFetchStatus.Success then
				imgLabel.Image = assetId
				break
			elseif status == Enum.AssetFetchStatus.Failure then
				-- retry on failure
				imgLabel.Image = ""
				task.wait(0.1)
				imgLabel.Image = assetId
				attempts += 1
			else
				-- still loading, just wait
				attempts += 1
			end
			task.wait(0.2)
		end
		-- Final assign regardless
		if imgLabel and imgLabel.Parent then
			imgLabel.Image = assetId
		end
	end)
end

local function buildTag(plr)
	if not mutualPlrs[plr.UserId] then return end
	if taggedPlrs[plr.UserId]     then return end
	local char = plr.Character
	if not char then return end
	local hd  = char:FindFirstChild("Head")
	if not hd  then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	taggedPlrs[plr.UserId] = true

	local pg = lp:WaitForChild("PlayerGui")

	for _, obj in pairs(pg:GetChildren()) do
		if obj.Name == "KiroTag_" .. plr.UserId then obj:Destroy() end
	end

	local customData  = getCustomData(plr)
	local tagColor    = customData and customData.color    or Color3.fromRGB(255, 255, 255)
	local glowColor   = customData and customData.glowColor or Color3.fromRGB(255, 255, 255)
	local displayName = customData and customData.customName or "Kiro User"
	local isOwner     = (displayName == "Kiro Owner")
	local gradA       = (customData and customData.gradientA) or GRADIENT_COLOR_A
	local gradB       = (customData and customData.gradientB) or GRADIENT_COLOR_B
	local logoAsset   = (customData and customData.logoAsset) or LOGO_ASSET_ID

	local bb = Instance.new("BillboardGui")
	bb.Name        = "KiroTag_" .. plr.UserId
	bb.Parent      = pg
	bb.Size        = defaultTagSz
	bb.StudsOffset = tagOff
	bb.AlwaysOnTop = true
	bb.MaxDistance  = math.huge
	bb.Adornee     = hd
	bb.Active      = true

	local btn = Instance.new("TextButton")
	btn.Parent               = bb
	btn.Size                 = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text                 = ""
	btn.ZIndex               = 20
	btn.AutoButtonColor      = false
	btn.Active               = true
	if plr ~= lp then
		btn.MouseButton1Click:Connect(function()
			local myChar = lp.Character
			if myChar and myChar:FindFirstChild("HumanoidRootPart") and hrp and hrp.Parent then
				myChar.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, 3)
			end
		end)
	end

	local bg = Instance.new("Frame")
	bg.Parent               = bb
	bg.Size                 = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3     = Color3.fromRGB(10, 10, 14)
	bg.BorderSizePixel      = 0
	bg.BackgroundTransparency = 0.15
	bg.ZIndex               = 1

	local cr = Instance.new("UICorner")
	cr.CornerRadius = TAG_CORNER
	cr.Parent       = bg

	local stroke = Instance.new("UIStroke")
	stroke.Parent          = bg
	stroke.Color           = Color3.fromRGB(255, 255, 255)
	stroke.Thickness       = 1.5
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Transparency    = 0.4

	local strokeGrad = Instance.new("UIGradient")
	strokeGrad.Color    = ColorSequence.new(gradA, gradB)
	strokeGrad.Rotation = 0
	strokeGrad.Parent   = stroke

	local bgGrad = Instance.new("UIGradient")
	bgGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 20)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 12)),
	})
	bgGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(1, 0.25),
	})
	bgGrad.Rotation = 0
	bgGrad.Parent   = bg

	spawn(function()
		local rot = 0
		local last = tick()
		while bb and bb.Parent do
			local now = tick()
			rot = (rot + GRADIENT_SPIN_SPEED * (now - last)) % 360
			last = now
			strokeGrad.Rotation = rot
			strokeGrad.Color = ColorSequence.new(gradA, gradB)
			wait(1 / 30)
		end
	end)

	local IMG_W       = 36
	local IMG_PAD     = 8
	local TEXT_OFFSET = IMG_PAD + IMG_W + 8

	local logoHolder = Instance.new("Frame")
	logoHolder.Name               = "LogoHolder"
	logoHolder.Parent             = bg
	logoHolder.Size               = UDim2.new(0, IMG_W, 0, IMG_W)
	logoHolder.Position           = UDim2.new(0, IMG_PAD, 0.5, -IMG_W/2)
	logoHolder.BackgroundColor3   = Color3.fromRGB(20, 20, 28)
	logoHolder.BackgroundTransparency = 0.3
	logoHolder.BorderSizePixel    = 0
	logoHolder.ZIndex             = 4
	logoHolder.ClipsDescendants   = true

	local logoCorner = Instance.new("UICorner")
	logoCorner.CornerRadius = UDim.new(0, 8)
	logoCorner.Parent       = logoHolder

	local logoStroke = Instance.new("UIStroke")
	logoStroke.Parent          = logoHolder
	logoStroke.Color           = Color3.fromRGB(255, 255, 255)
	logoStroke.Thickness       = 1
	logoStroke.Transparency    = 0.6
	logoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local logoImg = Instance.new("ImageLabel")
	logoImg.Name                 = "LogoImage"
	logoImg.Parent               = logoHolder
	logoImg.Size                 = UDim2.new(1, 0, 1, 0)
	logoImg.BackgroundTransparency = 1
	logoImg.ScaleType            = Enum.ScaleType.Fit
	logoImg.ZIndex               = 5

	-- Use retry loader to guarantee the image shows up after respawn
	forceLoadImage(logoImg, logoAsset)

	local kzk = Instance.new("TextLabel")
	kzk.Name                 = "DisplayName"
	kzk.Parent               = bg
	kzk.Size                 = UDim2.new(1, -(TEXT_OFFSET + 8), 0, 16)
	kzk.Position             = UDim2.new(0, TEXT_OFFSET, 0, 8)
	kzk.BackgroundTransparency = 1
	kzk.Text                 = displayName
	kzk.TextColor3           = tagColor
	kzk.TextScaled           = true
	kzk.TextXAlignment       = Enum.TextXAlignment.Left
	kzk.Font                 = Enum.Font.GothamBold
	kzk.TextStrokeTransparency = 0.5
	kzk.TextStrokeColor3     = Color3.fromRGB(0, 0, 0)
	kzk.ZIndex               = 3

	local kzkConstraint = Instance.new("UITextSizeConstraint")
	kzkConstraint.MaxTextSize = 14
	kzkConstraint.Parent      = kzk

	local dname = Instance.new("TextLabel")
	dname.Name               = "Username"
	dname.Parent             = bg
	dname.Size               = UDim2.new(1, -(TEXT_OFFSET + 8), 0, 12)
	dname.Position           = UDim2.new(0, TEXT_OFFSET, 0, 28)
	dname.BackgroundTransparency = 1
	dname.Text               = "@" .. plr.Name
	dname.TextColor3         = Color3.fromRGB(140, 140, 160)
	dname.TextScaled         = true
	dname.TextXAlignment     = Enum.TextXAlignment.Left
	dname.Font               = Enum.Font.Gotham
	dname.TextStrokeTransparency = 0.8
	dname.ZIndex             = 3

	local dnameConstraint = Instance.new("UITextSizeConstraint")
	dnameConstraint.MaxTextSize = 10
	dnameConstraint.Parent      = dname

	if isOwner then
		spawn(function()
			while bb and bb.Parent do
				wait(math.random(200, 500) / 100)
				if not bb or not kzk or not kzk.Parent then break end
				for _ = 1, math.random(5, 10) do
					if not kzk or not kzk.Parent then break end
					kzk.Text = glitchString(displayName)
					wait(0.04)
				end
				if kzk and kzk.Parent then kzk.Text = displayName end
			end
		end)
	end

	spawn(function()
		while bb and bb.Parent do
			for i = 0, 1, 0.1 do
				if not stroke or not stroke.Parent then break end
				stroke.Transparency = 0.3 + (i * 0.3)
				wait(0.03)
			end
			for i = 1, 0, -0.1 do
				if not stroke or not stroke.Parent then break end
				stroke.Transparency = 0.3 + (i * 0.3)
				wait(0.03)
			end
			wait(0.2)
		end
	end)

	local pFrm = Instance.new("Frame")
	pFrm.Parent               = bg
	pFrm.Size                 = UDim2.new(1, 0, 1, 0)
	pFrm.BackgroundTransparency = 1
	pFrm.ClipsDescendants     = true
	pFrm.ZIndex               = 1
	Instance.new("UICorner", pFrm).CornerRadius = TAG_CORNER
	for _ = 1, 12 do
		local dot = Instance.new("Frame")
		dot.Parent              = pFrm
		dot.Size                = UDim2.new(0, 2, 0, 2)
		dot.Position            = UDim2.new(math.random() * 0.9 + 0.05, 0, math.random() * 0.9 + 0.05, 0)
		dot.BackgroundColor3    = tagColor
		dot.BackgroundTransparency = math.random(40, 75) / 100
		dot.ZIndex              = 1
		Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
	end
	spawn(function()
		while bb and bb.Parent do
			for _, dot in pairs(pFrm:GetChildren()) do
				if dot:IsA("Frame") then
					local pos  = dot.Position
					local yVal = pos.Y.Scale - 0.008
					if yVal < -0.1 then yVal = 1.1 end
					dot.Position           = UDim2.new(pos.X.Scale, 0, yVal, 0)
					dot.BackgroundTransparency = 0.3 + math.random(0, 50) / 100
				end
			end
			wait(0.05)
		end
	end)

	local tweenCfg = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local isZoomed = false
	spawn(function()
		while bb and bb.Parent and hrp and hrp.Parent do
			local myChar = lp.Character
			if myChar and myChar:FindFirstChild("HumanoidRootPart") then
				local dist = (myChar.HumanoidRootPart.Position - hrp.Position).Magnitude
				if dist > ZOOMOUT_DISTANCE and not isZoomed then
					isZoomed = true
					tweenSvc:Create(bb, tweenCfg, {Size = ZOOMOUT_SIZE}):Play()
					kzk.Visible = false; dname.Visible = false
					pFrm.Visible = false
				elseif dist <= ZOOMOUT_DISTANCE and isZoomed then
					isZoomed = false
					tweenSvc:Create(bb, tweenCfg, {Size = defaultTagSz}):Play()
					kzk.Visible = true; dname.Visible = true
					pFrm.Visible = true
				end
			end
			wait(0.1)
		end
	end)

	if plr ~= lp then
		local cleanup
		cleanup = runSvc.Heartbeat:Connect(function()
			if not hd or not hd.Parent then
				cleanup:Disconnect()
				if bb and bb.Parent then
					bb.Adornee = nil
					bb:Destroy()
				end
				if plr and plr.Parent then
					taggedPlrs[plr.UserId] = nil
					local newChar = plr.Character or plr.CharacterAdded:Wait()
					newChar:WaitForChild("Head", 5)
					task.wait(0.3)
					buildTag(plr)
				end
			end
		end)
	else
		local cleanup
		cleanup = runSvc.Heartbeat:Connect(function()
			if not hd or not hd.Parent then
				cleanup:Disconnect()
				if bb and bb.Parent then
					bb.Adornee = nil
					bb:Destroy()
				end
				taggedPlrs[lp.UserId] = nil
			end
		end)
	end
end

local function rebuildTag(plr)
	taggedPlrs[plr.UserId] = nil
	local pg = lp:FindFirstChild("PlayerGui")
	if pg then
		local old = pg:FindFirstChild("KiroTag_" .. plr.UserId)
		if old then old:Destroy() end
	end
	task.wait(0.5)
	buildTag(plr)
end

for _, plr in pairs(plrs:GetPlayers()) do
	plr.CharacterAdded:Connect(function(char)
		char:WaitForChild("Head", 5)
		rebuildTag(plr)
	end)
end

lp.CharacterAdded:Connect(function(char)
	char:WaitForChild("Head", 5)
	rebuildTag(lp)
	for userId, _ in pairs(mutualPlrs) do
		if userId ~= lp.UserId then
			local plr = plrs:GetPlayerByUserId(userId)
			if plr then rebuildTag(plr) end
		end
	end
end)

plrs.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		char:WaitForChild("Head", 5)
		rebuildTag(plr)
	end)
end)

local hasInitialized = false
local hasResponded = {}

local function handleMessage(msg, ch)
	if not msg or not msg.Text then return end
	local text = msg.Text
	local src = msg.TextSource
	if not src then return end
	local sender = plrs:GetPlayerByUserId(src.UserId)
	if not sender or sender == lp then return end

	if string.find(text, "\217\136\217\136\217\136") then
		mutualPlrs[sender.UserId] = true

		local replyKey = tostring(sender.UserId)
		if not hasResponded[replyKey] then
			hasResponded[replyKey] = true
			task.wait(0.5)
			ch:SendAsync("\217\136")
			task.delay(5, function()
				hasResponded[replyKey] = nil
			end)
		end

		if not taggedPlrs[sender.UserId] then
			if sender.Character then buildTag(sender)
			else sender.CharacterAdded:Wait(); wait(0.5); buildTag(sender) end
		end

	elseif string.find(text, "\217\136") and not string.find(text, "\217\136\217\136\217\136") then
		mutualPlrs[sender.UserId] = true
		if not taggedPlrs[sender.UserId] then
			if sender.Character then buildTag(sender)
			else sender.CharacterAdded:Wait(); wait(0.5); buildTag(sender) end
		end
	end
end

local channels = txtChat:WaitForChild("TextChannels", 5)
local general  = channels and channels:FindFirstChild("RBXGeneral")
if channels then
	for _, ch in pairs(channels:GetChildren()) do
		if ch:IsA("TextChannel") then
			ch.MessageReceived:Connect(function(msg) handleMessage(msg, ch) end)
		end
	end
	channels.ChildAdded:Connect(function(ch)
		if ch:IsA("TextChannel") then
			ch.MessageReceived:Connect(function(msg) handleMessage(msg, ch) end)
		end
	end)
	if general and not hasInitialized then
		hasInitialized = true
		task.wait(1)
		general:SendAsync("\217\136\217\136\217\136")
	end
end

mutualPlrs[lp.UserId] = true
task.wait(1)
if lp.Character then buildTag(lp)
else lp.CharacterAdded:Wait(); task.wait(0.5); buildTag(lp) end

plrs.PlayerRemoving:Connect(function(plr)
	taggedPlrs[plr.UserId]    = nil
	respondedPlrs[plr.UserId] = nil
	mutualPlrs[plr.UserId]    = nil
	local pg = lp:FindFirstChild("PlayerGui")
	if pg then
		local tag = pg:FindFirstChild("KiroTag_" .. plr.UserId)
		if tag then tag:Destroy() end
	end
end)

game:BindToClose(function()
	local pg = lp:FindFirstChild("PlayerGui")
	if pg then
		for _, obj in pairs(pg:GetChildren()) do
			if string.find(obj.Name, "KiroTag_") then obj:Destroy() end
		end
	end
end)
