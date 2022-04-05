local THoverLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TRiotGunMuzzleFxTank = import('/lua/EffectTemplates.lua').TRiotGunMuzzleFxTank
local TDFRiotWeapon = import('/lua/terranweapons.lua').TDFRiotWeapon

UEL0203 = Class(THoverLandUnit) {
    Weapons = {
        Riotgun01 = Class(TDFRiotWeapon) {
            FxMuzzleFlash = TRiotGunMuzzleFxTank
        },
    },
}

TypeClass = UEL0203