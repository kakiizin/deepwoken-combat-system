local CombatConfig = {
    -- Configurações de Dano e Postura
    Damage = {
        Light = 10,
        Medium = 15,
        Heavy = 25,
    },
    PostureDamage = {
        Light = 15,
        Medium = 20,
        Heavy = 35,
    },
    MaxPosture = 100,
    PostureRegenRate = 5, -- Por segundo
    PostureRegenDelay = 2, -- Segundos sem tomar dano para começar a regenerar

    -- Timings (em segundos)
    ParryWindow = 0.25, -- Janela de tempo para um parry perfeito
    BlockStun = 0.5, -- Tempo de stun ao bloquear um ataque
    ParryStun = 1.2, -- Tempo de stun do atacante ao ser parreado
    DodgeDuration = 0.4, -- Duração da esquiva (i-frames)
    DodgeCooldown = 1.5,
    AttackCooldown = 0.6,

    -- Custos de Stamina
    StaminaCosts = {
        LightAttack = 10,
        Parry = 15,
        BlockPerSecond = 5, -- Custo por segundo ao bloquear
        Dodge = 20,
    },

    -- IDs de Animação (Deixe que o usuário preencha)
    Animations = {
        LightAttacks = {
            "rbxassetid://0", -- M1 1
            "rbxassetid://0", -- M1 2
            "rbxassetid://0", -- M1 3
        },
        Block = "rbxassetid://0",
        Parry = "rbxassetid://0",
        Dodge = "rbxassetid://0",
        Stunned = "rbxassetid://0",
        GuardBreak = "rbxassetid://0",
    },

    -- Sons (Opcional)
    Sounds = {
        Hit = "rbxassetid://0",
        Parry = "rbxassetid://0",
        Block = "rbxassetid://0",
        Swing = "rbxassetid://0",
    }
}

return CombatConfig
