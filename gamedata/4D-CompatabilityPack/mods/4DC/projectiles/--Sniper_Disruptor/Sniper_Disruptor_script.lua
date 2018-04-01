-----------------------------------------------------------------------------
--  File     : /mods/4DC/projectiles/Sniper_Disruptor/Sniper_Disruptor_script.lua
--
--  Author(s): EbolaSoup, Resin Smoker, Optimus Prime, Vissroid 
--
--  Summary  : Aeon Sniper Disruptor projectile
--
--  Copyright © 2010 4DC  All rights reserved.
-----------------------------------------------------------------------------

local AShieldDisruptorProjectile = import('/lua/aeonprojectiles.lua').AQuantumCannonProjectile --AShieldDisruptorProjectile
Sniper_DisruptorProjectile = import('/mods/4DC/lua/CustomAbilities/4D_ProjectileSuperClass/4D_ProjectileSuperClass.lua').ShieldDisruptor( AShieldDisruptorProjectile )
local EffectTemplate = import('/lua/EffectTemplates.lua')

Sniper_Disruptor = Class(Sniper_DisruptorProjectile) {
    FxImpactUnit =  EffectTemplate.ASonanceWeaponHit02,
    FxImpactProp =  EffectTemplate.ASonanceWeaponHit02,
    FxImpactLand =  EffectTemplate.ASonanceWeaponHit02,
    FxTrails = {
        '/effects/emitters/quantum_cannon_munition_05_emit.bp',
        '/effects/emitters/quantum_cannon_munition_06_emit.bp',  
    },
}
TypeClass = Sniper_Disruptor