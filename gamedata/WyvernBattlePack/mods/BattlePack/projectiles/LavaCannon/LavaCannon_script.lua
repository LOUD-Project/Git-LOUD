-----------------------------------------------------------------------------
--  File     :  /projectiles/cybran/cartillery01/cartillery01_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran Artillery: CArtillery01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local NapalmProjectile01 = import('/mods/BattlePack/lua/BattlePackprojectiles.lua').NapalmProjectile01
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local EffectTemplate = import('/lua/EffectTemplates.lua')

EmtBpPath = '/effects/emitters/'
ModEmitterPath = '/mods/BattlePack/effects/emitters/'

LavaCannon = Class(NapalmProjectile01) {

	FxTrails = { 
			'/mods/BattlePack/effects/emitters/w_c_art02_p_03_glow_emit.bp',
			'/mods/BattlePack/effects/emitters/w_c_art02_p_04_glow_emit.bp',
			'/mods/BattlePack/effects/emitters/w_c_art02_p_05_glow_emit.bp',
			},

    FxTrailScale = 0.75,
    FxImpactUnit = {
        ModEmitterPath  .. 'napalm_fire_emit_2.bp',
        EmtBpPath .. 'napalm_01_emit.bp',
    },
    FxImpactProp = {
        ModEmitterPath  .. 'napalm_fire_emit_2.bp',
        EmtBpPath .. 'napalm_01_emit.bp',
    },
    FxImpactLand = {
        ModEmitterPath  .. 'napalm_fire_emit_2.bp',
        EmtBpPath .. 'napalm_01_emit.bp',
    },
    FxImpactWater = EffectTemplate.TNapalmHvyCarpetBombHitWater01,
    FxImpactUnderWater = {},

	FxNoneHitScale = 2,
    FxUnderWaterHitScale = 2,
    FxWaterHitScale = 2,
    FxLandHitScale = 2,
    FxUnitHitScale = 2,
}
TypeClass = LavaCannon