--==========================================================================================--
--                                  LUXURY HACKER HUB v4                                    --
--                 Optimized for Delta Executor | UI Style: Dynamic Themes                 --
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
local CurrentTheme = "Luxury"
local CurrentScale = 1

local BASE_WIDTH = 440
local BASE_HEIGHT = 260

-- Очистка старых UI перед перезапуском
local oldUi = game:GetService("CoreGui"):FindFirstChild("HackerHub") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("HackerHub")
if oldUi then oldUi:Destroy() end

-- Создание ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HackerHub"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Списки элементов для динамического обновления темы
local GradientsToUpdate = {}
local BackgroundsToUpdate = {}
local TextToUpdate = {}

--==========================================================================================--
--                                   ФУНКЦИИ СТИЛИЗАЦИИ                                      --
--==========================================================================================--
local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

-- Динамический градиент (Luxury или Hacker)
local function applyThemeGradient(parent)
    local oldGrad = parent:FindFirstChild("ThemeGradient")
    if oldGrad then oldGrad:Destroy() end
    
    local gradient = Instance.new("UIGradiient") -- Защита от перезаписи имени класса в движке
    gradient = Instance.new("UIGradient")
    gradient.Name = "ThemeGradient"
    
    if CurrentTheme == "Luxury" then
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 140, 0)), -- Оранжевый
            ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 175, 55))  -- Золотой
        })
    else
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),   -- Токсично-зеленый
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 0))    -- Темно-зеленый
        })
    end
    gradient.Parent = parent
    GradientsToUpdate[parent] = true
    return gradient
end

-- Обновление всей темы на лету
local function updateThemeUI()
    local mainBg = (CurrentTheme == "Luxury") and Color3.fromRGB(5, 5, 5) or Color3.fromRGB(0, 0, 0)
    local sideBg = (CurrentTheme == "Luxury") and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(5, 5, 5)
    local listBg = (CurrentTheme == "Luxury") and Color3.fromRGB(8, 8, 8) or Color3.fromRGB(3, 3, 3)
    
    for frame, t in pairs(BackgroundsToUpdate) do
        if frame and frame.Parent then
            if frame.Name == "MainFrame" then frame.BackgroundColor3 = mainBg
            elseif frame.Name == "Sidebar" then frame.BackgroundColor3 = sideBg
            elseif frame.Name == "PlayerListFrame" then frame.BackgroundColor3 = listBg
            end
        end
    end
    
    for obj, _ in pairs(GradientsToUpdate) do
        if obj and obj.Parent then applyThemeGradient(obj) end
    end
    
    for txtObj, typeStr do
        if txtObj and txtObj.Parent then
            if typeStr == "Status" then
                txtObj.TextColor3 = (CurrentTheme == "Luxury") and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(0, 255, 0)
            end
        end
    end
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
MainFrame.Size = UDim2.new(0, BASE_WIDTH, 0, BASE_HEIGHT)
MainFrame.Position = UDim2.new(0.5, -BASE_WIDTH/2, 0.5, -BASE_HEIGHT/2)
MainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
createCorner(MainFrame, 8)
BackgroundsToUpdate[MainFrame] = true

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
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 110, 1, -39)
Sidebar.Position = UDim2.new(0, 0, 0, 39)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
BackgroundsToUpdate[Sidebar] = true

local SidebarUIList = Instance.new("UIListLayout")
SidebarUIList.Padding = UDim.new(0, 4)
SidebarUIList.Parent = Sidebar

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -120, 1, -44)
ContentFrame.Position = UDim2.new(0, 120, 0, 41)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Менеджер вкладок
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
        applyThemeGradient(TabBtn)
    else
        TabBtn.TextColor3 = Color3.fromRGB(130, 130, 130)
    end
    
    Tabs[name] = {Btn = TabBtn, Content = TabContent}
    
    TabBtn.MouseButton1Click:Connect(function()
        for tName, tData in pairs(Tabs) do
            tData.Content.Visible = (tName == name)
            GradientsToUpdate[tData.Btn] = nil
            local oldGrad = tData.Btn:FindFirstChild("ThemeGradient")
            if oldGrad then oldGrad:Destroy() end
            
            if tName == name then
                tData.Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                applyThemeGradient(tData.Btn)
            else
                tData.Btn.TextColor3 = Color3.fromRGB(130, 130, 130)
            end
        end
        ActiveTab = name
    end)
    return TabContent
end

local CheatTab = createTab("CHEAT")
local SettingsTab = createTab("SETTINGS")

-- Сворачивание
MinimizeBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    if IsMinimized then
        MainFrame:TweenSize(UDim2.new(0, BASE_WIDTH / CurrentScale, 0, 39), "Out", "Quad", 0.2, true)
        Sidebar.Visible = false
        ContentFrame.Visible = false
        MinimizeBtn.Text = "🗖"
    else
        MainFrame:TweenSize(UDim2.new(0, BASE_WIDTH / CurrentScale, 0, BASE_HEIGHT / CurrentScale), "Out", "Quad", 0.2, true)
        Sidebar.Visible = true
        ContentFrame.Visible = true
        MinimizeBtn.Text = "—"
    end
end)

--==========================================================================================--
--                                      ВКЛАДКА НАСТРОЕК                                    --
--==========================================================================================--
local SettingsLayout = Instance.new("UIListLayout")
SettingsLayout.Padding = UDim.new(0, 8)
SettingsLayout.Parent = SettingsTab

-- Поле изменения размера хаба (Твоя формула: Новая Сила = База / Коэффициент)
local ScaleRow = Instance.new("Frame")
ScaleRow.Size = UDim2.new(1, 0, 0, 35)
ScaleRow.BackgroundTransparency = 1
ScaleRow.Parent = SettingsTab

local ScaleLabel = Instance.new("TextLabel")
ScaleLabel.Size = UDim2.new(0, 130, 1, 0)
ScaleLabel.Text = "HUB SCALE DIVIDER:"
ScaleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
ScaleLabel.TextSize = 11
ScaleLabel.Font = Enum.Font.GothamBold
ScaleLabel.BackgroundTransparency = 1
ScaleLabel.TextXAlignment = Enum.TextXAlignment.Left
ScaleLabel.Parent = ScaleRow

local ScaleInput = Instance.new("TextBox")
ScaleInput.Size = UDim2.new(1, -140, 0, 28)
ScaleInput.Position = UDim2.new(0, 130, 0, 3)
ScaleInput.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ScaleInput.Text = "1"
ScaleInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ScaleInput.TextSize = 12
ScaleInput.Font = Enum.Font.GothamBold
ScaleInput.Parent = ScaleRow
createCorner(ScaleInput, 4)

ScaleInput.FocusLost:Connect(function(enterPressed)
    local val = tonumber(ScaleInput.Text)
    if val and val > 0 then
        CurrentScale = val
        local targetW = BASE_WIDTH / CurrentScale
        local targetH = BASE_HEIGHT / CurrentScale
        MainFrame.Size = UDim2.new(0, targetW, 0, targetH)
        MainFrame.Position = UDim2.new(0.5, -targetW/2, 0.5, -targetH/2)
    else
        ScaleInput.Text = tostring(CurrentScale)
    end
end)

-- Переключатели тем
local ThemeLabel = Instance.new("TextLabel")
ThemeLabel.Size = UDim2.new(1, 0, 0, 20)
ThemeLabel.Text = "SELECT STYLE THEME:"
ThemeLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
ThemeLabel.TextSize = 11
ThemeLabel.Font = Enum.Font.GothamBold
ThemeLabel.BackgroundTransparency = 1
ThemeLabel.TextXAlignment = Enum.TextXAlignment.Left
ThemeLabel.Parent = SettingsTab

local ThemeButtonsRow = Instance.new("Frame")
ThemeButtonsRow.Size = UDim2.new(1, 0, 0, 35)
ThemeButtonsRow.BackgroundTransparency = 1
ThemeButtonsRow.Parent = SettingsTab

local LuxThemeBtn = Instance.new("TextButton")
LuxThemeBtn.Size = UDim2.new(0.5, -4, 1, 0)
LuxThemeBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LuxThemeBtn.Text = "LUXURY STYLING"
LuxThemeBtn.TextColor3 = Color3.fromRGB(255, 140, 0)
LuxThemeBtn.TextSize = 11
LuxThemeBtn.Font = Enum.Font.GothamBold
LuxThemeBtn.Parent = ThemeButtonsRow
createCorner(LuxThemeBtn, 4)

local HackThemeBtn = Instance.new("TextButton")
HackThemeBtn.Size = UDim2.new(0.5, -4, 1, 0)
HackThemeBtn.Position = UDim2.new(0.5, 4, 0, 0)
HackThemeBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
HackThemeBtn.Text = "HACKER GREEN"
HackThemeBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
HackThemeBtn.TextSize = 11
HackThemeBtn.Font = Enum.Font.GothamBold
HackThemeBtn.Parent = ThemeButtonsRow
createCorner(HackThemeBtn, 4)

LuxThemeBtn.MouseButton1Click:Connect(function()
    CurrentTheme = "Luxury"
    updateThemeUI()
end)

HackThemeBtn.MouseButton1Click:Connect(function()
    CurrentTheme = "Hacker"
    updateThemeUI()
end)

--==========================================================================================--
--                                   ВКЛАДКА CHEAT (UI ПАНЕЛИ)                              --
--==========================================================================================--
local PlayerListFrame = Instance.new("ScrollingFrame")
PlayerListFrame.Name = "PlayerListFrame"
PlayerListFrame.Size = UDim2.new(0, 165, 1, 0)
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerListFrame.ScrollBarThickness = 3
PlayerListFrame.Parent = CheatTab
createCorner(PlayerListFrame, 4)
BackgroundsToUpdate[PlayerListFrame] = true

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 4)
ListLayout.Parent = PlayerListFrame

local ControlPanel = Instance.new("Frame")
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
PosStatus.Size = UDim2.new(1, 0, 0, 18)
PosStatus.Text = "TP: Current Pos"
PosStatus.TextColor3 = Color3.fromRGB(120, 120, 120)
PosStatus.TextSize = 11
PosStatus.Font = Enum.Font.Gotham
PosStatus.BackgroundTransparency = 1
PosStatus.Parent = ControlPanel
TextToUpdate[PosStatus] = "Status"

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
    for _, child in ipairs(PlayerListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, 0, 0, 32)
            pBtn.BackgroundColor3 = TargetPlayers[player] and Color3.fromRGB(25, 12, 5) or Color3.fromRGB(14, 14, 14)
            pBtn.Text = "  " .. player.DisplayName
            pBtn.TextColor3 = TargetPlayers[player] and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(200, 200, 200)
            pBtn.TextSize = 12
            pBtn.Font = Enum.Font.GothamBold
            pBtn.TextXAlignment = Enum.TextXAlignment.Left
            pBtn.BorderSizePixel = 0
            pBtn.Parent = PlayerListFrame
            createCorner(pBtn, 4)
            
            local chk = Instance.new("TextLabel")
            chk.Size = UDim2.new(0, 25, 1, 0)
            chk.Position = UDim2.new(1, -30, 0, 0)
            chk.Text = TargetPlayers[player] and "✓" or "○"
            chk.TextColor3 = TargetPlayers[player] and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(70, 70, 70)
            chk.Font = Enum.Font.GothamBold
            chk.TextSize = 13
            chk.BackgroundTransparency = 1
            chk.Parent = pBtn
            
            pBtn.MouseButton1Click:Connect(function()
                TargetPlayers[player] = not TargetPlayers[player]
                
                if CurrentTheme == "Luxury" then
                    pBtn.BackgroundColor3 = TargetPlayers[player] and Color3.fromRGB(25, 12, 5) or Color3.fromRGB(14, 14, 14)
                    pBtn.TextColor3 = TargetPlayers[player] and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(200, 200, 200)
                    chk.TextColor3 = TargetPlayers[player] and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(70, 70, 70)
                else
                    pBtn.BackgroundColor3 = TargetPlayers[player] and Color3.fromRGB(5, 30, 5) or Color3.fromRGB(14, 14, 14)
                    pBtn.TextColor3 = TargetPlayers[player] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 200, 200)
                    chk.TextColor3 = TargetPlayers[player] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(70, 70, 70)
                end
                chk.Text = TargetPlayers[player] and "✓" or "○"
            end)
        end
    end
    PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(function(player) TargetPlayers[player] = nil updatePlayerList() end)
updatePlayerList()

local allSelected = false
SelectAllBtn.MouseButton1Click:Connect(function()
    allSelected = not allSelected
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then TargetPlayers[player] = allSelected end
    end
    SelectAllBtn.Text = allSelected and "DESELECT ALL" or "SELECT ALL"
    updatePlayerList()
end)

SetTpBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        SavedTpPosition = hrp.Position
        PosStatus.Text = "TP: Custom Set!"
        PosStatus.TextColor3 = (CurrentTheme == "Luxury") and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(0, 255, 0)
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
    
    if seatType == "ToolSeat" and #targets > 1 then
        ActionBtn.Text = "CHOOSE 1 PERSON!"
        task.wait(1.5) ActionBtn.Text = "TP THESE PEOPLE"
        return
    end
    
    local finalTpPos = SavedTpPosition
    if not finalTpPos then
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHrp then finalTpPos = myHrp.Position end
    end
    if not finalTpPos then return end
    
    ActionBtn.Text = "KIDNAPPING..."
    
    for _, vPlayer in ipairs(targets) do
        local targetChar = vPlayer.Character
        local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
        local myChar = LocalPlayer.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        
        if targetHrp and myHrp then
            if seatType == "Vehicle" then
                local startTime = tick()
                while seat.Occupant == nil and (tick() - startTime) < 5 do
                    RunService.Heartbeat:Wait()
                    local offset = seat.Position - myHrp.Position
                    myHrp.CFrame = CFrame.new(targetHrp.Position + Vector3.new(0, 2, 0) - offset)
                end
            else
                local startTime = tick()
                local angle = 0
                local radius = 4
                while seat.Occupant == nil and (tick() - startTime) < 6 do
                    RunService.Heartbeat:Wait()
                    angle = angle + 0.6
                    local posX = targetHrp.Position.X + math.cos(angle) * radius
                    local posZ = targetHrp.Position.Z + math.sin(angle) * radius
                    myHrp.CFrame = CFrame.new(Vector3.new(posX, targetHrp.Position.Y + 1, posZ), targetHrp.Position)
                end
            end
            
            if seat.Occupant then
                task.wait(0.1)
                myHrp.CFrame = CFrame.new(finalTpPos + Vector3.new(0, 3, 0))
                task.wait(0.2)
                
                local tool = myChar:FindFirstChildOfClass("Tool")
                if tool then
                    tool.Parent = LocalPlayer.Backpack
                elseif seatType == "Vehicle" then
                    local oldParent = seat.Parent
                    seat.Parent = nil
                    task.wait(0.1)
                    seat.Parent = oldParent
                end
                task.wait(0.3)
            end
        end
    end
    
    ActionBtn.Text = "TP THESE PEOPLE"
    for k in pairs(TargetPlayers) do TargetPlayers[k] = false end
    allSelected = false
    SelectAllBtn.Text = "SELECT ALL"
    updatePlayerList()
end)
