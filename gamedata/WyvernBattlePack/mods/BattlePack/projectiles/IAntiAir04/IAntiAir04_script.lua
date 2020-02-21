-----------------------------------------------------------------------------
--  File     : /projectiles/illuminate/iantiair04/iantiair04_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Illuminate AntiAir: IAntiAir04
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local EffectTemplate = import('/lua/EffectTemplates.lua')
IAntiAir04 = Class(import('/mods/BattlePack/lua/BattlePackDefaultProjectiles.lua').SC2MultiPolyTrailProjectile) {

	FxTrails = {'/mods/BattlePack/effects/emitters/w_i_aa01_p_03_brightglow_emit.bp'},

    PolyTrails = {
	'/mods/BattlePack/effects/emitters/w_i_aa01_p_01_polytrails_emit.bp',
	'/mods/BattlePack/effects/emitters/w_i_aa01_p_02_polytrails_emit.bp',
	},

	PolyTrailOffset = {0,0},

    FxImpactAirUnit = EffectTemplate.SShleoCannonUnitHit,
    FxImpactLand = EffectTemplate.SShleoCannonLandHit,
    FxImpactWater = EffectTemplate.SShleoCannonLandHit,
    FxImpactNone = EffectTemplate.SShleoCannonHit,
    FxImpactProp = EffectTemplate.SShleoCannonHit, 
    FxImpactUnit = EffectTemplate.SShleoCannonUnitHit, 
}

TypeClass = IAntiAir04