local CStructureUnit = import('/lua/cybranunits.lua').CStructureUnit

local CKrilTorpedoLauncherWeapon = import('/lua/cybranweapons.lua').CKrilTorpedoLauncherWeapon

XRB2308 = Class(CStructureUnit) {

    Weapons = {
        Turret01 = Class(CKrilTorpedoLauncherWeapon) {},
    },
}

TypeClass = XRB2308