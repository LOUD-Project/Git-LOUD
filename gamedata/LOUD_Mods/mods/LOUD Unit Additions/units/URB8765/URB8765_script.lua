local CEnergyStorageUnit= import('/lua/cybranunits.lua').CEnergyStorageUnit
local CWeapons = import('/lua/cybranweapons.lua')
local CIFCommanderDeathWeapon = CWeapons.CIFCommanderDeathWeapon

URB8765 = Class(CEnergyStorageUnit) {
    DestructionPartsChassisToss = {'URB8765'},

    OnStopBeingBuilt = function(self,builder,layer)
        CEnergyStorageUnit.OnStopBeingBuilt(self,builder,layer)
        self:ForkThread(self.AnimThread)
    end,

    Weapons = {
        DeathWeapon = Class(CIFCommanderDeathWeapon) {},
    },

    AnimThread = function(self)
        # Play the "activate" sound
        local myBlueprint = self:GetBlueprint()
        if myBlueprint.Audio.Activate then
            self:PlaySound(myBlueprint.Audio.Activate)
        end

        local sliderManip = CreateStorageManip(self, 'Lift', 'ENERGY', 0, 0, 0, 0, 6.25, 0)
    end,
}

TypeClass = URB8765