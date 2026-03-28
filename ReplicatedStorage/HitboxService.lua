local HitboxService = {}

--[[
    Este serviço cria hitboxes precisas usando Raycasting.
    Ele detecta inimigos em uma área à frente do jogador.
]]

function HitboxService.CreateHitbox(player, character, range, width)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return {} end

    local hitTargets = {}
    local overlapParams = OverlapParams.new()
    overlapParams.FilterDescendantsInstances = {character}
    overlapParams.FilterType = Enum.RaycastFilterType.Exclude

    -- Cria uma caixa de detecção à frente do jogador
    local hitboxSize = Vector3.new(width, 6, range)
    local hitboxCFrame = rootPart.CFrame * CFrame.new(0, 0, -range/2)

    local parts = workspace:GetPartBoundsInBox(hitboxCFrame, hitboxSize, overlapParams)

    for _, part in ipairs(parts) do
        local model = part:FindFirstAncestorOfClass("Model")
        if model and model:FindFirstChild("Humanoid") and model ~= character then
            if not hitTargets[model] then
                hitTargets[model] = true -- Usar true para evitar duplicatas
            end
        end
    end

    local finalTargets = {}
    for model, _ in pairs(hitTargets) do
        table.insert(finalTargets, model)
    end

    return finalTargets
end

return HitboxService
