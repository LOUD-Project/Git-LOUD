local SHeavyCavitationTorpedo = import('/lua/seraphimprojectiles.lua').SHeavyCavitationTorpedo
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local EffectTemplate = import('/lua/EffectTemplates.lua')

local ForkThread = ForkThread
local WaitSeconds = WaitSeconds

local CreateEmitterOnEntity = CreateEmitterOnEntity

local VDist2 = VDist2

-- this is the split projectile created by the Heavy Cavitation Torpedo 2 ( from T2 Torp Launcher )
SANHeavyCavitationTorpedo04 = Class(SHeavyCavitationTorpedo) {

	CountDownLength = 10,

	OnCreate = function(self)
	
		SHeavyCavitationTorpedo.OnCreate(self)
		
		self:ForkThread(self.PauseUntilTrack)
		
		CreateEmitterOnEntity(self,self:GetArmy(),EffectTemplate.SHeavyCavitationTorpedoFxTrails)
		
	end,

	PauseUntilTrack = function(self)
	
		local distance = self:GetDistanceToTarget()
		local waittime
		local turnrate = 540
		
		-- The pause time needs to scale down depending on how far away the target is, otherwise
		-- the torpedoes will initially shoot past their target.
		if distance > 6 then

			waittime = .45

			if distance > 12 then
			
				waittime = .7

				if distance > 18 then
					
					waittime = 1

				end

			end

		else
			
			waittime = .2
			turnrate = 720

		end

		WaitSeconds(waittime)
		
		self:SetAcceleration(3)
		
		self:SetMaxSpeed(10)
		
		self:TrackTarget(true)
		
		self:SetTurnRate(turnrate)

	end,

	GetDistanceToTarget = function(self)
	
		local tpos = self:GetCurrentTargetPosition()
		
		local mpos = self:GetPosition()
		
		local dist = VDist2(mpos[1], mpos[3], tpos[1], tpos[3])
		
		return dist
		
    end,

    OnLostTarget = function(self) # added
	
        self:SetMaxSpeed(2)
        self:SetAcceleration(-0.6)
        self:ForkThread(self.CountdownMovement)
		
    end,

    CountdownMovement = function(self) #added
	
        WaitSeconds(3)
		
        self:SetMaxSpeed(0)
        self:SetAcceleration(0)
        self:SetVelocity(0)
		self:SetLifetime(2)
		
    end,
	
}

TypeClass = SANHeavyCavitationTorpedo04