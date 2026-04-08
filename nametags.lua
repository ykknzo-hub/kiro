-- [[ KIRO Nametag System v3 ]]

local GRADIENT_COLOR_A    = Color3.fromRGB(255, 255, 255)
local GRADIENT_COLOR_B    = Color3.fromRGB(0, 0, 0)
local GRADIENT_SPIN_SPEED = 60

local ZOOMOUT_SIZE     = UDim2.new(0, 38, 0, 38)
local ZOOMOUT_RADIUS   = UDim.new(0, 8)
local ZOOMOUT_DISTANCE = 60

local THEMES = {
	purple = { Color3.fromRGB(150, 60, 255), Color3.fromRGB(255, 150, 255) },
	gold   = { Color3.fromRGB(255, 180,  20), Color3.fromRGB(255, 255, 180) },
	cyan   = { Color3.fromRGB( 20, 200, 255), Color3.fromRGB(180, 255, 255) },
	fire   = { Color3.fromRGB(255,  50,   0), Color3.fromRGB(255, 230,  50) },
	bw     = { Color3.fromRGB( 40,  40,  40), Color3.fromRGB(220, 220, 220) },
}

local CONFIG = {
	RankText           = "KIRO USER",
	DisplayName        = "@user",
	Theme              = "bw",
	ShimmerEnabled     = true,
	PulseEnabled       = true,
	RainbowRankEnabled = false,
	FloatAmplitude     = 0.08,
	FloatSpeed         = 1.4,
	RankEffect         = "typing",
}

local function getThemeColors()
	return THEMES[CONFIG.Theme] or THEMES.purple
end

local customPlayers = {
	["Robloxianw3s1j0e2o"] = {
		customName = "KIRO OWNER",
		gradientA  = Color3.fromRGB(255, 128, 139),
		gradientB  = Color3.fromRGB(255, 255, 255),
		rankEffect = "glitch",
		logoAsset  = "rbxassetid://88344135795603",
	},
	["6vryzx"] = {
		customName = "CO-OWNER",
		gradientA  = Color3.fromRGB(0, 0, 255),
		gradientB  = Color3.fromRGB(0, 0, 0),
		rankEffect = "glitch",
		logoAsset  = "rbxassetid://131090669162422",
	},
	["isntkalay"] = {
		customName = "Kiro Owner ALT",
		gradientA  = Color3.fromRGB(255, 128, 139),
		gradientB  = Color3.fromRGB(255, 255, 255),
		rankEffect = "glitch",
		logoAsset  = "rbxassetid://88344135795603",
	},
	["forrandomsthings"] = {
		customName = "KIRO V3X",
		gradientA  = Color3.fromRGB(0, 255, 255),
		gradientB  = Color3.fromRGB(128, 128, 128),
		rankEffect = "glitch",
		logoAsset  = "rbxassetid://86149749300598",
	},
	["g6h2z"] = {
		customName = "KIRO STAFF",
		gradientA  = Color3.fromRGB(255, 255, 255),
		gradientB  = Color3.fromRGB(0, 0, 0),
		rankEffect = "glitch",
		logoAsset  = "rbxassetid://138252827537421",
	},
	["gamergod0007"] = {
		customName = "KIRO STAFF",
		gradientA  = Color3.fromRGB(255, 255, 255),
		gradientB  = Color3.fromRGB(0, 0, 0),
		rankEffect = "glitch",
		logoAsset  = "rbxassetid://138252827537421",
	},
	["Kreative_Lexiii"] = {
		customName = "KIRO SUPPORT",
		gradientA  = Color3.fromRGB(0, 255, 0),
		gradientB  = Color3.fromRGB(0, 255, 0),
		rankEffect = "glitch",
		logoAsset  = "rbxassetid://139812142649953",
	},
	["20reuben14alt5"] = {
		customName = "KIRO SUPPORT",
		gradientA  = Color3.fromRGB(0, 255, 0),
		gradientB  = Color3.fromRGB(0, 255, 0),
		rankEffect = "glitch",
		logoAsset  = "rbxassetid://139812142649953",
	},
	["rainbowdelux0765"] = {
		customName = "KIRO ALEAH",
		gradientA  = Color3.fromRGB(255, 255, 255),
		gradientB  = Color3.fromRGB(0, 0, 0),
		rankEffect = "glitch",
		logoAsset  = "rbxassetid://74960672416607",
	},
	["MRmiskingpapa1221"] = {
		customName = "KIRO STAFF",
		gradientA  = Color3.fromRGB(0, 0, 0),
		gradientB  = Color3.fromRGB(0, 0, 0),
		rankEffect = "glitch",
		logoAsset  = "rbxassetid://138252827537421",
	},
	["Adamalchoum2"] = {
		customName = "KIRO NT TEAM",
		gradientA  = Color3.fromRGB(128, 0, 128),
		gradientB  = Color3.fromRGB(128, 0, 128),
		rankEffect = "glitch",
		logoAsset  = "rbxassetid://138252827537421",
	},
}

local function lerp(a, b, t) return a + (b - a) * t end

local function lerpColor(c1, c2, t)
	return Color3.new(lerp(c1.R, c2.R, t), lerp(c1.G, c2.G, t), lerp(c1.B, c2.B, t))
end

local function cyclicLerp(colors, t)
	local n   = #colors
	local pos = (t % 1) * n
	local idx = math.floor(pos) + 1
	local frac = pos - math.floor(pos)
	return lerpColor(colors[idx], colors[(idx % n) + 1], frac)
end

local function makeColorSequence(colors)
	local kps = {}
	for i, c in ipairs(colors) do
		kps[i] = ColorSequenceKeypoint.new((i - 1) / (#colors - 1), c)
	end
	return ColorSequence.new(kps)
end

local function randomBetween(a, b) return a + math.random() * (b - a) end

local function startTypingEffect(label, fullText, cursorLabel)
	spawn(function()
		local chars = #fullText
		local phase = "pause_full"
		local blinks, curOn = 0, true
		while label and label.Parent do
			if phase == "pause_full" then
				label.Text = fullText
				if cursorLabel then cursorLabel.Text = "|" end
				wait(1.5); phase = "blink_loop"; blinks = 0; curOn = true
			elseif phase == "blink_loop" then
				curOn = not curOn
				if cursorLabel then cursorLabel.Text = curOn and "|" or "" end
				wait(0.5); blinks = blinks + 0.5
				if blinks >= 3 then wait(0.3); phase = "delete"; if cursorLabel then cursorLabel.Text = "|" end end
			elseif phase == "delete" then
				if chars > 0 then chars -= 1; label.Text = string.sub(fullText, 1, chars); wait(0.05)
				else phase = "pause_empty"; wait(0.4); phase = "type" end
			elseif phase == "type" then
				if chars < #fullText then chars += 1; label.Text = string.sub(fullText, 1, chars); wait(0.07)
				else phase = "pause_full" end
			end
		end
	end)
end

local GLITCH_CHARS = {"#","@","!","$","%","&","?","*","/","\\","|","~","^","X","Z"}
local function glitchString(original)
	local result = {}
	for i = 1, #original do
		result[i] = math.random() < 0.4 and GLITCH_CHARS[math.random(1, #GLITCH_CHARS)] or string.sub(original, i, i)
	end
	return table.concat(result)
end

local function startGlitchEffect(label, fullText)
	spawn(function()
		while label and label.Parent do
			wait(randomBetween(2.0, 4.5))
			if not label or not label.Parent then break end
			for _ = 1, math.random(5, 10) do
				if not label or not label.Parent then break end
				label.Text = glitchString(fullText); wait(0.04)
			end
			if label and label.Parent then label.Text = fullText end
		end
	end)
end

local function startWaveEffect(parent, fullText, basePos, textColor, font)
	local CHAR_W = 7
	local startX, startYs, startYo = basePos.X.Offset, basePos.Y.Scale, basePos.Y.Offset
	local charLabels = {}
	for i = 1, #fullText do
		local ch  = string.sub(fullText, i, i)
		local lbl = Instance.new("TextLabel")
		lbl.Parent = parent
		lbl.Size   = UDim2.new(0, CHAR_W + 2, 0, 16)
		lbl.Position = UDim2.new(basePos.X.Scale, startX + (i-1)*CHAR_W, startYs, startYo)
		lbl.BackgroundTransparency = 1
		lbl.Text   = ch == " " and "\u{00A0}" or ch
		lbl.TextColor3 = textColor; lbl.Font = font
		lbl.TextScaled = false; lbl.TextSize = 12
		lbl.TextStrokeTransparency = 0.5
		lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		lbl.ZIndex = 3
		charLabels[i] = lbl
	end
	local running = true
	spawn(function()
		local t = 0
		while running do
			t = t + 0.05
			for i, lbl in ipairs(charLabels) do
				if not lbl or not lbl.Parent then running = false; break end
				local wave = math.sin(t * 4 + (i-1) * 0.75) * 2.8
				lbl.Position = UDim2.new(basePos.X.Scale, startX + (i-1)*CHAR_W, startYs, startYo + wave)
			end
			wait(0.05)
		end
	end)
	return function()
		running = false
		for _, lbl in ipairs(charLabels) do if lbl and lbl.Parent then lbl:Destroy() end end
	end
end

local plrs       = game:GetService("Players")
local txtChat    = game:GetService("TextChatService")
local tweenSvc   = game:GetService("TweenService")
local runSvc     = game:GetService("RunService")
local starterGui = game:GetService("StarterGui")
local lp         = plrs.LocalPlayer

local taggedPlrs = {}
local mutualPlrs = {}

local defaultTagSz = UDim2.new(0, 160, 0, 44)
local tagOff       = Vector3.new(0, 2.0, 0)
local LOGO_ASSET_ID = "rbxassetid://121655015965144"
local TAG_CORNER    = UDim.new(0, 8)

starterGui:SetCore("SendNotification", {
	Title = "Kiro Nametags"; Text = "Nametag system loaded"; Duration = 5;
})

local function getCustomData(plr)
	if customPlayers[plr.Name]   then return customPlayers[plr.Name]   end
	if customPlayers[plr.UserId] then return customPlayers[plr.UserId] end
	return nil
end

local function buildTag(plr)
	if not mutualPlrs[plr.UserId] then return end
	if taggedPlrs[plr.UserId]     then return end
	local char = plr.Character
	if not char then return end
	local hd  = char:FindFirstChild("Head"); if not hd  then return end
	local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end

	taggedPlrs[plr.UserId] = true

	local pg = lp:WaitForChild("PlayerGui")
	for _, obj in pairs(pg:GetChildren()) do
		if obj.Name == "KiroTag_" .. plr.UserId then obj:Destroy() end
	end

	local customData = getCustomData(plr)
	local displayName = customData and customData.customName or "Kiro User"
	local gradA = (customData and customData.gradientA) or GRADIENT_COLOR_A
	local gradB = (customData and customData.gradientB) or GRADIENT_COLOR_B

	local resolvedRankEffect = customData and (customData.rankEffect or "none") or CONFIG.RankEffect

	local function getColors()
		if gradA and gradB then return {gradA, gradB} end
		if plr == lp then return getThemeColors() end
		return {GRADIENT_COLOR_A, GRADIENT_COLOR_B}
	end

	local finalColors = getColors()
	local tagColor    = finalColors[1] or Color3.fromRGB(255, 255, 255)

	local bb = Instance.new("BillboardGui")
	bb.Name = "KiroTag_" .. plr.UserId; bb.Parent = pg
	bb.Size = defaultTagSz; bb.StudsOffset = tagOff
	bb.AlwaysOnTop = true; bb.MaxDistance = math.huge
	bb.Adornee = hd; bb.Active = true

	local btn = Instance.new("TextButton")
	btn.Parent = bb; btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1; btn.Text = ""
	btn.ZIndex = 20; btn.AutoButtonColor = false; btn.Active = true
	if plr ~= lp then
		btn.MouseButton1Click:Connect(function()
			local myChar = lp.Character
			if myChar and myChar:FindFirstChild("HumanoidRootPart") and hrp and hrp.Parent then
				myChar.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, 3)
			end
		end)
	end

	local bg = Instance.new("Frame")
	bg.Parent = bb; bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(15, 12, 24)
	bg.BorderSizePixel = 0; bg.BackgroundTransparency = 0.12; bg.ZIndex = 1
	Instance.new("UICorner", bg).CornerRadius = TAG_CORNER

	local bgGrad = Instance.new("UIGradient")
	bgGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, finalColors[1]),
		ColorSequenceKeypoint.new(1, finalColors[2] or finalColors[1]),
	})
	bgGrad.Rotation = 135; bgGrad.Parent = bg

	local stroke = Instance.new("UIStroke")
	stroke.Parent = bg; stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 1.5; stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Transparency = 0.4
	local strokeGrad = Instance.new("UIGradient")
	strokeGrad.Color = ColorSequence.new(finalColors[1], finalColors[2] or finalColors[1])
	strokeGrad.Rotation = 0; strokeGrad.Parent = stroke

	local shimmer = Instance.new("Frame")
	shimmer.Name = "Shimmer"; shimmer.Size = UDim2.new(0.35, 0, 1, 0)
	shimmer.Position = UDim2.new(-0.35, 0, 0, 0)
	shimmer.BackgroundColor3 = Color3.new(1, 1, 1)
	shimmer.BackgroundTransparency = 0.82; shimmer.BorderSizePixel = 0
	shimmer.ZIndex = 8; shimmer.ClipsDescendants = false; shimmer.Parent = bg
	Instance.new("UICorner", shimmer).CornerRadius = TAG_CORNER
	local shimGrad = Instance.new("UIGradient")
	shimGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,    1),
		NumberSequenceKeypoint.new(0.45, 0.6),
		NumberSequenceKeypoint.new(0.5,  0.3),
		NumberSequenceKeypoint.new(0.55, 0.6),
		NumberSequenceKeypoint.new(1,    1),
	})
	shimGrad.Rotation = 15; shimGrad.Parent = shimmer

	local IMG_W       = 32
	local IMG_PAD     = 6
	local TEXT_OFFSET = IMG_PAD + IMG_W + 6

	local logoHolder = Instance.new("Frame")
	logoHolder.Name = "LogoHolder"; logoHolder.Parent = bg
	logoHolder.Size = UDim2.new(0, IMG_W, 0, IMG_W)
	logoHolder.Position = UDim2.new(0, IMG_PAD, 0.5, -IMG_W/2)
	logoHolder.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
	logoHolder.BackgroundTransparency = 1; logoHolder.BorderSizePixel = 0
	logoHolder.ZIndex = 4; logoHolder.ClipsDescendants = true
	Instance.new("UICorner", logoHolder).CornerRadius = UDim.new(1, 0)

	local logoStroke = Instance.new("UIStroke")
	logoStroke.Parent = logoHolder; logoStroke.Color = Color3.fromRGB(255, 255, 255)
	logoStroke.Thickness = 1; logoStroke.Transparency = 1
	logoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local logoImg = Instance.new("ImageLabel")
	logoImg.Name = "LogoImage"; logoImg.Parent = logoHolder
	logoImg.Size = UDim2.new(1, 0, 1, 0); logoImg.BackgroundTransparency = 1
	logoImg.Image = (customData and customData.logoAsset) or LOGO_ASSET_ID
	logoImg.ScaleType = Enum.ScaleType.Fit; logoImg.ZIndex = 5
	Instance.new("UICorner", logoImg).CornerRadius = UDim.new(1, 0)

	local kzk = Instance.new("TextLabel")
	kzk.Name = "DisplayName"; kzk.Parent = bg
	kzk.Size = UDim2.new(1, -(TEXT_OFFSET + 8), 0, 16)
	kzk.Position = UDim2.new(0, TEXT_OFFSET, 0, 8)
	kzk.BackgroundTransparency = 1; kzk.Text = displayName
	kzk.TextColor3 = Color3.fromRGB(255, 255, 255); kzk.TextScaled = true
	kzk.TextXAlignment = Enum.TextXAlignment.Left; kzk.Font = Enum.Font.GothamBold
	kzk.TextStrokeTransparency = 0.5; kzk.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	kzk.ZIndex = 3
	local kzkConstraint = Instance.new("UITextSizeConstraint")
	kzkConstraint.MaxTextSize = 12; kzkConstraint.Parent = kzk
	local kzkGrad = Instance.new("UIGradient")
	kzkGrad.Color = ColorSequence.new(tagColor); kzkGrad.Rotation = 0; kzkGrad.Parent = kzk

	local cursorLabel = Instance.new("TextLabel")
	cursorLabel.Name = "TypingCursor"; cursorLabel.Parent = bg
	cursorLabel.Size = UDim2.new(0, 8, 0, 16)
	cursorLabel.Position = UDim2.new(0, TEXT_OFFSET, 0, 10)
	cursorLabel.BackgroundTransparency = 1; cursorLabel.Text = ""
	cursorLabel.TextColor3 = Color3.fromRGB(255, 255, 255); cursorLabel.TextScaled = true
	cursorLabel.TextXAlignment = Enum.TextXAlignment.Left; cursorLabel.Font = Enum.Font.GothamBold
	cursorLabel.ZIndex = 4; cursorLabel.Visible = false

	local dname = Instance.new("TextLabel")
	dname.Name = "Username"; dname.Parent = bg
	dname.Size = UDim2.new(1, -(TEXT_OFFSET + 8), 0, 10)
	dname.Position = UDim2.new(0, TEXT_OFFSET, 0.5, 3)
	dname.BackgroundTransparency = 1; dname.Text = "@" .. plr.Name
	dname.TextColor3 = Color3.fromRGB(255, 255, 255); dname.TextScaled = true
	dname.TextXAlignment = Enum.TextXAlignment.Left; dname.Font = Enum.Font.Gotham
	dname.TextStrokeTransparency = 0.85; dname.ZIndex = 3
	local dnameGrad = Instance.new("UIGradient")
	dnameGrad.Name = "UserGrad"
	dnameGrad.Color = ColorSequence.new(finalColors[1], finalColors[2] or finalColors[1])
	dnameGrad.Rotation = 0; dnameGrad.Parent = dname
	local dnameConstraint = Instance.new("UITextSizeConstraint")
	dnameConstraint.MaxTextSize = 9; dnameConstraint.Parent = dname

	local waveCleanup = nil
	if resolvedRankEffect == "typing" then
		cursorLabel.Visible = true
		startTypingEffect(kzk, displayName, cursorLabel)
	elseif resolvedRankEffect == "glitch" then
		startGlitchEffect(kzk, displayName)
	elseif resolvedRankEffect == "wave" then
		kzk.Visible = false; cursorLabel.Visible = false
		waveCleanup = startWaveEffect(bg, displayName, UDim2.new(0, TEXT_OFFSET, 0, 8), Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold)
	end

	local pFrm = Instance.new("Frame")
	pFrm.Parent = bg; pFrm.Size = UDim2.new(1, 0, 1, 0)
	pFrm.BackgroundTransparency = 1; pFrm.ClipsDescendants = true; pFrm.ZIndex = 1
	Instance.new("UICorner", pFrm).CornerRadius = TAG_CORNER
	for i = 1, 18 do
		local dot = Instance.new("Frame"); dot.Parent = pFrm
		local sz  = math.random(1, 3)
		dot.Size  = UDim2.new(0, sz, 0, sz)
		dot.Position = UDim2.new(math.random() * 0.95, 0, math.random() * 0.95, 0)
		dot.BackgroundColor3 = finalColors[math.random(1, #finalColors)]
		dot.BackgroundTransparency = math.random(60, 90) / 100; dot.ZIndex = 1
		Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
	end
	spawn(function()
		while bb and bb.Parent do
			for _, dot in pairs(pFrm:GetChildren()) do
				if dot:IsA("Frame") then
					local pos = dot.Position
					local yVal = pos.Y.Scale - 0.008
					if yVal < -0.1 then yVal = 1.1 end
					dot.Position = UDim2.new(pos.X.Scale, 0, yVal, 0)
					dot.BackgroundTransparency = 0.3 + math.random(0, 50) / 100
				end
			end
			wait(0.05)
		end
	end)

	local tweenCfg = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local isZoomed = false
	local t0 = tick()

	local connection
	connection = runSvc.Heartbeat:Connect(function()
		if not bb or not bb.Parent then
			connection:Disconnect()
			if waveCleanup then waveCleanup() end
			return
		end
		local t      = tick() - t0
		local colors = getColors()

		if CONFIG.ShimmerEnabled then
			local sweepPos = (t * 0.45) % 1.7 - 0.35
			shimmer.Position = UDim2.new(sweepPos - 0.35, 0, 0, 0)
		end
		if CONFIG.PulseEnabled then
			stroke.Transparency = 0.3 + 0.15 * math.sin(t * 2.2)
		end

		strokeGrad.Rotation = 0
		strokeGrad.Color = makeColorSequence(colors)

		if not CONFIG.RainbowRankEnabled or plr ~= lp then
			kzk.TextColor3 = Color3.fromRGB(255, 255, 255)
			local c1 = colors[1]:Lerp(Color3.new(1,1,1), 0.3)
			local c2 = (colors[2] or colors[1]):Lerp(Color3.new(1,1,1), 0.3)
			kzkGrad.Color    = makeColorSequence({c1, c2})
			kzkGrad.Rotation = 0
			local dgr = dname:FindFirstChild("UserGrad")
			if dgr then dgr.Color = makeColorSequence({c1, c2}) end
		else
			kzk.TextColor3 = cyclicLerp(colors, (t * 0.5) % 1)
			kzkGrad.Color = makeColorSequence({
				cyclicLerp(colors, (t * 0.5)       % 1),
				cyclicLerp(colors, (t * 0.5 + 0.5) % 1),
			})
			kzkGrad.Rotation = (t * 50) % 360
		end

		if resolvedRankEffect == "typing" and cursorLabel and cursorLabel.Parent then
			local approxW = math.min(#kzk.Text * 7, kzk.AbsoluteSize.X)
			cursorLabel.Position = UDim2.new(0, TEXT_OFFSET + approxW, 0, 8)
		end

		local floatY = math.sin(t * CONFIG.FloatSpeed) * CONFIG.FloatAmplitude
		bb.StudsOffset = tagOff + Vector3.new(0, floatY, 0)

		local myChar = lp.Character
		if myChar and myChar:FindFirstChild("HumanoidRootPart") and hrp and hrp.Parent then
			local dist = (myChar.HumanoidRootPart.Position - hrp.Position).Magnitude
			if dist > ZOOMOUT_DISTANCE and not isZoomed then
				isZoomed = true
				tweenSvc:Create(bb, tweenCfg, {Size = ZOOMOUT_SIZE}):Play()
				tweenSvc:Create(logoHolder, tweenCfg, {Position = UDim2.new(0.5, -IMG_W/2, 0.5, -IMG_W/2)}):Play()
				kzk.Visible = false; dname.Visible = false
				cursorLabel.Visible = false; pFrm.Visible = false
			elseif dist <= ZOOMOUT_DISTANCE and isZoomed then
				isZoomed = false
				tweenSvc:Create(bb, tweenCfg, {Size = defaultTagSz}):Play()
				tweenSvc:Create(logoHolder, tweenCfg, {Position = UDim2.new(0, IMG_PAD, 0.5, -IMG_W/2)}):Play()
				kzk.Visible = (resolvedRankEffect ~= "wave")
				dname.Visible = true
				cursorLabel.Visible = (resolvedRankEffect == "typing")
				pFrm.Visible = true
			end
		end

		for _, p in pairs(plrs:GetPlayers()) do
			local c = p.Character
			local h = c and c:FindFirstChild("Humanoid")
			if h then
				h.DisplayDistanceType   = Enum.HumanoidDisplayDistanceType.None
				h.NameDisplayDistance   = 0
				h.HealthDisplayDistance = 0
			end
		end
	end)

	local cleanup
	cleanup = runSvc.Heartbeat:Connect(function()
		if not hd or not hd.Parent then
			if bb and bb.Parent then bb.Adornee = nil end
			if plr and plr.Parent then
				local newChar = plr.Character
				if newChar and newChar:FindFirstChild("Head") then
					if bb and bb.Parent then
						bb.Adornee = newChar.Head
						hd  = newChar.Head
						hrp = newChar:FindFirstChild("HumanoidRootPart")
					end
				end
			else
				bb:Destroy()
				if waveCleanup then waveCleanup() end
				cleanup:Disconnect()
			end
		end
	end)
end

local function rebuildTag(plr)
	taggedPlrs[plr.UserId] = nil
	wait(0.3)
	buildTag(plr)
end

for _, plr in pairs(plrs:GetPlayers()) do
	plr.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid", 5)
		if hum then
			hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			hum.NameDisplayDistance = 0; hum.HealthDisplayDistance = 0
		end
		char:WaitForChild("Head", 5); rebuildTag(plr)
	end)
end

lp.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid", 5)
	if hum then
		hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		hum.NameDisplayDistance = 0; hum.HealthDisplayDistance = 0
	end
	char:WaitForChild("Head", 5)
	for userId in pairs(mutualPlrs) do
		local plr = plrs:GetPlayerByUserId(userId)
		if plr then rebuildTag(plr) end
	end
end)

plrs.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid", 5)
		if hum then
			hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			hum.NameDisplayDistance = 0; hum.HealthDisplayDistance = 0
		end
		char:WaitForChild("Head", 5); rebuildTag(plr)
	end)
end)

local hasInitialized = false
local hasResponded   = {}

local function handleMessage(msg, ch)
	if not msg or not msg.Text then return end
	local text = msg.Text
	local src  = msg.TextSource
	if not src then return end
	local sender = plrs:GetPlayerByUserId(src.UserId)
	if not sender or sender == lp then return end

	if string.find(text, "○") then
		local replyKey = tostring(sender.UserId)
		if hasResponded[replyKey] or mutualPlrs[sender.UserId] then return end
		hasResponded[replyKey] = true
		task.wait(0.5)
		ch:SendAsync("●")
		mutualPlrs[sender.UserId] = true
		if not taggedPlrs[sender.UserId] then
			if sender.Character then buildTag(sender)
			else sender.CharacterAdded:Wait(); wait(0.5); buildTag(sender) end
		end
	elseif string.find(text, "●") then
		mutualPlrs[sender.UserId] = true
		if not taggedPlrs[sender.UserId] then
			if sender.Character then buildTag(sender)
			else sender.CharacterAdded:Wait(); wait(0.5); buildTag(sender) end
		end
	end
end

local channels = txtChat:WaitForChild("TextChannels", 5)
local general  = channels and channels:FindFirstChild("RBXGeneral")

if general then
	general.MessageReceived:Connect(function(msg) handleMessage(msg, general) end)
	task.wait(3)
	if not hasInitialized and next(mutualPlrs) == nil then
		hasInitialized = true
		general:SendAsync("○")
	end
end

mutualPlrs[lp.UserId] = true
task.wait(1)
if lp.Character then buildTag(lp)
else lp.CharacterAdded:Wait(); task.wait(0.5); buildTag(lp) end

plrs.PlayerRemoving:Connect(function(plr)
	taggedPlrs[plr.UserId] = nil; mutualPlrs[plr.UserId] = nil
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

return {
	SetRankText = function(text)
		CONFIG.RankText = text
		local pg  = lp:FindFirstChild("PlayerGui")
		local bb  = pg and pg:FindFirstChild("KiroTag_" .. lp.UserId)
		local lbl = bb and bb:FindFirstChild("DisplayName", true)
		if lbl then lbl.Text = text end
	end,
	SetDisplayName = function(name)
		CONFIG.DisplayName = name
		local pg  = lp:FindFirstChild("PlayerGui")
		local bb  = pg and pg:FindFirstChild("KiroTag_" .. lp.UserId)
		local lbl = bb and bb:FindFirstChild("Username", true)
		if lbl then lbl.Text = name end
	end,
	SetTheme = function(themeName)
		if THEMES[themeName] then CONFIG.Theme = themeName; rebuildTag(lp) end
	end,
	SetRainbow  = function(enabled) CONFIG.RainbowRankEnabled = enabled end,
	SetRankEffect = function(effect) CONFIG.RankEffect = effect; rebuildTag(lp) end,
	Rebuild     = function() rebuildTag(lp) end,
}
