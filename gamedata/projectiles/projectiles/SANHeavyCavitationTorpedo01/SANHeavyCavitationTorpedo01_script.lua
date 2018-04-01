local SHeavyCavitationTorpedo = import('/lua/seraphimprojectiles.lua').SHeavyCavitationTorpedo 

local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local EffectTemplate = import('/lua/EffectTemplates.lua')

local ForkThread = ForkThread
local WaitSeconds = WaitSeconds

local CreateEmitterAtEntity = CreateEmitterAtEntity
local CreateEmitterOnEntity = CreateEmitterOnEntity

-- This torpedo is dropped by the T2 Torpedo bomber --
-- but splits into 3 torpedoes ( see Cavitation Torpedo 4 )
SANHeavyCavitationTorpedo01 = Class(SHeavyCavitationTorpedo) {

	FxSplashScale = .4,
	
	FxEnterWaterEmitter = {'/effects/emitters/destruction_water_splash_wash_01_emit.bp'},	--'/effects/emitters/destruction_water_splash_ripples_01_emit.bp',

	OnEnterWater = function(self)
	
		SHeavyCavitationTorpedo.OnEnterWater(self)
		
		local army = self:GetArmy()

		for i in self.FxEnterWaterEmitter do
		
			CreateEmitterAtEntity(self,army,self.FxEnterWaterEmitter[i]):ScaleEmitter(self.FxSplashScale)
			
		end
		
		self.AirTrails:Destroy()
		
		CreateEmitterOnEntity(self,army,EffectTemplate.SHeavyCavitationTorpedoFxTrails)

		self:TrackTarget(true):StayUnderwater(true)
		
    	self:SetCollideSurface(false)
		
		self:SetTurnRate(540)
		
		self:ForkThread(self.ProjectileSplit)
		
	end,

    OnCreate = function( self, inWater )
	
        SHeavyCavitationTorpedo.OnCreate( self, inWater )
		
        -- if we are starting in the water then immediately switch to tracking in water
        self:TrackTarget(false)
		
        self.AirTrails = CreateEmitterOnEntity(self,self:GetArmy(),EffectTemplate.SHeavyCavitationTorpedoFxTrails02)
		
    end,
    
	ProjectileSplit = function(self)
	
		local LOUDPI = math.pi
		local LOUDSIN = math.sin
		local LOUDCOS = math.cos
		local CreateEmitterAtEntity = CreateEmitterAtEntity
		
		WaitTicks(10)
		
		-- this is the projectile it will split into --
		local ChildProjectileBP = '/projectiles/SANHeavyCavitationTorpedo03/SANHeavyCavitationTorpedo03_proj.bp'  
		local vx, vy, vz = self:GetVelocity()
		local velocity = 7
		
		-- Create projectiles in a dispersal pattern
		local numProjectiles = 3
		local angle = (2*LOUDPI) / numProjectiles
		local angleInitial = RandomFloat( 0, angle )
	    
		-- Randomization of the spread
		local angleVariation = angle * 0.3 -- Adjusts angle variance spread
		local spreadMul = .4 	-- Adjusts the width of the dispersal        
		local xVec = 0 
		local yVec = vy
		local zVec = 0
	    
		-- Divide the damage between each projectile.  The damage in the BP is used as the initial projectile's 
		-- damage, in case the torpedo hits something before it splits.
		local DividedDamageData = self.DamageData
		
		DividedDamageData.DamageAmount = DividedDamageData.DamageAmount / numProjectiles
	    
		-- disabled the split effect
	    local FxFragEffect = {}	--EffectTemplate.SHeavyCavitationTorpedoSplit

        -- Split effects
        for k, v in FxFragEffect do
            CreateEmitterAtEntity( self, self:GetArmy(), v )
        end
	    
		-- Launch projectiles at semi-random angles away from split location
		for i = 0, (numProjectiles -1) do
		
			xVec = vx + (LOUDSIN(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul
			zVec = vz + (LOUDCOS(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul 
			
			local proj = self:CreateChildProjectile(ChildProjectileBP)
			
			proj:PassDamageData(DividedDamageData)
			
			proj:PassData(self:GetTrackingTarget())  
			
			proj:SetVelocity(xVec,yVec,zVec)
			
			proj:SetVelocity(velocity)
			
		end
		
		self:Destroy()
		
	end,	
	
}

TypeClass = SANHeavyCavitationTorpedo01