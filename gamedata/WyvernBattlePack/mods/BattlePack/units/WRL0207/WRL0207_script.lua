local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

WRL0207 = Class(CWalkingLandUnit) {

	OnStopBeingBuilt = function(self,builder,layer)
    
        CWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
        
        self.Rotator1 = CreateRotator(self, 'Shaft', 'y', nil, 30, 5, 30)
        self.Trash:Add(self.Rotator1)
		self.ShieldEffectsBag = {}
    end,
	
	OnShieldEnabled = function(self)
    
        CWalkingLandUnit.OnShieldEnabled(self)
        
        if self.Rotator1 then
            self.Rotator1:SetTargetSpeed(10)
        end
        
        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end

    end,

    OnShieldDisabled = function(self)
    
        CWalkingLandUnit.OnShieldDisabled(self)
        
        self.Rotator1:SetTargetSpeed(0)
        
        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
    end,

}

TypeClass = WRL0207
