_G.PlayerStates = _G.PlayerStates or {}

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local StateModule = require(ReplicatedStorage:WaitForChild("StateModule"))

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local AttackEvent = RemoteEvents:WaitForChild("AttackEvent")
local BlockEvent = RemoteEvents:WaitForChild("BlockEvent")
local ParryEvent = RemoteEvents:WaitForChild("ParryEvent")
local DodgeEvent = RemoteEvents:WaitForChild("DodgeEvent")

local player = Players.LocalPlayer

--[[
    Este script (LocalScript) captura a entrada do jogador e a envia para o servidor.
]]

local f_key_pressed_time = nil
local is_blocking = false

local function onInputBegan(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    -- M1 (Ataque Leve)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if not StateModule.Is(player, "Attacking") and not StateModule.Is(player, "Stunned") then
            AttackEvent:FireServer()
        end
    end

    -- Dodge
    if input.KeyCode == Enum.KeyCode.Q then
        if not StateModule.Is(player, "Attacking") and not StateModule.Is(player, "Stunned") then
            DodgeEvent:FireServer()
        end
    end

    -- Início do Pressionamento da Tecla F
    if input.KeyCode == Enum.KeyCode.F then
        if not StateModule.Is(player, "Attacking") and not StateModule.Is(player, "Stunned") then
            f_key_pressed_time = os.clock()
        end
    end
end

local function onInputEnded(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    -- Fim do Pressionamento da Tecla F
    if input.KeyCode == Enum.KeyCode.F then
        if f_key_pressed_time then
            local press_duration = os.clock() - f_key_pressed_time
            
            if is_blocking then
                -- Se já estava bloqueando, para de bloquear
                BlockEvent:FireServer(false)
                is_blocking = false
            elseif press_duration < 0.2 then
                -- Se a duração for curta, é um Parry
                ParryEvent:FireServer()
            end
        end
        f_key_pressed_time = nil
    end
end

-- Loop para verificar o hold da tecla F
game:GetService("RunService").Heartbeat:Connect(function()
    if f_key_pressed_time and not is_blocking then
        if (os.clock() - f_key_pressed_time) >= 0.2 then
            BlockEvent:FireServer(true)
            is_blocking = true
        end
    end
end)

UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputEnded:Connect(onInputEnded)

print("InputHandler (R6/R15 Fix) carregado para o jogador local.")
