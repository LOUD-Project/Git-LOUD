local ASeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local AIFQuasarAntiTorpedoWeapon = import('/lua/aeonweapons.lua').AIFQuasarAntiTorpedoWeapon

UAS0305 = Class(ASeaUnit) {

    Weapons = {
        AntiTorpedo01 = Class(AIFQuasarAntiTorpedoWeapon) {},
    },
    
    TimedSonarTTIdleEffects = {
        {
            Bones = {
                'Probe',
            },
            Type = 'SonarBuoy01',
        },
    },    
    
    CreateIdleEffects = function(self)
        --ASeaUnit.CreateIdleEffects(self)
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
        --ASeaUnit.DestroyIdleEffects(self)
    end,      
}

TypeClass = UAS0305