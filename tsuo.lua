loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "EMANO HUB",
    ConfigurationSaving = {Enabled = false}
})

local Tab = Window:CreateTab("ATM e Pânico", 4483362458)
local Player = game:GetService("Players").LocalPlayer
local Props = workspace:WaitForChild("Map"):WaitForChild("Props")
local SliderMinigame = require(game.ReplicatedStorage.Modules.Game.Minigames.SliderMinigame)

local ATMHackEnabled = false
local ATMESPEnabled = false
local Highlights = {}
local CooldownHack = true
local CooldownUI = true
local TPWalk = false

Tab:CreateParagraph({Title = "EMANO HUB - Créditos", Content = "Criado por edu_emano\nFunções: ATM Hack, ESP ATM, TP Walk e Botão de Pânico"})

Tab:CreateParagraph({Title = "ATM Hack", Content = "Completa o minigame automaticamente após 1.3 segundos"})

local function GetClosestATM()
    for _, atm in ipairs(Props:GetDescendants()) do
        if atm:IsA("Model") and atm.Name:lower():find("atm") then
            local part = atm.PrimaryPart or atm:FindFirstChildWhichIsA("BasePart")
            if part and (part.Position - Player.Character.HumanoidRootPart.Position).Magnitude < 8 then
                return atm
            end
        end
    end
end

Tab:CreateToggle({
    Name = "Ativar ATM Hack",
    CurrentValue = false,
    Callback = function(state)
        ATMHackEnabled = state
        if state then
            SliderMinigame.enabled.hook(function(started)
                if started then task.wait(1.3) SliderMinigame.win:Fire(true) end
            end)

            task.spawn(function()
                while ATMHackEnabled and task.wait(0.5) do
                    if CooldownHack then
                        local atm = GetClosestATM()
                        if atm then
                            local prompt = atm:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if prompt then
                                fireproximityprompt(prompt)
                                CooldownHack = false
                                task.delay(5, function() CooldownHack = true end)
                            end
                        end
                    end
                end
            end)

            task.spawn(function()
                while ATMHackEnabled and task.wait(0.25) do
                    if CooldownUI then
                        local UI = require(game.ReplicatedStorage.Modules.Core.UI)
                        local btn = UI.get("ATMHackButton", true)
                        if btn and btn.Visible and btn:IsDescendantOf(Player.PlayerGui) then
                            firesignal(btn.MouseButton1Click)
                            CooldownUI = false
                            task.delay(2.5, function() CooldownUI = true end)
                        end
                    end
                end
            end)
        end
    end
})

Tab:CreateToggle({
    Name = "Ativar ESP ATM (vermelho)",
    CurrentValue = false,
    Callback = function(state)
        ATMESPEnabled = state
        for _, h in ipairs(Highlights) do h:Destroy() end
        table.clear(Highlights)

        if state then
            for _, atm in ipairs(Props:GetDescendants()) do
                if atm:IsA("Model") and atm.Name:lower():find("atm") then
                    local part = atm.PrimaryPart or atm:FindFirstChildWhichIsA("BasePart")
                    if part then
                        local highlight = Instance.new("Highlight")
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.FillTransparency = 0.6
                        highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
                        highlight.OutlineTransparency = 0
                        highlight.Adornee = atm
                        highlight.Parent = part
                        table.insert(Highlights, highlight)
                    end
                end
            end
        end
    end
})

Tab:CreateParagraph({Title = "TP Walk [Pressione X ou botão abaixo]", Content = "Você pode atravessar paredes andando"})

Tab:CreateButton({
    Name = "Alternar TP Walk (Mobile)",
    Callback = function()
        TPWalk = not TPWalk
        Rayfield:Notify({Title = "TP Walk", Content = TPWalk and "Ativado" or "Desativado", Duration = 3})
    end
})

game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.X then
        TPWalk = not TPWalk
    end
end)

task.spawn(function()
    while task.wait() do
        if TPWalk then
            local char = Player.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildWhichIsA("Humanoid")
                if root and hum and hum.MoveDirection.Magnitude > 0 then
                    root.CFrame = root.CFrame + (hum.MoveDirection.Unit * 1)
                end
            end
        end
    end
end)

-- Botão de Pânico
Tab:CreateButton({
    Name = "Botão de Pânico (Fugir)",
    Callback = function()
        local root = Player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local panicDirection = Vector3.new(math.random(-100,100), 0, math.random(-100,100)).Unit * 50
            root.CFrame = root.CFrame + panicDirection
            Rayfield:Notify({Title = "Pânico!", Content = "Você fugiu rapidamente!", Duration = 3})
        end
    end
})
