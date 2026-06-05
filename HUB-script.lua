--==========================================================================================--
--                                  LUXURY HACKER HUB v5                                    --
--                 Optimized for Delta Executor | Smart TP & Multi-Select                   --
--==========================================================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Хранилище состояний
local TargetPlayers = {}
local SavedTpPosition = nil
local IsMinimized = false
local ActiveTab = "CHEAT"
local MultiSelectMode = false

-- Конфигурация тем оформления
local Theme = {
    Current = "Luxury",
    Luxury = {
        Seq = ColorSequence.new(Color3.fromRGB(255, 140, 0), Color3.fromRGB(212, 175, 55)),
        MainBg = Color3.fromRGB(5, 5, 5),
        SideBg = Color3.fromRGB(10, 10, 10),
        ListBg = Color3.fromRGB(8, 8, 8),
        PrimaryText = Color3.fromRGB(255, 140, 0),
        SecondaryText = Color3.fromRGB(200, 200, 200),
        SelectBg = Color3.fromRGB(25, 12, 5)
    },
    Hacker = {
        Seq = ColorSequence.new(Color3.fromRGB(0, 255, 50), Color3.fromRGB(0, 100, 10)),
        MainBg = Color3.fromRGB(0, 0, 0),
        SideBg = Color3.fromRGB(4, 12, 4),
        ListBg = Color3.fromRGB(2, 6, 2),
        PrimaryText = Color3.fromRGB(0, 255, 50),
        SecondaryText = Color3.fromRGB(140, 180, 140),
        SelectBg = Color3.fromRGB(5, 35, 5)
    }
}

local oldUi = game:GetService("CoreGui"):FindFirstChild("HackerHub") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("HackerHub")
if oldUi then oldUi:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HackerHub"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

--==========================================================================================--
--                                   ФУНКЦИИ СТИЛИЗАЦИИ                                      --
--==========================================================================================--
local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local function applyThemeGradient(parent)
    local gradient = Instance.new("UIGradient")
    gradient.Name = "LuxuryGradient"
    gradient.Color = Theme[Theme.Current].Seq
    gradient.Parent = parent
    return gradient
end

local function makeDraggable(dragFrame, parentFrame)
    local dragging, dragInput, dragStart, startPos
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = parentFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            parentFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--==========================================================================================--
--                                      ГЛАВНЫЕ ФРЕЙМЫ                                      --
--==========================================================================================--
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 440, 0, 260)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Theme[Theme.Current].MainBg
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
createCorner(MainFrame, 8)

local MainScale = Instance.new("UIScale")
MainScale.Scale = 1
MainScale.Parent = MainFrame

local TopLine = Instance.new("Frame")
TopLine.Size = UDim2.new(1, 0, 0, 4)
TopLine.BorderSizePixel = 0
TopLine.Parent = MainFrame
applyThemeGradient(TopLine)
createCorner(TopLine, 4)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.Position = UDim2.new(0, 0, 0, 4)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame
makeDraggable(TopBar, MainFrame)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 250, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "SYSTEM OVERRIDE // LUX HUB"
Title.TextSize = 15 
Title.Font = Enum.Font.GothamBold 
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = TopBar
applyThemeGradient(Title)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 2)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BackgroundTransparency = 1
CloseBtn.Parent = TopBar
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 35, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -75, 0, 2)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Parent = TopBar

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 110, 1, -39)
Sidebar.Position = UDim2.new(0, 0, 0, 39)
Sidebar.BackgroundColor3 = Theme[Theme.Current].SideBg
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarUIList = Instance.new("UIListLayout")
SidebarUIList.Padding = UDim.new(0, 4)
SidebarUIList.Parent = Sidebar

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -120, 1, -44)
ContentFrame.Position = UDim2.new(0, 120, 0, 41)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local Tabs = {}
local function createTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 40)
    TabBtn.Text = "  " .. name
    TabBtn.TextSize = 13
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.BackgroundTransparency = 1
    TabBtn.Parent = Sidebar
    
    local TabContent = Instance.new("Frame")
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = (name == "CHEAT")
    TabContent.Parent = ContentFrame
    
    if name == "CHEAT" then
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        local g = applyThemeGradient(TabBtn)
        g.Name = "TabGrad"
    else
        TabBtn.TextColor3 = Theme[Theme.Current].SecondaryText
    end
    
    Tabs[name] = {Btn = TabBtn, Content = TabContent}
    
    TabBtn.MouseButton1Click:Connect(function()
        for tName, tData in pairs(Tabs) do
            tData.Content.Visible = (tName == name)
            local oldGrad = tData.Btn:FindFirstChild("TabGrad")
            if oldGrad then oldGrad:Destroy() end
            
            if tName == name then
                tData.Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                local g = applyThemeGradient(tData.Btn)
                g.Name = "TabGrad"
            else
                tData.Btn.TextColor3 = Theme[Theme.Current].SecondaryText
            end
        end
        ActiveTab = name
    end)
    return TabContent
end

local CheatTab = createTab("CHEAT")
local SettingsTab = createTab("SETTINGS")

MinimizeBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    if IsMinimized then
        MainFrame:TweenSize(UDim2.new(0, 440, 0, 39), "Out", "Quad", 0.2, true)
        Sidebar.Visible = false
        ContentFrame.Visible = false
        MinimizeBtn.Text = "🗖"
    else
        MainFrame:TweenSize(UDim2.new(0, 440, 0, 260), "Out", "Quad", 0.2, true)
        Sidebar.Visible = true
        ContentFrame.Visible = true
        MinimizeBtn.Text = "—"
    end
end)

local function switchTheme(themeName)
    Theme.Current = themeName
    local t = Theme[themeName]
    for _, obj in ipairs(ScreenGui:GetDescendants()) do
        if obj:IsA("UIGradient") and obj.Name == "LuxuryGradient" then obj.Color = t.Seq end
    end
    MainFrame.BackgroundColor3 = t.MainBg
    Sidebar.BackgroundColor3 = t.SideBg
    for tName, tData in pairs(Tabs) do
        if tName ~= ActiveTab then tData.Btn.TextColor3 = t.SecondaryText end
    end
    if CheatTab.Visible then
        local pList = CheatTab:FindFirstChildOfClass("ScrollingFrame")
        if pList then pList.BackgroundColor3 = t.ListBg end
        local cp = CheatTab:FindFirstChild("ControlPanel")
        if cp then
            local status = cp:FindFirstChild("PosStatus")
            if status then status.TextColor3 = t.SecondaryText end
        end
    end
    local updatePlayerList = _G.UpdatePlayerListFunc
    if updatePlayerList then updatePlayerList() end
end

--==========================================================================================--
--                                      ВКЛАДКА НАСТРОЕК                                    --
--==========================================================================================--
local SettingsLayout = Instance.new("UIListLayout")
SettingsLayout.Padding = UDim.new(0, 6)
SettingsLayout.Parent = SettingsTab

local function createSettingInfo(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 20)
    lbl.Text = " > " .. text
    lbl.TextColor3 = Color3.fromRGB(14, 114, 14)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1
    lbl.Parent = SettingsTab
end

createSettingInfo("HWID STATUS: STABLE ACTIVE")
createSettingInfo("RENDER MODE: RUNSERVICE OPTIMIZED")

local Div = Instance.new("Frame")
Div.Size = UDim2.new(1, -10, 0, 1)
Div.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Div.BorderSizePixel = 0
Div.Parent = SettingsTab

local ScaleLabel = Instance.new("TextLabel")
ScaleLabel.Size = UDim2.new(1, -10, 0, 18)
ScaleLabel.Text = "HUB SCALE (1.5 = smaller, 0.75 = bigger):"
ScaleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
ScaleLabel.TextSize = 11
ScaleLabel.Font = Enum.Font.GothamBold
ScaleLabel.TextXAlignment = Enum.TextXAlignment.Left
ScaleLabel.BackgroundTransparency = 1
ScaleLabel.Parent = SettingsTab

local ScaleInput = Instance.new("TextBox")
ScaleInput.Size = UDim2.new(0, 80, 0, 26)
ScaleInput.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
ScaleInput.Text = "1"
ScaleInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ScaleInput.Font = Enum.Font.GothamBold
ScaleInput.TextSize = 12
createCorner(ScaleInput, 4)
ScaleInput.Parent = SettingsTab

ScaleInput.FocusLost:Connect(function()
    local num = tonumber(ScaleInput.Text)
    if num and num > 0 then MainScale.Scale = 1 / num
    else ScaleInput.Text = tostring(1 / MainScale.Scale) end
end)

local ThemeLabel = Instance.new("TextLabel")
ThemeLabel.Size = UDim2.new(1, -10, 0, 18)
ThemeLabel.Text = "SELECT INTERFACE THEME:"
ThemeLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
ThemeLabel.TextSize = 11
ThemeLabel.Font = Enum.Font.GothamBold
ThemeLabel.TextXAlignment = Enum.TextXAlignment.Left
ThemeLabel.BackgroundTransparency = 1
ThemeLabel.Parent = SettingsTab

local ThemeContainer = Instance.new("Frame")
ThemeContainer.Size = UDim2.new(1, -10, 0, 30)
ThemeContainer.BackgroundTransparency = 1
ThemeContainer.Parent = SettingsTab
local ThemeLayout = Instance.new("UIListLayout")
ThemeLayout.FillDirection = Enum.FillDirection.Horizontal
ThemeLayout.Padding = UDim.new(0, 8)
ThemeLayout.Parent = ThemeContainer

local LuxBtn = Instance.new("TextButton")
LuxBtn.Size = UDim2.new(0, 85, 1, 0)
LuxBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
LuxBtn.Text = "LUXURY"
LuxBtn.TextColor3 = Color3.fromRGB(255, 140, 0)
LuxBtn.Font = Enum.Font.GothamBold
LuxBtn.TextSize = 11
createCorner(LuxBtn, 4)
LuxBtn.Parent = ThemeContainer
LuxBtn.MouseButton1Click:Connect(function() switchTheme("Luxury") end)

local HackBtn = Instance.new("TextButton")
HackBtn.Size = UDim2.new(0, 85, 1, 0)
HackBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
HackBtn.Text = "HACKER"
HackBtn.TextColor3 = Color3.fromRGB(0, 255, 50)
HackBtn.Font = Enum.Font.GothamBold
HackBtn.TextSize = 11
createCorner(HackBtn, 4)
HackBtn.Parent = ThemeContainer
HackBtn.MouseButton1Click:Connect(function() switchTheme("Hacker") end)

--==========================================================================================--
--                                   ВКЛАДКА CHEAT (UI ПАНЕЛИ)                              --
--==========================================================================================--
local PlayerListFrame = Instance.new("ScrollingFrame")
PlayerListFrame.Size = UDim2.new(0, 165, 1, 0)
PlayerListFrame.BackgroundColor3 = Theme[Theme.Current].ListBg
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerListFrame.ScrollBarThickness = 3
PlayerListFrame.Parent = CheatTab
createCorner(PlayerListFrame, 4)

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 4)
ListLayout.Parent = PlayerListFrame

local ControlPanel = Instance.new("Frame")
ControlPanel.Name = "ControlPanel"
ControlPanel.Size = UDim2.new(1, -175, 1, 0)
ControlPanel.Position = UDim2.new(0, 175, 0, 0)
ControlPanel.BackgroundTransparency = 1
ControlPanel.Parent = CheatTab

local ControlLayout = Instance.new("UIListLayout")
ControlLayout.Padding = UDim.new(0, 6)
ControlLayout.Parent = ControlPanel

local function createHackButton(text, hasGradient)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    btn.Text = text
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = ControlPanel
    createCorner(btn, 4)
    if hasGradient then
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        applyThemeGradient(btn)
    else
        btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
    return btn
end

local SelectAllBtn = createHackButton("SELECT ALL", false)
local SetTpBtn = createHackButton("SET CUSTOM TP", false)
local ActionBtn = createHackButton("TP THESE PEOPLE", true)

local PosStatus = Instance.new("TextLabel")
PosStatus.Name = "PosStatus"
PosStatus.Size = UDim2.new(1, 0, 0, 18)
PosStatus.Text = "TP: Current Pos | MODE: SINGLE"
PosStatus.TextColor3 = Theme[Theme.Current].SecondaryText
PosStatus.TextSize = 10
PosStatus.Font = Enum.Font.Gotham
PosStatus.BackgroundTransparency = 1
PosStatus.Parent = ControlPanel

--==========================================================================================--
--                                         ЛОГИКА                                           --
--==========================================================================================--
local function getSeatContext()
    local char = LocalPlayer.Character
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local seat = tool:FindFirstChildOfClass("Seat") or tool:FindFirstChildOfClass("VehicleSeat")
        if seat then return seat, "ToolSeat" end
    end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.SeatPart then
        local seat = humanoid.SeatPart
        if seat:IsA("VehicleSeat") or #seat.Parent:GetDescendants() > 30 then
            return seat, "Vehicle"
        else
            return seat, "ToolSeat" end
    end
    return nil
end

local function updatePlayerList()
    local t = Theme[Theme.Current]
    for _, child in ipairs(PlayerListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local isSelected = TargetPlayers[player]
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, 0, 0, 32)
            pBtn.BackgroundColor3 = isSelected and t.SelectBg or Color3.fromRGB(14, 14, 14)
            pBtn.Text = "  " .. player.DisplayName
            pBtn.TextColor3 = isSelected and t.PrimaryText or t.SecondaryText
            pBtn.TextSize = 12
            pBtn.Font = Enum.Font.GothamBold
            pBtn.TextXAlignment = Enum.TextXAlignment.Left
            pBtn.BorderSizePixel = 0
            pBtn.Parent = PlayerListFrame
            createCorner(pBtn, 4)
            
            local chk = Instance.new("TextLabel")
            chk.Size = UDim2.new(0, 25, 1, 0)
            chk.Position = UDim2.new(1, -30, 0, 0)
            chk.Text = isSelected and "✓" or "○"
            chk.TextColor3 = isSelected and t.PrimaryText or Color3.fromRGB(70, 70, 70)
            chk.Font = Enum.Font.GothamBold
            chk.TextSize = 13
            chk.BackgroundTransparency = 1
            chk.Parent = pBtn
            
            pBtn.MouseButton1Click:Connect(function()
                local now = tick()
                if now - (pBtn:GetAttribute("LastClick") or 0) < 0.4 then
                    MultiSelectMode = not MultiSelectMode
                    local modeText = MultiSelectMode and "MULTI" or "SINGLE"
                    PosStatus.Text = (SavedTpPosition and "TP: Custom Set! | " or "TP: Current Pos | ") .. "MODE: " .. modeText
                    TargetPlayers[player] = true
                else
                    if not MultiSelectMode then
                        for k in pairs(TargetPlayers) do TargetPlayers[k] = false end
                    end
                    TargetPlayers[player] = not TargetPlayers[player]
                end
                pBtn:SetAttribute("LastClick", now)
                updatePlayerList()
            end)
        end
    end
    PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
end

_G.UpdatePlayerListFunc = updatePlayerList
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(function(player) TargetPlayers[player] = nil updatePlayerList() end)
updatePlayerList()

local allSelected = false
SelectAllBtn.MouseButton1Click:Connect(function()
    allSelected = not allSelected
    MultiSelectMode = true
    PosStatus.Text = (SavedTpPosition and "TP: Custom Set! | " or "TP: Current Pos | ") .. "MODE: MULTI"
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then TargetPlayers[player] = allSelected end
    end
    SelectAllBtn.Text = allSelected and "DESELECT ALL" or "SELECT ALL"
    updatePlayerList()
end)

SetTpBtn.MouseButton1Click:Connect(function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        SavedTpPosition = hrp.Position
        PosStatus.Text = "TP: Custom Set! | MODE: " .. (MultiSelectMode and "MULTI" or "SINGLE")
        PosStatus.TextColor3 = Theme[Theme.Current].PrimaryText
    end
end)

--==========================================================================================--
--                                   БЛОК ТЕЛЕПОРТАЦИИ                                      --
--==========================================================================================--
ActionBtn.MouseButton1Click:Connect(function()
    local seat, seatType = getSeatContext()
    if not seat then
        ActionBtn.Text = "NO SEAT!"
        task.wait(1) ActionBtn.Text = "TP THESE PEOPLE"
        return
    end
    
    local targets = {}
    for player, selected in pairs(TargetPlayers) do
        if selected and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(targets, player)
        end
    end
    
    if #targets == 0 then
        ActionBtn.Text = "NO TARGETS!"
        task.wait(1) ActionBtn.Text = "TP THESE PEOPLE"
        return
    end
    
    local finalTpPos = SavedTpPosition
    if not finalTpPos then
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHrp then finalTpPos = myHrp.Position end
    end
    if not finalTpPos then return end
    
    ActionBtn.Text = "KIDNAPPING..."
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

    -- Конвейер для предмета в руках (по одному)
    if seatType == "ToolSeat" then
        for _, vPlayer in ipairs(targets) do
            local tool = myChar:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
            if not tool then break end
            tool.Parent = myChar
            task.wait(0.1)

            local tHrp = vPlayer.Character and vPlayer.Character:FindFirstChild("HumanoidRootPart")
            local currentSeat = tool:FindFirstChildOfClass("Seat") or tool:FindFirstChildOfClass("VehicleSeat")

            if tHrp and currentSeat and myHrp then
                local startT = tick()
                local angle = 0
                while currentSeat.Occupant == nil and (tick() - startT) < 5 do
                    RunService.Heartbeat:Wait()
                    if currentSeat.Occupant then break end
                    angle = angle + 0.6
                    myHrp.CFrame = CFrame.new(Vector3.new(tHrp.Position.X + math.cos(angle)*4, tHrp.Position.Y + 1, tHrp.Position.Z + math.sin(angle)*4), tHrp.Position)
                end

                if currentSeat.Occupant then
                    myHrp.CFrame = CFrame.new(finalTpPos + Vector3.new(0, 3, 0))
                    task.wait(0.2)
                    local weld = currentSeat:FindFirstChild("SeatWeld")
                    if weld then weld:Destroy() end
                    tool.Parent = LocalPlayer.Backpack
                    task.wait(0.3)
                end
            end
        end
    
    -- Конвейер для машины (группами по количеству мест)
    elseif seatType == "Vehicle" then
        local vehicle = seat.Parent
        local passSeats = {}
        for _, v in ipairs(vehicle:GetDescendants()) do
            if (v:IsA("Seat") or v:IsA("VehicleSeat")) and v ~= seat then
                table.insert(passSeats, v)
            end
        end
        if #passSeats == 0 then table.insert(passSeats, seat) end

        local q = {unpack(targets)}
        while #q > 0 do
            local batch = {}
            for i = 1, #passSeats do
                if #q > 0 then table.insert(batch, table.remove(q, 1)) end
            end

            for _, vPlayer in ipairs(batch) do
                local tHrp = vPlayer.Character and vPlayer.Character:FindFirstChild("HumanoidRootPart")
                if tHrp and myHrp then
                    local startT = tick()
                    while (tick() - startT) < 4 do
                        RunService.Heartbeat:Wait()
                        local sat = false
                        for _, s in ipairs(passSeats) do
                            if s.Occupant and s.Occupant.Parent == vPlayer.Character then sat = true break end
                        end
                        if sat then break end
                        local offset = seat.Position - myHrp.Position
                        myHrp.CFrame = CFrame.new(tHrp.Position + Vector3.new(0, 2, 0) - offset)
                    end
                end
            end

            if myHrp then
                myHrp.CFrame = CFrame.new(finalTpPos + Vector3.new(0, 3, 0))
                task.wait(0.3)
                for _, s in ipairs(passSeats) do
                    local w = s:FindFirstChild("SeatWeld")
                    if w then w:Destroy() end
                end
                task.wait(0.3)
            end
        end
    end
    
    ActionBtn.Text = "TP THESE PEOPLE"
end)
