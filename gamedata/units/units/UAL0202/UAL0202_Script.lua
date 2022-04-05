local ALandUnit = import('/lua/defaultunits.lua').MobileUnit

local ADFCannonQuantumWeapon = import('/lua/aeonweapons.lua').ADFCannonQuantumWeapon

UAL0202 = Class(ALandUnit) {

    Weapons = {
        MainGun = Class(ADFCannonQuantumWeapon) {}
    },
    
}
TypeClass = UAL0202