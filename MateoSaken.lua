--[[
    ⚠️ ADVERTENCIA: Úsalo bajo tu propia responsabilidad
    📛 Nombre: MateoSaken
    ✨ Versión personal oficial
]]

getfenv().ADittoKey = "NOL_FRERKEY_THISISFOR" ---SPINNIN' ON IT

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local PlayerGui = lp:WaitForChild("PlayerGui")

local UI = {}
UI.main = Drawing.new("Square")
UI.header = Drawing.new("Square")
UI.title = Drawing.new("Text")
UI.keybinfo = Drawing.new("Text")
UI.active = "Autoblock"
UI.visible1 = true

UI.main.Color = Color3.fromHex("#12071c")
UI.main.Thickness = 2
UI.main.Filled = true
UI.main.Transparency = 0.2
UI.main.Position = Vector2.new(50, 50)
UI.main.Size = Vector2.new(280, 320)

UI.header.Color = Color3.fromHex("#2B0B42")
UI.header.Filled = true
UI.header.Position = Vector2.new(50, 50)
UI.header.Size = Vector2.new(280, 45)

UI.title.Text = "⚜️ MateoSaken"
UI.title.Color = Color3.fromHex("#c77dff")
UI.title.Size = 19
UI.title.Position = Vector2.new(70, 58)
UI.title.Outline = true

UI.keybinfo.Text = "Presiona R-Ctrl para abrir/cerrar"
UI.keybinfo.Color = Color3.fromHex("#9d4edd")
UI.keybinfo.Size = 12
UI.keybinfo.Position = Vector2.new(65, 340)

local Config = {
    AutoBlockAnim = true,
    AutoBlockAudio = true,
    RangoDeteccion = 15,
    ChequearDeFrente = true,
    ValorFrente = -0.3,
    RetrasoBloqueo = -0.014,
    EstaminaInfinita = true,
    VerAsesinos = true,
    VerSupervivientes = true,
    AntiCeguera = true,
    AntiSubespacio = true
}

local SonidosAtaque = {
    ["1022282740553929"] = true,
    ["919157970363905"] = true,
    ["772111347672087"] = true,
    ["117612992431895"] = true,
    ["919157970363905"] = true,
    ["130972335839797"] = true
}

local AnimacionesAtaque = {
    "131430497821198", "83829782357897", "126830014841198", "105458270463374",
    "127172483138092", "87259391926321", "106014898528300", "77124578197357"
}

local Bloquear, Cooldown = nil, nil
local function ActualizarReferencias()
    local MainUI = PlayerGui:FindFirstChild("MainUI")
    if MainUI then
        local Contenedor = MainUI:FindFirstChild("AbilityContainer")
        Bloquear = Contenedor and Contenedor:FindFirstChild("Block")
        Cooldown = Bloquear and Bloquear:FindFirstChild("CooldownTime")
    end
end

PlayerGui.ChildAdded:Connect(function(c)
    if c.Name == "MainUI" then task.wait(0.1) ActualizarReferencias() end
end)

lp.CharacterAdded:Connect(function() task.wait(0.5) ActualizarReferencias() end)

local function PresionarBloqueo()
    if not Bloquear then return end
    for _, c in ipairs(getconnections(Bloquear.MouseButton1Click)) do
        pcall(c.Fire, c)
    end
    task.spawn(function() Bloquear:Activate() end)
end

local function EstaDeFrente(miRaiz, raizObjetivo)
    if not Config.ChequearDeFrente then return true end
    local direccion = (miRaiz.Position - raizObjetivo.Position).Unit
    local producto = raizObjetivo.CFrame.LookVector:Dot(direccion)
    return producto > Config.ValorFrente
end

RunService.RenderStepped:Connect(function()
    if not Config.AutoBlockAnim or not lp.Character then return end
    local miRaiz = lp.Character:FindFirstChild("HumanoidRootPart")
    local Asesinos = workspace:FindFirstChild("Killers")
    if not miRaiz or not Asesinos then return end
    if Cooldown and Cooldown.Text ~= "" then return end

    for _, obj in ipairs(Asesinos:GetDescendants()) do
        local raiz = obj:FindFirstChild("HumanoidRootPart")
        local hum = obj:FindFirstChild("Humanoid")
        local anim = hum and hum:FindFirstChild("Animator")
        if raiz and anim and (raiz.Position - miRaiz.Position).Magnitude <= Config.RangoDeteccion then
            for _, trazo in ipairs(anim:GetPlayingAnimationTracks()) do
                local id = trazo.Animation.AnimationId:match("%d+")
                if id and table.find(AnimacionesAtaque, id) then
                    if EstaDeFrente(miRaiz, raiz) then
                        task.wait(Config.RetrasoBloqueo)
                        PresionarBloqueo()
                        return
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if not Config.EstaminaInfinita then continue end
        local ok, Modulo = pcall(function() return require(ReplicatedStorage.Systems.Character.Game.Sprinting) end)
        if ok and Modulo then
            Modulo.stamina = Modulo.maxstamina
        end
    end
end)

local Resaltados = {}
RunService.RenderStepped:Connect(function()
    for i=1, #Resaltados do if Resaltados[i] then Resaltados[i]:Destroy() end end
    table.clear(Resaltados)

    local Grupo = workspace:FindFirstChild("Players")
    if not Grupo then return end

    if Config.VerAsesinos and Grupo:FindFirstChild("Killers") then
        for _, k in ipairs(Grupo.Killers:GetChildren()) do
            if k:FindFirstChild("Humanoid") then
                local h = Instance.new("Highlight")
                h.OutlineColor = Color3.new(1, 0.2, 0.2)
                h.FillTransparency = 1
                h.Parent = k
                table.insert(Resaltados, h)
            end
        end
    end

    if Config.VerSupervivientes and Grupo:FindFirstChild("Survivors") then
        for _, s in ipairs(Grupo.Survivors:GetChildren()) do
            if s:FindFirstChild("Humanoid") then
                local h = Instance.new("Highlight")
                h.OutlineColor = Color3.new(0.2, 1, 0.2)
                h.FillTransparency = 1
                h.Parent = s
                table.insert(Resaltados, h)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if Config.AntiCeguera then
            local b = Lighting:FindFirstChild("BlindnessBlur")
            if b then b:Destroy() end
        end
        if Config.AntiSubespacio then
            local a1 = Lighting:FindFirstChild("SubspaceVFXBlur")
            local a2 = Lighting:FindFirstChild("SubspaceVFXColorCorrection")
            if a1 then a1:Destroy() end
            if a2 then a2:Destroy() end
        end
    end
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        UI.visible1 = not UI.visible1
        UI.main.Visible = UI.visible1
        UI.header.Visible = UI.visible1
        UI.title.Visible = UI.visible1
        UI.keybinfo.Visible = UI.visible1
    end
end)

print("✅ MateoSaken cargado! R-Ctrl para abrir/cerrar")
