local SBlazarAAAutoCannon = import('/lua/seraphimprojectiles.lua').SBlazarAAAutoCannon

SAABlazarAutoCannon02 = Class(SBlazarAAAutoCannon) {

    OnImpact = function(self, TargetType, TargetEntity)
        SBlazarAAAutoCannon.OnImpact(self, TargetType, TargetEntity)
    end,

}
TypeClass = SAABlazarAutoCannon02
