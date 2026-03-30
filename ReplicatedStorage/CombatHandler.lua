_G.PlayerStates = _G.PlayerStates or {}

local CombatHandler = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CombatConfig = require(ReplicatedStorage:WaitForChild("CombatConfig"))
local StateModule = require(ReplicatedStorage:WaitForChild("StateModule"))
local HitboxService = require(ReplicatedStorage:WaitForChild("HitboxService"))

-- Presume que os RemoteEvents estão em uma pasta chamada "RemoteEvents" em ReplicatedStorage
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local AttackEvent = RemoteEvents:WaitForChild("AttackEvent")
local ParryEvent = RemoteEvents:WaitForChild("ParryEvent")
local BlockEvent = RemoteEvents:WaitForChild("BlockEvent")
local DodgeEvent = RemoteEvents:WaitForChild("DodgeEvent")
local PlayAnimationEvent = RemoteEvents:WaitForChild("PlayAnimationEvent")

-- Variáveis de estado do jogador no lado do servidor
local lastAttackTime = {}
local attackCombo = {}
local lastDamageTime = {}

-- Inicializa um jogador
local function setupPlayer(player)
    local userId = tostring(player.UserId)
    _G.PlayerStates[userId] = {
        Posture = CombatConfig.MaxPosture,
        Stamina = 100
    }
    lastAttackTime[userId] = 0
    attackCombo[userId] = 1
    lastDamageTime[userId] = 0
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

Players.PlayerRemoving:Connect(function(player)
    local userId = tostring(player.UserId)
    _G.PlayerStates[userId] = nil
    lastAttackTime[userId] = nil
    attackCombo[userId] = nil
    lastDamageTime[userId] = nil
end)

function CombatHandler.ApplyDamage(attacker, target, damageConfig)
    local targetHumanoid = target:FindFirstChildOfClass("Humanoid")
    if not targetHumanoid or targetHumanoid.Health <= 0 then return end

    local targetPlayer = Players:GetPlayerFromCharacter(target)
    if not targetPlayer then return end

    local targetUserId = tostring(targetPlayer.UserId)
    lastDamageTime[targetUserId] = os.clock()

    -- Lógica de Bloqueio e Parry
    if StateModule.Is(targetPlayer, "Blocking") then
        local isParry = StateModule.Get(targetPlayer, "ParryWindow")
        if isParry then
            -- Lógica de Parry (será chamada de outro módulo)
            -- Evento para stunar o atacante
            print(attacker.Name .. " foi parreado por " .. target.Name)
            -- RemoteEvents.StunEvent:FireClient(attacker, CombatConfig.ParryStun)
            _G.PlayerStates[targetUserId].Posture = _G.PlayerStates[targetUserId].Posture - (damageConfig.Posture * 0.1) -- Parry reduz dano de postura
        else
            -- Lógica de Bloqueio
            print(target.Name .. " bloqueou o ataque.")
            targetHumanoid:TakeDamage(damageConfig.Damage * 0.2) -- 80% de redução
            _G.PlayerStates[targetUserId].Posture = _G.PlayerStates[targetUserId].Posture - damageConfig.Posture
        end
    else
        -- Dano normal
        targetHumanoid:TakeDamage(damageConfig.Damage)
        _G.PlayerStates[targetUserId].Posture = _G.PlayerStates[targetUserId].Posture - damageConfig.Posture
    end

    -- Quebra de Postura (Guard Break)
    if _G.PlayerStates[targetUserId].Posture <= 0 then
        print(target.Name .. " teve a postura quebrada!")
        StateModule.Set(targetPlayer, "Stunned", true)
        PlayAnimationEvent:FireClient(targetPlayer, CombatConfig.Animations.GuardBreak)
        task.delay(2, function()
            StateModule.Set(targetPlayer, "Stunned", false)
            _G.PlayerStates[targetUserId].Posture = CombatConfig.MaxPosture * 0.5 -- Recupera metade
        end)
    end
end

-- Lida com o evento de ataque M1
local function onAttack(player)
    local character = player.Character
    if not character or StateModule.Is(player, "Stunned") or StateModule.Is(player, "Dodging") or StateModule.Is(player, "Blocking") then return end

    local userId = tostring(player.UserId)
    if _G.PlayerStates[userId].Stamina < CombatConfig.StaminaCosts.LightAttack then
        print(player.Name .. " não tem stamina suficiente para atacar.")
        return
    end
    _G.PlayerStates[userId].Stamina = math.max(0, _G.PlayerStates[userId].Stamina - CombatConfig.StaminaCosts.LightAttack)
    local now = os.clock()

    if now - (lastAttackTime[userId] or 0) < CombatConfig.AttackCooldown then return end
    lastAttackTime[userId] = now

    -- Resetar combo se o tempo entre ataques for muito longo
    if now - (lastAttackTime[userId] or 0) > 1.5 then
        attackCombo[userId] = 1
    end

    StateModule.Set(player, "Attacking", true)

    local combo = attackCombo[userId]
    local animId = CombatConfig.Animations.LightAttacks[combo]
    print("Player " .. player.Name .. " usou M1 combo " .. combo)
    PlayAnimationEvent:FireClient(player, animId)

    -- Criar hitbox
    task.wait(0.1) -- Pequeno delay para a animação começar
    local targets = HitboxService.CreateHitbox(player, character, 7, 5)
    for _, targetModel in ipairs(targets) do
        CombatHandler.ApplyDamage(player, targetModel, {Damage = CombatConfig.Damage.Light, Posture = CombatConfig.PostureDamage.Light})
    end

    -- Avançar o combo
    attackCombo[userId] = (attackCombo[userId] % #CombatConfig.Animations.LightAttacks) + 1

    task.delay(0.5, function()
        StateModule.Set(player, "Attacking", false)
    end)
end

AttackEvent.OnServerEvent:Connect(onAttack)

-- Lida com o evento de Parry
ParryEvent.OnServerEvent:Connect(function(player)
    local character = player.Character
    local userId = tostring(player.UserId)
    if not character or StateModule.Is(player, "Stunned") or StateModule.Is(player, "Attacking") or StateModule.Is(player, "Dodging") then return end

    if _G.PlayerStates[userId].Stamina < CombatConfig.StaminaCosts.Parry then
        print(player.Name .. " não tem stamina suficiente para parry.")
        return
    end
    _G.PlayerStates[userId].Stamina = math.max(0, _G.PlayerStates[userId].Stamina - CombatConfig.StaminaCosts.Parry)

    StateModule.Set(player, "Parrying", true)
    PlayAnimationEvent:FireClient(player, CombatConfig.Animations.Parry)
    print(player.Name .. " está parrying!")

    -- Define uma janela de parry
    StateModule.Set(player, "ParryWindow", true)
    task.delay(CombatConfig.ParryWindow, function()
        StateModule.Set(player, "ParryWindow", false)
        StateModule.Set(player, "Parrying", false)
    end)
end)

-- Lida com o evento de Bloqueio
BlockEvent.OnServerEvent:Connect(function(player, isBlocking)
    local character = player.Character
    local userId = tostring(player.UserId)
    if not character or StateModule.Is(player, "Stunned") or StateModule.Is(player, "Attacking") or StateModule.Is(player, "Dodging") then return end

    if isBlocking and _G.PlayerStates[userId].Stamina < CombatConfig.StaminaCosts.BlockPerSecond then
        print(player.Name .. " não tem stamina suficiente para bloquear.")
        return
    end

    StateModule.Set(player, "Blocking", isBlocking)
    if isBlocking then
        PlayAnimationEvent:FireClient(player, CombatConfig.Animations.Block)
        print(player.Name .. " está bloqueando!")
    else
        print(player.Name .. " parou de bloquear.")
    end
end)

-- Lida com o evento de Esquiva
DodgeEvent.OnServerEvent:Connect(function(player)
    local character = player.Character
    local userId = tostring(player.UserId)
    if not character or StateModule.Is(player, "Stunned") or StateModule.Is(player, "Attacking") or StateModule.Is(player, "Blocking") or StateModule.Is(player, "Dodging") then return end

    if _G.PlayerStates[userId].Stamina < CombatConfig.StaminaCosts.Dodge then
        print(player.Name .. " não tem stamina suficiente para esquivar.")
        return
    end
    _G.PlayerStates[userId].Stamina = math.max(0, _G.PlayerStates[userId].Stamina - CombatConfig.StaminaCosts.Dodge)

    StateModule.Set(player, "Dodging", true)
    PlayAnimationEvent:FireClient(player, CombatConfig.Animations.Dodge)
    print(player.Name .. " está esquivando!")

    -- Aplica i-frames ou move o jogador rapidamente
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local originalWalkSpeed = character.Humanoid.WalkSpeed
        character.Humanoid.WalkSpeed = 0 -- Impede movimento durante a esquiva
        rootPart.CFrame = rootPart.CFrame * CFrame.new(0, 0, -10) -- Exemplo de movimento para trás
        task.delay(CombatConfig.DodgeDuration, function()
            character.Humanoid.WalkSpeed = originalWalkSpeed
            StateModule.Set(player, "Dodging", false)
            -- Cooldown da esquiva
            task.delay(CombatConfig.DodgeCooldown, function()
                -- Esquiva pronta novamente
            end)
        end)
    end
end)

-- Loop para regenerar Postura
task.spawn(function()
    while task.wait(1) do
        for _, player in ipairs(Players:GetPlayers()) do
            local userId = tostring(player.UserId)
            if _G.PlayerStates[userId] then
                -- Regeneração de Stamina (se não estiver em estados que impedem)
                if not StateModule.Is(player, "Attacking") and not StateModule.Is(player, "Blocking") and not StateModule.Is(player, "Dodging") and not StateModule.Is(player, "Stunned") then
                    _G.PlayerStates[userId].Stamina = math.min(100, _G.PlayerStates[userId].Stamina + 5) -- Exemplo: 5 de stamina por segundo
                end

                -- Regeneração de Postura (se não tiver tomado dano recentemente)
                if os.clock() - (lastDamageTime[userId] or 0) > CombatConfig.PostureRegenDelay then
                    if _G.PlayerStates[userId].Posture < CombatConfig.MaxPosture then
                        _G.PlayerStates[userId].Posture = math.min(CombatConfig.MaxPosture, _G.PlayerStates[userId].Posture + CombatConfig.PostureRegenRate)
                    end
                end
                -- TODO: Disparar RemoteEvent para atualizar UI do cliente com Stamina e Postura
            end
        end
    end
end)

return CombatHandler
