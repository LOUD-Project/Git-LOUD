local CSonarUnit = import('/lua/defaultunits.lua').SonarUnit

URB3102 = Class(CSonarUnit) {

    TimedSonarTTIdleEffects = {
        {Bones = {'URB3102'},Offset = {0,-0.8,0},Type = 'SonarBuoy01'}
    },

    CreateIdleEffects = function(self)
    
        CSonarUnit.CreateIdleEffects(self)

        self.TimedSonarEffectsThread = self:ForkThread( self.TimedIdleSonarEffects )
		
    end,

    TimedIdleSonarEffects = function( self )
	
        local layer = self:GetCurrentLayer()
        local army = self:GetArmy()
        local pos = self:GetPosition()
        
        if self.TimedSonarTTIdleEffects then
		
            while not self:IsDead() do
			
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
    
}

TypeClass = URB3102