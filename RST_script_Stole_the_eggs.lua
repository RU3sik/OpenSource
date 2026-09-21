-- [[ RST happ - Tornado Hub Style for Mobile ]] --
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild("RST_Happ_Menu") then
    CoreGui["RST_Happ_Menu"]:Destroy()
end

-- === АНТИ-БАН (ВКЛЮЧЕН ВСЕГДА) ===
local rawmetatable = getrawmetatable(game)
local oldindex = rawmetatable.__index
local oldnamecall = rawmetatable.__namecall
setreadonly(rawmetatable, false)

rawmetatable.__index = newcclosure(function(self, key)
    if not checkcaller() and self == LocalPlayer.Character and (key == "WalkSpeed" or key == "JumpPower") then
        return key == "WalkSpeed" and 16 or 50
    end
    return oldindex(self, key)
end)

rawmetatable.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if not checkcaller() and (method == "Kick" or method == "kick") then
        return nil
    end
    return oldnamecall(self, ...)
end)
setreadonly(rawmetatable, true)

-- === СОЗДАНИЕ ИНТЕРФЕЙСА ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RST_Happ_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 330, 0, 440)
MainFrame.Position = UDim2.new(0.5, -165, 0.5, -220)
MainFrame.BackgroundColor3 = Color3.fromHex("#121212")
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2.5
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Parent = MainFrame

-- Шапка меню
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleContainer = Instance.new("Frame")
TitleContainer.Size = UDim2.new(1, 0, 1, 0)
TitleContainer.BackgroundTransparency = 1
TitleContainer.Parent = Header

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout.Parent = TitleContainer

local T_Rst = Instance.new("TextLabel")
T_Rst.Text = "RST "
T_Rst.Size = UDim2.new(0, 45, 1, 0)
T_Rst.BackgroundTransparency = 1
T_Rst.Font = Enum.Font.GothamBold
T_Rst.TextSize = 18
T_Rst.TextColor3 = Color3.fromRGB(255, 255, 255)
T_Rst.Parent = TitleContainer

local T_Happ = Instance.new("TextLabel")
T_Happ.Text = "happ"
T_Happ.Size = UDim2.new(0, 50, 1, 0)
T_Happ.BackgroundTransparency = 1
T_Happ.Font = Enum.Font.GothamBold
T_Happ.TextSize = 18
T_Happ.TextColor3 = Color3.fromRGB(0, 0, 255)
T_Happ.Parent = TitleContainer

-- Скролл-контейнер
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -60)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 600)
Container.ScrollBarThickness = 2
Container.Parent = MainFrame

local ContainerLayout = Instance.new("UIListLayout")
ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContainerLayout.Padding = UDim.new(0, 10)
ContainerLayout.Parent = Container

-- Анимации Неона
task.spawn(function()
    while true do
        local t1 = TweenService:Create(UIStroke, TweenInfo.new(2, Enum.EasingStyle.Linear), {Color = Color3.fromRGB(0, 0, 255)})
        t1:Play() t1.Completed:Wait()
        local t2 = TweenService:Create(UIStroke, TweenInfo.new(2, Enum.EasingStyle.Linear), {Color = Color3.fromRGB(255, 0, 0)})
        t2:Play() t2.Completed:Wait()
        local t3 = TweenService:Create(UIStroke, TweenInfo.new(2, Enum.EasingStyle.Linear), {Color = Color3.fromRGB(255, 255, 255)})
        t3:Play() t3.Completed:Wait()
    end
end)

task.spawn(function()
    while true do
        local t1 = TweenService:Create(T_Happ, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(255, 0, 0)})
        t1:Play() t1.Completed:Wait()
        local t2 = TweenService:Create(T_Happ, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(0, 0, 255)})
        t2:Play() t2.Completed:Wait()
    end
end)

-- Сенсорное перемещение (Touch)
local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- === КОНСТРУКТОРЫ ЭЛЕМЕНТОВ ===
local UI = {}

function UI:CreateToggle(text, callback)
    local Enabled = false
    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(1, 0, 0, 45)
    Toggle.BackgroundColor3 = Color3.fromHex("#1c1c1c")
    Toggle.Text = ""
    Toggle.Parent = Container

    local TCorn = Instance.new("UICorner")
    TCorn.CornerRadius = UDim.new(0, 6)
    TCorn.Parent = Toggle

    local Label = Instance.new("TextLabel")
    Label.Text = text
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamMedium
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Toggle

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 16, 0, 16)
    Indicator.Position = UDim2.new(1, -26, 0.5, -8)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Indicator.Parent = Toggle

    local ICorn = Instance.new("UICorner")
    ICorn.CornerRadius = UDim.new(1, 0)
    ICorn.Parent = Indicator

    Toggle.MouseButton1Click:Connect(function()
        Enabled = not Enabled
        Indicator.BackgroundColor3 = Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        callback(Enabled)
    end)
    return Toggle
end

function UI:CreateButton(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.Text = text
    Button.TextColor3 = Color3.fromHex("#121212")
    Button.TextSize = 13
    Button.Parent = Container

    local BCorn = Instance.new("UICorner")
    BCorn.CornerRadius = UDim.new(0, 6)
    BCorn.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
    return Button
end

-- === ЛОГИКА ФУНКЦИЙ ===
local State = { Speed = false, Fly = false, AutoBring = false }
local SpeedVal = 50
local FlySpeed = 40
local CurrentEggIndex = 1

-- Вспомогательная функция для ТП на свою базу
local function teleportToBase()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local myTeamColor = LocalPlayer.TeamColor
    local spawnPart = nil
    
    -- Динамический поиск спавна по TeamColor или названию команды
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") and obj.TeamColor == myTeamColor then
            spawnPart = obj
            break
        elseif obj:IsA("BasePart") and string.find(string.lower(obj.Name), "spawn") and string.find(string.lower(obj.Name), string.lower(tostring(LocalPlayer.Team))) then
            spawnPart = obj
            break
        end
    end
    
    -- Если стандартные методы не нашли, ищем любую точку с именем твоей команды
    if not spawnPart then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and string.find(string.lower(obj.Name), string.lower(tostring(LocalPlayer.Team))) then
                spawnPart = obj
                break
            end
        end
    end
    
    if spawnPart then
        char.HumanoidRootPart.CFrame = spawnPart.CFrame + Vector3.new(0, 4, 0)
    end
end

-- Перемещение (Speedhack)
UI:CreateToggle("Включить Спидхак", function(val)
    State.Speed = val
end)

RunService.Stepped:Connect(function()
    if State.Speed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 then
            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + (hum.MoveDirection * (SpeedVal / 100))
        end
    end
end)

-- Полет
UI:CreateToggle("Включить Полет", function(val)
    State.Fly = val
    if not val and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
    end
end)

RunService.RenderStepped:Connect(function()
    if State.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local camCFrame = workspace.CurrentCamera.CFrame
        hrp.Velocity = Vector3.new(0, 0.1, 0)
        
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if hum and hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (camCFrame.LookVector * (FlySpeed / 50) * hum.MoveDirection.Z * -1) + (camCFrame.RightVector * (FlySpeed / 50) * hum.MoveDirection.X)
        end
    end
end)

-- Бессмертие
UI:CreateButton("Активировать Бессмертие", function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local clone = hum:Clone()
            clone.Parent = char
            char.PrimaryPart = char:FindFirstChild("HumanoidRootPart")
            hum:Destroy()
            workspace.CurrentCamera.CameraSubject = clone
        end
    end
end)

-- Поиск яиц и ТП к ним
UI:CreateButton("Найти яйцо и ТП к нему", function()
    local eggs = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "egg") then
            table.insert(eggs, obj)
        elseif obj:IsA("Model") and string.find(string.lower(obj.Name), "egg") and obj.PrimaryPart then
            table.insert(eggs, obj.PrimaryPart)
        end
    end

    if #eggs > 0 then
        if CurrentEggIndex > #eggs then 
            CurrentEggIndex = 1 
        end
        
        local targetEgg = eggs[CurrentEggIndex]
        if targetEgg and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetEgg.CFrame + Vector3.new(0, 3, 0)
            CurrentEggIndex = CurrentEggIndex + 1
        end
    end
end)

-- Авто-Сдача при подборе
UI:CreateToggle("Авто-Сдача на Базу", function(val)
    State.AutoBring = val
end)

-- Цикл проверки наличия яйца в руках
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoBring and LocalPlayer.Character then
            local hasEgg = false
            
            -- Проверяем, прикреплено ли яйцо к персонажу или лежит в бэкпаке как тул
            for _, child in pairs(LocalPlayer.Character:GetChildren()) do
                if string.find(string.lower(child.Name), "egg") then
                    hasEgg = true
                    break
                end
            end
            
            if not hasEgg and LocalPlayer:FindFirstChild("Backpack") then
                for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if string.find(string.lower(tool.Name), "egg") then
                        hasEgg = true
                        break
                    end
                end
            end
            
            -- Если яйцо найдено — мгновенный возврат домой
            if hasEgg then
                teleportToBase()
            end
        end
    end
end)

UI:CreateButton("Скрыть Чит-Меню", function()
    ScreenGui:Destroy()
end)
