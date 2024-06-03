local CLandUnit = import('/lua/defaultunits.lua').MobileUnit

local CybranWeaponsFile = import('/lua/cybranweapons.lua')

local CDFElectronBolterWeapon   = CybranWeaponsFile.CDFElectronBolterWeapon
local CDFMissileMesonWeapon     = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local TorpedoLauncher           = CybranWeaponsFile.CANNaniteTorpedoWeapon

CybranWeaponsFile = nil


URL0203 = Class(CLandUnit) {

    Weapons = {
        Bolter  = Class(CDFElectronBolterWeapon) {},
        Rocket  = Class(CDFMissileMesonWeapon) {},
        Torpedo = Class(TorpedoLauncher) {},
    },
    
}
TypeClass = URL0203