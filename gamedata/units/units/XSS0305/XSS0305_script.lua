local SSeaUnit = import('/lua/seraphimunits.lua').SSeaUnit

local SeraphimWeapons = import('/lua/seraphimweapons.lua')
local SANAnaitTorpedo = SeraphimWeapons.SANAnaitTorpedo

local CreateBuildCubeThread = import('/lua/EffectUtilities.lua').CreateBuildCubeThread

XSS0305 = Class(SSeaUnit) {

    Weapons = {
	
        Torpedo01 = Class(SANAnaitTorpedo) {},
		
    },
    
    TimedSonarTTIdleEffects = {
        {
            Bones = {
                'B14',
            },
            Offset = {
                0,
                -0.6,
                0,
            },
            Type = 'SonarBuoy01',
        },
    }, 

    CreateIdleEffects = function(self)
	
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
    
    DestroyIdleEffects = function(self)
	
		if self.TimedSonarEffectsThread then
			self.TimedSonarEffectsThread:Destroy()
		end

    end,     
    
    StartBeingBuiltEffects = function(self, builder, layer)
	
    	self:HideBone(0, true)
		self.BeingBuiltShowBoneTriggered = false
		
		if self:GetBlueprint().General.UpgradesFrom != builder:GetUnitId() then
			self.OnBeingBuiltEffectsBag:Add( self:ForkThread( CreateBuildCubeThread, builder, self.OnBeingBuiltEffectsBag )	)		
		end
		
    end,          
}

TypeClass = XSS0305