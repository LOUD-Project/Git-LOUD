local CConstructionStructureUnit = import('/lua/cybranunits.lua').CConstructionStructureUnit

XRB0104 = Class(CConstructionStructureUnit) {

    OnStartBuild = function(self, unitBeingBuilt, order)

        local myArmy = self:GetAIBrain().ArmyIndex
        local otherArmy = unitBeingBuilt:GetAIBrain().ArmyIndex
		
        if order != 'Repair' or (IsAlly( myArmy, otherArmy) and not ArmyIsCivilian( otherArmy)) then
		
			CConstructionStructureUnit.OnStartBuild(self, unitBeingBuilt, order)
        
			if not self.AnimationManipulator then
            
				self.AnimationManipulator = CreateAnimator(self)
				self.Trash:Add(self.AnimationManipulator)
			end
            
			self.AnimationManipulator:PlayAnim(__blueprints[self.BlueprintID].Display.AnimationOpen, false):SetRate(4)
			
        else
            IssueStop( {self} )
            IssueClearCommands( {self} )
        end
    end,
    
    OnStopBuild = function(self, unitBeingBuilt)
    
        CConstructionStructureUnit.OnStopBuild(self, unitBeingBuilt)
        
        if not self.AnimationManipulator then
        
            self.AnimationManipulator = CreateAnimator(self)
            self.Trash:Add(self.AnimationManipulator)
        end
        
        self.AnimationManipulator:SetRate(-4)
    end,
}

TypeClass = XRB0104