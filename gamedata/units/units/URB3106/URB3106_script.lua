local CMassStorageUnit = import('/lua/defaultunits.lua').StructureUnit

URB1106 = Class(CMassStorageUnit) {
    OnStopBeingBuilt = function(self,builder,layer)
        CMassStorageUnit.OnStopBeingBuilt(self,builder,layer)
        self:ForkThread(self.AnimThread)
        local myBlueprint = self:GetBlueprint()
        if myBlueprint.Audio.Activate then
            self:PlaySound(myBlueprint.Audio.Activate)
        end
    end,

    AnimThread = function(self)
        local sliderManip = CreateStorageManip(self, 'B01', 'MASS', 0, 0, 0, 0, 0, 1.098)
    end,
}

TypeClass = URB1106