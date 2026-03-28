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

local function onInputBegan(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    -- M1 (Ataque Leve)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if not StateModule.Is(player, "Attacking") and not StateModule.Is(player, "Stunned") then
            AttackEvent:FireServer()
        end
    end

    -- Parry
    if input.KeyCode == Enum.KeyCode.F then
        if not StateModule.Is(player, "Attacking") and not StateModule.Is(player, "Stunned") and not StateModule.Is(player, "Blocking") then
            ParryEvent:FireServer()
        end
    end

    -- Dodge
    if input.KeyCode == Enum.KeyCode.Q then
        if not StateModule.Is(player, "Attacking") and not StateModule.Is(player, "Stunned") then
            DodgeEvent:FireServer()
        end
    end

    -- Block (Segurar)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if not StateModule.Is(player, "Attacking") and not StateModule.Is(player, "Stunned") then
            BlockEvent:FireServer(true) -- Começa a bloquear
        end
    end
end

local function onInputEnded(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    -- Parar de bloquear
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        BlockEvent:FireServer(false) -- Para de bloquear
    end
end

UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputEnded:Connect(onInputEnded)

print("InputHandler carregado para o jogador local.")
