local SHeavyCavitationTorpedo = import('/lua/seraphimprojectiles.lua').SHeavyCavitationTorpedo 

local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local EffectTemplate = import('/lua/EffectTemplates.lua')

local ForkThread = ForkThread
local WaitSeconds = WaitSeconds

local CreateEmitterAtEntity = CreateEmitterAtEntity
local CreateEmitterOnEntity = CreateEmitterOnEntity

-- This torpedo is air dropped and splits into 3
SANHeavyCavitationTorpedo01 = Class(SHeavyCavitationTorpedo) {

	FxSplashScale = .5,
	
	FxEnterWaterEmitter = {'/effects/emitters/destruction_water_splash_wash_01_emit.bp'},

    OnCreate = function( self, inWater )
	
        SHeavyCavitationTorpedo.OnCreate( self, inWater )
        
        if not inWater then
	
            self.AirTrails = CreateEmitterOnEntity(self,self:GetArmy(),EffectTemplate.SHeavyCavitationTorpedoFxTrails02)
            
        else
            self.OnEnterWater(self)
        end
		
    end,
   
	OnEnterWater = function(self)
		
		local army = self:GetArmy()

		for i in self.FxEnterWaterEmitter do
		
			CreateEmitterAtEntity(self,army,self.FxEnterWaterEmitter[i]):ScaleEmitter(self.FxSplashScale)
			
		end
		
        if self.AirTrails then
            self.AirTrails:Destroy()
        end
		
		CreateEmitterOnEntity(self,army,EffectTemplate.SHeavyCavitationTorpedoFxTrails)
		
    	self:SetCollideSurface(false)
		
		self:ForkThread(self.ProjectileSplit)
		
	end,
 
	ProjectileSplit = function(self)
	
		local LOUDSIN = math.sin
		local LOUDCOS = math.cos
		local CreateEmitterAtEntity = CreateEmitterAtEntity
		
		WaitTicks(3)
		
		-- this is the projectile it will split into --
		local ChildProjectileBP = '/projectiles/SANHeavyCavitationTorpedo03/SANHeavyCavitationTorpedo03_proj.bp'  
		local numProjectiles = 3

		local vx, vy, vz = self:GetVelocity()

		--local velocity = 7
		
		-- Create projectiles in a dispersal pattern
		local angle             = 6.28 / numProjectiles
		local angleInitial      = RandomFloat( 0, angle )
		local angleVariation    = angle * 0.65      -- Adjusts angle variance spread
		local spreadMul         = .70               -- Adjusts the width of the dispersal        
	    
		-- disabled the split effect
	    local FxFragEffect = EffectTemplate.SHeavyCavitationTorpedoSplit

        -- Split effects
        for k, v in FxFragEffect do
            CreateEmitterAtEntity( self, self:GetArmy(), v )
        end
        
        self:SetVelocity(0)
	    
		-- Divide the damage between each projectile.  The damage in the BP is used as the initial projectile's 
		-- damage, in case the torpedo hits something before it splits.
		local DividedDamageData = self.DamageData
		
		DividedDamageData.DamageAmount = DividedDamageData.DamageAmount / numProjectiles
        
        local xVec, zVec, proj
	    
		-- Launch projectiles at semi-random angles away from split location
		for i = 0, (numProjectiles -1) do
		
			xVec = vx + (LOUDSIN(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul
			zVec = vz + (LOUDCOS(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul 
			
			proj = self:CreateChildProjectile(ChildProjectileBP)
			
			proj:SetVelocity(xVec, vy/3 ,zVec)
			
			proj:PassDamageData(DividedDamageData)
			
			proj:PassData(self:GetTrackingTarget())  
			
			--proj:SetVelocity(velocity)
			
		end
		
        -- destroy the original projectile
		self:Destroy()
		
	end,	
	
}

TypeClass = SANHeavyCavitationTorpedo01