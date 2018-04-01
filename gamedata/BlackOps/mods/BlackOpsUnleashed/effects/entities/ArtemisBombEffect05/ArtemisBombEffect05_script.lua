#****************************************************************************
#**
#**  File     :  /data/projectiles/ArtemisBombEffect05/ArtemisBombEffect05_script.lua
#**  Author(s):  Matt Vainio
#**
#**  Summary  :  Seraphim experimental nuke effect script, non-damaging
#**
#**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local EffectTemplate = import('/lua/EffectTemplates.lua')
local BlackOpsEffectTemplate = import('/mods/BlackOpsUnleashed/lua/BlackOpsEffectTemplates.lua')

ArtemisBombEffect05 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
    FxTrails = BlackOpsEffectTemplate.ArtemisBombPlumeFxTrails05,
	FxTrailScale = 0.5,
}
TypeClass = ArtemisBombEffect05

