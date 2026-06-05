--==========================================================================================--
--                                  BLACK-HAT HACKER HUB                                    --
--                 Optimized for Delta Executor | UI Style: Dark & Darker                  --
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

-- Очистка старых UI перед перезапуском
local oldUi = game:GetService("CoreGui"):FindFirstChild("HackerHub") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("HackerHub")
if oldUi then oldUi:Destroy() end

-- Создание ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HackerHub"
ScreenGui.ResetOnSpawn = false
pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

--==========================================================================================--
--                                        UI UTILS                                          --
--==========================================================================================--
local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
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
--                                      MAIN FRAMES                                         --
--==========================================================================================--
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 340)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
createCorner(MainFrame, 6)

-- Линия сверху (Хакерский декор)
local TopLine = Instance.new("Frame")
TopLine.Size = UDim2.new(1, 0, 0, 3)
TopLine.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
TopLine.BorderSizePixel = 0
TopLine.Parent = MainFrame
createCorner(TopLine, 3)

-- Полоса сворачивания (Топбар)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.Position = UDim2.new(0, 0, 0, 3)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame
makeDraggable(TopBar, MainFrame)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "SYSTEM_OVERRIDE // HACK.RAR"
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.TextSize = 14
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = TopBar

-- Кнопки управления окном
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 25)
CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.Code
CloseBtn.BackgroundTransparency = 1
CloseBtn.Parent = TopBar
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -65, 0, 2)
MinimizeBtn.Text = "_"
MinimizeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.Code
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Parent = TopBar

-- Панель Вкладок (Слева)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -33)
Sidebar.Position = UDim2.new(0, 0, 0, 33)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarUIList = Instance.new("UIListLayout")
SidebarUIList.Padding = UDim.new(0, 5)
SidebarUIList.Parent = Sidebar

-- Контейнер для контента
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -125, 1, -38)
ContentFrame.Position = UDim2.new(0, 125, 0, 35)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Переключаемые вкладки
local Tabs = {}
local function createTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.Text = "  " .. name
    TabBtn.TextColor3 = name == "CHEAT" and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(150, 150, 150)
    TabBtn.TextSize = 12
    TabBtn.Font = Enum.Font.Code
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.BackgroundTransparency = 1
    TabBtn.Parent = Sidebar
    
    local TabContent = Instance.new("Frame")
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = (name == "CHEAT")
    TabContent.Parent = ContentFrame
    
    Tabs[name] = {Btn = TabBtn, Content = TabContent}
    
    TabBtn.MouseButton1Click:Connect(function()
        for tName, tData in pairs(Tabs) do
            tData.Content.Visible = (tName == name)
            tData.Btn.TextColor3 = (tName == name) and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(150, 150, 150)
        end
        ActiveTab = name
    end)
    return TabContent
end

local CheatTab = createTab("CHEAT")
local SettingsTab = createTab("SETTINGS")

-- Сворачивание в полоску
MinimizeBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    if IsMinimized then
        MainFrame:TweenSize(UDim2.new(0, 520, 0, 33), "Out", "Quad", 0.2, true)
        Sidebar.Visible = false
        ContentFrame.Visible = false
        MinimizeBtn.Text = "O"
    else
        MainFrame:TweenSize(UDim2.new(0, 520, 0, 340), "Out", "Quad", 0.2, true)
        Sidebar.Visible = true
        ContentFrame.Visible = true
        MinimizeBtn.Text = "_"
    end
end)

--==========================================================================================--
--                                   SETTINGS TAB IMPLEMENTATION                            --
--==========================================================================================--
local SettingsLayout = Instance.new("UIListLayout")
SettingsLayout.Padding = UDim.new(0, 8)
SettingsLayout.Parent = SettingsTab

local function createSettingInfo(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 25)
    lbl.Text = " > " .. text
    lbl.TextColor3 = Color3.fromRGB(120, 120, 120)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1
    lbl.Parent = SettingsTab
end

createSettingInfo("DEVICE: " .. tostring(UserInputService:GetPlatform():gsub("Enum.Platform.", "")))
createSettingInfo("RESOLUTION: FIXED HACKER RATIO")
createSettingInfo("STATUS: INJECTION STABLE")

--==========================================================================================--
--                                    CHEAT TAB: UI ELEMENTS                                --
--==========================================================================================--
-- Скролл-список игроков
local PlayerListFrame = Instance.new("ScrollingFrame")
PlayerListFrame.Size = UDim2.new(0, 220, 1, -10)
PlayerListFrame.Position = UDim2.new(0, 0, 0, 5)
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerListFrame.ScrollBarThickness = 4
PlayerListFrame.Parent = CheatTab
createCorner(PlayerListFrame, 4)

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 3)
ListLayout.Parent = PlayerListFrame

-- Панель управления справа
local ControlPanel = Instance.new("Frame")
ControlPanel.Size = UDim2.new(1, -230, 1, -10)
ControlPanel.Position = UDim2.new(0, 230, 0, 5)
ControlPanel.BackgroundTransparency = 1
ControlPanel.Parent = CheatTab

local ControlLayout = Instance.new("UIListLayout")
ControlLayout.Padding = UDim.new(0, 8)
ControlLayout.Parent = ControlPanel

-- Правые кнопки управления
local function createHackButton(text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    btn.Text = text
    btn.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    btn.TextSize = 12
    btn.Font = Enum.Font.Code
    btn.BorderSizePixel = 0
    btn.Parent = ControlPanel
    createCorner(btn, 4)
    
    -- Простой ховер-эффект
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(18, 18, 18) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(12, 12, 12) end)
    
    return btn
end

local SelectAllBtn = createHackButton("[ SELECT ALL TARGETS ]", Color3.fromRGB(0, 180, 255))
local SetTpBtn = createHackButton("[ SET CUSTOM TP POINT ]", Color3.fromRGB(220, 220, 0))
local ActionBtn = createHackButton("TP THESE PEOPLE\n(pls equip seat tool)", Color3.fromRGB(0, 255, 100))

-- Метка статуса выбранной позиции
local PosStatus = Instance.new("TextLabel")
PosStatus.Size = UDim2.new(1, 0, 0, 20)
PosStatus.Text = "TP Point: Default (Your Pos)"
PosStatus.TextColor3 = Color3.fromRGB(100, 100, 100)
PosStatus.TextSize = 11
PosStatus.Font = Enum.Font.Code
PosStatus.BackgroundTransparency = 1
PosStatus.Parent = ControlPanel

--==========================================================================================--
--                                   LOGIC & FUNCTIONALITY                                  --
--==========================================================================================--

-- Функция получения активного сиденья у игрока (в руках или машина)
local function getSeatContext()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    -- Ищем инструмент в руках с сиденьем внутри
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local seat = tool:FindFirstChildOfClass("Seat") or tool:FindFirstChildOfClass("VehicleSeat")
        if seat then
            return seat, "ToolSeat"
        end
    end
    
    -- Проверяем, сидит ли игрок уже в машине (крупная модель)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.SeatPart then
        local seat = humanoid.SeatPart
        if seat:IsA("VehicleSeat") or #seat.Parent:GetDescendants() > 30 then
            return seat, "Vehicle"
        else
            return seat, "ToolSeat"
        end
    end
    
    return nil
end

-- Обновление списка игроков
local function updatePlayerList()
    for _, child in ipairs(PlayerListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, 0, 0, 28)
            pBtn.BackgroundColor3 = TargetPlayers[player] and Color3.fromRGB(20, 5, 5) or Color3.fromRGB(12, 12, 12)
            pBtn.Text = "  " .. player.DisplayName .. " (@" .. player.Name .. ")"
            pBtn.TextColor3 = TargetPlayers[player] and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(180, 180, 180)
            pBtn.TextSize = 11
            pBtn.Font = Enum.Font.Code
            pBtn.TextXAlignment = Enum.TextXAlignment.Left
            pBtn.BorderSizePixel = 0
            pBtn.Parent = PlayerListFrame
            createCorner(pBtn, 3)
            
            -- Галочка выбора
            local chk = Instance.new("TextLabel")
            chk.Size = UDim2.new(0, 20, 1, 0)
            chk.Position = UDim2.new(1, -25, 0, 0)
            chk.Text = TargetPlayers[player] and "[X]" or "[ ]"
            chk.TextColor3 = TargetPlayers[player] and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(80, 80, 80)
            chk.Font = Enum.Font.Code
            chk.TextSize = 11
            chk.BackgroundTransparency = 1
            chk.Parent = pBtn
            
            pBtn.MouseButton1Click:Connect(function()
                TargetPlayers[player] = not TargetPlayers[player]
                pBtn.BackgroundColor3 = TargetPlayers[player] and Color3.fromRGB(20, 5, 5) or Color3.fromRGB(12, 12, 12)
                pBtn.TextColor3 = TargetPlayers[player] and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(180, 180, 180)
                chk.Text = TargetPlayers[player] and "[X]" or "[ ]"
                chk.TextColor3 = TargetPlayers[player] and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(80, 80, 80)
            end)
        end
    end
    PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(function(player)
    TargetPlayers[player] = nil
    updatePlayerList()
end)
updatePlayerList()

-- Выбрать всех игроков
local allSelected = false
SelectAllBtn.MouseButton1Click:Connect(function()
    allSelected = not allSelected
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            TargetPlayers[player] = allSelected
        end
    end
    SelectAllBtn.Text = allSelected and "[ DESELECT ALL ]" or "[ SELECT ALL TARGETS ]"
    updatePlayerList()
end)

-- Задать кастомную точку для ТП
SetTpBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        SavedTpPosition = hrp.Position
        PosStatus.Text = "TP Point: Custom Lock Set!"
        PosStatus.TextColor3 = Color3.fromRGB(220, 220, 0)
    end
end)

--==========================================================================================--
--                                     THE KIDNAP EXPLOIT                                   --
--==========================================================================================--
ActionBtn.MouseButton1Click:Connect(function()
    local seat, seatType = getSeatContext()
    if not seat then
        ActionBtn.Text = "ERROR: NO SEAT FOUND!"
        task.wait(1.5)
        ActionBtn.Text = "TP THESE PEOPLE\n(pls equip seat tool)"
        return
    end
    
    -- Считаем выбранных игроков
    local targets = {}
    for player, selected in pairs(TargetPlayers) do
        if selected and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(targets, player)
        end
    end
    
    if #targets == 0 then
        ActionBtn.Text = "ERROR: NO TARGETS CHOSEN!"
        task.wait(1.5)
        ActionBtn.Text = "TP THESE PEOPLE\n(pls equip seat tool)"
        return
    end
    
    -- Если сиденье одиночное (коляска), а целей много — блокируем
    if seatType == "ToolSeat" and #targets > 1 then
        ActionBtn.Text = "ERROR: CHOOSE 1 PERSON FOR TOOL!"
        task.wait(2)
        ActionBtn.Text = "TP THESE PEOPLE\n(pls equip seat tool)"
        return
    end
    
    -- Фиксация финишной точки ТП
    local finalTpPos = SavedTpPosition
    if not finalTpPos then
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHrp then finalTpPos = myHrp.Position end
    end
    
    if not finalTpPos then return end
    
    ActionBtn.Text = "EXECUTING KIDNAP..."
    
    -- Главный цикл похищения
    for _, vPlayer in ipairs(targets) do
        local targetChar = vPlayer.Character
        local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
        local myChar = LocalPlayer.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        
        if targetHrp and myHrp then
            -- Механика для МАШИНЫ (подлет сиденьем прямо к цели)
            if seatType == "Vehicle" then
                local startTime = tick()
                while seat.Occupant == nil and (tick() - startTime) < 5 do
                    RunService.Heartbeat:Wait()
                    -- Рассчитываем позицию сиденья автомобиля прямо на хитбокс цели
                    local offset = seat.Position - myHrp.Position
                    myHrp.CFrame = CFrame.new(targetHrp.Position + Vector3.new(0, 2, 0) - offset)
                end
                
            -- Механика для КОЛЯСКИ / ИНСТРУМЕНТА (Орбитальное бешеное кручение чуть дальше)
            else
                local startTime = tick()
                local angle = 0
                local radius = 4 -- Дистанция с учетом ручки коляски
                
                while seat.Occupant == nil and (tick() - startTime) < 6 do
                    RunService.Heartbeat:Wait()
                    angle = angle + 0.6 -- Бешеная угловая скорость
                    
                    -- Крутимся вокруг цели, направляя хитбокс сиденья на неё
                    local posX = targetHrp.Position.X + math.cos(angle) * radius
                    local posZ = targetHrp.Position.Z + math.sin(angle) * radius
                    myHrp.CFrame = CFrame.new(Vector3.new(posX, targetHrp.Position.Y + 1, posZ), targetHrp.Position)
                end
            end
            
            -- Если цель успешно села — увозим её в точку сброса
            if seat.Occupant then
                task.wait(0.1) -- Даем физике закрепиться
                myHrp.CFrame = CFrame.new(finalTpPos + Vector3.new(0, 3, 0))
                task.wait(0.2)
                
                -- Сброс игрока (Высадка через локальное удаление инструмента/сиденья)
                local tool = myChar:FindFirstChildOfClass("Tool")
                if tool then
                    tool.Parent = LocalPlayer.Backpack -- Убираем в инвентарь, ломая сиденье
                elseif seatType == "Vehicle" then
                    -- Если это машина, кратковременно отключаем сиденье, чтобы выбросить пассажиров
                    local oldParent = seat.Parent
                    seat.Parent = nil
                    task.wait(0.1)
                    seat.Parent = oldParent
                end
                task.wait(0.3)
            end
        end
    end
    
    -- Сброс настроек UI
    ActionBtn.Text = "TP THESE PEOPLE\n(pls equip seat tool)"
    for k in pairs(TargetPlayers) do TargetPlayers[k] = false end
    allSelected = false
    SelectAllBtn.Text = "[ SELECT ALL TARGETS ]"
    updatePlayerList()
end)
