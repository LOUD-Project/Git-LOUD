#****************************************************************************
#**
#**  File     :  /data/projectiles/ArtemisBombEffect04/ArtemisBombEffect04_script.lua
#**  Author(s):  Greg Kohne, Gordon Duclos
#**
#**  Summary  :  Seraphim Experimental Nuke effect script, non-damaging
#**
#**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local EffectTemplate = import('/lua/EffectTemplates.lua')
local BlackOpsEffectTemplate = import('/mods/BlackOpsUnleashed/lua/BlackOpsEffectTemplates.lua')

ArtemisBombEffect04 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
	FxTrails = BlackOpsEffectTemplate.ArtemisBombPlumeFxTrails03,
	FxTrailScale = 0.5,
}
TypeClass = ArtemisBombEffect04
