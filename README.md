# Sistema de Combate Deepwoken-like para Roblox

Este pacote contém os módulos e scripts necessários para implementar um sistema de combate básico inspirado no Deepwoken, incluindo ataques M1, parry, bloqueio, esquiva, e gerenciamento de postura e stamina.

## Estrutura do Projeto

Os arquivos fornecidos devem ser organizados da seguinte forma no seu projeto Roblox Studio:

```
├── ReplicatedStorage
│   ├── CombatConfig.lua
│   ├── CombatHandler.lua
│   ├── HitboxService.lua
│   ├── StateModule.lua
│   └── RemoteEvents
│       ├── AttackEvent (RemoteEvent)
│       ├── ParryEvent (RemoteEvent)
│       ├── BlockEvent (RemoteEvent)
│       └── DodgeEvent (RemoteEvent)
├── ServerScriptService
│   └── ServerScript.lua
└── StarterPlayer
    └── StarterPlayerScripts
        └── ClientScript.lua
```

## Configuração no Roblox Studio

Siga os passos abaixo para configurar o sistema no seu jogo:

1.  **Crie a pasta `RemoteEvents`:**
    *   No `ReplicatedStorage`, crie uma nova `Folder` e renomeie-a para `RemoteEvents`.

2.  **Crie os `RemoteEvents`:**
    *   Dentro da pasta `RemoteEvents` recém-criada, crie quatro `RemoteEvent`s e renomeie-os para `AttackEvent`, `ParryEvent`, `BlockEvent` e `DodgeEvent`.

3.  **Mova os módulos para `ReplicatedStorage`:**
    *   Mova os arquivos `CombatConfig.lua`, `CombatHandler.lua`, `HitboxService.lua` e `StateModule.lua` para `ReplicatedStorage`.
    *   **Importante:** No Roblox Studio, você precisará criar um novo `ModuleScript` para cada um desses arquivos e copiar o conteúdo do `.lua` correspondente para dentro deles.

4.  **Configure o `ServerScript`:**
    *   Crie um novo `Script` dentro de `ServerScriptService` e renomeie-o para `ServerScript.lua`.
    *   Copie o conteúdo do arquivo `ServerScript.lua` fornecido para este novo script.
    *   Este script será responsável por inicializar o `CombatHandler` e garantir que os `RemoteEvents` estejam configurados corretamente.

5.  **Configure o `ClientScript`:**
    *   Crie um novo `LocalScript` dentro de `StarterPlayer > StarterPlayerScripts` e renomeie-o para `ClientScript.lua`.
    *   Copie o conteúdo do arquivo `ClientScript.lua` fornecido para este novo script.
    *   Este script será responsável por capturar a entrada do jogador e disparar os `RemoteEvents` correspondentes.

## Personalização

*   **`CombatConfig.lua`:** Este arquivo contém todas as configurações numéricas e IDs de animação. Você deve preencher os `rbxassetid://0` com os IDs das suas próprias animações para ataques, bloqueio, parry, esquiva, stun e quebra de guarda. Ajuste os valores de dano, postura, stamina e timings conforme a necessidade do seu jogo.
*   **Animações:** As funções `CombatHandler.PlayAnimation` no `CombatHandler.lua` e `InputHandler.lua` são placeholders. Você precisará implementar a lógica real para carregar e reproduzir suas animações, provavelmente no lado do cliente para melhor responsividade.
*   **UI:** Atualmente, não há uma interface de usuário para exibir a stamina e a postura. Você precisará criar uma UI e usar `RemoteEvents` adicionais (ou modificar os existentes) para enviar as atualizações de stamina e postura do servidor para o cliente.
*   **Hitbox:** O `HitboxService.lua` usa `GetPartBoundsInBox` para detecção de hitbox. Para maior precisão ou diferentes formas de ataque, você pode explorar outras técnicas de hitbox (como `Raycasting` mais complexo ou `Region3`).

## Como Funciona (Visão Geral)

1.  **`InputHandler.lua` (LocalScript):** Detecta a entrada do jogador (clique do mouse, teclas F, Q, etc.) e dispara `RemoteEvents` para o servidor.
2.  **`CombatHandler.lua` (ModuleScript no servidor):** Recebe os eventos do cliente, verifica a validade da ação (stamina, estado do jogador), aplica a lógica de combate (dano, postura, stun) e gerencia a regeneração de stamina e postura.
3.  **`StateModule.lua` (ModuleScript no servidor):** Gerencia os estados atuais de cada jogador (atacando, bloqueando, parry, esquivando, stunado) para evitar ações conflitantes e garantir a fluidez do combate.
4.  **`HitboxService.lua` (ModuleScript no servidor):** Usado pelo `CombatHandler` para detectar alvos dentro de uma área de ataque definida.
5.  **`CombatConfig.lua` (ModuleScript):** Armazena todas as variáveis configuráveis do sistema de combate.

Este sistema fornece uma base robusta para você expandir e adaptar às necessidades específicas do seu jogo. Lembre-se de testar exaustivamente todas as funcionalidades após a implementação.
