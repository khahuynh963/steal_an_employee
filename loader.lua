--[[
    ===================================================================
    💼 STEAL AN EMPLOYEE! (ĂN CẮP MỘT NHÂN VIÊN) - FAST LOADER V1.0
    Repository: https://github.com/khahuynh963/steal_an_employee.git
    Tương thích: Delta Executor (Android & PC), Wave, Codex, Fluxus.
    ===================================================================
--]]

pcall(function()
    local container = (gethui and gethui()) or game:GetService("CoreGui")
    if container and container:FindFirstChild("StealEmployeeGui") then
        container.StealEmployeeGui:Destroy()
    end
    local pl = game:GetService("Players").LocalPlayer
    if pl and pl:FindFirstChild("PlayerGui") and pl.PlayerGui:FindFirstChild("StealEmployeeGui") then
        pl.PlayerGui.StealEmployeeGui:Destroy()
    end
end)

loadstring(game:HttpGet("https://raw.githubusercontent.com/khahuynh963/steal_an_employee/main/script.lua?v=" .. tostring(os.time()) .. "_" .. tostring(math.random(10000, 99999))))()
