-- TUSAR v3 | Mobile Delta | ESP + Aimbot + Fly

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════
--           CONFIG
-- ══════════════════════════════════════
local CFG = {
    ESP = {
        Enabled = true,
        Box = true,
        CornerBox = false,
        Name = true,
        Health = true,
        Distance = true,
        Tracer = true,
        TeamCheck = true,
        WallCheck = false,
        Color = Color3.fromRGB(0, 255, 80),
        TeamColor = Color3.fromRGB(80, 140, 255),
        MaxDist = 2000,
    },
    Aimbot = {
        Enabled = false,
        FOV = 180,
        Smooth = 0.12,
        Part = "Head",
        TeamCheck = true,
        Prediction = true,
        PredStr = 0.14,
        ShowFOV = true,
        AutoFire = false,
    },
    Triggerbot = {
        Enabled = false,
        TeamCheck = true,
        Delay = 0.03,
    },
    Fly = {
        Enabled = false,
        Speed = 60,
    },
}

-- ══════════════════════════════════════
--           UTILITY
-- ══════════════════════════════════════
local function isAlive(p)
    local c = p.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function isTeammate(p)
    return p.Team and p.Team == LocalPlayer.Team
end

local function getRoot(p)
    return p.Character and p.Character:FindFirstChild("HumanoidRootPart")
end

local function getHum(p)
    return p.Character and p.Character:FindFirstChildOfClass("Humanoid")
end

local function w2s(pos)
    local v, on = Camera:WorldToViewportPoint(pos)
    return Vector2.new(v.X, v.Y), on, v.Z
end

local function getCharBounds(p)
    local char = p.Character
    if not char then return nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not root or not head then return nil, nil end
    local topPos, _, topZ = w2s(head.Position + Vector3.new(0, head.Size.Y/2 + 0.2, 0))
    local botPos, _, botZ = w2s(root.Position - Vector3.new(0, 3.1, 0))
    if topZ < 0 or botZ < 0 then return nil, nil end
    return topPos, botPos
end

-- ══════════════════════════════════════
--           GUI
-- ══════════════════════════════════════
pcall(function()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        local old = pg:FindFirstChild("TusarV3")
        if old then old:Destroy() end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TusarV3"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
local MainFrame
-- ── Logo Button ──
local LogoBtn = Instance.new("TextButton")
LogoBtn.Name = "LogoBtn"
LogoBtn.Parent = ScreenGui
LogoBtn.Size = UDim2.new(0, 46, 0, 46)
LogoBtn.Position = UDim2.new(0, 16, 0.5, -23)
LogoBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
LogoBtn.Text = "T"
LogoBtn.Font = Enum.Font.GothamBold
LogoBtn.TextSize = 18
LogoBtn.TextColor3 = Color3.fromRGB(0, 255, 80)
LogoBtn.BorderSizePixel = 0
LogoBtn.ZIndex = 10
LogoBtn.Visible = false
Instance.new("UICorner", LogoBtn).CornerRadius = UDim.new(0, 12)
local logoStroke = Instance.new("UIStroke", LogoBtn)
logoStroke.Color = Color3.fromRGB(0, 200, 60)
logoStroke.Thickness = 1.5
logoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Logo drag + tap
local logoDragging = false
local logoDragInput = nil
local logoDragStart = Vector3.new()
local logoStartPos = UDim2.new()
local logoWasDragged = false

LogoBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then
        logoWasDragged = false
        logoDragging = true
        logoDragInput = i
        logoDragStart = i.Position
        logoStartPos = LogoBtn.Position
    end
end)

LogoBtn.InputChanged:Connect(function(i)
    if logoDragging and (i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = i.Position - logoDragStart
        if delta.Magnitude > 6 then logoWasDragged = true end
        LogoBtn.Position = UDim2.new(
            logoStartPos.X.Scale, logoStartPos.X.Offset + delta.X,
            logoStartPos.Y.Scale, logoStartPos.Y.Offset + delta.Y
        )
    end
end)

LogoBtn.InputEnded:Connect(function(i)
    if i ~= logoDragInput then
        return
    end

    logoDragging = false
    logoDragInput = nil

    -- A drag should not open the menu
    if logoWasDragged then
        return
    end

    -- Restore the main window
    MainFrame.Visible = true
    LogoBtn.Visible = false

    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

    TweenService:Create(
        MainFrame,
        TweenInfo.new(
            0.22,
            Enum.EasingStyle.Back,
            Enum.EasingDirection.Out
        ),
        {
            Size = UDim2.new(0, 290, 0, 400),
            Position = UDim2.new(0.5, -145, 0.5, -200)
        }
    ):Play()
end)

-- ── Main Window ──
MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 290, 0, 400)
MainFrame.Position = UDim2.new(0.5, -145, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", MainFrame)
stroke.Color = Color3.fromRGB(0, 200, 60)
stroke.Thickness = 1.5
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Title Bar
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2

local accentLine = Instance.new("Frame", TitleBar)
accentLine.Size = UDim2.new(1, 0, 0, 1)
accentLine.Position = UDim2.new(0, 0, 1, -1)
accentLine.BackgroundColor3 = Color3.fromRGB(0, 220, 60)
accentLine.BorderSizePixel = 0
accentLine.ZIndex = 3

local dot = Instance.new("Frame", TitleBar)
dot.Size = UDim2.new(0, 7, 0, 7)
dot.Position = UDim2.new(0, 12, 0.5, -3)
dot.BackgroundColor3 = Color3.fromRGB(0, 255, 80)
dot.BorderSizePixel = 0
dot.ZIndex = 3
Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 26, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "TUSAR  ESP"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 12
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 3

local VersionTag = Instance.new("TextLabel", TitleBar)
VersionTag.Size = UDim2.new(0, 36, 0, 14)
VersionTag.Position = UDim2.new(0, 106, 0.5, -7)
VersionTag.BackgroundColor3 = Color3.fromRGB(0, 150, 45)
VersionTag.Text = "v3.0"
VersionTag.Font = Enum.Font.GothamBold
VersionTag.TextSize = 8
VersionTag.TextColor3 = Color3.fromRGB(255, 255, 255)
VersionTag.BorderSizePixel = 0
VersionTag.ZIndex = 4
Instance.new("UICorner", VersionTag).CornerRadius = UDim.new(0, 4)

-- Close → logo
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -28, 0.5, -10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 10
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 5
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(
            MainFrame.Position.X.Scale,
            MainFrame.Position.X.Offset + 145,
            MainFrame.Position.Y.Scale,
            MainFrame.Position.Y.Offset + 200
        )
    }):Play()
    task.delay(0.2, function()
        MainFrame.Visible = false
        LogoBtn.Visible = true
    end)
end)

-- Main drag
local dragging = false
local dragInput = nil
local dragStart = Vector3.new()
local startPos = UDim2.new()

TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragInput = i
        dragStart = i.Position
        startPos = MainFrame.Position
    end
end)
TitleBar.InputEnded:Connect(function(i)
    if i == dragInput then dragging = false dragInput = nil end
end)
TitleBar.InputChanged:Connect(function(i)
    if dragging and dragInput and
    (i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = i.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ── Tabs ──
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, 0, 0, 32)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 2
local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 1)

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, 0, 1, -72)
ContentFrame.Position = UDim2.new(0, 0, 0, 72)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ClipsDescendants = true
ContentFrame.ZIndex = 2

local tabs = {}
local activeTab = nil

local function makeTab(name, icon, order)
    local page = Instance.new("ScrollingFrame", ContentFrame)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 60)
    page.Visible = false
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ZIndex = 2
    local pad = Instance.new("UIPadding", page)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    local layout = Instance.new("UIListLayout", page)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)

    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(0, 70, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
    btn.Text = icon .. " " .. name
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 10
    btn.TextColor3 = Color3.fromRGB(110, 110, 120)
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    btn.ZIndex = 3

    local indicator = Instance.new("Frame", btn)
    indicator.Size = UDim2.new(0.65, 0, 0, 2)
    indicator.Position = UDim2.new(0.175, 0, 1, -2)
    indicator.BackgroundColor3 = Color3.fromRGB(0, 255, 80)
    indicator.BorderSizePixel = 0
    indicator.BackgroundTransparency = 1
    indicator.ZIndex = 4

    btn.MouseButton1Click:Connect(function()
        if activeTab then
            TweenService:Create(activeTab.btn, TweenInfo.new(0.12), {TextColor3 = Color3.fromRGB(110, 110, 120)}):Play()
            TweenService:Create(activeTab.indicator, TweenInfo.new(0.12), {BackgroundTransparency = 1}):Play()
            activeTab.page.Visible = false
        end
        activeTab = {btn = btn, indicator = indicator, page = page}
        TweenService:Create(btn, TweenInfo.new(0.12), {TextColor3 = Color3.fromRGB(0, 255, 80)}):Play()
        TweenService:Create(indicator, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play()
        page.Visible = true
    end)

    tabs[name] = {btn = btn, indicator = indicator, page = page}
    return page
end

local PageESP     = makeTab("ESP",     "◈", 1)
local PageAimbot  = makeTab("Aim",     "⊕", 2)
local PageTrigger = makeTab("Trig",    "⚡", 3)
local PageFly     = makeTab("Fly",     "✈", 4)

task.defer(function()
    tabs["ESP"].btn.MouseButton1Click:Fire()
end)

-- ── Components ──
local function makeSection(parent, title, order)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 22)
    f.BackgroundTransparency = 1
    f.LayoutOrder = order or 0
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  " .. string.upper(title)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 8
    lbl.TextColor3 = Color3.fromRGB(0, 200, 60)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 4
    local line = Instance.new("Frame", f)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0, 18)
    line.BackgroundColor3 = Color3.fromRGB(0, 70, 20)
    line.BorderSizePixel = 0
end

local function makeToggle(parent, label, default, callback, order)
    local state = default
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(16, 17, 22)
    row.BorderSizePixel = 0
    row.LayoutOrder = order or 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -54, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextColor3 = Color3.fromRGB(210, 210, 215)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 4

    local pill = Instance.new("Frame", row)
    pill.Size = UDim2.new(0, 34, 0, 18)
    pill.Position = UDim2.new(1, -44, 0.5, -9)
    pill.BackgroundColor3 = state and Color3.fromRGB(0, 200, 60) or Color3.fromRGB(40, 40, 50)
    pill.BorderSizePixel = 0
    pill.ZIndex = 4
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", pill)
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 5
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local clickBtn = Instance.new("TextButton", row)
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 6
    clickBtn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(pill, TweenInfo.new(0.12), {
            BackgroundColor3 = state and Color3.fromRGB(0, 200, 60) or Color3.fromRGB(40, 40, 50)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.12), {
            Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
        }):Play()
        callback(state)
    end)
    return row
end

local function makeSlider(parent, label, min, max, default, callback, order)
    local val = default
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 52)
    frame.BackgroundColor3 = Color3.fromRGB(16, 17, 22)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order or 0
    frame.ClipsDescendants = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.65, 0, 0, 26)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextColor3 = Color3.fromRGB(210, 210, 215)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 4

    local valLbl = Instance.new("TextLabel", frame)
    valLbl.Size = UDim2.new(0.35, -10, 0, 26)
    valLbl.Position = UDim2.new(0.65, 0, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(val)
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 10
    valLbl.TextColor3 = Color3.fromRGB(0, 255, 80)
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 4

    local track = Instance.new("Frame", frame)
    track.Size = UDim2.new(1, -20, 0, 4)
    track.Position = UDim2.new(0, 10, 0, 36)
    track.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
    track.BorderSizePixel = 0
    track.ZIndex = 4
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((val-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 60)
    fill.BorderSizePixel = 0
    fill.ZIndex = 5
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local thumb = Instance.new("Frame", track)
    thumb.Size = UDim2.new(0, 12, 0, 12)
    thumb.Position = UDim2.new((val-min)/(max-min), -6, 0.5, -6)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 6
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    local sliding = false
    local slideInput = nil

    local function update(i)
        local abs = track.AbsolutePosition
        local sz = track.AbsoluteSize
        local relX = math.clamp((i.Position.X - abs.X) / sz.X, 0, 1)
        val = math.floor(min + (max-min) * relX)
        valLbl.Text = tostring(val)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        thumb.Position = UDim2.new(relX, -6, 0.5, -6)
        callback(val)
    end

    local hitbox = Instance.new("TextButton", frame)
    hitbox.Size = UDim2.new(1, 0, 0, 22)
    hitbox.Position = UDim2.new(0, 0, 0, 28)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.ZIndex = 7

    hitbox.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true slideInput = i update(i)
        end
    end)
    hitbox.InputChanged:Connect(function(i)
        if sliding and (i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseMovement) then update(i) end
    end)
    hitbox.InputEnded:Connect(function(i)
        if i == slideInput then sliding = false slideInput = nil end
    end)
end

-- ── Populate ESP ──
makeSection(PageESP, "Visibility", 1)
makeToggle(PageESP, "ESP Enabled",  CFG.ESP.Enabled,   function(v) CFG.ESP.Enabled   = v end, 2)
makeToggle(PageESP, "Box ESP",      CFG.ESP.Box,       function(v) CFG.ESP.Box        = v end, 3)
makeToggle(PageESP, "Corner Box",   CFG.ESP.CornerBox, function(v) CFG.ESP.CornerBox  = v end, 4)
makeToggle(PageESP, "Name Tag",     CFG.ESP.Name,      function(v) CFG.ESP.Name       = v end, 5)
makeToggle(PageESP, "Health Bar",   CFG.ESP.Health,    function(v) CFG.ESP.Health     = v end, 6)
makeToggle(PageESP, "Distance",     CFG.ESP.Distance,  function(v) CFG.ESP.Distance   = v end, 7)
makeToggle(PageESP, "Tracer Lines", CFG.ESP.Tracer,    function(v) CFG.ESP.Tracer     = v end, 8)
makeSection(PageESP, "Filters", 9)
makeToggle(PageESP, "Team Check",   CFG.ESP.TeamCheck, function(v) CFG.ESP.TeamCheck  = v end, 10)
makeToggle(PageESP, "Wall Check",   CFG.ESP.WallCheck, function(v) CFG.ESP.WallCheck  = v end, 11)
makeSection(PageESP, "Range", 12)
makeSlider(PageESP, "Max Distance", 100, 5000, CFG.ESP.MaxDist, function(v) CFG.ESP.MaxDist = v end, 13)

-- ── Populate Aimbot ──
makeSection(PageAimbot, "Aimbot", 1)
makeToggle(PageAimbot, "Aimbot Enabled", CFG.Aimbot.Enabled,    function(v) CFG.Aimbot.Enabled    = v end, 2)
makeToggle(PageAimbot, "Show FOV",       CFG.Aimbot.ShowFOV,    function(v) CFG.Aimbot.ShowFOV    = v end, 3)
makeToggle(PageAimbot, "Team Check",     CFG.Aimbot.TeamCheck,  function(v) CFG.Aimbot.TeamCheck  = v end, 4)
makeToggle(PageAimbot, "Prediction",     CFG.Aimbot.Prediction, function(v) CFG.Aimbot.Prediction = v end, 5)
makeSection(PageAimbot, "Settings", 6)
makeSlider(PageAimbot, "FOV Radius",  50, 500, CFG.Aimbot.FOV, function(v) CFG.Aimbot.FOV = v end, 7)
makeSlider(PageAimbot, "Smoothness",  1, 30, math.floor(CFG.Aimbot.Smooth*100), function(v) CFG.Aimbot.Smooth = v/100 end, 8)
makeSlider(PageAimbot, "Prediction",  1, 30, math.floor(CFG.Aimbot.PredStr*100), function(v) CFG.Aimbot.PredStr = v/100 end, 9)

-- ── Populate Trigger ──
makeSection(PageTrigger, "Triggerbot", 1)
makeToggle(PageTrigger, "Triggerbot On", CFG.Triggerbot.Enabled,   function(v) CFG.Triggerbot.Enabled   = v end, 2)
makeToggle(PageTrigger, "Team Check",    CFG.Triggerbot.TeamCheck, function(v) CFG.Triggerbot.TeamCheck = v end, 3)
makeSection(PageTrigger, "Timing", 4)
makeSlider(PageTrigger, "Delay (ms)", 0, 300, math.floor(CFG.Triggerbot.Delay*1000), function(v) CFG.Triggerbot.Delay = v/1000 end, 5)

-- ── Populate Fly ──
makeSection(PageFly, "Fly", 1)
makeToggle(PageFly, "Fly Enabled", CFG.Fly.Enabled, function(v)
    CFG.Fly.Enabled = v
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    if v then
        hum.PlatformStand = true
    else
        hum.PlatformStand = false
        if root:FindFirstChild("FlyBody") then
            root.FlyBody:Destroy()
        end
        if root:FindFirstChild("FlyGyro") then
            root.FlyGyro:Destroy()
        end
    end
end, 2)
makeSection(PageFly, "Settings", 3)
makeSlider(PageFly, "Speed", 10, 300, CFG.Fly.Speed, function(v) CFG.Fly.Speed = v end, 4)

-- ══════════════════════════════════════
--      ESP DRAWINGS
-- ══════════════════════════════════════
local espObjects = {}

local function newDraw(type, props)
    local ok, d = pcall(function() return Drawing.new(type) end)
    if not ok then return {Visible=false, Remove=function()end} end
    for k, v in pairs(props) do pcall(function() d[k] = v end) end
    return d
end

local function makeESP(player)
    local e = {
        box     = newDraw("Square", {Visible=false, Color=CFG.ESP.Color,              Thickness=1.5, Filled=false, ZIndex=3}),
        outline = newDraw("Square", {Visible=false, Color=Color3.fromRGB(0,0,0),       Thickness=3,   Filled=false, ZIndex=2}),
        name    = newDraw("Text",   {Visible=false, Color=Color3.fromRGB(255,255,255), Size=13, Font=2, Center=true, Outline=true, ZIndex=4}),
        hpBg    = newDraw("Square", {Visible=false, Color=Color3.fromRGB(20,20,20),    Thickness=1,   Filled=true,  ZIndex=3}),
        hpFill  = newDraw("Square", {Visible=false, Color=Color3.fromRGB(0,220,60),    Thickness=1,   Filled=true,  ZIndex=4}),
        dist    = newDraw("Text",   {Visible=false, Color=Color3.fromRGB(160,160,160), Size=11, Font=2, Center=true, Outline=true, ZIndex=4}),
        tracer  = newDraw("Line",   {Visible=false, Color=CFG.ESP.Color,              Thickness=1,   ZIndex=2}),
        corners = {},
    }
    for i = 1, 8 do
        e.corners[i] = newDraw("Line", {Visible=false, Color=CFG.ESP.Color, Thickness=2, ZIndex=4})
    end
    espObjects[player] = e
end

local function removeESP(player)
    local e = espObjects[player]
    if not e then return end
    for _, d in pairs(e) do
        if type(d) == "table" then
            for _, line in pairs(d) do pcall(function() line:Remove() end) end
        else
            pcall(function() d:Remove() end)
        end
    end
    espObjects[player] = nil
end

local function drawCorners(e, tl, size)
    local cL = size.X * 0.22
    local hL = size.Y * 0.18
    local pts = {
        {tl,                                    Vector2.new(tl.X+cL, tl.Y)},
        {tl,                                    Vector2.new(tl.X, tl.Y+hL)},
        {Vector2.new(tl.X+size.X, tl.Y),        Vector2.new(tl.X+size.X-cL, tl.Y)},
        {Vector2.new(tl.X+size.X, tl.Y),        Vector2.new(tl.X+size.X, tl.Y+hL)},
        {Vector2.new(tl.X, tl.Y+size.Y),        Vector2.new(tl.X+cL, tl.Y+size.Y)},
        {Vector2.new(tl.X, tl.Y+size.Y),        Vector2.new(tl.X, tl.Y+size.Y-hL)},
        {Vector2.new(tl.X+size.X, tl.Y+size.Y), Vector2.new(tl.X+size.X-cL, tl.Y+size.Y)},
        {Vector2.new(tl.X+size.X, tl.Y+size.Y), Vector2.new(tl.X+size.X, tl.Y+size.Y-hL)},
    }
    for i, c in ipairs(pts) do
        e.corners[i].From    = c[1]
        e.corners[i].To      = c[2]
        e.corners[i].Visible = true
    end
end

local fovCircle = newDraw("Circle", {
    Visible=false, Radius=CFG.Aimbot.FOV,
    Color=Color3.fromRGB(0,255,80), Thickness=1.2,
    Filled=false, NumSides=64,
    Position=Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2),
})

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then makeESP(p) end
end
Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then makeESP(p) end
end)
Players.PlayerRemoving:Connect(removeESP)

-- ══════════════════════════════════════
--      IMPROVED AIMBOT
-- ══════════════════════════════════════
local velHistory = {}
local historySize = 6

local function getBestTarget()
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X/2, vp.Y/2)
    local best, bestPart, bestDist = nil, nil, CFG.Aimbot.FOV
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if CFG.Aimbot.TeamCheck and isTeammate(p) then continue end
        if not isAlive(p) then continue end
        local part = p.Character and p.Character:FindFirstChild(CFG.Aimbot.Part)
        if not part then continue end
        local sp, on = w2s(part.Position)
        if not on then continue end
        local d = (sp - center).Magnitude
        if d < bestDist then
            bestDist = d
            best = p
            bestPart = part
        end
    end
    return best, bestPart
end

local lastPos2 = nil
local lastTime2 = nil

RunService:BindToRenderStep("TusarAimbot", Enum.RenderPriority.Camera.Value + 1, function()
    if not CFG.Aimbot.Enabled then return end
    local _, part = getBestTarget()
    if not part then
        lastPos2 = nil
        lastTime2 = nil
        velHistory = {}
        return
    end

    local now = tick()
    local aimPos = part.Position

    -- Averaged velocity prediction
    if CFG.Aimbot.Prediction and lastPos2 and lastTime2 then
        local dt = now - lastTime2
        if dt > 0 and dt < 0.2 then
            local vel = (part.Position - lastPos2) / dt
            table.insert(velHistory, vel)
            if #velHistory > historySize then
                table.remove(velHistory, 1)
            end
            -- average last N velocities = smoother prediction
            local avgVel = Vector3.new()
            for _, v in ipairs(velHistory) do
                avgVel = avgVel + v
            end
            avgVel = avgVel / #velHistory
            aimPos = part.Position + avgVel * CFG.Aimbot.PredStr
        end
    end

    lastPos2 = part.Position
    lastTime2 = now

    local camPos = Camera.CFrame.Position
    local targetDir = (aimPos - camPos).Unit
    local currentLook = Camera.CFrame.LookVector

    -- Adaptive smooth — faster when far from target, slower when close
    local sp = w2s(aimPos)
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X/2, vp.Y/2)
    local screenDist = (sp - center).Magnitude
    local adaptiveSmooth = math.clamp(
        CFG.Aimbot.Smooth * (screenDist / 80),
        CFG.Aimbot.Smooth * 0.3,
        1
    )

    local newLook = currentLook:Lerp(targetDir, adaptiveSmooth).Unit
    Camera.CFrame = CFrame.new(camPos, camPos + newLook)
end)

-- ══════════════════════════════════════
--      FLY ENGINE
-- ══════════════════════════════════════
local flyConnection = nil

local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    hum.PlatformStand = true

    -- BodyVelocity
    local bv = root:FindFirstChild("FlyBody") or Instance.new("BodyVelocity")
    bv.Name = "FlyBody"
    bv.Velocity = Vector3.new()
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Parent = root

    -- BodyGyro
    local bg = root:FindFirstChild("FlyGyro") or Instance.new("BodyGyro")
    bg.Name = "FlyGyro"
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.D = 100
    bg.CFrame = Camera.CFrame
    bg.Parent = root

    if flyConnection then flyConnection:Disconnect() end
    flyConnection = RunService.RenderStepped:Connect(function()
        if not CFG.Fly.Enabled then
            bv:Destroy()
            bg:Destroy()
            hum.PlatformStand = false
            flyConnection:Disconnect()
            flyConnection = nil
            return
        end

        local speed = CFG.Fly.Speed
        local camCF = Camera.CFrame
        local moveDir = Vector3.new()

        -- WASD / joystick via Humanoid MoveDirection
        local md = hum.MoveDirection
        if md.Magnitude > 0.1 then
            moveDir = moveDir + camCF.RightVector * md.X + camCF.LookVector * md.Z
        end

        -- Up = Jump button holdh
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)
        or UserInputService:IsKeyDown(Enum.KeyCode.ButtonA) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end

        -- Down
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
        or UserInputService:IsKeyDown(Enum.KeyCode.ButtonB) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end

        if moveDir.Magnitude > 0 then
            bv.Velocity = moveDir.Unit * speed
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end

        bg.CFrame = CFrame.new(root.Position, root.Position + camCF.LookVector)
    end)
end

local function stopFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if root then
        if root:FindFirstChild("FlyBody")  then root.FlyBody:Destroy()  end
        if root:FindFirstChild("FlyGyro")  then root.FlyGyro:Destroy()  end
    end
    if hum then hum.PlatformStand = false end
end

-- Reconnect fly on respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if CFG.Fly.Enabled then startFly() end
end)

-- Watch fly toggle
local flyWatcher = RunService.Heartbeat:Connect(function()
    if CFG.Fly.Enabled and not flyConnection then
        startFly()
    elseif not CFG.Fly.Enabled and flyConnection then
        stopFly()
    end
end)

-- ══════════════════════════════════════
--      TRIGGERBOT
-- ══════════════════════════════════════
local trigFiring = false
local function checkTrigger()
    if not CFG.Triggerbot.Enabled then return end
    local unitRay = Camera:ScreenPointToRay(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local ray = Ray.new(unitRay.Origin, unitRay.Direction * 1000)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, workspace.Terrain})
    if not hit then return end
    local model = hit:FindFirstAncestorOfClass("Model")
    if not model then return end
    local p = Players:GetPlayerFromCharacter(model)
    if not p or p == LocalPlayer then return end
    if CFG.Triggerbot.TeamCheck and isTeammate(p) then return end
    if not isAlive(p) then return end
    if trigFiring then return end
    trigFiring = true
    task.delay(CFG.Triggerbot.Delay, function()
        pcall(function()
            local vms = game:GetService("VirtualInputManager")
            vms:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.05)
            vms:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
        trigFiring = false
    end)
end

-- ══════════════════════════════════════
--      MAIN LOOP
-- ══════════════════════════════════════
RunService.RenderStepped:Connect(function()
    pcall(function()
        fovCircle.Visible = CFG.Aimbot.Enabled and CFG.Aimbot.ShowFOV
        fovCircle.Radius  = CFG.Aimbot.FOV
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end)

    checkTrigger()

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local e = espObjects[player]
        if not e then continue end

        local function hide()
            pcall(function()
                e.box.Visible    = false
                e.outline.Visible = false
                e.name.Visible   = false
                e.hpBg.Visible   = false
                e.hpFill.Visible = false
                e.dist.Visible   = false
                e.tracer.Visible = false
                for _, c in ipairs(e.corners) do c.Visible = false end
            end)
        end

        if not CFG.ESP.Enabled        then hide() continue end
        if not isAlive(player)         then hide() continue end
        if CFG.ESP.TeamCheck and isTeammate(player) then hide() continue end

        local root = getRoot(player)
        if not root then hide() continue end

        local dist = (root.Position - Camera.CFrame.Position).Magnitude
        if dist > CFG.ESP.MaxDist then hide() continue end

        if CFG.ESP.WallCheck then
            local lr = getRoot(LocalPlayer)
            if lr then
                local ray = Ray.new(lr.Position, (root.Position - lr.Position).Unit * dist)
                local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, workspace.Terrain})
                if hit and not hit:IsDescendantOf(player.Character) then hide() continue end
            end
        end

        local topPos, botPos = getCharBounds(player)
        if not topPos or not botPos then hide() continue end

        local h   = math.abs(botPos.Y - topPos.Y)
        local w   = h * 0.55
        local tl  = Vector2.new(topPos.X - w/2, topPos.Y)
        local sz  = Vector2.new(w, h)
        local col = isTeammate(player) and CFG.ESP.TeamColor or CFG.ESP.Color

        pcall(function()
            if CFG.ESP.Box and not CFG.ESP.CornerBox then
                e.outline.Visible  = true
                e.outline.Position = tl - Vector2.new(1,1)
                e.outline.Size     = sz + Vector2.new(2,2)
                e.box.Visible      = true
                e.box.Position     = tl
                e.box.Size         = sz
                e.box.Color        = col
            else
                e.box.Visible     = false
                e.outline.Visible = false
            end

            if CFG.ESP.CornerBox then
                drawCorners(e, tl, sz)
                for _, c in ipairs(e.corners) do c.Color = col end
            else
                for _, c in ipairs(e.corners) do c.Visible = false end
            end

            if CFG.ESP.Name then
                e.name.Visible  = true
                e.name.Text     = player.DisplayName
                e.name.Position = Vector2.new(topPos.X, topPos.Y - 16)
                e.name.Color    = col
            else
                e.name.Visible = false
            end

            local hum = getHum(player)
            if CFG.ESP.Health and hum then
                local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                e.hpBg.Visible    = true
                e.hpBg.Position   = Vector2.new(tl.X - 7, topPos.Y)
                e.hpBg.Size       = Vector2.new(4, h)
                e.hpFill.Visible  = true
                e.hpFill.Position = Vector2.new(tl.X - 7, topPos.Y + h*(1-hp))
                e.hpFill.Size     = Vector2.new(4, h*hp)
                e.hpFill.Color    = Color3.fromRGB(math.floor((1-hp)*255), math.floor(hp*220), 40)
            else
                e.hpBg.Visible   = false
                e.hpFill.Visible = false
            end

            if CFG.ESP.Distance then
                e.dist.Visible  = true
                e.dist.Text     = string.format("[%.0fm]", dist)
                e.dist.Position = Vector2.new(topPos.X, botPos.Y + 3)
            else
                e.dist.Visible = false
            end

            if CFG.ESP.Tracer then
                e.tracer.Visible = true
                e.tracer.From    = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                e.tracer.To      = Vector2.new(topPos.X, botPos.Y)
                e.tracer.Color   = col
            else
                e.tracer.Visible = false
            end
        end)
    end
end)

print("[TUSAR v3] Loaded")