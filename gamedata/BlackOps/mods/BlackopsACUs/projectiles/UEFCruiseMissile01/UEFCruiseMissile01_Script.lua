#
# Terran Land-Based Cruise Missile
#
local UEFCruiseMissile01Projectile = import('/mods/BlackopsEXUnits/lua/EXBlackOpsprojectiles.lua').UEFCruiseMissile01Projectile
local Explosion = import('/lua/defaultexplosions.lua')

UEFCruiseMissile01 = Class(UEFCruiseMissile01Projectile) {

    FxAirUnitHitScale = 1.5,
    FxLandHitScale = 1.5,
    FxNoneHitScale = 1.5,
    FxPropHitScale = 1.5,
    FxProjectileHitScale = 1.5,
    FxProjectileUnderWaterHitScale = 1.5,
    FxShieldHitScale = 1.5,
    FxUnderWaterHitScale = 1.5,
    FxUnitHitScale = 1.5,
    FxWaterHitScale = 1.5,
    FxOnKilledScale = 1.5,

    OnCreate = function(self)
        UEFCruiseMissile01Projectile.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 1.2)
        self:ForkThread(self.CruiseMissileThread)
    end,

    CruiseMissileThread = function(self)
        self:SetTurnRate(180)
        WaitSeconds(2)
        self:SetTurnRate(180)
        WaitSeconds(1)
        self:SetTurnRate(360)
    end,

}
TypeClass = UEFCruiseMissile01

