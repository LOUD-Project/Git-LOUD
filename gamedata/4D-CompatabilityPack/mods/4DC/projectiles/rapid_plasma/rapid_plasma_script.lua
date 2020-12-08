--****************************************************************************
--**  File     :  /mods/4DC/projectiles/rapid_plasma/rapid_plasma_script_script.lua
--**
--**  Author(s):  EbolaSoup, Resin Smoker, Optimus Prime, Vissroid
--**
--**  Summary  :  UEF Rapid Plasma for Rampage Assault 
--**
--**  Copyright � 2010 4DC  All rights reserved.
--****************************************************************************
local Rapid_PlasmaProjectile = import('/mods/4DC/lua/4D_projectiles.lua').Rapid_PlasmaProjectile
local EffectTemplate = import('/lua/EffectTemplates.lua')

Rapid_Plasma = Class(Rapid_PlasmaProjectile) {
    FxImpactLand = EffectTemplate.ALightMortarHit01,
    FxImpactProp = EffectTemplate.ALightMortarHit01,
    FxImpactUnit = EffectTemplate.ALightMortarHit01,
}
TypeClass = Rapid_Plasma