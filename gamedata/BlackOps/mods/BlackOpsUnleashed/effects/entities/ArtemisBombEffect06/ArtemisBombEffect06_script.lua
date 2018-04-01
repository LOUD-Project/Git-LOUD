#****************************************************************************
#**
#**  File     :  /data/projectiles/ArtemisBombEffect06/ArtemisBombEffect06_script.lua
#**  Author(s):  Matt Vainio
#**
#**  Summary  :  Seraphim experimental nuke effect script, non-damaging
#**
#**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local EffectTemplate = import('/lua/EffectTemplates.lua')
local BlackOpsEffectTemplate = import('/mods/BlackOpsUnleashed/lua/BlackOpsEffectTemplates.lua')

ArtemisBombEffect06 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
    FxTrails = BlackOpsEffectTemplate.ArtemisBombPlumeFxTrails06,
	FxTrailScale = 0.7,
}
TypeClass = ArtemisBombEffect06

