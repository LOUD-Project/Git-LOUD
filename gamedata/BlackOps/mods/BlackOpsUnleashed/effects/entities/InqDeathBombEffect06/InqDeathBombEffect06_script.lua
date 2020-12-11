--****************************************************************************
--**
--**  File     :  /data/projectiles/SBOKhamaseenBombEffect05/SBOKhamaseenBombEffect05_script.lua
--**  Author(s):  Greg Kohne
--**
--**  Summary  :  Ohwalli Strategic Bomb effect script, non-damaging
--**
--**  Copyright � 2007 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local EffectTemplate = import('/lua/EffectTemplates.lua')
local BlackOpsEffectTemplate = import('/mods/BlackOpsUnleashed/lua/BlackOpsEffectTemplates.lua')

InqDeathBombEffect06 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
    FxTrails = BlackOpsEffectTemplate.GoldLaserBombHitRingProjectileFxTrails06,
    FxTrailScale = 0.3,
}
TypeClass = InqDeathBombEffect06

