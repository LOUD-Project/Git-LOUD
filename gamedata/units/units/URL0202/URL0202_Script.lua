
local CLandUnit = import('/lua/defaultunits.lua').MobileUnit
local CDFParticleCannonWeapon = import('/lua/terranweapons.lua').TDFHiroPlasmaCannon

URL0202 = Class(CLandUnit) {
    Weapons = {
        MainGun = Class(CDFParticleCannonWeapon) {},
    },
}

TypeClass = URL0202