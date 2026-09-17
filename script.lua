--[[
    ===================================================================
    💼 STEAL AN EMPLOYEE! (ĂN CẮP MỘT NHÂN VIÊN) - HYPER SPEED & 3D ESP
    Repository: https://github.com/khahuynh963/steal_an_employee.git
    
    🎮 BẢN TỐI ƯU SIÊU NHẸ (LITE EDITION):
      1. 👁️ VISUALS & 3D EMPLOYEE ESP:
         - 3D Employee ESP Xuyên Tường (Hiển thị tên, phẩm cấp, $/s)
         - Cột Sáng Neon Lên Trời (Sky Beacons cho Secret, Divine, Mythic, Legendary)
         - Chế Độ Siêu Mượt 60 FPS (FPS Boost)
      2. 🏃 TỐC ĐỘ & TIỆN ÍCH:
         - WalkSpeed Slider (Mốc từ 32 đến 10,000 studs/s)
         - Lướt Siêu Tốc CFrame Multiplier (2x đến 100x)
         - Nhảy Vô Hạn (Infinite Jump)
         - Đi Xuyên Tường (Noclip)
         - Lướt Xuyên Cửa / Pha CFrame Qua Tường (25m)
         - Chống Văng Game 24/7 (Anti-AFK)
    ===================================================================
--]]

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

repeat task.wait() until Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer

-- ── Safe GUI Parenting Helper (Tương thích 100% mọi Executor) ──
local function safeParentGui(gui)
    local parented = false

    -- 1. Ưu tiên gethui() (Ẩn CoreGui an toàn)
    pcall(function()
        if gethui then
            gui.Parent = gethui()
            parented = true
        end
    end)
    if parented and gui.Parent then return true end

    -- 2. Thử CoreGui
    pcall(function()
        if game:GetService("CoreGui") then
            gui.Parent = game:GetService("CoreGui")
            parented = true
        end
    end)
    if parented and gui.Parent then return true end

    -- 3. Fallback PlayerGui (Chạy mượt trên mọi thiết bị và executor di động)
    pcall(function()
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
        if pg then
            gui.Parent = pg
            parented = true
        end
    end)

    return parented
end

-- Clear old GUI instances
pcall(function()
    if gethui then
        local g = gethui():FindFirstChild("StealEmployeeGui")
        if g then g:Destroy() end
    end
    pcall(function()
        local cg = game:GetService("CoreGui"):FindFirstChild("StealEmployeeGui")
        if cg then cg:Destroy() end
    end)
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("StealEmployeeGui") then
        LocalPlayer.PlayerGui.StealEmployeeGui:Destroy()
    end
end)

-- ── State Variables ──
local State = {
    -- 1. Visuals & 3D Employee ESP
    EmployeeESP = false,
    SkyBeacons = false,
    FPSBoost = true,

    -- 2. Tốc Độ & Tiện Ích
    SpeedEnabled = false,
    WalkSpeed = 100,
    CFrameBoost = false,
    CFrameSpeed = 4,
    InfiniteJump = false,
    Noclip = false,
    AntiAFK = true
}

local ALL_WALK_SPEEDS = {32, 50, 80, 100, 150, 200, 300, 500, 1000, 2500, 5000, 10000}
local ALL_CFRAME_SPEEDS = {2, 4, 6, 8, 12, 16, 25, 50, 100}

local function getWalkSpeedDesc(spd)
    if spd <= 32 then return "Mặc định x2 (" .. spd .. ")"
    elseif spd <= 50 then return "Nhanh vừa (" .. spd .. ")"
    elseif spd <= 80 then return "Lướt nhanh (" .. spd .. ")"
    elseif spd <= 100 then return "Rất nhanh (" .. spd .. ")"
    elseif spd <= 150 then return "Tốc biến (" .. spd .. ")"
    elseif spd <= 200 then return "Siêu tốc (" .. spd .. ")"
    elseif spd <= 300 then return "Thần tốc (" .. spd .. ")"
    elseif spd <= 500 then return "Vận tốc âm thanh (" .. spd .. ")"
    elseif spd <= 1000 then return "Hyper Sonic (" .. spd .. ")"
    elseif spd <= 2500 then return "Tia chớp (" .. spd .. ")"
    elseif spd <= 5000 then return "Vũ trụ (" .. spd .. ")"
    else return "Thần thánh max (" .. spd .. ")"
    end
end

-- Rarity Colors
local RARITY_COLORS = {
    Secret = Color3.fromRGB(255, 0, 128),
    Divine = Color3.fromRGB(255, 215, 0),
    Mythic = Color3.fromRGB(220, 20, 60),
    Legendary = Color3.fromRGB(255, 140, 0),
    Epic = Color3.fromRGB(186, 85, 211),
    Rare = Color3.fromRGB(30, 144, 255),
    Uncommon = Color3.fromRGB(50, 205, 50),
    Common = Color3.fromRGB(200, 200, 200)
}

-- Character Helpers
local function getCharacter()
    return LocalPlayer.Character
end

local function getRootPart()
    local char = getCharacter()
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Value Parser
local function parseValueString(str)
    if not str or str == "" then return 0 end
    local clean = str:gsub(",", ""):gsub("%$", ""):gsub("/s", ""):gsub(" ", "")
    local numPart, suffix = clean:match("([%d%.]+)%s*([kKmMbBtTqQ]?)")
    local val = tonumber(numPart) or 0
    if suffix == "k" or suffix == "K" then val = val * 1e3
    elseif suffix == "m" or suffix == "M" then val = val * 1e6
    elseif suffix == "b" or suffix == "B" then val = val * 1e9
    elseif suffix == "t" or suffix == "T" then val = val * 1e12
    elseif suffix == "q" or suffix == "Q" then val = val * 1e15
    end
    return val
end

-- Rarity Detection
local function detectRarity(item)
    if not item then return "Common" end
    local found = nil

    local function matchWord(str)
        if not str or str == "" then return nil end
        local lower = str:lower()
        if lower:find("secret") or lower:find("bí mật") then return "Secret" end
        if lower:find("divine") or lower:find("thần thánh") then return "Divine" end
        if lower:find("mythic") or lower:find("thần thoại") then return "Mythic" end
        if lower:find("legendary") or lower:find("huyền thoại") then return "Legendary" end
        if lower:find("epic") or lower:find("sử thi") then return "Epic" end
        if lower:find("rare") or lower:find("hiếm") then return "Rare" end
        if lower:find("uncommon") or lower:find("không phổ biến") then return "Uncommon" end
        if lower:find("common") or lower:find("thường") then return "Common" end
        return nil
    end

    pcall(function()
        for _, attr in ipairs({"Rarity", "Tier", "Rank", "Quality", "Type"}) do
            local v = item:GetAttribute(attr)
            if v and type(v) == "string" then
                found = matchWord(v)
                if found then return end
            end
        end
        for _, child in ipairs(item:GetChildren()) do
            if child:IsA("StringValue") and (child.Name == "Rarity" or child.Name == "Tier" or child.Name == "Rank") then
                found = matchWord(child.Value)
                if found then return end
            end
        end
        found = matchWord(item.Name)
    end)

    return found or "Common"
end

-- Employee Value Calculation
local function getEmployeeValue(emp)
    local val = 0
    local rarity = "Common"
    local rawText = ""

    pcall(function()
        rarity = detectRarity(emp)
        for _, desc in ipairs(emp:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Visible then
                local txt = desc.Text
                if txt:find("%$") or txt:find("/s") then
                    local parsed = parseValueString(txt)
                    if parsed > val then
                        val = parsed
                        rawText = txt
                    end
                end
                local rMatch = detectRarity(desc)
                if rMatch ~= "Common" and rarity == "Common" then
                    rarity = rMatch
                end
            end
            if desc:IsA("NumberValue") and (desc.Name == "Income" or desc.Name == "Value" or desc.Name == "CashPerSec" or desc.Name == "Rate") then
                if desc.Value > val then val = desc.Value end
            end
        end
    end)

    return val, rarity, rawText
end

-- ═══════════════════════════════════════════════════════════
-- 👁️ 3D EMPLOYEE ESP & SKY BEACONS SYSTEM
-- ═══════════════════════════════════════════════════════════

local ESPBillboards = {}
local ESPBeacons = {}

local function clearESP()
    for _, bb in ipairs(ESPBillboards) do
        pcall(function() bb:Destroy() end)
    end
    table.clear(ESPBillboards)

    for _, b in ipairs(ESPBeacons) do
        pcall(function() b:Destroy() end)
    end
    table.clear(ESPBeacons)
end

local function updateESP(enable)
    clearESP()
    if not enable then return end

    pcall(function()
        local hrp = getRootPart()
        local list = {}

        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and desc.Enabled then
                local parent = desc.Parent
                if parent then
                    local empModel = parent
                    while empModel and not empModel:IsA("Model") and empModel ~= Workspace do
                        empModel = empModel.Parent
                    end

                    local act = (desc.ActionText or ""):lower()
                    local obj = (desc.ObjectText or ""):lower()
                    local pName = parent.Name:lower()

                    local isSteal = act:find("steal") or act:find("take") or act:find("cướp") or act:find("lấy") or act:find("trộm")
                                 or obj:find("employee") or obj:find("worker") or obj:find("nhân viên") or pName:find("employee")

                    local hasHum = empModel and empModel:IsA("Model") and empModel:FindFirstChildOfClass("Humanoid")

                    if isSteal or hasHum then
                        local part = parent:IsA("BasePart") and parent or (empModel:IsA("Model") and (empModel.PrimaryPart or empModel:FindFirstChildWhichIsA("BasePart")))
                        if part then
                            local score, rarity, labelTxt = getEmployeeValue(empModel)
                            table.insert(list, {
                                Model = empModel,
                                Part = part,
                                Rarity = rarity,
                                Score = score,
                                LabelText = labelTxt
                            })
                        end
                    end
                end
            end
        end

        for _, emp in ipairs(list) do
            local part = emp.Part
            if part and part.Parent then
                local color = RARITY_COLORS[emp.Rarity] or Color3.fromRGB(200, 200, 200)

                local bb = Instance.new("BillboardGui")
                bb.Name = "EmployeeESP"
                bb.Adornee = part
                bb.Size = UDim2.new(0, 180, 0, 50)
                bb.StudsOffset = Vector3.new(0, 3.5, 0)
                bb.AlwaysOnTop = true
                bb.Parent = part

                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.BackgroundColor3 = Color3.fromRGB(10, 15, 25)
                frame.BackgroundTransparency = 0.35
                frame.BorderSizePixel = 0
                frame.Parent = bb

                local uic = Instance.new("UICorner")
                uic.CornerRadius = UDim.new(0, 6)
                uic.Parent = frame

                local stroke = Instance.new("UIStroke")
                stroke.Color = color
                stroke.Thickness = 1.5
                stroke.Parent = frame

                local title = Instance.new("TextLabel")
                title.Size = UDim2.new(1, 0, 0, 24)
                title.BackgroundTransparency = 1
                title.Text = "💼 " .. (emp.Model and emp.Model.Name or "Nhân Viên")
                title.TextColor3 = Color3.fromRGB(255, 255, 255)
                title.Font = Enum.Font.GothamBold
                title.TextSize = 12
                title.Parent = frame

                local dist = hrp and math.floor((hrp.Position - part.Position).Magnitude) or 0
                local valText = emp.Score > 0 and (" | 💰 $" .. emp.Score .. "/s") or (emp.LabelText ~= "" and (" | " .. emp.LabelText) or "")

                local sub = Instance.new("TextLabel")
                sub.Size = UDim2.new(1, 0, 0, 20)
                sub.Position = UDim2.new(0, 0, 0, 24)
                sub.BackgroundTransparency = 1
                sub.Text = "[" .. emp.Rarity:upper() .. "] 📍 " .. dist .. "m" .. valText
                sub.TextColor3 = color
                sub.Font = Enum.Font.Gotham
                sub.TextSize = 9
                sub.Parent = frame

                table.insert(ESPBillboards, bb)

                if State.SkyBeacons and (emp.Rarity == "Secret" or emp.Rarity == "Divine" or emp.Rarity == "Mythic" or emp.Rarity == "Legendary") then
                    local beacon = Instance.new("Part")
                    beacon.Size = Vector3.new(1.2, 300, 1.2)
                    beacon.CFrame = part.CFrame * CFrame.new(0, 150, 0)
                    beacon.Material = Enum.Material.Neon
                    beacon.Color = color
                    beacon.Transparency = 0.45
                    beacon.CanCollide = false
                    beacon.Anchored = true
                    beacon.Parent = Workspace
                    table.insert(ESPBeacons, beacon)
                end
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- 🎨 MODERN OBSIDIAN & EMERALD GUI (LITE EDITION)
-- ═══════════════════════════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealEmployeeGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

safeParentGui(ScreenGui)

-- Toggle Floating Button (💼)
local ToggleIcon = Instance.new("TextButton")
ToggleIcon.Name = "ToggleIcon"
ToggleIcon.Size = UDim2.new(0, 48, 0, 48)
ToggleIcon.Position = UDim2.new(0, 18, 0, 160)
ToggleIcon.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
ToggleIcon.Text = "💼"
ToggleIcon.TextSize = 24
ToggleIcon.Font = Enum.Font.GothamBold
ToggleIcon.TextColor3 = Color3.fromRGB(0, 255, 170)
ToggleIcon.AutoButtonColor = false
ToggleIcon.Parent = ScreenGui

local tCorner = Instance.new("UICorner")
tCorner.CornerRadius = UDim.new(1, 0)
tCorner.Parent = ToggleIcon

local tStroke = Instance.new("UIStroke")
tStroke.Color = Color3.fromRGB(0, 255, 170)
tStroke.Thickness = 2
tStroke.Parent = ToggleIcon

-- Draggable Logic
local function makeDraggable(guiObject, handle)
    handle = handle or guiObject
    local dragging = false
    local dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

makeDraggable(ToggleIcon)

-- Main Menu Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 360, 0, 480)
MainFrame.Position = UDim2.new(0, 75, 0, 120)
MainFrame.BackgroundColor3 = Color3.fromRGB(11, 15, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local mCorner = Instance.new("UICorner")
mCorner.CornerRadius = UDim.new(0, 12)
mCorner.Parent = MainFrame

local mStroke = Instance.new("UIStroke")
mStroke.Color = Color3.fromRGB(0, 255, 170)
mStroke.Thickness = 1.5
mStroke.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 44)
TopBar.BackgroundColor3 = Color3.fromRGB(16, 22, 36)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local tbCorner = Instance.new("UICorner")
tbCorner.CornerRadius = UDim.new(0, 12)
tbCorner.Parent = TopBar

makeDraggable(MainFrame, TopBar)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -90, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "💼 STEAL AN EMPLOYEE (LITE)"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 13
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TopBar

local cbCorner = Instance.new("UICorner")
cbCorner.CornerRadius = UDim.new(0, 6)
cbCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

ToggleIcon.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Content ScrollFrame
local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "ContentScroll"
Scroll.Size = UDim2.new(1, -20, 1, -85)
Scroll.Position = UDim2.new(0, 10, 0, 48)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 170)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 7)
Layout.Parent = Scroll

-- Component: Section Header
local function createSectionHeader(titleText, accentColor)
    local col = accentColor or Color3.fromRGB(0, 255, 170)
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 28)
    header.BackgroundTransparency = 1
    header.Parent = Scroll

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 4, 0, 18)
    bar.Position = UDim2.new(0, 4, 0, 5)
    bar.BackgroundColor3 = col
    bar.BorderSizePixel = 0
    bar.Parent = header

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 2)
    bCorner.Parent = bar

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = titleText
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextColor3 = col
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = header
end

-- Component: Toggle Button
local function createToggleButton(titleText, defaultState, callback)
    local isChecked = defaultState

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = isChecked and Color3.fromRGB(16, 42, 32) or Color3.fromRGB(16, 22, 32)
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = Scroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn

    local s = Instance.new("UIStroke")
    s.Color = isChecked and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(35, 45, 65)
    s.Thickness = 1
    s.Parent = btn

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -75, 1, 0)
    titleLbl.Position = UDim2.new(0, 10, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = titleText
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextSize = 11
    titleLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = btn

    local badge = Instance.new("Frame")
    badge.Size = UDim2.new(0, 52, 0, 22)
    badge.Position = UDim2.new(1, -58, 0, 7)
    badge.BackgroundColor3 = isChecked and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(30, 40, 55)
    badge.BorderSizePixel = 0
    badge.Parent = btn

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = badge

    local badgeLbl = Instance.new("TextLabel")
    badgeLbl.Size = UDim2.new(1, 0, 1, 0)
    badgeLbl.BackgroundTransparency = 1
    badgeLbl.Text = isChecked and "BẬT" or "TẮT"
    badgeLbl.Font = Enum.Font.GothamBold
    badgeLbl.TextSize = 10
    badgeLbl.TextColor3 = isChecked and Color3.fromRGB(10, 20, 15) or Color3.fromRGB(160, 170, 185)
    badgeLbl.Parent = badge

    btn.MouseButton1Click:Connect(function()
        isChecked = not isChecked
        btn.BackgroundColor3 = isChecked and Color3.fromRGB(16, 42, 32) or Color3.fromRGB(16, 22, 32)
        s.Color = isChecked and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(35, 45, 65)
        badge.BackgroundColor3 = isChecked and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(30, 40, 55)
        badgeLbl.Text = isChecked and "BẬT" or "TẮT"
        badgeLbl.TextColor3 = isChecked and Color3.fromRGB(10, 20, 15) or Color3.fromRGB(160, 170, 185)
        pcall(callback, isChecked)
    end)

    return btn
end

-- Component: Action Button
local function createActionButton(titleText, valueText, accentColor, callback)
    local col = accentColor or Color3.fromRGB(0, 255, 170)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(16, 22, 32)
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = Scroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(35, 45, 65)
    s.Thickness = 1
    s.Parent = btn

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -20, 0, 18)
    titleLbl.Position = UDim2.new(0, 10, 0, 2)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = titleText
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextSize = 11
    titleLbl.TextColor3 = col
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = btn

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(1, -20, 0, 14)
    valLbl.Position = UDim2.new(0, 10, 0, 18)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = valueText or ""
    valLbl.Font = Enum.Font.Gotham
    valLbl.TextSize = 9
    valLbl.TextColor3 = Color3.fromRGB(150, 165, 185)
    valLbl.TextXAlignment = Enum.TextXAlignment.Left
    valLbl.Parent = btn

    btn.MouseButton1Click:Connect(function()
        pcall(callback, btn, valLbl)
    end)

    return btn
end

-- Status Bar
local StatusBar = Instance.new("Frame")
StatusBar.Name = "StatusBar"
StatusBar.Size = UDim2.new(1, 0, 0, 28)
StatusBar.Position = UDim2.new(0, 0, 1, -28)
StatusBar.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
StatusBar.BorderSizePixel = 0
StatusBar.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 1, 0)
StatusLabel.Position = UDim2.new(0, 10, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "⚡ Steal An Employee (Lite) - Sẵn Sàng"
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 10
StatusLabel.TextColor3 = Color3.fromRGB(120, 255, 200)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusBar

local function setStatus(txt)
    StatusLabel.Text = tostring(txt)
end

-- ═══════════════════════════════════════════════════════════
-- SECTION 1: 👁️ VISUALS & 3D EMPLOYEE ESP
-- ═══════════════════════════════════════════════════════════
createSectionHeader("👁️ VISUALS & 3D EMPLOYEE ESP", Color3.fromRGB(168, 85, 247))

createToggleButton("🔍 Bật 3D Employee ESP Xuyên Tường", State.EmployeeESP, function(v)
    State.EmployeeESP = v
    updateESP(v)
    setStatus(v and "Đã BẬT 3D Employee ESP xuyên tường!" or "Đã TẮT 3D Employee ESP.")
end)

createToggleButton("🗼 Bật Cột Sáng Neon (Sky Beacons)", State.SkyBeacons, function(v)
    State.SkyBeacons = v
    if State.EmployeeESP then updateESP(true) end
    setStatus(v and "Đã BẬT cột sáng Neon chỉ đường!" or "Đã TẮT cột sáng Neon.")
end)

createToggleButton("⚡ Chế Độ Siêu Mượt 60 FPS (FPS Boost)", State.FPSBoost, function(v)
    State.FPSBoost = v
    if v then
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            for _, fx in ipairs(Lighting:GetChildren()) do
                if fx:IsA("PostEffect") then fx.Enabled = false end
            end
            if settings and settings().Rendering then
                settings().Rendering.QualityLevel = 1
            end
        end)
        setStatus("Đã bật chế độ 60 FPS siêu mượt!")
    end
end)

-- ═══════════════════════════════════════════════════════════
-- SECTION 2: 🏃 TỐC ĐỘ & TIỆN ÍCH
-- ═══════════════════════════════════════════════════════════
createSectionHeader("🏃 TỐC ĐỘ & TIỆN ÍCH", Color3.fromRGB(0, 255, 170))

createToggleButton("⚡ Bật Tăng Tốc Di Chuyển (WalkSpeed)", State.SpeedEnabled, function(v)
    State.SpeedEnabled = v
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = v and State.WalkSpeed or 16 end
    setStatus(v and ("Tốc độ: " .. State.WalkSpeed .. " - " .. getWalkSpeedDesc(State.WalkSpeed)) or "Đã về tốc độ thường.")
end)

createActionButton("⚡ Chỉnh Mốc Tốc Độ (WalkSpeed Presets)", "Hiện tại: [ " .. tostring(State.WalkSpeed) .. " ] (" .. getWalkSpeedDesc(State.WalkSpeed) .. ")", Color3.fromRGB(0, 255, 170), function(btn, lbl)
    local curIdx = 1
    for idx, spd in ipairs(ALL_WALK_SPEEDS) do
        if spd == State.WalkSpeed then curIdx = idx break end
    end
    curIdx = curIdx + 1
    if curIdx > #ALL_WALK_SPEEDS then curIdx = 1 end
    State.WalkSpeed = ALL_WALK_SPEEDS[curIdx]
    lbl.Text = "Hiện tại: [ " .. tostring(State.WalkSpeed) .. " ] (" .. getWalkSpeedDesc(State.WalkSpeed) .. ")"
    if State.SpeedEnabled then
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = State.WalkSpeed end
    end
    setStatus("⚡ Đã chọn tốc độ: " .. State.WalkSpeed .. " (" .. getWalkSpeedDesc(State.WalkSpeed) .. ")")
end)

createToggleButton("🌀 Bật Lướt Siêu Tốc CFrame (Bỏ Qua Anti-Cheat)", State.CFrameBoost, function(v)
    State.CFrameBoost = v
    setStatus(v and ("Đã bật Lướt CFrame " .. State.CFrameSpeed .. "x") or "Đã tắt Lướt CFrame.")
end)

createActionButton("🌀 Chỉnh Mức Lướt CFrame Multiplier", "Hiện tại: [ " .. tostring(State.CFrameSpeed) .. "x ] -> Bấm để đổi mốc", Color3.fromRGB(0, 200, 255), function(btn, lbl)
    local curIdx = 1
    for idx, spd in ipairs(ALL_CFRAME_SPEEDS) do
        if spd == State.CFrameSpeed then curIdx = idx break end
    end
    curIdx = curIdx + 1
    if curIdx > #ALL_CFRAME_SPEEDS then curIdx = 1 end
    State.CFrameSpeed = ALL_CFRAME_SPEEDS[curIdx]
    lbl.Text = "Hiện tại: [ " .. tostring(State.CFrameSpeed) .. "x ] -> Bấm để đổi mốc"
    setStatus("🌀 Mức lướt CFrame: " .. State.CFrameSpeed .. "x")
end)

createToggleButton("🦘 Nhảy Vô Hạn (Infinite Jump)", State.InfiniteJump, function(v)
    State.InfiniteJump = v
end)

createToggleButton("👻 Đi Xuyên Tường (Noclip)", State.Noclip, function(v)
    State.Noclip = v
end)

createActionButton("🚀 Lướt Xuyên Cửa / Pha CFrame Qua Tường (25m)", "Bấm để phóng người xuyên thẳng qua cánh cửa phía trước", Color3.fromRGB(255, 170, 0), function()
    local hrp = getRootPart()
    if hrp then
        hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -25)
        setStatus("🚀 Đã lướt CFrame xuyên qua cánh cửa 25 studs!")
    end
end)

createToggleButton("🛡️ Chống Văng Game 24/7 (Anti-AFK)", State.AntiAFK, function(v)
    State.AntiAFK = v
end)

-- ═══════════════════════════════════════════════════════════
-- 🏃 MOVEMENT & INPUT HOOKS
-- ═══════════════════════════════════════════════════════════
pcall(function()
    LocalPlayer.Idled:Connect(function()
        if State.AntiAFK then
            VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        end
    end)
end)

RunService.Stepped:Connect(function()
    if State.Noclip then
        local char = getCharacter()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
    if State.SpeedEnabled then
        local hum = getHumanoid()
        if hum and hum.WalkSpeed ~= State.WalkSpeed then
            hum.WalkSpeed = State.WalkSpeed
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if State.CFrameBoost then
        local hrp = getRootPart()
        local hum = getHumanoid()
        if hrp and hum and hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (State.CFrameSpeed * 10 * dt))
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local hum = getHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

pcall(function()
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if State.SpeedEnabled then
            local hum = char:WaitForChild("Humanoid", 3)
            if hum then hum.WalkSpeed = State.WalkSpeed end
        end
    end)
end)

-- ═══════════════════════════════════════════════════════════
-- 🔄 BACKGROUND ESP LOOP & FPS BOOST
-- ═══════════════════════════════════════════════════════════

-- ESP Refresh Loop
task.spawn(function()
    while true do
        task.wait(3.5)
        if State.EmployeeESP then
            updateESP(true)
        end
    end
end)

-- Kích hoạt FPS Boost ngay khi chạy
pcall(function()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    for _, fx in ipairs(Lighting:GetChildren()) do
        if fx:IsA("PostEffect") then fx.Enabled = false end
    end
    if settings and settings().Rendering then
        settings().Rendering.QualityLevel = 1
    end
end)

setStatus("✅ Đã khởi chạy Steal An Employee (Lite) thành công!")

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "💼 Steal An Employee (Lite)",
        Text = "✅ Đã tải Hub thành công! Bấm icon 💼 để bật/tắt menu.",
        Duration = 6
    })
end)
print("✅ [Steal An Employee Lite] Ultimate Hyper Speed & 3D ESP Hub loaded successfully!")
