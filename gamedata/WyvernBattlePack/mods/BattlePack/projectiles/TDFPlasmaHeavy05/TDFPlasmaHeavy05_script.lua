#****************************************************************************
#**
#**  File     :  /effects/projectiles/TDFPlasmsaHeavy04/TDFPlasmsaHeavy04_script.lua
#**  Author(s):  Gordon Duclos
#**
#**  Summary  :  UEF Heavy Plasma Cannon projectile, UEL0303
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

TDFPlasmaHeavy05 = Class(import('/lua/terranprojectiles.lua').THeavyPlasmaCannonProjectile) {

    FxTrail = '/mods/BattlePack/effects/emitters/alternateplasma_cannon_trail_02_emit.bp',
    FxTrailScale = 0.5,
    FxPropHitScale = 0.5,
    FxShieldHitScale = 0.5,
    FxLandHitScale = 0.5,
    FxUnitHitScale = 0.5,
    FxWaterHitScale = 0.5,
}
TypeClass = TDFPlasmaHeavy05

