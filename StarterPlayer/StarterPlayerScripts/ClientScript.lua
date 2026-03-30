local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local InputHandler = require(ReplicatedStorage:WaitForChild("InputHandler"))

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local PlayAnimationEvent = RemoteEvents:WaitForChild("PlayAnimationEvent")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local loadedAnimations = {}

local function playAnimation(animId)
    if not humanoid then return end

    local animation = loadedAnimations[animId]
    if not animation then
        local newAnimation = Instance.new("Animation")
        newAnimation.AnimationId = animId
        animation = humanoid:LoadAnimation(newAnimation)
        loadedAnimations[animId] = animation
    end

    -- Parar animações anteriores do mesmo tipo para evitar sobreposição
    for _, animTrack in pairs(humanoid:GetPlayingAnimationTracks()) do
        if animTrack.Animation.AnimationId == animId then
            animTrack:Stop()
        end
    end

    animation:Play()
    print("Reproduzindo animação: " .. animId)
end

PlayAnimationEvent.OnClientEvent:Connect(playAnimation)

InputHandler.Setup()

print("ClientScript e InputHandler configurados com suporte a animações.")
