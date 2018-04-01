#****************************************************************************
#**  File     :  /mods/4DC/projectiles/Over_Charge/Over_Charge_script_script.lua
#**
#**  Author(s):  EbolaSoup, Resin Smoker, Optimus Prime, Vissroid
#**
#**  Summary  :  UEF Over_Charge for Rampage Assault Not 
#**
#**  Copyright © 2010 4DC  All rights reserved.
#****************************************************************************
local Over_ChargeProjectile = import('/mods/4DC/lua/4D_projectiles.lua').Over_ChargeProjectile                          
local EffectTemplate = import('/lua/EffectTemplates.lua')

Over_Charge = Class(Over_ChargeProjectile) {
    FxTrails = EffectTemplate.TCommanderOverchargeFXTrail01,
    FxTrailScale = 0.5, 
}
TypeClass = Over_Charge