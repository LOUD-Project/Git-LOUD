local AMassCollectionUnit = import('/lua/defaultunits.lua').MassCollectionUnit

UAB1202 = Class(AMassCollectionUnit) {
    
    OnStartBuild = function(self, unitBeingBuilt, order)
        AMassCollectionUnit.OnStartBuild(self, unitBeingBuilt, order)
        if not self.AnimationManipulator then return end
        self.AnimationManipulator:SetRate(0)
        self.AnimationManipulator:Destroy()
        self.AnimationManipulator = nil
    end,

    PlayActiveAnimation = function(self)
        AMassCollectionUnit.PlayActiveAnimation(self)
        if not self.AnimationManipulator then
            self.AnimationManipulator = CreateAnimator(self)
            self.Trash:Add(self.AnimationManipulator)
        end
        self.AnimationManipulator:PlayAnim(self:GetBlueprint().Display.AnimationActivate, true)
    end,

    OnProductionPaused = function(self)
        AMassCollectionUnit.OnProductionPaused(self)
        if not self.AnimationManipulator then return end
        self.AnimationManipulator:SetRate(0)
    end,

    OnProductionUnpaused = function(self)
        AMassCollectionUnit.OnProductionUnpaused(self)
        if not self.AnimationManipulator then return end
        self.AnimationManipulator:SetRate(1)
    end,

}   
    
    
TypeClass = UAB1202
    
    
    