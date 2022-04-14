local CEnergyStorageUnit= import('/lua/defaultunits.lua').StructureUnit

URB1105 = Class(CEnergyStorageUnit) {
    DestructionPartsChassisToss = {'URB1105'},

    OnStopBeingBuilt = function(self,builder,layer)
        CEnergyStorageUnit.OnStopBeingBuilt(self,builder,layer)
        self:ForkThread(self.AnimThread)
    end,

    AnimThread = function(self)

        local myBlueprint = __blueprints[self.BlueprintID]
        
        if myBlueprint.Audio.Activate then
            self:PlaySound(myBlueprint.Audio.Activate)
        end

        local sliderManip = CreateStorageManip(self, 'Lift', 'ENERGY', 0, 0, 0, 0, .8, 0)
    end,
}

TypeClass = URB1105