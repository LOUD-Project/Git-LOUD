--****************************************************************************
--**
--**  File     :  /data/projectiles/SBOKhamaseenBombEffect04/SBOKhamaseenBombEffect04_script.lua
--**  Author(s):  Greg Kohne
--**
--**  Summary  :  Ohwalli Strategic Bomb effect script, non-damaging
--**
--**  Copyright � 2007 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local EffectTemplate = import('/lua/EffectTemplates.lua')
local RandomInt = import('/lua/utilities.lua').GetRandomInt
local BlackOpsEffectTemplate = import('/mods/BlackOpsUnleashed/lua/BlackOpsEffectTemplates.lua')


InqDeathBombEffect04 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
	FxTrails = BlackOpsEffectTemplate.GoldLaserBombHitRingProjectileFxTrails04,
}
TypeClass = InqDeathBombEffect04
