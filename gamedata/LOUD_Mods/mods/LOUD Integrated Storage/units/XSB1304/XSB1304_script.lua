
local SMassCollectionUnit = import('/lua/seraphimunits.lua').SMassCollectionUnit

XSB1304 = Class(SMassCollectionUnit) {

	OnStopBeingBuilt = function(self,builder,layer)
        SMassCollectionUnit.OnStopBeingBuilt(self,builder,layer)
        self.AnimationManipulator = CreateAnimator(self)
        self.Trash:Add(self.AnimationManipulator)
        self.AnimationManipulator:PlayAnim(self:GetBlueprint().Display.AnimationActivate, true)
    end,
    
    OnStartBuild = function(self, unitBeingBuilt, order)
        SMassCollectionUnit.OnStartBuild(self, unitBeingBuilt, order)
        if not self.AnimationManipulator then return end
        self.AnimationManipulator:SetRate(0)
        self.AnimationManipulator:Destroy()
        self.AnimationManipulator = nil
    end,
    
    OnProductionPaused = function(self)
        SMassCollectionUnit.OnProductionPaused(self)
        if not self.AnimationManipulator then return end
        self.AnimationManipulator:SetRate(0)
    end,

    OnProductionUnpaused = function(self)
        SMassCollectionUnit.OnProductionUnpaused(self)
        if not self.AnimationManipulator then return end
        self.AnimationManipulator:SetRate(1)
    end,

}

TypeClass = XSB1304
    
    
    