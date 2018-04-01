#****************************************************************************
#**
#**  File     :  /data/projectiles/GoldLaserBombEffect01/GoldLaserBombEffect01_script.lua
#**  Author(s):  Greg Kohne, Gordon Duclos
#**
#**  Summary  :  Ohwalli Strategic Bomb effect script, non-damaging
#**
#**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local EffectTemplate = import('/lua/EffectTemplates.lua')
local BlackOpsEffectTemplate = import('/mods/BlackOpsUnleashed/lua/BlackOpsEffectTemplates.lua')
GoldLaserBombEffect01 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
	FxTrails = BlackOpsEffectTemplate.GoldLaserBombPlumeFxTrails01,
	FxTrailScale = 0.1,
}
TypeClass = GoldLaserBombEffect01
