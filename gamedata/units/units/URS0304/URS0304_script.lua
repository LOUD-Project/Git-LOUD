local CSubUnit =  import('/lua/defaultunits.lua').SubUnit

local CybranWeapons = import('/lua/cybranweapons.lua')

local CIFMissileLoaWeapon = CybranWeapons.CIFMissileLoaWeapon
local CIFMissileStrategicWeapon = CybranWeapons.CIFMissileStrategicWeapon
local CANTorpedoLauncherWeapon = CybranWeapons.CANTorpedoLauncherWeapon

URS0304 = Class(CSubUnit) {

    Weapons = {
	
        NukeMissile = Class(CIFMissileStrategicWeapon){},
        CruiseMissile = Class(CIFMissileLoaWeapon){},
        Torpedo = Class(CANTorpedoLauncherWeapon){},

    },

}

TypeClass = URS0304

