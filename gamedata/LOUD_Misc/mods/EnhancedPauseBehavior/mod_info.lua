-- ============================================================================
-- Enhanced Pause Behavior
--
-- Resuming a paused multiplayer game requires all human players to confirm
-- they are ready, followed by a countdown. UI Lua only, no sim files.
-- ============================================================================

name        = "Enhanced Pause Behavior"
version     = 1.0
description = "Multiplayer: resuming a paused game requires all human players to be ready, followed by a countdown. Changes nothing else in the game."
author      = "Paul"
copyright   = "none"

-- 256x256 PNG shown in the mod manager
icon = "/mods/enhancedpausebehavior/enhancedpausebehavior.png"

uid = "E9410707-B979-462F-B9E8-3DDB886DB31B"

selectable = true
enabled    = true
exclusive  = false

-- Intentionally false although the mod is UI only: only game mods are passed
-- to all clients via gameInfo.GameMods and checked by the lobby
-- (CheckIfHaveMods). The ready check needs the mod on every client.
ui_only    = false

hookdir   = '/hook'
shadowdir = '/shadow'
