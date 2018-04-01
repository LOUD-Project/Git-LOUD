local CConstructionStructureUnit = import('/lua/cybranunits.lua').CConstructionStructureUnit

BRB0004 = Class(CConstructionStructureUnit){
    
    OnStartBuild = function(self, unitBeingBuilt, order)
        CConstructionStructureUnit.OnStartBuild(self, unitBeingBuilt, order)
        
        if not self.AnimationManipulator then
            self.AnimationManipulator = CreateAnimator(self)
            self.Trash:Add(self.AnimationManipulator)
        end
        self.AnimationManipulator:PlayAnim(self:GetBlueprint().Display.AnimationOpen, false):SetRate(1)
    end,
    
    OnStopBuild = function(self, unitBeingBuilt)
        CConstructionStructureUnit.OnStopBuild(self, unitBeingBuilt)
        
        if not self.AnimationManipulator then
            self.AnimationManipulator = CreateAnimator(self)
            self.Trash:Add(self.AnimationManipulator)
        end
        self.AnimationManipulator:SetRate(-1)
    end,
	
    --Make this unit invulnerable
    OnDamage = function()
    end,
	
	Parent = nil,

    SetParent = function(self, parent, droneName)
        self.Parent = parent
        self.Drone = droneName
    end,
}
TypeClass = BRB0004