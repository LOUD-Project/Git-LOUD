local TSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local TANTorpedoAngler = import('/lua/terranweapons.lua').TANTorpedoAngler

local CreateBuildCubeThread = import('/lua/EffectUtilities.lua').CreateBuildCubeThread

UES0305 = Class(TSeaUnit) {

    Weapons = {
        Torpedo01 = Class(TANTorpedoAngler) {},
    },
    
    TimedSonarTTIdleEffects = {
        { Bones = {'B14'}, Offset = {0,-0.6,0}, Type = 'SonarBuoy01' },
    }, 

    StartBeingBuiltEffects = function(self, builder, layer)
	
    	self:HideBone(0, true)

		self.BeingBuiltShowBoneTriggered = false
		
		if self:GetBlueprint().General.UpgradesFrom != builder:GetUnitId() then
			self.OnBeingBuiltEffectsBag:Add( self:ForkThread( CreateBuildCubeThread, builder, self.OnBeingBuiltEffectsBag )	)		
		end
		
    end,    

    CreateIdleEffects = function(self)

        self.TimedSonarEffectsThread = self:ForkThread( self.TimedIdleSonarEffects )
		
    end,
    
    DestroyIdleEffects = function(self)
	
		if self.TimedSonarEffectsThread then
		
			self.TimedSonarEffectsThread:Destroy()
			
		end

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

    OnMotionHorzEventChange = function( self, new, old )

        if self.Dead then
            return
        end

        TSeaUnit.OnMotionHorzEventChange( self, new, old )

		local Intel = __blueprints[self.BlueprintID].Intel

        -- blueprint defaults --
        local radar = Intel.RadarRadius or 2
        local sonar = Intel.SonarRadius or 2
        local Omni  = Intel.OmniRadius or 2
        
        if old == 'Stopped' then    -- or (old == 'Stopping' and (new == 'Cruise' or new == 'TopSpeed'))) then
        
            -- intel ranges are halved while moving
            self:SetIntelRadius('Radar', self:GetIntelRadius('Radar') * 0.5)
            self:SetIntelRadius('Sonar', self:GetIntelRadius('Sonar') * 0.5)
            self:SetIntelRadius('Omni', self:GetIntelRadius('Omni') * 0.5)

        end

        if new == 'Stopped' then
        
            -- intel ranges are normalized
            self:SetIntelRadius('Radar', self:GetIntelRadius('Radar') * 2)
            self:SetIntelRadius('Sonar', self:GetIntelRadius('Sonar') * 2)
            self:SetIntelRadius('Omni', self:GetIntelRadius('Omni') * 2)

        end

    end,

}

TypeClass = UES0305