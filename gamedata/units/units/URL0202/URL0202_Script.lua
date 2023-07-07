local CLandUnit = import('/lua/defaultunits.lua').MobileUnit

local CDFParticleCannonWeapon = import('/lua/cybranweapons.lua').CDFParticleCannonWeapon

URL0202 = Class(CLandUnit) {
    Weapons = {
        MainGun = Class(CDFParticleCannonWeapon) {},
    },
}

TypeClass = URL0202