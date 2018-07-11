local TEnergyStorageUnit = import('/lua/terranunits.lua').TEnergyStorageUnit
local TWalkingLandUnit = import('/lua/terranunits.lua').TWalkingLandUnit
local TerranWeaponFile = import('/lua/terranweapons.lua')
local TIFCommanderDeathWeapon = TerranWeaponFile.TIFCommanderDeathWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')
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