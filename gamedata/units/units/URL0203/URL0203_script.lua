local CLandUnit = import('/lua/defaultunits.lua').MobileUnit

local CybranWeaponsFile = import('/lua/cybranweapons.lua')

local CDFElectronBolterWeapon = CybranWeaponsFile.CDFElectronBolterWeapon
local CDFMissileMesonWeapon = CybranWeaponsFile.CDFMissileMesonWeapon
local CANTorpedoLauncherWeapon = CybranWeaponsFile.CANTorpedoLauncherWeapon

URL0203 = Class(CLandUnit) {

    Weapons = {
        Bolter = Class(CDFElectronBolterWeapon) {},
        Rocket = Class(CDFMissileMesonWeapon) {},
        Torpedo = Class(CANTorpedoLauncherWeapon) {},
    },
    
}
TypeClass = URL0203