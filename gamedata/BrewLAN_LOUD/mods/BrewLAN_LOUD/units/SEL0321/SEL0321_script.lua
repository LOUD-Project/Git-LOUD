local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TAMInterceptorWeapon = import('/lua/terranweapons.lua').TAMInterceptorWeapon

SEL0321 = Class(TLandUnit) {

    Weapons = {
        AntiMissile = Class(TAMInterceptorWeapon) {},
    },
    
}

TypeClass = SEL0321
