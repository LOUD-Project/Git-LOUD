local ALandUnit = import('/lua/aeonunits.lua').ALandUnit
local ADFCannonQuantumWeapon = import('/lua/aeonweapons.lua').ADFCannonQuantumWeapon

UAL0202 = Class(ALandUnit) {

    Weapons = {
        MainGun = Class(ADFCannonQuantumWeapon) {}
    },
    
}
TypeClass = UAL0202