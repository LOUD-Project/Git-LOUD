local CSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

URB3302 = Class(CSeaUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
	
        CSeaUnit.OnStopBeingBuilt(self,builder,layer)
		
        --enable sonar economy
        self:SetMaintenanceConsumptionActive()
		
    end,

    TimedSonarTTIdleEffects = {
	
        {
            Bones = {
                'Plunger',
            },
            Type = 'SonarBuoy01',
        },
    }, 

    CreateIdleEffects = function(self)
	
        CSeaUnit.CreateIdleEffects(self)
        self.TimedSonarEffectsThread = self:ForkThread( self.TimedIdleSonarEffects )
		
    end,
    
    TimedIdleSonarEffects = function( self )
	
        local layer = self:GetCurrentLayer()
        local army = self:GetArmy()
        local pos = self:GetPosition()
        
        if self.TimedSonarTTIdleEffects then
			
			local CreateAttachedEmitter = CreateAttachedEmitter
			
            while not self.Dead do
			
                for kTypeGroup, vTypeGroup in self.TimedSonarTTIdleEffects do
				
                    local effects = self.GetTerrainTypeEffects( 'FXIdle', layer, pos, vTypeGroup.Type, nil )
       
       for kb, vBone in vTypeGroup.Bones do
					
                        for ke, vEffect in effects do
						
                            emit = CreateAttachedEmitter(self,vBone,army,vEffect):ScaleEmitter(vTypeGroup.Scale or 1)
							
                            if vTypeGroup.Offset then
							
                                emit:OffsetEmitter(vTypeGroup.Offset[1] or 0, vTypeGroup.Offset[2] or 0,vTypeGroup.Offset[3] or 0)
								
                            end
							
                        end
						
                    end 
					
				end
				
                WaitSeconds( 6.0 )
				
            end
			
        end
		
    end,
    
    DestroyIdleEffects = function(self)
	
		if self.TimedSonarEffectsThread then
			self.TimedSonarEffectsThread:Destroy()
		end

		CSeaUnit.DestroyIdleEffects(self)
    end,               
}

TypeClass = URB3302