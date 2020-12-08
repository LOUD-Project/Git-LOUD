--****************************************************************************
--**
--**  File     :  /data/projectiles/SBOKhamaseenBombEffect03/SBOKhamaseenBombEffect03_script.lua
--**  Author(s):  Greg Kohne
--**
--**  Summary  :  Ohwalli Strategic Bomb effect script, non-damaging
--**
--**  Copyright � 2007 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

InqDeathBombEffect03 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
	FxTrails = import('/mods/BlackOpsUnleashed/lua/BlackOpsEffectTemplates.lua').GoldLaserBombHitRingProjectileFxTrails03,
}
TypeClass = InqDeathBombEffect03
