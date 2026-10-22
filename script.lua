-- TUSAR ESP v2 | Premium GUI | Green Theme
-- Full: ESP + Aimbot + Triggerbot + Wall/Team Check

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
        Skeleton = false,
        TeamCheck = true,
        WallCheck = false,
        Color = Color3.fromRGB(0, 255, 80),
        TeamColor = Color3.fromRGB(80, 140, 255),
        MaxDist = 2000,
        Thickness = 1.5,
    },
    Aimbot = {
        Enabled = false,
        FOV = 180,
        Smooth = 0.18,
        Part = "Head",
        TeamCheck = true,
        WallCheck = false,
        Prediction = true,
        PredStr = 0.13,
        ShowFOV = true,
        Key = Enum.UserInputType.MouseButton2,
    },
    Triggerbot = {
        Enabled = false,
        TeamCheck = true,
        Delay = 0.04,
        Key = Enum.KeyCode.CapsLock,
    },
    Chams = {
        Enabled = false,
        Color = Color3.fromRGB(0, 255, 80),
        TeamColor = Color3.fromRGB(80, 140, 255),
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

local function getHead(p)
    return p.Character and p.Character:FindFirstChild("Head")
end

local function getHum(p)
    return p.Character and p.Character:FindFirstChildOfClass("Humanoid")
end

local function w2s(pos)
    local v, on = Camera:WorldToViewportPoint(pos)
    return Vector2.new(v.X, v.Y), on, v.Z
end

local function wallCheck(origin, target)
    local dir = (target - origin)
    local ray = Ray.new(origin, dir)
    local ignore = {LocalPlayer.Character, workspace.Terrain}
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, ignore)
    if not hit then return true end
    local targetModel = workspace:FindFirstChild(target.Parent and target.Parent.Name or "")
    return hit:IsDescendantOf(targetModel or hit)
end

local function getCharBounds(p)
    local char = p.Character
    if not char then return nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not root or not head then return nil, nil end
    local topPos, topOn, topZ = w2s(head.Position + Vector3.new(0, head.Size.Y / 2 + 0.2, 0))
    local botPos, botOn, botZ = w2s(root.Position - Vector3.new(0, 3.1, 0))
    if topZ < 0 or botZ < 0 then return nil, nil end
    return topPos, botPos
end

-- ══════════════════════════════════════
--           GUI
-- ══════════════════════════════════════
local function create(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    if children then
        for _, child in pairs(children) do child.Parent = obj end
    end
    return obj
end

local ScreenGui = create("ScreenGui", {
    Name = "Tusar's aimbot",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
})

-- Try gethui() or CoreGui
pcall(function()
    ScreenGui.Parent = gethui and gethui() or game:GetService("CoreGui")
end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Drawing layer for ESP
local ESPFolder = Instance.new("Folder", ScreenGui)
ESPFolder.Name = "ESPDrawings"

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = CFG.Aimbot.FOV
FOVCircle.Color = Color3.fromRGB(0, 255, 80)
FOVCircle.Thickness = 1.2
FOVCircle.Filled = false
FOVCircle.NumSides = 64
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- ── Main Window ──
local MainFrame = create("Frame", {
    Name = "MainFrame",
    Parent = ScreenGui,
    Size = UDim2.new(0, 480, 0, 540),
    Position = UDim2.new(0.5, -240, 0.5, -270),
    BackgroundColor3 = Color3.fromRGB(10, 10, 14),
    BorderSizePixel = 0,
    ClipsDescendants = true,
})

create("UICorner", {CornerRadius = UDim.new(0, 10)}, nil).Parent = MainFrame
create("UIStroke", {
    Color = Color3.fromRGB(0, 200, 60),
    Thickness = 1.5,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
}, nil).Parent = MainFrame

-- Drop shadow
local Shadow = create("ImageLabel", {
    Parent = MainFrame,
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    Position = UDim2.new(0.5, 0, 0.5, 4),
    Size = UDim2.new(1, 30, 1, 30),
    ZIndex = -1,
    Image = "rbxassetid://6014261993",
    ImageColor3 = Color3.fromRGB(0, 255, 80),
    ImageTransparency = 0.82,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(49, 49, 450, 450),
})

-- Title Bar
local TitleBar = create("Frame", {
    Parent = MainFrame,
    Size = UDim2.new(1, 0, 0, 44),
    BackgroundColor3 = Color3.fromRGB(10, 10, 14),
    BorderSizePixel = 0,
    ZIndex = 2,
})

-- Accent line under title
create("Frame", {
    Parent = TitleBar,
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 1, -1),
    BackgroundColor3 = Color3.fromRGB(0, 220, 60),
    BorderSizePixel = 0,
    ZIndex = 3,
})

-- Logo dot
create("Frame", {
    Parent = TitleBar,
    Size = UDim2.new(0, 8, 0, 8),
    Position = UDim2.new(0, 16, 0.5, -4),
    BackgroundColor3 = Color3.fromRGB(0, 255, 80),
    BorderSizePixel = 0,
    ZIndex = 3,
}):FindFirstChildOfClass("UICorner") or create("UICorner", {CornerRadius = UDim.new(1, 0)}, nil).Parent = TitleBar:FindFirstChild("Frame")

local dot = TitleBar:FindFirstChildWhichIsA("Frame")
create("UICorner", {CornerRadius = UDim.new(1, 0)}, nil).Parent = dot

local TitleLabel = create("TextLabel", {
    Parent = TitleBar,
    Size = UDim2.new(1, -80, 1, 0),
    Position = UDim2.new(0, 32, 0, 0),
    BackgroundTransparency = 1,
    Text = "Tusar's aimbot",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 3,
})

-- Version tag
create("TextLabel", {
    Parent = TitleBar,
    Size = UDim2.new(0, 60, 0, 18),
    Position = UDim2.new(0, 32, 0.5, -2),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundTransparency = 1,
    Text = "",  -- spacer
    ZIndex = 3,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextColor3 = Color3.fromRGB(0, 255, 80),
})

local VersionTag = create("TextLabel", {
    Parent = TitleBar,
    Size = UDim2.new(0, 44, 0, 16),
    Position = UDim2.new(0, 114, 0.5, -8),
    BackgroundColor3 = Color3.fromRGB(0, 180, 50),
    Text = "v2.0",
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    ZIndex = 4,
    BorderSizePixel = 0,
})
create("UICorner", {CornerRadius = UDim.new(0, 4)}, nil).Parent = VersionTag

-- Close / Minimize buttons
local function makeBtn(icon, posX, color, callback)
    local btn = create("TextButton", {
        Parent = TitleBar,
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(1, posX, 0.5, -11),
        BackgroundColor3 = color,
        Text = icon,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 5,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6)}, nil).Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

makeBtn("✕", -36, Color3.fromRGB(180, 40, 40), function()
    TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 480, 0, 0), Position = UDim2.new(0.5, -240, 0.5, 0)}):Play()
    task.delay(0.22, function() ScreenGui:Destroy() end)
end)

local minimized = false
makeBtn("─", -64, Color3.fromRGB(40, 40, 55), function()
    minimized = not minimized
    TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
        Size = minimized and UDim2.new(0, 480, 0, 44) or UDim2.new(0, 480, 0, 540)
    }):Play()
end)

-- Drag logic
do
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- ── Tabs ──
local TabBar = create("Frame", {
    Parent = MainFrame,
    Size = UDim2.new(1, 0, 0, 36),
    Position = UDim2.new(0, 0, 0, 44),
    BackgroundColor3 = Color3.fromRGB(14, 14, 20),
    BorderSizePixel = 0,
    ZIndex = 2,
})

local TabLayout = create("UIListLayout", {
    Parent = TabBar,
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 1),
})

local ContentFrame = create("Frame", {
    Parent = MainFrame,
    Size = UDim2.new(1, 0, 1, -80),
    Position = UDim2.new(0, 0, 0, 80),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    ZIndex = 2,
})

local tabs = {}
local tabPages = {}
local activeTab = nil

local function makeTab(name, icon, order)
    local page = create("ScrollingFrame", {
        Parent = ContentFrame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(0, 200, 60),
        Visible = false,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 2,
    })
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
    }, nil).Parent = page
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
    }, nil).Parent = page

    local btn = create("TextButton", {
        Parent = TabBar,
        Size = UDim2.new(0, 94, 1, 0),
        BackgroundColor3 = Color3.fromRGB(14, 14, 20),
        Text = icon .. "  " .. name,
        Font = Enum.Font.GothamSemibold,
        TextSize = 11,
        TextColor3 = Color3.fromRGB(120, 120, 130),
        BorderSizePixel = 0,
        LayoutOrder = order,
        ZIndex = 3,
    })

    local indicator = create("Frame", {
        Parent = btn,
        Size = UDim2.new(0.7, 0, 0, 2),
        Position = UDim2.new(0.15, 0, 1, -2),
        BackgroundColor3 = Color3.fromRGB(0, 255, 80),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        ZIndex = 4,
    })

    btn.MouseButton1Click:Connect(function()
        if activeTab then
            TweenService:Create(activeTab.btn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(120, 120, 130)}):Play()
            TweenService:Create(activeTab.indicator, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
            activeTab.page.Visible = false
        end
        activeTab = {btn = btn, indicator = indicator, page = page}
        TweenService:Create(btn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(0, 255, 80)}):Play()
        TweenService:Create(indicator, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
        page.Visible = true
    end)

    tabs[name] = {btn = btn, indicator = indicator, page = page}
    return page
end

local PageESP      = makeTab("ESP",       "◈", 1)
local PageAimbot   = makeTab("Aimbot",    "⊕", 2)
local PageTrigger  = makeTab("Trigger",   "⚡", 3)
local PageVisuals  = makeTab("Visuals",   "◉", 4)
local PageSettings = makeTab("Settings",  "⚙", 5)

-- Activate first tab
task.defer(function()
    tabs["ESP"].btn.MouseButton1Click:Fire()
end)

-- ── Toggle / Slider components ──
local function makeSection(parent, title, order)
    local frame = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        LayoutOrder = order or 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 3,
    })
    create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "  " .. string.upper(title),
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextColor3 = Color3.fromRGB(0, 200, 60),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
    })
    local line = create("Frame", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 22),
        BackgroundColor3 = Color3.fromRGB(0, 80, 25),
        BorderSizePixel = 0,
        ZIndex = 3,
    })
    return frame
end

local function makeToggle(parent, label, default, callback, order)
    local state = default

    local row = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Color3.fromRGB(16, 17, 22),
        BorderSizePixel = 0,
        LayoutOrder = order or 0,
        ZIndex = 3,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 7)}, nil).Parent = row

    create("TextLabel", {
        Parent = row,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(210, 210, 215),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
    })

    -- Toggle pill
    local pill = create("Frame", {
        Parent = row,
        Size = UDim2.new(0, 38, 0, 20),
        Position = UDim2.new(1, -52, 0.5, -10),
        BackgroundColor3 = state and Color3.fromRGB(0, 200, 60) or Color3.fromRGB(40, 40, 50),
        BorderSizePixel = 0,
        ZIndex = 4,
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0)}, nil).Parent = pill

    local knob = create("Frame", {
        Parent = pill,
        Size = UDim2.new(0, 14, 0, 14),
        Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 5,
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0)}, nil).Parent = knob

    local clickBtn = create("TextButton", {
        Parent = row,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 6,
    })

    clickBtn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(pill, TweenInfo.new(0.15), {
            BackgroundColor3 = state and Color3.fromRGB(0, 200, 60) or Color3.fromRGB(40, 40, 50)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        }):Play()
        callback(state)
    end)

    -- hover glow
    clickBtn.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(20, 22, 28)}):Play()
    end)
    clickBtn.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(16, 17, 22)}):Play()
    end)

    return row
end

local function makeSlider(parent, label, min, max, default, callback, order)
    local val = default

    local frame = create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = Color3.fromRGB(16, 17, 22),
        BorderSizePixel = 0,
        LayoutOrder = order or 0,
        ZIndex = 3,
        ClipsDescendants = true,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 7)}, nil).Parent = frame

    local topRow = create("Frame", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        ZIndex = 4,
    })
    create("TextLabel", {
        Parent = topRow,
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(210, 210, 215),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
    })
    local valLabel = create("TextLabel", {
        Parent = topRow,
        Size = UDim2.new(0.3, -10, 1, 0),
        Position = UDim2.new(0.7, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(val),
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Color3.fromRGB(0, 255, 80),
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 5,
    })

    local track = create("Frame", {
        Parent = frame,
        Size = UDim2.new(1, -28, 0, 4),
        Position = UDim2.new(0, 14, 0, 38),
        BackgroundColor3 = Color3.fromRGB(30, 32, 42),
        BorderSizePixel = 0,
        ZIndex = 4,
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0)}, nil).Parent = track

    local fill = create("Frame", {
        Parent = track,
        Size = UDim2.new((val - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 200, 60),
        BorderSizePixel = 0,
        ZIndex = 5,
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0)}, nil).Parent = fill

    local thumb = create("Frame", {
        Parent = track,
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new((val - min) / (max - min), -6, 0.5, -6),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 6,
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0)}, nil).Parent = thumb

    local sliding = false
    local hitbox = create("TextButton", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 0, 28),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 7,
    })

    local function updateSlider(input)
        local abs = track.AbsolutePosition
        local sz = track.AbsoluteSize
        local relX = math.clamp((input.Position.X - abs.X) / sz.X, 0, 1)
        val = math.floor(min + (max - min) * relX)
        valLabel.Text = tostring(val)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        thumb.Position = UDim2.new(relX, -6, 0.5, -6)
        callback(val)
    end

    hitbox.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            updateSlider(i)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(i)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)

    return frame
end

-- ── Populate ESP Tab ──
makeSection(PageESP, "Visibility", 1)
makeToggle(PageESP, "ESP Enabled",       CFG.ESP.Enabled,   function(v) CFG.ESP.Enabled   = v end, 2)
makeToggle(PageESP, "Box ESP",           CFG.ESP.Box,       function(v) CFG.ESP.Box        = v end, 3)
makeToggle(PageESP, "Corner Box",        CFG.ESP.CornerBox, function(v) CFG.ESP.CornerBox  = v end, 4)
makeToggle(PageESP, "Name Tag",          CFG.ESP.Name,      function(v) CFG.ESP.Name       = v end, 5)
makeToggle(PageESP, "Health Bar",        CFG.ESP.Health,    function(v) CFG.ESP.Health     = v end, 6)
makeToggle(PageESP, "Distance Tag",      CFG.ESP.Distance,  function(v) CFG.ESP.Distance   = v end, 7)
makeToggle(PageESP, "Tracer Lines",      CFG.ESP.Tracer,    function(v) CFG.ESP.Tracer     = v end, 8)
makeToggle(PageESP, "Skeleton ESP",      CFG.ESP.Skeleton,  function(v) CFG.ESP.Skeleton   = v end, 9)
makeSection(PageESP, "Filters", 10)
makeToggle(PageESP, "Team Check",        CFG.ESP.TeamCheck,  function(v) CFG.ESP.TeamCheck  = v end, 11)
makeToggle(PageESP, "Wall Check (Hide)", CFG.ESP.WallCheck,  function(v) CFG.ESP.WallCheck  = v end, 12)
makeSection(PageESP, "Range", 13)
makeSlider(PageESP, "Max Distance", 100, 5000, CFG.ESP.MaxDist, function(v) CFG.ESP.MaxDist = v end, 14)

-- ── Populate Aimbot Tab ──
makeSection(PageAimbot, "Aimbot", 1)
makeToggle(PageAimbot, "Aimbot Enabled", CFG.Aimbot.Enabled,    function(v) CFG.Aimbot.Enabled    = v end, 2)
makeToggle(PageAimbot, "Show FOV Circle",CFG.Aimbot.ShowFOV,    function(v) CFG.Aimbot.ShowFOV    = v end, 3)
makeToggle(PageAimbot, "Team Check",     CFG.Aimbot.TeamCheck,  function(v) CFG.Aimbot.TeamCheck  = v end, 4)
makeToggle(PageAimbot, "Wall Check",     CFG.Aimbot.WallCheck,  function(v) CFG.Aimbot.WallCheck  = v end, 5)
makeToggle(PageAimbot, "Prediction",     CFG.Aimbot.Prediction, function(v) CFG.Aimbot.Prediction = v end, 6)
makeSection(PageAimbot, "Settings", 7)
makeSlider(PageAimbot, "FOV Radius",    50, 600, CFG.Aimbot.FOV,     function(v) CFG.Aimbot.FOV = v; FOVCircle.Radius = v end, 8)
makeSlider(PageAimbot, "Smoothness %",  1,  50,  math.floor(CFG.Aimbot.Smooth * 100), function(v) CFG.Aimbot.Smooth = v / 100 end, 9)
makeSlider(PageAimbot, "Prediction Str",1,  30,  math.floor(CFG.Aimbot.PredStr * 100), function(v) CFG.Aimbot.PredStr = v / 100 end, 10)

-- ── Populate Trigger Tab ──
makeSection(PageTrigger, "Triggerbot", 1)
makeToggle(PageTrigger, "Triggerbot Enabled", CFG.Triggerbot.Enabled,   function(v) CFG.Triggerbot.Enabled   = v end, 2)
makeToggle(PageTrigger, "Team Check",         CFG.Triggerbot.TeamCheck, function(v) CFG.Triggerbot.TeamCheck = v end, 3)
makeSection(PageTrigger, "Timing", 4)
makeSlider(PageTrigger, "Fire Delay (ms)", 0, 300, math.floor(CFG.Triggerbot.Delay * 1000), function(v) CFG.Triggerbot.Delay = v / 1000 end, 5)

-- ── Populate Visuals Tab ──
makeSection(PageVisuals, "Chams", 1)
makeToggle(PageVisuals, "Chams Enabled", CFG.Chams.Enabled, function(v)
    CFG.Chams.Enabled = v
end, 2)

-- ── Populate Settings Tab ──
makeSection(PageSettings, "Interface", 1)
makeToggle(PageSettings, "GUI Visible", true, function(v)
    for _, c in ipairs(MainFrame:GetChildren()) do
        if c.Name ~= "TitleBar" then
            TweenService:Create(c, TweenInfo.new(0.2), {BackgroundTransparency = v and 0 or 1}):Play()
        end
    end
end, 2)

-- Keybind hint
create("TextLabel", {
    Parent = PageSettings,
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundColor3 = Color3.fromRGB(16, 17, 22),
    Text = "  Toggle GUI:  RightShift",
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = Color3.fromRGB(180, 180, 190),
    TextXAlignment = Enum.TextXAlignment.Left,
    BorderSizePixel = 0,
    LayoutOrder = 3,
    ZIndex = 3,
}):FindFirstChildOfClass("UICorner") or create("UICorner", {CornerRadius = UDim.new(0, 7)}, nil).Parent = PageSettings:FindFirstChildWhichIsA("TextLabel")

-- Toggle GUI with RightShift
UserInputService.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ══════════════════════════════════════
--      ESP DRAWINGS ENGINE
-- ══════════════════════════════════════
local espObjects = {}

local function newDrawing(type, props)
    local d = Drawing.new(type)
    for k, v in pairs(props) do d[k] = v end
    return d
end

local function createESP(player)
    local e = {
        box     = newDrawing("Square", {Visible=false, Color=CFG.ESP.Color, Thickness=CFG.ESP.Thickness, Filled=false, ZIndex=3}),
        outline = newDrawing("Square", {Visible=false, Color=Color3.fromRGB(0,0,0), Thickness=CFG.ESP.Thickness+1.5, Filled=false, ZIndex=2}),
        name    = newDrawing("Text",   {Visible=false, Color=Color3.fromRGB(255,255,255), Size=13, Font=2, Center=true, Outline=true, ZIndex=4}),
        hpBg    = newDrawing("Square", {Visible=false, Color=Color3.fromRGB(20,20,20), Thickness=1, Filled=true, ZIndex=3}),
        hpFill  = newDrawing("Square", {Visible=false, Color=Color3.fromRGB(0,220,60), Thickness=1, Filled=true, ZIndex=4}),
        dist    = newDrawing("Text",   {Visible=false, Color=Color3.fromRGB(180,180,180), Size=11, Font=2, Center=true, Outline=true, ZIndex=4}),
        tracer  = newDrawing("Line",   {Visible=false, Color=CFG.ESP.Color, Thickness=1, ZIndex=2}),
        corners = {},
    }
    for i = 1, 8 do
        e.corners[i] = newDrawing("Line", {Visible=false, Color=CFG.ESP.Color, Thickness=2, ZIndex=4})
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

local function drawCornerBox(e, topLeft, size)
    local cLen = size.X * 0.22
    local hLen = size.Y * 0.18
    local corners = {
        {topLeft, Vector2.new(topLeft.X + cLen, topLeft.Y)},
        {topLeft, Vector2.new(topLeft.X, topLeft.Y + hLen)},
        {Vector2.new(topLeft.X + size.X, topLeft.Y), Vector2.new(topLeft.X + size.X - cLen, topLeft.Y)},
        {Vector2.new(topLeft.X + size.X, topLeft.Y), Vector2.new(topLeft.X + size.X, topLeft.Y + hLen)},
        {Vector2.new(topLeft.X, topLeft.Y + size.Y), Vector2.new(topLeft.X + cLen, topLeft.Y + size.Y)},
        {Vector2.new(topLeft.X, topLeft.Y + size.Y), Vector2.new(topLeft.X, topLeft.Y + size.Y - hLen)},
        {Vector2.new(topLeft.X + size.X, topLeft.Y + size.Y), Vector2.new(topLeft.X + size.X - cLen, topLeft.Y + size.Y)},
        {Vector2.new(topLeft.X + size.X, topLeft.Y + size.Y), Vector2.new(topLeft.X + size.X, topLeft.Y + size.Y - hLen)},
    }
    for i, c in ipairs(corners) do
        e.corners[i].From = c[1]
        e.corners[i].To   = c[2]
        e.corners[i].Visible = true
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then createESP(p) end
end
Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then createESP(p) end
end)
Players.PlayerRemoving:Connect(removeESP)

-- ══════════════════════════════════════
--      AIMBOT ENGINE
-- ══════════════════════════════════════
local function getBestTarget()
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local bestDist = CFG.Aimbot.FOV
    local bestTarget = nil
    local bestPart = nil

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if CFG.Aimbot.TeamCheck and isTeammate(p) then continue end
        if not isAlive(p) then continue end
        local part = p.Character and p.Character:FindFirstChild(CFG.Aimbot.Part)
        if not part then continue end
        if CFG.Aimbot.WallCheck then
            local root = getRoot(LocalPlayer)
            if root and not wallCheck(root.Position, part.Position) then continue end
        end
        local screenPos, onScreen = w2s(part.Position)
        if not onScreen then continue end
        local dist2d = (screenPos - center).Magnitude
        if dist2d < bestDist then
            bestDist = dist2d
            bestTarget = p
            bestPart = part
        end
    end
    return bestTarget, bestPart
end

local lastPos = nil
local lastTime = nil

-- ══════════════════════════════════════
--      TRIGGERBOT ENGINE
-- ══════════════════════════════════════
local trigFiring = false
local function triggerCheck()
    if not CFG.Triggerbot.Enabled then return end
    if not UserInputService:IsKeyDown(CFG.Triggerbot.Key) then return end
    local unitRay = Camera:ScreenPointToRay(
        Camera.ViewportSize.X / 2,
        Camera.ViewportSize.Y / 2
    )
    local ray = Ray.new(unitRay.Origin, unitRay.Direction * 1000)
    local ignore = {LocalPlayer.Character, workspace.Terrain}
    local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, ignore)
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
        local vms = game:GetService("VirtualInputManager")
        pcall(function()
            vms:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.04)
            vms:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
        trigFiring = false
    end)
end

-- ══════════════════════════════════════
--      CHAMS ENGINE
-- ══════════════════════════════════════
local chamObjects = {}

local function applyChams(player)
    local char = player.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local hi = Instance.new("SelectionBox")
            hi.Color3 = isTeammate(player) and CFG.Chams.TeamColor or CFG.Chams.Color
            hi.SurfaceColor3 = hi.Color3
            hi.SurfaceTransparency = 0.5
            hi.LineThickness = 0
            hi.Adornee = part
            hi.Parent = part
            chamObjects[part] = hi
        end
    end
end

local function removeChams(player)
    local char = player.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if chamObjects[part] then
            chamObjects[part]:Destroy()
            chamObjects[part] = nil
        end
    end
end

-- ══════════════════════════════════════
--      MAIN RENDER LOOP
-- ══════════════════════════════════════
RunService.RenderStepped:Connect(function()
    -- FOV circle update
    FOVCircle.Visible = CFG.Aimbot.Enabled and CFG.Aimbot.ShowFOV
    FOVCircle.Radius = CFG.Aimbot.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Aimbot
    if CFG.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(CFG.Aimbot.Key) then
        local _, part = getBestTarget()
        if part then
            local now = tick()
            local aimPos = part.Position
            if CFG.Aimbot.Prediction and lastPos and lastTime then
                local vel = (part.Position - lastPos) / (now - lastTime)
                aimPos = part.Position + vel * CFG.Aimbot.PredStr
            end
            lastPos = part.Position
            lastTime = now

            local screenTarget, onScreen = w2s(aimPos)
            if onScreen then
                local vp = Camera.ViewportSize
                local center = Vector2.new(vp.X / 2, vp.Y / 2)
                local delta = screenTarget - center
                local sens = CFG.Aimbot.Smooth
                mousemoverel(delta.X * sens, delta.Y * sens)
            end
        else
            lastPos = nil
            lastTime = nil
        end
    end

    -- Triggerbot
    triggerCheck()

    -- ESP per player
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local e = espObjects[player]
        if not e then continue end

        local function hide()
            e.box.Visible    = false
            e.outline.Visible = false
            e.name.Visible   = false
            e.hpBg.Visible   = false
            e.hpFill.Visible = false
            e.dist.Visible   = false
            e.tracer.Visible = false
            for _, c in ipairs(e.corners) do c.Visible = false end
        end

        if not CFG.ESP.Enabled then hide() continue end
        if not isAlive(player) then hide() continue end
        if CFG.ESP.TeamCheck and isTeammate(player) then hide() continue end

        local root = getRoot(player)
        local head = getHead(player)
        if not root or not head then hide() continue end

        local dist = (root.Position - Camera.CFrame.Position).Magnitude
        if dist > CFG.ESP.MaxDist then hide() continue end

        -- Wall check
        if CFG.ESP.WallCheck then
            local localRoot = getRoot(LocalPlayer)
            if localRoot then
                local ray = Ray.new(localRoot.Position, (root.Position - localRoot.Position).Unit * dist)
                local hitPart = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, workspace.Terrain})
                if hitPart and not hitPart:IsDescendantOf(player.Character) then
                    hide() continue
                end
            end
        end

        local topPos, botPos = getCharBounds(player)
        if not topPos or not botPos then hide() continue end

        local height = math.abs(botPos.Y - topPos.Y)
        local width  = height * 0.55
        local topLeft = Vector2.new(topPos.X - width / 2, topPos.Y)
        local size    = Vector2.new(width, height)

        local color = isTeammate(player) and CFG.ESP.TeamColor or CFG.ESP.Color

        -- Box
        if CFG.ESP.Box and not CFG.ESP.CornerBox then
            e.outline.Visible  = true
            e.outline.Position = topLeft - Vector2.new(1, 1)
            e.outline.Size     = size + Vector2.new(2, 2)
            e.box.Visible      = true
            e.box.Position     = topLeft
            e.box.Size         = size
            e.box.Color        = color
        else
            e.box.Visible    = false
            e.outline.Visible = false
        end

        -- Corner Box
        if CFG.ESP.CornerBox then
            drawCornerBox(e, topLeft, size)
            for _, c in ipairs(e.corners) do c.Color = color end
        else
            for _, c in ipairs(e.corners) do c.Visible = false end
        end

        -- Name
        if CFG.ESP.Name then
            e.name.Visible  = true
            e.name.Text     = player.DisplayName
            e.name.Position = Vector2.new(topPos.X, topPos.Y - 16)
            e.name.Color    = color
        else
            e.name.Visible = false
        end

        -- Health Bar
        local hum = getHum(player)
        if CFG.ESP.Health and hum then
            local hp    = hum.Health / hum.MaxHealth
            local bX    = topLeft.X - 8
            local bH    = height
            local bY    = topPos.Y
            e.hpBg.Visible  = true
            e.hpBg.Position = Vector2.new(bX - 4, bY)
            e.hpBg.Size     = Vector2.new(4, bH)
            e.hpFill.Visible  = true
            e.hpFill.Position = Vector2.new(bX - 4, bY + bH * (1 - hp))
            e.hpFill.Size     = Vector2.new(4, bH * hp)
            local r = 1 - hp
            local g = hp
            e.hpFill.Color = Color3.fromRGB(math.floor(r * 255), math.floor(g * 220), 40)
        else
            e.hpBg.Visible  = false
            e.hpFill.Visible = false
        end

        -- Distance
        if CFG.ESP.Distance then
            e.dist.Visible  = true
            e.dist.Text     = string.format("[%.0fm]", dist)
            e.dist.Position = Vector2.new(topPos.X, botPos.Y + 3)
            e.dist.Color    = Color3.fromRGB(160, 160, 165)
        else
            e.dist.Visible = false
        end

        -- Tracer
        if CFG.ESP.Tracer then
            e.tracer.Visible = true
            e.tracer.From    = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            e.tracer.To      = Vector2.new(topPos.X, botPos.Y)
            e.tracer.Color   = color
        else
            e.tracer.Visible = false
        end
    end

    -- Chams update
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if CFG.Chams.Enabled and isAlive(player) then
            if not next(chamObjects) then applyChams(player) end
        else
            removeChams(player)
        end
    end
end)

-- Clean up on character respawn
LocalPlayer.CharacterAdded:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            removeChams(p)
        end
    end
end)

print("[Tusar's Aimbot] Loaded — RightShift to toggle GUI")