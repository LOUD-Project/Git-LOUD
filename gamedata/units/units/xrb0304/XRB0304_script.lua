local CConstructionStructureUnit = import('/lua/cybranunits.lua').CConstructionStructureUnit

XRB0304 = Class(CConstructionStructureUnit) {

    OnStartBeingBuilt = function(self, builder, layer)

        CConstructionStructureUnit.OnStartBeingBuilt(self, builder, layer)

        self:HideBone('xrb0304', true)

        self:ShowBone('TurretT3', true)
        self:ShowBone('Door3_B03', true)
        self:ShowBone('B03', true)
        self:ShowBone('Attachpoint03', true)
    end,   
    
    OnStartBuild = function(self, unitBeingBuilt, order)
	
        local myArmy = self:GetAIBrain():GetArmyIndex()
        local otherArmy = unitBeingBuilt:GetAIBrain():GetArmyIndex()
		
        if order != 'Repair' or (IsAlly( myArmy, otherArmy) and not ArmyIsCivilian( otherArmy)) then
		
			CConstructionStructureUnit.OnStartBuild(self, unitBeingBuilt, order)
        
			if not self.AnimationManipulator then
				self.AnimationManipulator = CreateAnimator(self)
				self.Trash:Add(self.AnimationManipulator)
			end
			self.AnimationManipulator:PlayAnim(self:GetBlueprint().Display.AnimationOpen, false):SetRate(1)
			
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
		
        self.AnimationManipulator:SetRate(-1)
    end,
}

TypeClass = XRB0304