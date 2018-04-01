
local TPodTowerUnit = import('/lua/terranunits.lua').TPodTowerUnit

XEB0204 = Class(TPodTowerUnit) {
    OnStopBeingBuilt = function(self,builder,layer)
        TPodTowerUnit.OnStopBeingBuilt(self,builder,layer)
        if not self.OpenAnim then
            self.OpenAnim = CreateAnimator(self)
            self.Trash:Add(self.OpenAnim)
        end
        self.OpenAnim:PlayAnim(self:GetBlueprint().Display.AnimationOpen, false):SetRate(0.4)
    end,
}

TypeClass = XEB0204