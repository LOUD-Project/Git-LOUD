local SLosaareAAAutoCannon = import('/lua/seraphimprojectiles.lua').SLosaareAAAutoCannon

SAALosaareAutoCannon02 = Class(SLosaareAAAutoCannon) {

    OnImpact = function(self, TargetType, TargetEntity)
        SLosaareAAAutoCannon.OnImpact(self, TargetType, TargetEntity)
    end,

}
TypeClass = SAALosaareAutoCannon02
