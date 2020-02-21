-----------------------------------------------------------------------------
--  File     :  /projectiles/cybran/cantiair02/cantiair02_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran AntiAir: CAntiAir02
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

CAntiAir02 = Class(import('/lua/sim/defaultprojectiles.lua').SinglePolyTrailProjectile) {
	FxImpactTrajectoryAligned =true,

	PolyTrail = '/mods/BattlePack/effects/emitters/w_c_aa01_p_03_polytrail_emit.bp',

    FxImpactUnit = {'/effects/emitters/auto_cannon_hit_flash_01_emit.bp', },
    FxImpactProp ={'/effects/emitters/auto_cannon_hit_flash_01_emit.bp', },
    FxImpactAirUnit = {'/effects/emitters/auto_cannon_hit_flash_01_emit.bp', },
    FxImpactLand = {'/effects/emitters/auto_cannon_hit_flash_01_emit.bp', },


}
TypeClass = CAntiAir02