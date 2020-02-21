-----------------------------------------------------------------------------
--  File     :  /projectiles/cybran/claser06/claser06_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran Laser: CLaser01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local EffectTemplate = import('/lua/EffectTemplates.lua')
CLaser06 = Class(import('/lua/sim/defaultprojectiles.lua').SinglePolyTrailProjectile) {
	FxImpactTrajectoryAligned =true,

	PolyTrail = '/mods/BattlePack/effects/emitters/w_c_aa01_p_03_polytrail_emit.bp',

    FxImpactUnit = EffectTemplate.CElectronBolterHitUnit01,
    FxImpactProp = EffectTemplate.CElectronBolterHitUnit01,
    FxImpactLand = EffectTemplate.CElectronBolterHitLand01,

}
TypeClass = CLaser06