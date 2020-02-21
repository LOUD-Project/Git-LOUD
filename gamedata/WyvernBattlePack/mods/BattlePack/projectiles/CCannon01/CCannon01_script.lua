-----------------------------------------------------------------------------
--  File     :  /projectiles/cybran/ccannon01/ccannon01_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran Cannon: CCannon01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local EffectTemplate = import('/lua/EffectTemplates.lua')
CCannon01 = Class(import('/lua/sim/defaultprojectiles.lua').SinglePolyTrailProjectile) {

FxTrail = '/mods/BattlePack/effects/emitters/w_c_las01_p_02_trail_emit.bp',
PolyTrail ='/mods/BattlePack/effects/emitters/w_c_las01_p_01_polytrail_emit.bp',

    FxImpactUnit = EffectTemplate.CHvyProtonCannonHitUnit,
    FxImpactProp = EffectTemplate.CHvyProtonCannonHitUnit,
    FxImpactLand = EffectTemplate.CHvyProtonCannonHitLand,
    FxImpactUnderWater = EffectTemplate.CHvyProtonCannonHit01,
    FxImpactWater = EffectTemplate.CHvyProtonCannonHit01,

}
TypeClass = CCannon01