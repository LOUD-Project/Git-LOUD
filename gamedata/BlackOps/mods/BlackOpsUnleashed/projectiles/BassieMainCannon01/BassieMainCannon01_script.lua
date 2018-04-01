#****************************************************************************
#**
#**  File     :  /data/projectiles/CDFProtonCannon05/CDFProtonCannon05_script.lua
#**  Author(s):  Gordon Duclos, Matt Vainio
#**
#**  Summary  :  Cybran Proton Artillery projectile script, XRL0403
#**
#**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local CDFHvyProtonCannonProjectile = import('/lua/cybranprojectiles.lua').CDFHvyProtonCannonProjectile
local BlackOpsEffectTemplate = import('/mods/BlackOpsUnleashed/lua/BlackOpsEffectTemplates.lua')


CDFProtonCannon05 = Class(CDFHvyProtonCannonProjectile) {
	
	PolyTrails = {
        BlackOpsEffectTemplate.BassieCannonPolyTrail,
        '/mods/BlackOpsUnleashed/effects/emitters/bassie_cannon_trail_01_emit.bp',
    },

    FxTrails = BlackOpsEffectTemplate.BassieCannonFxTrail,
	FxImpactUnit = BlackOpsEffectTemplate.BassieCannonHitUnit,
    FxImpactProp = BlackOpsEffectTemplate.BassieCannonHitUnit,
    FxImpactLand = BlackOpsEffectTemplate.BassieCannonHitLand,
    FxImpactUnderWater = BlackOpsEffectTemplate.BassieCannonHit01,
    FxImpactWater = BlackOpsEffectTemplate.BassieCannonHit01,
    FxUnitHitScale = 1.5,
    FxPropHitScale = 1.5,
    FxLandHitScale = 1.5,
    FxUnderWarerHitScale = 1.5,
    FxWaterHitScale = 1.5,

	OnImpact = function(self, TargetType, TargetEntity) 
		###self:ShakeCamera( radius, maxShakeEpicenter, minShakeAtRadius, interval )
		self:ShakeCamera( 15, 0.25, 0, 0.2 )
		CDFHvyProtonCannonProjectile.OnImpact (self, TargetType, TargetEntity)
	end,
}
TypeClass = CDFProtonCannon05