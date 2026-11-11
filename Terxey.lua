-- [[ Murder Mystery 2 - Simple & Clean GUI ]] --
-- Compatible con ejecutores de PC y Móvil --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Destruir GUI anterior si ya existe
if CoreGui:FindFirstChild("MM2SimpleGUI") then
    CoreGui.MM2SimpleGUI:Destroy()
end

-- Variables de Estado
local autofarmEnabled = false
local farmSpeed = 16 -- Velocidad por defecto
local noclipEnabled = false
local autoGrabGun = false

-- Creación de la Interfaz (GUI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2SimpleGUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -175)
MainFrame.Size = UDim2.new(0, 350, 0, 340)
MainFrame.Active = true
MainFrame.Draggable = true -- Permite mover el panel por la pantalla

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "MM2 Simple Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Contenedor de Opciones
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = MainFrame
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollingFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 1.4, 0)
ScrollingFrame.ScrollBarThickness = 4

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- Función auxiliar para crear botones de activación
function createToggle(name, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = ScrollingFrame
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Font = Enum.Font.GothamMedium
    btn.Text = name .. ": [OFF]"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 14
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            btn.Text = name .. ": [ON]"
            btn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.Text = name .. ": [OFF]"
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        callback(active)
    end)
end

-- Función auxiliar para botones de acción única
function createButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = ScrollingFrame
    btn.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Font = Enum.Font.GothamMedium
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
end

-- 1. SECCIÓN AUTOFARM
createToggle("Autofarm Monedas", function(state)
    autofarmEnabled = state
end)

-- Velocidad de Autofarm
local speedBox = Instance.new("TextBox")
speedBox.Parent = ScrollingFrame
speedBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
speedBox.Size = UDim2.new(1, 0, 0, 35)
speedBox.Font = Enum.Font.GothamMedium
speedBox.PlaceholderText = "Velocidad de vuelo (Ej: 16 o 25)"
speedBox.Text = "Velocidad: 16"
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.TextSize = 14

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 6)
speedCorner.Parent = speedBox

speedBox.FocusLost:Connect(function()
    local num = tonumber(speedBox.Text:match("%d+"))
    if num then
        farmSpeed = num
        speedBox.Text = "Velocidad: " .. farmSpeed
    else
        speedBox.Text = "Velocidad: " .. farmSpeed
    end
end)

-- 2. SECCIÓN MOVIMIENTO (NOCLIP / BAJO SUELO)
createToggle("Noclip (Traspasar Paredes / Suelo)", function(state)
    noclipEnabled = state
end)

-- 3. SECCIÓN SHERIFF
createToggle("Auto-Recoger Arma (Sheriff)", function(state)
    autoGrabGun = state
end)

-- 4. SECCIÓN MURDERER
createButton("Kill All (Si eres Murderer)", function()
    pcall(function()
        local char = LocalPlayer.Character
        local knife = LocalPlayer.Backpack:FindFirstChild("Knife") or (char and char:FindFirstChild("Knife"))
        if knife then
            if char:FindFirstChild("Humanoid") then
                char.Humanoid:EquipTool(knife)
            end
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    knife.Parent = char
                    knife:Activate()
                    task.wait(0.1)
                    char.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
                end
            end
        end
    end)
end)

createButton("Llevar al Murderer al Vacío", function()
    pcall(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Tool") then
                if player.Character.Tool:FindFirstChild("Knife") and player.Character:FindFirstChild("HumanoidRootPart") then
                    local root = LocalPlayer.Character.HumanoidRootPart
                    local targetRoot = player.Character.HumanoidRootPart
                    local oldPos = root.CFrame
                    root.CFrame = targetRoot.CFrame
                    task.wait(0.2)
                    root.CFrame = CFrame.new(0, -500, 0) -- Lo manda debajo del mapa/suelo
                    task.wait(0.5)
                    root.CFrame = oldPos
                end
            end
        end
    end)
end)

-- BUCLES DE FUNCIONAMIENTO (LOGICA PRINCIPAL)

-- Noclip Loop
RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Autofarm genérico por eventos de mapa (detecta cualquier moneda de cualquier evento: Navidad, Halloween, Verano, Normal)
task.spawn(function()
    while true do
        task.wait(0.5)
        if autofarmEnabled then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    -- Busca contenedores comunes de monedas en el mapa
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if not autofarmEnabled then break end
                        if obj.Name == "CoinVisual" or obj.Name == "Coin" or obj.Name:match("Coin") then
                            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                            if part then
                                -- Moverse de forma fluida hacia la moneda (incluso por debajo del suelo)
                                local tweenService = game:GetService("TweenService")
                                local distance = (root.Position - part.Position).Magnitude
                                local timeToTravel = distance / farmSpeed
                                
                                local info = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
                                local tween = tweenService:Create(root, info, {CFrame = part.CFrame + Vector3.new(0, 2, 0)})
                                tween:Play()
                                
                                local connection
                                connection = tween.Completed:Connect(function()
                                    connection:Disconnect()
                                end)
                                
                                while tween.PlaybackState == Enum.PlaybackState.Playing and autofarmEnabled do
                                    task.wait(0.1)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Recoger Pistola del Sheriff caído
task.spawn(function()
    while true do
        task.wait(1)
        if autoGrabGun then
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj.Name == "GunDrop" and obj:IsA("BasePart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame
                    end
                end
            end)
        end
    end
end)
