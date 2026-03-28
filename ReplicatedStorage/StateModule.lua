_G.PlayerStates = _G.PlayerStates or {}

local StateModule = {}

--[[ 
    Gerencia o estado do jogador (ex: atacando, bloqueando, etc.)
    para evitar ações conflitantes.
]]

function StateModule.Set(player, state, value)
    local playerUserId = tostring(player.UserId)
    if not _G.PlayerStates[playerUserId] then
        _G.PlayerStates[playerUserId] = {}
    end
    _G.PlayerStates[playerUserId][state] = value
    
    -- Se o valor for nil, remove a chave para limpar a memória
    if value == nil then
        _G.PlayerStates[playerUserId][state] = nil
    end
end

function StateModule.Get(player, state)
    local playerUserId = tostring(player.UserId)
    if not _G.PlayerStates[playerUserId] then
        return nil
    end
    return _G.PlayerStates[playerUserId][state]
end

function StateModule.Is(player, state)
    local playerUserId = tostring(player.UserId)
    if not _G.PlayerStates[playerUserId] then
        return false
    end
    return _G.PlayerStates[playerUserId][state] == true
end

function StateModule.ClearAll(player)
    local playerUserId = tostring(player.UserId)
    _G.PlayerStates[playerUserId] = {}
end

return StateModule
