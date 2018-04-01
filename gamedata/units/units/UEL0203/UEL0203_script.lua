local TRiotGunMuzzleFxTank = import('/lua/EffectTemplates.lua').TRiotGunMuzzleFxTank
local THoverLandUnit = import('/lua/terranunits.lua').THoverLandUnit
local TDFRiotWeapon = import('/lua/terranweapons.lua').TDFRiotWeapon

UEL0203 = Class(THoverLandUnit) {
    Weapons = {
        Riotgun01 = Class(TDFRiotWeapon) {
            FxMuzzleFlash = TRiotGunMuzzleFxTank
        },
    },
}

TypeClass = UEL0203