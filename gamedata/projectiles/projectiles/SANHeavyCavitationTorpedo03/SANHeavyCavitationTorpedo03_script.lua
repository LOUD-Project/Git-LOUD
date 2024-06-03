local SHeavyCavitationTorpedo = import('/lua/seraphimprojectiles.lua').SHeavyCavitationTorpedo

local EffectTemplate = import('/lua/EffectTemplates.lua')

local ForkThread = ForkThread
local WaitSeconds = WaitSeconds

local VDist2 = VDist2

local CreateEmitterOnEntity = CreateEmitterOnEntity

-- this torpedo is the split projectile created by the Heavy Cavitation Torpedo 1 & 2 ( from T2 & T3 Torpedo launcher )
-- the essential difference is that this torp doesn't start tracking for several ticks depending on how far it is
-- from the target
SANHeavyCavitationTorpedo03 = Class(SHeavyCavitationTorpedo) {

    OnCreate = function(self, inWater)
	
        SHeavyCavitationTorpedo.OnCreate( self, inWater )
        
        self:TrackTarget(false)
		
        self:ForkThread( self.PauseUntilTrack )
		
        CreateEmitterOnEntity( self, self:GetArmy(), EffectTemplate.SHeavyCavitationTorpedoFxTrails ):ScaleEmitter(0.35)  
		
    end,

    PauseUntilTrack = function(self)
	
        local tpos = self:GetCurrentTargetPosition()
	
        local mpos = self:GetPosition()
		
        local distance = VDist2(mpos[1], mpos[3], tpos[1], tpos[3])
		
        local waittime
		
        -- The pause time needs to scale down depending on how far away the target is, otherwise
        -- the torpedoes will initially shoot past their target.
        if distance > 6 then
		
            waittime = .4
			
            if distance > 12 then
			
                waittime = .7
				
                if distance > 18 then
				
                    waittime = 1
					
                end
            end
			
        else
		
            waittime = .2
		
			self:SetTurnRate(240)

        end
		
        WaitSeconds(waittime)
		
        self:TrackTarget(true)

    end,

}

TypeClass = SANHeavyCavitationTorpedo03