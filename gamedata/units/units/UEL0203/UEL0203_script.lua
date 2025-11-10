local THoverLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TRiotGunMuzzleFxTank = import('/lua/EffectTemplates.lua').TRiotGunMuzzleFxTank
local TDFRiotWeapon = import('/lua/terranweapons.lua').TDFRiotWeapon
local AANDepthChargeBombWeapon      = import('/lua/aeonweapons.lua').AANDepthChargeBombWeapon

UEL0203 = Class(THoverLandUnit) {
    Weapons = {
        Riotgun01 = Class(TDFRiotWeapon) { FxMuzzleFlash = TRiotGunMuzzleFxTank },
        DepthCharge = Class(AANDepthChargeBombWeapon) {},
    },
}

TypeClass = UEL0203