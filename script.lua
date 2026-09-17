--[[
    ===================================================================
    💼 STEAL AN EMPLOYEE! (ĂN CẮP MỘT NHÂN VIÊN) - ULTIMATE AUTO HUB V1.0
    Game: [💸UPD] Ăn cắp một nhân viên / Steal an Employee! (Build a Crew)
    
    🎮 TÍNH NĂNG TOÀN DIỆN:
      1. 🏃 Auto Steal Employee: Tự động lướt trộm nhân viên giá trị cao nhất ($/s)
      2. 🌙 Night Employee Sniper: Tự động săn nhân viên hiếm xuất hiện ban đêm
      3. 🪑 Auto Office Placement: Tự xếp nhân viên vào bàn làm việc (Desk/Workstation)
      4. 😱 Anti-Boss 100%: Bay an toàn cách mặt đất, vô hiệu hóa chạm bắt của Boss
      5. 📈 Auto Upgrade Desks & Office: Tự nâng cấp bàn làm việc và mở rộng văn phòng
      6. 💰 Auto Collect Vault & Cash: Tự thu tiền két sắt ngoại tuyến và hút tiền sàn
      7. ⛏️ Auto Bonk (PvP): Tự động gõ đối thủ để cướp nhân viên
      8. 👁️ 3D Employee ESP & Sky Beacons: Định vị nhân viên Secret, Divine, Mythic
      9. ⚡ Speed Booster & CFrame Glide: Tăng tốc cực đại, Noclip, Anti-AFK 24/7
     10. ⚡ 60 FPS Boost: Khử giật lag tối đa cho Delta Executor (Mobile & PC)
    ===================================================================
--]]

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- ── Safe GUI Container Helper ──
local function getGuiContainer()
    local container = nil
    pcall(function()
        if gethui then
            container = gethui()
        elseif syn and syn.protect_gui then
            local f = Instance.new("Folder")
            syn.protect_gui(f)
            f.Parent = game:GetService("CoreGui")
            container = f
        elseif game:GetService("CoreGui") then
            container = game:GetService("CoreGui")
        end
    end)
    if not container then
        pcall(function()
            container = LocalPlayer:WaitForChild("PlayerGui")
        end)
    end
    return container
end

-- Clear old GUI instances
pcall(function()
    local c = getGuiContainer()
    if c and c:FindFirstChild("StealEmployeeGui") then
        c.StealEmployeeGui:Destroy()
    end
    if game:GetService("CoreGui"):FindFirstChild("StealEmployeeGui") then
        game:GetService("CoreGui").StealEmployeeGui:Destroy()
    end
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("StealEmployeeGui") then
        LocalPlayer.PlayerGui.StealEmployeeGui:Destroy()
    end
end)

-- ── State Variables ──
local State = {
    -- 1. Trộm Nhân Viên (Auto Steal)
    AutoSteal = false,
    StealHighestValue = true,
    MinRarityIndex = 1, -- 1 = All, 2 = Rare+, 3 = Epic+, 4 = Legendary+, 5 = Mythic+, 6 = Divine/Secret
    NightSniper = true,
    InstantPrompt = true,
    SafeFlight = true, -- Bay lướt trên không tránh bẫy và boss

    -- 2. Quản Lý Văn Phòng (Office & Desks)
    AutoPlaceDesk = true,
    AutoUpgradeDesk = false,
    AutoCollectVault = true,
    AutoCollectCash = true,

    -- 3. Khắc Tinh Con Trùm (Anti-Boss)
    AntiBoss = true,
    BossDistanceWarning = true,

    -- 4. Tấn Công Người Chơi (PvP Bonk)
    AutoBonk = false,
    BonkRange = 15,

    -- 5. Visuals & ESP
    EmployeeESP = false,
    SkyBeacons = false,
    BossESP = false,
    FPSBoost = true,

    -- 6. Tiện Ích & Tốc Độ
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

local ALL_RARITIES = {
    "All (Tất Cả)", "Rare+", "Epic+", "Legendary+", "Mythic+", "Divine/Secret"
}

local RARITY_COLORS = {
    ["Secret"] = Color3.fromRGB(255, 0, 128),
    ["Divine"] = Color3.fromRGB(255, 215, 0),
    ["Mythic"] = Color3.fromRGB(180, 50, 255),
    ["Mythical"] = Color3.fromRGB(180, 50, 255),
    ["Legendary"] = Color3.fromRGB(255, 140, 0),
    ["Epic"] = Color3.fromRGB(160, 50, 255),
    ["Rare"] = Color3.fromRGB(0, 180, 255),
    ["Common"] = Color3.fromRGB(180, 200, 220),
    ["Unknown"] = Color3.fromRGB(0, 255, 170)
}

local ESPHighlights = {}
local ESPBillboards = {}
local ESPBeacons = {}

-- ── Caching System (Zero Lag) ──
local cachedMyOffice = nil
local cachedDesks = {}
local cachedVault = nil
local cachedEmployees = {}
local cachedBosses = {}
local lastScanTime = 0
local isStealingInProgress = false

-- ── Character Helpers ──
local function getCharacter()
    return LocalPlayer.Character
end

local function getRootPart()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getBackpack()
    return LocalPlayer:FindFirstChild("Backpack")
end

-- ── Optimize & Trigger Proximity Prompt ──
local function optimizePrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        prompt.RequiresLineOfSight = false
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 999999
        prompt.Enabled = true
    end)
end

local function triggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    optimizePrompt(prompt)
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
            fireproximityprompt(prompt, 100)
            fireproximityprompt(prompt)
        end
    end)
    pcall(function()
        prompt:InputHoldBegin()
        task.wait(0.02)
        prompt:InputHoldEnd()
    end)
end

-- ── Number & Value Parser ($/s) ──
local function parseValueString(str)
    if not str then return 0 end
    local clean = tostring(str):lower():gsub(",", ""):gsub("%$", ""):gsub("/s", ""):gsub("%+", "")
    local numStr, sfx = clean:match("([%d%.]+)%s*([a-z]*)")
    if not numStr then return 0 end
    local val = tonumber(numStr) or 0
    sfx = sfx or ""

    local mults = {
        k = 1e3,
        m = 1e6,
        b = 1e9,
        t = 1e12,
        qa = 1e15, q = 1e15,
        qi = 1e18,
        sx = 1e21,
        sp = 1e24,
        oc = 1e27,
        no = 1e30,
        dc = 1e33
    }

    if mults[sfx] then
        val = val * mults[sfx]
    end
    return val
end

-- ── Rarity Detection ──
local function detectRarity(item)
    if not item then return "Common" end
    local found = nil

    local function matchWord(str)
        if not str or str == "" then return nil end
        local s = tostring(str):lower()
        for _, r in ipairs({"Secret", "Divine", "Mythical", "Mythic", "Legendary", "Epic", "Rare", "Common"}) do
            if s:find(r:lower()) then return r end
        end
        return nil
    end

    found = matchWord(item.Name)
    if found then return found end

    pcall(function()
        for _, attr in ipairs({"Rarity", "Tier", "Type", "Rank", "Quality"}) do
            local v = item:GetAttribute(attr)
            if v then
                local res = matchWord(v)
                if res then found = res break end
            end
        end

        if not found then
            for _, desc in ipairs(item:GetDescendants()) do
                if desc:IsA("StringValue") and (desc.Name:lower():find("rarity") or desc.Name:lower():find("tier")) then
                    local res = matchWord(desc.Value)
                    if res then found = res break end
                elseif desc:IsA("TextLabel") and desc.Visible then
                    local res = matchWord(desc.Text)
                    if res then found = res break end
                end
            end
        end
    end)

    return found or "Common"
end

-- ── Extract Value ($/s) from Employee ──
local function getEmployeeValue(emp)
    local bestVal = 0
    local labelFound = ""

    pcall(function()
        for _, desc in ipairs(emp:GetDescendants()) do
            if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                local txt = desc.Text
                if txt and (txt:find("%$") or txt:lower():find("/s") or txt:match("[%d%.]+[kmbqt]")) then
                    local val = parseValueString(txt)
                    if val > bestVal then
                        bestVal = val
                        labelFound = txt
                    end
                end
            end
        end

        if bestVal == 0 then
            for _, attr in ipairs({"Value", "Cash", "Income", "Rate", "PerSecond", "Money"}) do
                local v = emp:GetAttribute(attr)
                if v then
                    local val = tonumber(v) or parseValueString(tostring(v))
                    if val > bestVal then bestVal = val end
                end
            end
        end
    end)

    local rarity = detectRarity(emp)
    local rarityBonus = 0
    if rarity == "Secret" then rarityBonus = 1e12
    elseif rarity == "Divine" then rarityBonus = 1e10
    elseif rarity == "Mythic" or rarity == "Mythical" then rarityBonus = 1e8
    elseif rarity == "Legendary" then rarityBonus = 1e6
    elseif rarity == "Epic" then rarityBonus = 1e4
    elseif rarity == "Rare" then rarityBonus = 1e2
    end

    return bestVal + rarityBonus, rarity, labelFound
end

-- ── Detect Player Office / Base ──
local function getMyOffice()
    if cachedMyOffice and cachedMyOffice.Parent then return cachedMyOffice end

    local myId = tostring(LocalPlayer.UserId)
    local pName = LocalPlayer.Name:lower()
    local pDisp = LocalPlayer.DisplayName:lower()

    pcall(function()
        local folders = {
            Workspace:FindFirstChild("Offices"),
            Workspace:FindFirstChild("Plots"),
            Workspace:FindFirstChild("Bases"),
            Workspace:FindFirstChild("Companies"),
            Workspace:FindFirstChild("Tycoons")
        }

        for _, folder in ipairs(folders) do
            if folder then
                for _, child in ipairs(folder:GetChildren()) do
                    local cName = child.Name:lower()
                    if cName:find(myId) or cName:find(pName) or cName:find(pDisp) then
                        cachedMyOffice = child
                        return child
                    end
                    local owner = child:FindFirstChild("Owner") or child:FindFirstChild("Player")
                    if owner and (owner.Value == LocalPlayer or tostring(owner.Value):lower() == pName) then
                        cachedMyOffice = child
                        return child
                    end
                end
            end
        end

        -- Direct child in Workspace
        for _, child in ipairs(Workspace:GetChildren()) do
            local cName = child.Name:lower()
            if (cName:find("office") or cName:find("plot") or cName:find("base")) and (cName:find(myId) or cName:find(pName)) then
                cachedMyOffice = child
                return child
            end
        end
    end)

    return cachedMyOffice
end

-- ── Check if container belongs to another player ──
local function isOtherPlayerOffice(container)
    if not container or container == Workspace then return false end
    local myOff = getMyOffice()
    if myOff and (container == myOff or container:IsDescendantOf(myOff)) then
        return false
    end

    local myId = tostring(LocalPlayer.UserId)
    local curr = container
    while curr and curr ~= Workspace do
        local cName = curr.Name:lower()
        if cName:find("office") or cName:find("plot") or cName:find("base") or cName:find("company") or cName:find("tycoon") then
            local pId = cName:match("(%d+)")
            if pId and pId ~= myId then return true end
            for _, attr in ipairs({"Owner", "Player", "UserId", "Username"}) do
                local val = curr:GetAttribute(attr)
                if val and tostring(val) ~= myId and tostring(val):lower() ~= LocalPlayer.Name:lower() then
                    return true
                end
            end
            local owner = curr:FindFirstChild("Owner") or curr:FindFirstChild("Player")
            if owner and owner.Value ~= LocalPlayer then
                return true
            end
        end
        curr = curr.Parent
    end

    return false
end

-- ── Scanner: Available Desks in Player's Office ──
local function getAvailableDesks()
    local desks = {}
    local office = getMyOffice()
    if not office then return desks end

    pcall(function()
        for _, desc in ipairs(office:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and desc.Enabled then
                local act = (desc.ActionText or ""):lower()
                local obj = (desc.ObjectText or ""):lower()
                local pName = desc.Parent and desc.Parent.Name:lower() or ""

                if act:find("place") or act:find("sit") or act:find("assign") or act:find("put") 
                   or act:find("đặt") or act:find("ngồi") or obj:find("desk") or obj:find("chair") 
                   or pName:find("desk") or pName:find("chair") or pName:find("workstation") then
                    table.insert(desks, desc)
                end
            end
        end
    end)

    return desks
end

-- ── Scanner: Office Vault / Safe ──
local function getOfficeVaultPrompt()
    local office = getMyOffice()
    if not office then return nil end

    local foundPrompt = nil
    pcall(function()
        for _, desc in ipairs(office:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and desc.Enabled then
                local act = (desc.ActionText or ""):lower()
                local obj = (desc.ObjectText or ""):lower()
                local pName = desc.Parent and desc.Parent.Name:lower() or ""

                if act:find("collect") or act:find("claim") or act:find("open") or act:find("thu") 
                   or obj:find("vault") or obj:find("safe") or obj:find("kho") or pName:find("vault") or pName:find("safe") then
                    foundPrompt = desc
                    break
                end
            end
        end
    end)

    return foundPrompt
end

-- ── Scanner: Boss / Guard NPCs ──
local function getNearbyBosses()
    local bosses = {}
    local hrp = getRootPart()

    pcall(function()
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") and obj ~= LocalPlayer.Character then
                local nameLower = obj.Name:lower()
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart

                if hum and root and (nameLower:find("boss") or nameLower:find("manager") or nameLower:find("ceo") 
                   or nameLower:find("guard") or nameLower:find("security") or nameLower:find("trùm")) then
                    local dist = hrp and (hrp.Position - root.Position).Magnitude or 9999
                    table.insert(bosses, {
                        Model = obj,
                        Root = root,
                        Distance = dist,
                        Name = obj.Name
                    })
                end
            end
        end
    end)

    table.sort(bosses, function(a, b) return a.Distance < b.Distance end)
    return bosses
end

-- ── Scanner: Stealable Employees Across Companies ──
local function getStealableEmployees()
    local list = {}
    local hrp = getRootPart()
    local myOff = getMyOffice()

    pcall(function()
        -- 1. Tìm các Folder công ty / Spawn / Map
        local targets = {}
        for _, name in ipairs({"Companies", "Spawns", "Employees", "Workers", "NPCs", "Map", "Buildings"}) do
            local f = Workspace:FindFirstChild(name)
            if f then table.insert(targets, f) end
        end

        if #targets == 0 then
            for _, child in ipairs(Workspace:GetChildren()) do
                if child:IsA("Folder") or child:IsA("Model") then
                    local n = child.Name:lower()
                    if (n:find("company") or n:find("zone") or n:find("office") or n:find("city")) and child ~= myOff then
                        table.insert(targets, child)
                    end
                end
            end
        end

        if #targets == 0 then table.insert(targets, Workspace) end

        for _, target in ipairs(targets) do
            for _, desc in ipairs(target:GetDescendants()) do
                if desc:IsA("ProximityPrompt") and desc.Enabled then
                    local parent = desc.Parent
                    if parent and not isOtherPlayerOffice(parent) then
                        local act = (desc.ActionText or ""):lower()
                        local obj = (desc.ObjectText or ""):lower()
                        local pName = parent.Name:lower()

                        local isStealPrompt = act:find("steal") or act:find("take") or act:find("grab") or act:find("cướp")
                                           or act:find("hire") or act:find("recruit") or act:find("lấy") or act:find("bắt")
                                           or obj:find("employee") or obj:find("worker") or obj:find("nhân viên")
                                           or pName:find("employee") or pName:find("worker")

                        if isStealPrompt then
                            local model = parent
                            while model and not model:IsA("Model") and model ~= Workspace do
                                model = model.Parent
                            end
                            local empModel = (model and model:IsA("Model")) and model or parent
                            local score, rarity, labelTxt = getEmployeeValue(empModel)

                            local pos = parent:IsA("BasePart") and parent.Position 
                                     or (empModel:IsA("Model") and empModel.PrimaryPart and empModel.PrimaryPart.Position)
                                     or (empModel:FindFirstChildWhichIsA("BasePart") and empModel:FindFirstChildWhichIsA("BasePart").Position)

                            if pos then
                                local dist = hrp and (hrp.Position - pos).Magnitude or 0
                                table.insert(list, {
                                    Prompt = desc,
                                    Model = empModel,
                                    Position = pos,
                                    Score = score,
                                    Rarity = rarity,
                                    Label = labelTxt,
                                    Distance = dist
                                })
                            end
                        end
                    end
                end
            end
        end
    end)

    -- Sắp xếp theo giá trị $/s cao nhất (hoặc độ hiếm cao nhất)
    table.sort(list, function(a, b)
        if State.StealHighestValue then
            return a.Score > b.Score
        else
            return a.Distance < b.Distance
        end
    end)

    return list
end

-- ── Safe Glide & Teleport Helper (Anti-Boss 10-15 Studs Above) ──
local function safeGlideTo(targetPos)
    local hrp = getRootPart()
    if not hrp or not targetPos then return end

    -- Bay cách mặt đất 14 studs để không chạm Boss / bẫy
    local safeSkyPos = targetPos + Vector3.new(0, 14, 0)
    hrp.CFrame = CFrame.new(safeSkyPos)
    task.wait(0.08)

    -- Hạ nhanh xuống ngay vị trí tương tác
    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
    task.wait(0.05)
end

-- ── 3D Visuals & Employee ESP ──
local function clearESP()
    for _, h in pairs(ESPHighlights) do pcall(function() h:Destroy() end) end
    for _, b in pairs(ESPBillboards) do pcall(function() b:Destroy() end) end
    for _, c in pairs(ESPBeacons) do pcall(function() c:Destroy() end) end
    ESPHighlights = {}
    ESPBillboards = {}
    ESPBeacons = {}
end

local function updateESP(enable)
    clearESP()
    if not enable then return end

    local hrp = getRootPart()
    local employees = getStealableEmployees()
    local count = 0

    pcall(function()
        for _, emp in ipairs(employees) do
            if count >= 16 then break end -- Giới hạn 16 mục để đảm bảo 60 FPS
            count = count + 1

            local color = RARITY_COLORS[emp.Rarity] or Color3.fromRGB(0, 255, 170)
            local model = emp.Model
            local part = model:IsA("BasePart") and model or (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart"))

            if part then
                local bb = Instance.new("BillboardGui")
                bb.Adornee = part
                bb.AlwaysOnTop = true
                bb.Size = UDim2.new(0, 160, 0, 38)
                bb.StudsOffset = Vector3.new(0, 4, 0)
                bb.MaxDistance = 2000
                bb.Parent = part

                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.BackgroundColor3 = Color3.fromRGB(12, 16, 24)
                frame.BackgroundTransparency = 0.25
                frame.Parent = bb

                local fCorner = Instance.new("UICorner")
                fCorner.CornerRadius = UDim.new(0, 6)
                fCorner.Parent = frame

                local fStroke = Instance.new("UIStroke")
                fStroke.Color = color
                fStroke.Thickness = 1.2
                fStroke.Parent = frame

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 0.55, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = "💼 " .. model.Name
                lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 10
                lbl.Parent = frame

                local sub = Instance.new("TextLabel")
                sub.Size = UDim2.new(1, 0, 0.45, 0)
                sub.Position = UDim2.new(0, 0, 0.55, 0)
                sub.BackgroundTransparency = 1
                local dist = hrp and math.floor((hrp.Position - part.Position).Magnitude) or 0
                local valText = (emp.Label and emp.Label ~= "") and (" | " .. emp.Label) or ""
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
-- 🎨 MODERN OBSIDIAN & EMERALD GUI (STEAL AN EMPLOYEE)
-- ═══════════════════════════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealEmployeeGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local container = getGuiContainer()
ScreenGui.Parent = container

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

-- Draggable Function
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

makeDraggable(ToggleIcon, ToggleIcon)

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 440)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -220)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 14, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local mCorner = Instance.new("UICorner")
mCorner.CornerRadius = UDim.new(0, 12)
mCorner.Parent = MainFrame

local mStroke = Instance.new("UIStroke")
mStroke.Color = Color3.fromRGB(0, 255, 170)
mStroke.Thickness = 1.6
mStroke.Parent = MainFrame

ToggleIcon.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Title Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(15, 22, 34)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local hCorner = Instance.new("UICorner")
hCorner.CornerRadius = UDim.new(0, 12)
hCorner.Parent = Header

makeDraggable(MainFrame, Header)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "💼 STEAL AN EMPLOYEE V1.0"
Title.TextColor3 = Color3.fromRGB(0, 255, 170)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local MiniBtn = Instance.new("TextButton")
MiniBtn.Size = UDim2.new(0, 26, 0, 26)
MiniBtn.Position = UDim2.new(1, -60, 0.5, -13)
MiniBtn.BackgroundColor3 = Color3.fromRGB(24, 34, 52)
MiniBtn.Text = "—"
MiniBtn.TextColor3 = Color3.fromRGB(200, 220, 255)
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 12
MiniBtn.AutoButtonColor = false
MiniBtn.Parent = Header

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(0, 6)
miniCorner.Parent = MiniBtn

MiniBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -13)
CloseBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 30)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Content ScrollFrame
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -80)
Scroll.Position = UDim2.new(0, 8, 0, 46)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 170)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 6)
Layout.Parent = Scroll

-- Component: Section Header
local function createSectionHeader(titleText, accentColor)
    local col = accentColor or Color3.fromRGB(0, 255, 170)
    local sec = Instance.new("Frame")
    sec.Size = UDim2.new(1, 0, 0, 26)
    sec.BackgroundTransparency = 1
    sec.Parent = Scroll

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 0, 16)
    bar.Position = UDim2.new(0, 2, 0.5, -8)
    bar.BackgroundColor3 = col
    bar.BorderSizePixel = 0
    bar.Parent = sec

    local bCorn = Instance.new("UICorner")
    bCorn.CornerRadius = UDim.new(1, 0)
    bCorn.Parent = bar

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = titleText
    lbl.TextColor3 = col
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = sec

    return sec
end

-- Component: Modern Toggle Button
local function createToggleButton(titleText, defaultState, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(18, 38, 30) or Color3.fromRGB(16, 22, 32)
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = Scroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn

    local s = Instance.new("UIStroke")
    s.Color = defaultState and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(35, 45, 65)
    s.Thickness = 1.2
    s.Parent = btn

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -70, 1, 0)
    titleLbl.Position = UDim2.new(0, 10, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = titleText
    titleLbl.TextColor3 = defaultState and Color3.fromRGB(220, 255, 240) or Color3.fromRGB(180, 195, 215)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 11
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = btn

    local badge = Instance.new("Frame")
    badge.Size = UDim2.new(0, 50, 0, 20)
    badge.Position = UDim2.new(1, -58, 0.5, -10)
    badge.BackgroundColor3 = defaultState and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(35, 45, 65)
    badge.Parent = btn

    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(0, 5)
    badgeCorner.Parent = badge

    local badgeText = Instance.new("TextLabel")
    badgeText.Size = UDim2.new(1, 0, 1, 0)
    badgeText.BackgroundTransparency = 1
    badgeText.Text = defaultState and "BẬT" or "TẮT"
    badgeText.TextColor3 = defaultState and Color3.fromRGB(10, 20, 20) or Color3.fromRGB(130, 145, 170)
    badgeText.Font = Enum.Font.GothamBold
    badgeText.TextSize = 10
    badgeText.Parent = badge

    local currentState = defaultState
    btn.MouseButton1Click:Connect(function()
        currentState = not currentState
        btn.BackgroundColor3 = currentState and Color3.fromRGB(18, 38, 30) or Color3.fromRGB(16, 22, 32)
        s.Color = currentState and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(35, 45, 65)
        titleLbl.TextColor3 = currentState and Color3.fromRGB(220, 255, 240) or Color3.fromRGB(180, 195, 215)
        badge.BackgroundColor3 = currentState and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(35, 45, 65)
        badgeText.Text = currentState and "BẬT" or "TẮT"
        badgeText.TextColor3 = currentState and Color3.fromRGB(10, 20, 20) or Color3.fromRGB(130, 145, 170)
        callback(currentState, btn, s)
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
    titleLbl.TextColor3 = col
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 11
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = btn

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(1, -20, 0, 15)
    valLbl.Position = UDim2.new(0, 10, 0, 18)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = valueText
    valLbl.TextColor3 = Color3.fromRGB(180, 195, 215)
    valLbl.Font = Enum.Font.Gotham
    valLbl.TextSize = 10
    valLbl.TextXAlignment = Enum.TextXAlignment.Left
    valLbl.Parent = btn

    btn.MouseButton1Click:Connect(function()
        callback(btn, valLbl, s)
    end)

    return btn, valLbl
end

-- Status Bar
local StatusFrame = Instance.new("Frame")
StatusFrame.Size = UDim2.new(1, 0, 0, 32)
StatusFrame.Position = UDim2.new(0, 0, 1, -32)
StatusFrame.BackgroundColor3 = Color3.fromRGB(10, 14, 20)
StatusFrame.BorderSizePixel = 0
StatusFrame.Parent = MainFrame

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 7, 0, 7)
StatusDot.Position = UDim2.new(0, 10, 0.5, -3)
StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
StatusDot.BorderSizePixel = 0
StatusDot.Parent = StatusFrame

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = StatusDot

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -28, 1, 0)
StatusLabel.Position = UDim2.new(0, 24, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Sẵn sàng (Steal An Employee V1.0)."
StatusLabel.TextColor3 = Color3.fromRGB(200, 220, 240)
StatusLabel.TextSize = 10
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusFrame

local function setStatus(txt)
    StatusLabel.Text = txt
end

-- ═══════════════════════════════════════════════════════════
-- SECTION 1: 🏃 AUTO ĐÁNH CẮP NHÂN VIÊN (AUTO STEAL)
-- ═══════════════════════════════════════════════════════════
createSectionHeader("🏃 AUTO ĐÁNH CẮP NHÂN VIÊN", Color3.fromRGB(0, 255, 170))

createToggleButton("⚡ Bật Auto Steal Nhân Viên (Auto Farm)", State.AutoSteal, function(v)
    State.AutoSteal = v
    setStatus(v and "Đang tìm kiếm và đánh cắp nhân viên xịn nhất..." or "Đã dừng Auto Steal.")
end)

createToggleButton("🎯 Ưu Tiên Nhân Viên $/s Cao Nhất (Max Value)", State.StealHighestValue, function(v)
    State.StealHighestValue = v
    setStatus(v and "Chế độ: Ưu tiên nhân viên có $/s cao nhất!" or "Chế độ: Ưu tiên nhân viên ở gần nhất.")
end)

createActionButton("🎖️ Lọc Độ Hiếm Nhân Viên Tối Thiểu", "Hiện tại: [ " .. ALL_RARITIES[State.MinRarityIndex] .. " ]", Color3.fromRGB(255, 200, 50), function(btn, lbl)
    State.MinRarityIndex = State.MinRarityIndex + 1
    if State.MinRarityIndex > #ALL_RARITIES then State.MinRarityIndex = 1 end
    lbl.Text = "Hiện tại: [ " .. ALL_RARITIES[State.MinRarityIndex] .. " ]"
end)

createToggleButton("🌙 Night Sniper (Săn Nhân Viên Hiếm Ban Đêm)", State.NightSniper, function(v)
    State.NightSniper = v
end)

createToggleButton("🛡️ Bay Lướt An Toàn (Safe Sky Glide)", State.SafeFlight, function(v)
    State.SafeFlight = v
end)

-- ═══════════════════════════════════════════════════════════
-- SECTION 2: 🪑 QUẢN LÝ VĂN PHÒNG & BÀN LÀM VIỆC (OFFICE)
-- ═══════════════════════════════════════════════════════════
createSectionHeader("🪑 VĂN PHÒNG & BÀN LÀM VIỆC", Color3.fromRGB(0, 200, 255))

createToggleButton("🪑 Tự Đặt Nhân Viên Vào Bàn (Auto Place)", State.AutoPlaceDesk, function(v)
    State.AutoPlaceDesk = v
end)

createToggleButton("📈 Tự Động Nâng Cấp Bàn Làm Việc (Upgrade)", State.AutoUpgradeDesk, function(v)
    State.AutoUpgradeDesk = v
end)

createToggleButton("💰 Tự Thu Tiền Két Sắt (Vault Offline Cash)", State.AutoCollectVault, function(v)
    State.AutoCollectVault = v
end)

createToggleButton("💵 Tự Hút Tiền Rơi Trên Sàn (Collect Drops)", State.AutoCollectCash, function(v)
    State.AutoCollectCash = v
end)

-- ═══════════════════════════════════════════════════════════
-- SECTION 3: 😱 KHẮC TINH CON TRÙM (ANTI-BOSS)
-- ═══════════════════════════════════════════════════════════
createSectionHeader("😱 KHẮC TINH CON TRÙM (ANTI-BOSS)", Color3.fromRGB(255, 80, 80))

createToggleButton("🛡️ Chế Độ Né Trùm 100% (Anti-Boss Touch)", State.AntiBoss, function(v)
    State.AntiBoss = v
    setStatus(v and "Đã kích hoạt bảo vệ chống bắt của Boss!" or "Đã tắt Anti-Boss.")
end)

createToggleButton("⚠️ Cảnh Báo Khoảng Cách Boss (Boss Radar)", State.BossDistanceWarning, function(v)
    State.BossDistanceWarning = v
end)

-- ═══════════════════════════════════════════════════════════
-- SECTION 4: ⛏️ PVP BONK (TẤN CÔNG NGƯỜI CHƠI KHÁC)
-- ═══════════════════════════════════════════════════════════
createSectionHeader("⛏️ PVP CƯỚP NHÂN VIÊN (AUTO BONK)", Color3.fromRGB(255, 140, 0))

createToggleButton("🏏 Auto Bonk Người Chơi Ở Gần (Cướp)", State.AutoBonk, function(v)
    State.AutoBonk = v
    setStatus(v and "Đang tự động gõ đối thủ có nhân viên trên tay!" or "Đã tắt Auto Bonk.")
end)

-- ═══════════════════════════════════════════════════════════
-- SECTION 5: 👁️ VISUALS & 3D ESP
-- ═══════════════════════════════════════════════════════════
createSectionHeader("👁️ VISUALS & 3D EMPLOYEE ESP", Color3.fromRGB(190, 130, 255))

createToggleButton("🔍 Bật 3D Employee ESP Xuyên Tường", State.EmployeeESP, function(v)
    State.EmployeeESP = v
    updateESP(v)
end)

createToggleButton("🗼 Bật Cột Sáng Neon (Sky Beacons)", State.SkyBeacons, function(v)
    State.SkyBeacons = v
    updateESP(State.EmployeeESP)
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
-- SECTION 6: 🏃 TỐC ĐỘ & TIỆN ÍCH
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
            for _, part in ipairs(char:GetChildren()) do
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
-- 🔄 BACKGROUND AUTO WORKERS (ZERO LAG & HYPER RESPONSIVE)
-- ═══════════════════════════════════════════════════════════

-- 1. 🏃 AUTO STEAL & BRING TO OFFICE ENGINE
task.spawn(function()
    while true do
        task.wait(0.6)
        if State.AutoSteal and not isStealingInProgress then
            pcall(function()
                local hrp = getRootPart()
                local char = getCharacter()
                local bp = getBackpack()
                if not hrp then return end

                -- Kiểm tra xem người chơi đã đang cầm nhân viên trên tay chưa
                local hasEmployeeInHand = false
                if char then
                    for _, item in ipairs(char:GetChildren()) do
                        if item:IsA("Tool") or item.Name:lower():find("employee") or item.Name:lower():find("worker") then
                            hasEmployeeInHand = true break
                        end
                    end
                end

                -- Nếu đã vác nhân viên trên tay -> bay về văn phòng và xếp vào bàn ngay
                if hasEmployeeInHand then
                    local myOff = getMyOffice()
                    if myOff then
                        local desks = getAvailableDesks()
                        if #desks > 0 then
                            local deskPrompt = desks[1]
                            local dPos = deskPrompt.Parent:IsA("BasePart") and deskPrompt.Parent.Position 
                                      or (deskPrompt.Parent:IsA("Model") and deskPrompt.Parent.PrimaryPart and deskPrompt.Parent.PrimaryPart.Position)
                            if dPos then
                                setStatus("🪑 Đang xếp nhân viên vào bàn làm việc...")
                                hrp.CFrame = CFrame.new(dPos + Vector3.new(0, 3, 0))
                                task.wait(0.1)
                                triggerPrompt(deskPrompt)
                                task.wait(0.4)
                            end
                        end
                    end
                    return
                end

                -- Tìm nhân viên tốt nhất để đánh cắp
                local employees = getStealableEmployees()
                if #employees == 0 then
                    setStatus("🔍 Đang quét các công ty tìm nhân viên...")
                    return
                end

                -- Lọc theo độ hiếm tối thiểu
                local targetEmp = nil
                local minRarity = ALL_RARITIES[State.MinRarityIndex]

                for _, emp in ipairs(employees) do
                    local pass = true
                    if minRarity == "Rare+" then
                        pass = emp.Rarity ~= "Common"
                    elseif minRarity == "Epic+" then
                        pass = emp.Rarity ~= "Common" and emp.Rarity ~= "Rare"
                    elseif minRarity == "Legendary+" then
                        pass = emp.Rarity == "Legendary" or emp.Rarity == "Mythic" or emp.Rarity == "Mythical" or emp.Rarity == "Divine" or emp.Rarity == "Secret"
                    elseif minRarity == "Mythic+" then
                        pass = emp.Rarity == "Mythic" or emp.Rarity == "Mythical" or emp.Rarity == "Divine" or emp.Rarity == "Secret"
                    elseif minRarity == "Divine/Secret" then
                        pass = emp.Rarity == "Divine" or emp.Rarity == "Secret"
                    end

                    if pass then
                        targetEmp = emp
                        break
                    end
                end

                if not targetEmp then targetEmp = employees[1] end
                if not targetEmp or not targetEmp.Prompt or not targetEmp.Prompt.Parent then return end

                isStealingInProgress = true
                setStatus("🚀 Đang bay tới cướp: [" .. targetEmp.Rarity .. "] " .. targetEmp.Model.Name .. "...")

                -- Bay an toàn tiếp cận nhân viên (tránh Boss)
                if State.SafeFlight then
                    safeGlideTo(targetEmp.Position)
                else
                    hrp.CFrame = CFrame.new(targetEmp.Position + Vector3.new(0, 3, 0))
                    task.wait(0.05)
                end

                -- Kích hoạt trộm tức thời
                triggerPrompt(targetEmp.Prompt)
                task.wait(0.2)

                -- Tự động bay về văn phòng của mình
                local myOff = getMyOffice()
                if myOff then
                    local desks = getAvailableDesks()
                    if #desks > 0 then
                        local dPrompt = desks[1]
                        local dPos = dPrompt.Parent:IsA("BasePart") and dPrompt.Parent.Position 
                                  or (dPrompt.Parent:IsA("Model") and dPrompt.Parent.PrimaryPart and dPrompt.Parent.PrimaryPart.Position)
                        if dPos then
                            setStatus("🪑 Đã cướp thành công! Đang đặt vào bàn làm việc...")
                            hrp.CFrame = CFrame.new(dPos + Vector3.new(0, 3, 0))
                            task.wait(0.12)
                            triggerPrompt(dPrompt)
                            task.wait(0.4)
                        end
                    else
                        local offPos = myOff:IsA("BasePart") and myOff.Position 
                                    or (myOff:IsA("Model") and myOff.PrimaryPart and myOff.PrimaryPart.Position)
                        if offPos then
                            hrp.CFrame = CFrame.new(offPos + Vector3.new(0, 5, 0))
                        end
                    end
                end

                isStealingInProgress = false
                task.wait(0.5)
            end)
            isStealingInProgress = false
        end
    end
end)

-- 2. 🪑 AUTO PLACE EMPLOYEES AT DESKS (NẾU ĐÃ CÓ TRONG TÚI ĐỒ)
task.spawn(function()
    while true do
        task.wait(0.8)
        if State.AutoPlaceDesk and not isStealingInProgress then
            pcall(function()
                local char = getCharacter()
                local bp = getBackpack()
                local hrp = getRootPart()

                local empTool = nil
                if char then
                    for _, t in ipairs(char:GetChildren()) do
                        if t:IsA("Tool") and (t.Name:lower():find("employee") or t.Name:lower():find("worker") or t.Name:lower():find("staff")) then
                            empTool = t break
                        end
                    end
                end
                if not empTool and bp then
                    for _, t in ipairs(bp:GetChildren()) do
                        if t:IsA("Tool") and (t.Name:lower():find("employee") or t.Name:lower():find("worker") or t.Name:lower():find("staff")) then
                            empTool = t break
                        end
                    end
                end

                if empTool then
                    local desks = getAvailableDesks()
                    if #desks > 0 then
                        local deskPrompt = desks[1]
                        local dPos = deskPrompt.Parent:IsA("BasePart") and deskPrompt.Parent.Position 
                                  or (deskPrompt.Parent:IsA("Model") and deskPrompt.Parent.PrimaryPart and deskPrompt.Parent.PrimaryPart.Position)

                        if char and empTool.Parent == bp then
                            local hum = getHumanoid()
                            if hum then hum:EquipTool(empTool) else empTool.Parent = char end
                            task.wait(0.1)
                        end

                        if hrp and dPos then
                            hrp.CFrame = CFrame.new(dPos + Vector3.new(0, 3, 0))
                            task.wait(0.08)
                            triggerPrompt(deskPrompt)
                            task.wait(0.4)
                        end
                    end
                end
            end)
        end
    end
end)

-- 3. 📈 AUTO UPGRADE DESKS & OFFICE EXPANSION
task.spawn(function()
    while true do
        task.wait(1.5)
        if State.AutoUpgradeDesk then
            pcall(function()
                local office = getMyOffice()
                if not office then return end

                for _, desc in ipairs(office:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") and desc.Enabled then
                        local act = (desc.ActionText or ""):lower()
                        local obj = (desc.ObjectText or ""):lower()
                        local pName = desc.Parent and desc.Parent.Name:lower() or ""

                        if act:find("upgrade") or act:find("buy") or act:find("expand") 
                           or obj:find("upgrade") or pName:find("upgrade") or pName:find("button") then
                            triggerPrompt(desc)
                            task.wait(0.1)
                        end
                    end
                end
            end)
        end
    end
end)

-- 4. 💰 AUTO COLLECT VAULT & CASH DROPS
task.spawn(function()
    while true do
        task.wait(1.5)
        if State.AutoCollectVault then
            pcall(function()
                local vaultPrompt = getOfficeVaultPrompt()
                if vaultPrompt then
                    triggerPrompt(vaultPrompt)
                end
            end)
        end

        if State.AutoCollectCash then
            pcall(function()
                local hrp = getRootPart()
                if not hrp then return end
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if obj:IsA("BasePart") then
                        local name = obj.Name:lower()
                        if name:find("cash") or name:find("coin") or name:find("money") or name:find("bill") or name:find("drop") then
                            obj.CFrame = hrp.CFrame
                        end
                    end
                end
            end)
        end
    end
end)

-- 5. 😱 ANTI-BOSS & DANGER RADAR
task.spawn(function()
    while true do
        task.wait(0.3)
        if State.AntiBoss or State.BossDistanceWarning then
            pcall(function()
                local bosses = getNearbyBosses()
                local hrp = getRootPart()

                if #bosses > 0 and hrp then
                    local closestBoss = bosses[1]
                    if closestBoss.Distance < 35 then
                        if State.BossDistanceWarning then
                            setStatus("⚠️ CẢNH BÁO: " .. closestBoss.Name .. " đang ở gần (" .. math.floor(closestBoss.Distance) .. "m)!")
                        end

                        if State.AntiBoss and closestBoss.Distance < 20 then
                            -- Tự động búng người lên cao 15 studs để Boss không chạm vào được
                            hrp.CFrame = hrp.CFrame + Vector3.new(0, 15, 0)
                            task.wait(0.2)
                        end
                    end
                end
            end)
        end
    end
end)

-- 6. ⛏️ AUTO BONK (PVP CƯỚP NHÂN VIÊN)
task.spawn(function()
    while true do
        task.wait(0.3)
        if State.AutoBonk then
            pcall(function()
                local hrp = getRootPart()
                local char = getCharacter()
                if not hrp or not char then return end

                -- Cầm sẵn vũ khí Bonk nếu có
                local bonkTool = nil
                for _, t in ipairs(char:GetChildren()) do
                    if t:IsA("Tool") and (t.Name:lower():find("bat") or t.Name:lower():find("bonk") or t.Name:lower():find("club") or t.Name:lower():find("stick")) then
                        bonkTool = t break
                    end
                end
                if not bonkTool then
                    local bp = getBackpack()
                    if bp then
                        for _, t in ipairs(bp:GetChildren()) do
                            if t:IsA("Tool") and (t.Name:lower():find("bat") or t.Name:lower():find("bonk") or t.Name:lower():find("club") or t.Name:lower():find("stick")) then
                                local hum = getHumanoid()
                                if hum then hum:EquipTool(t) else t.Parent = char end
                                bonkTool = t
                                task.wait(0.1)
                                break
                            end
                        end
                    end
                end

                -- Quét người chơi khác ở gần
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local pRoot = player.Character:FindFirstChild("HumanoidRootPart")
                        if pRoot then
                            local dist = (hrp.Position - pRoot.Position).Magnitude
                            if dist <= (State.BonkRange or 15) then
                                if bonkTool then
                                    bonkTool:Activate()
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 7. 👁️ ESP REFRESH LOOP
task.spawn(function()
    while true do
        task.wait(4.0)
        if State.EmployeeESP then
            updateESP(true)
        end
    end
end)

-- 8. Kích hoạt FPS Boost ngay khi chạy
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

setStatus("✅ Đã khởi chạy Steal An Employee V1.0 thành công!")
