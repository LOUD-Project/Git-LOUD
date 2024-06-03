local ASeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local AIFQuasarAntiTorpedoWeapon = import('/lua/aeonweapons.lua').AIFQuasarAntiTorpedoWeapon

UAS0305 = Class(ASeaUnit) {

    Weapons = {
        AntiTorpedo01 = Class(AIFQuasarAntiTorpedoWeapon) {},
    },
    
    TimedSonarTTIdleEffects = { {Bones = {'Probe'},Type = 'SonarBuoy01'} },    
    
    CreateIdleEffects = function(self)
    
        ASeaUnit.CreateIdleEffects(self)    
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
        
		ASeaUnit.DestroyIdleEffects(self)
    end,

    OnMotionHorzEventChange = function( self, new, old )

        if self.Dead then
            return
        end

        ASeaUnit.OnMotionHorzEventChange( self, new, old )

		local Intel = __blueprints[self.BlueprintID].Intel

        -- blueprint defaults --
        local radar = Intel.RadarRadius or 2
        local sonar = Intel.SonarRadius or 2
        local Omni  = Intel.OmniRadius or 2
        
        if ( old == 'Stopped' or (old == 'Stopping' and (new == 'Cruise' or new == 'TopSpeed'))) then
        
            -- intel ranges are halved while moving
            self:SetIntelRadius('Radar', self:GetIntelRadius('Radar') * 0.5)
            self:SetIntelRadius('Sonar', self:GetIntelRadius('Sonar') * 0.5)
            self:SetIntelRadius('Omni', self:GetIntelRadius('Omni') * 0.5)

        end

        if (new == 'Stopped' or new == 'Stopping') then
        
            -- intel ranges are normalized
            self:SetIntelRadius('Radar', self:GetIntelRadius('Radar') * 2)
            self:SetIntelRadius('Sonar', self:GetIntelRadius('Sonar') * 2)
            self:SetIntelRadius('Omni', self:GetIntelRadius('Omni') * 2)

        end

    end,

}

TypeClass = UAS0305