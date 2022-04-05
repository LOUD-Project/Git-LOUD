local TEnergyStorageUnit = import('/lua/defaultunits.lua').StructureUnit

local TIFCommanderDeathWeapon = import('/lua/terranweapons.lua').TIFCommanderDeathWeapon

local Buff = import('/lua/sim/Buff.lua')

UEB8765 = Class(TEnergyStorageUnit) {

    Weapons = {
        DeathWeapon = Class(TIFCommanderDeathWeapon) {},
    },

    OnCreate = function(self)
        TEnergyStorageUnit.OnCreate(self)
        self.Trash:Add(CreateStorageManip(self, 'B01', 'ENERGY', 0, 0, -2.4, 0, 0, 0))
    end,

}

TypeClass = UEB8765