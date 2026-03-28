local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Cria a pasta RemoteEvents se não existir
local RemoteEvents = Instance.new("Folder")
RemoteEvents.Name = "RemoteEvents"
RemoteEvents.Parent = ReplicatedStorage

-- Cria os RemoteEvents
local AttackEvent = Instance.new("RemoteEvent")
AttackEvent.Name = "AttackEvent"
AttackEvent.Parent = RemoteEvents

local ParryEvent = Instance.new("RemoteEvent")
ParryEvent.Name = "ParryEvent"
ParryEvent.Parent = RemoteEvents

local BlockEvent = Instance.new("RemoteEvent")
BlockEvent.Name = "BlockEvent"
BlockEvent.Parent = RemoteEvents

local DodgeEvent = Instance.new("RemoteEvent")
DodgeEvent.Name = "DodgeEvent"
DodgeEvent.Parent = RemoteEvents

-- Requer o CombatHandler para iniciar a lógica do servidor
local CombatHandler = require(script.Parent:WaitForChild("CombatHandler"))

print("RemoteEvents configurados e CombatHandler iniciado.")
