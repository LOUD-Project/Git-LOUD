-----------------------------------------------------------------------------
--  File     : /projectiles/UEF/UCannonShell02/UCannonShell02_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 UEF Fatboy Cannon Shell: UCannonShell02
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local EffectTemplate = import('/lua/EffectTemplates.lua')

UCannonShell02 = Class(import('/lua/sim/defaultprojectiles.lua').MultiPolyTrailProjectile) {
	
	PolyTrails  = {
		'/mods/BattlePack/effects/emitters/w_u_gau01_p_01_polytrails_emit.bp',
		'/mods/BattlePack/effects/emitters/w_u_gau01_p_02_polytrails_emit.bp',
	},
	PolyTrailOffset = {0,0},

    FxImpactUnit = EffectTemplate.TGaussCannonHitUnit01,
    FxImpactProp = EffectTemplate.TGaussCannonHitUnit01,
    FxImpactLand = EffectTemplate.TGaussCannonHitLand01,
    FxImpactWater = EffectTemplate.TGaussCannonHitLand01,

    FxLandHitScale = 2,
    FxUnitHitScale = 2,
    FxPropHitScale = 2,
    FxWaterHitScale = 2,

	-- FxTrails = UEF_Gauss01_Polytrails01,
	-- FxImpactUnit = UEF_Gauss01_ImpactUnit01,
	-- FxImpactProp = UEF_Gauss01_ImpactUnit01,
	-- FxImpactLand = UEF_Gauss01_Impact01,
	-- FxImpactShield = UEF_Shield_Impact_Small01,
	-- FxImpactWater = Water_Impact_Small01,
}
TypeClass = UCannonShell02