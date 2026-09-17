--[[
    ===================================================================
    💼 STEAL AN EMPLOYEE! (ĂN CẮP MỘT NHÂN VIÊN) - FAST LOADER
    Repository: https://github.com/khahuynh963/steal_an_employee.git
    Tương thích: Delta, Wave, Codex, Fluxus, Arceus, Solara, Hydrogen...
    ===================================================================
--]]

-- Dọn dẹp GUI cũ trước khi load
pcall(function()
    if gethui then
        local g = gethui():FindFirstChild("StealEmployeeGui")
        if g then g:Destroy() end
    end
    pcall(function()
        local cg = game:GetService("CoreGui"):FindFirstChild("StealEmployeeGui")
        if cg then cg:Destroy() end
    end)
    local pl = game:GetService("Players").LocalPlayer
    if pl then
        local pg = pl:FindFirstChild("PlayerGui")
        if pg and pg:FindFirstChild("StealEmployeeGui") then
            pg.StealEmployeeGui:Destroy()
        end
    end
end)

-- Tải mã nguồn script.lua với cơ chế chống lỗi mạng và chống cache
local function loadHub()
    local baseUrl = "https://raw.githubusercontent.com/khahuynh963/steal_an_employee/main/script.lua"
    local code = nil

    -- Cách 1: Tải với random query để không bị dính cache GitHub
    pcall(function()
        code = game:HttpGet(baseUrl .. "?" .. tostring(math.random(1, 999999)))
    end)

    -- Cách 2: Nếu executor không hỗ trợ query string trên raw GitHub, tải URL sạch
    if not code or #code < 1000 then
        pcall(function()
            code = game:HttpGet(baseUrl)
        end)
    end

    if code and #code >= 1000 then
        local fn, err = loadstring(code)
        if fn then
            local ok, runErr = pcall(fn)
            if not ok then
                warn("❌ Lỗi khi thực thi script.lua: " .. tostring(runErr))
                pcall(function()
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "❌ Lỗi Script",
                        Text = tostring(runErr):sub(1, 80),
                        Duration = 8
                    })
                end)
            end
            return ok
        else
            warn("❌ Lỗi biên dịch script.lua: " .. tostring(err))
        end
    else
        warn("❌ Không thể tải mã nguồn script.lua từ GitHub!")
    end
    return false
end

local success = loadHub()
if not success then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "💼 Steal An Employee",
            Text = "Đang tải lại mã nguồn... Vui lòng đợi trong giây lát!",
            Duration = 5
        })
    end)
    task.wait(1)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/khahuynh963/steal_an_employee/main/script.lua"))()
end
