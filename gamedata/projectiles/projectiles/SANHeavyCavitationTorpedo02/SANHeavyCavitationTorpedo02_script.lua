local SHeavyCavitationTorpedo = import('/lua/seraphimprojectiles.lua').SHeavyCavitationTorpedo

local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local EffectTemplate = import('/lua/EffectTemplates.lua')

local ForkThread = ForkThread
local WaitSeconds = WaitSeconds

local CreateEmitterAtEntity = CreateEmitterAtEntity
local CreateEmitterOnEntity = CreateEmitterOnEntity

-- This torpedo is used by the T2 Torpedo Launcher --
-- and splits into 3 torpedoes ( see Cavitation Torpedo 3 )
SANHeavyCavitationTorpedo02 = Class(SHeavyCavitationTorpedo) {

    FxSplashScale = .4,
	
    FxEnterWaterEmitter = {'/effects/emitters/destruction_water_splash_ripples_01_emit.bp'},
	
    FxSplit = {
		'/effects/emitters/seraphim_heayvcavitation_torpedo_projectile_hit_01_emit.bp',
		'/effects/emitters/seraphim_heayvcavitation_torpedo_projectile_hit_02_emit.bp',
		'/effects/emitters/seraphim_heayvcavitation_torpedo_projectile_hit_03_emit.bp',
		'/effects/emitters/seraphim_heayvcavitation_torpedo_projectile_hit_04_emit.bp',
		'/effects/emitters/seraphim_heayvcavitation_torpedo_projectile_hit_05_emit.bp',
    },

    OnCreate = function(self, inwater)
	
        SHeavyCavitationTorpedo.OnCreate(self, inwater)
		
        if inwater then
            self:ForkThread(self.ProjectileSplit)
        else
    
            self:TrackTarget(false)             -- stop tracking

            self:SetAcceleration(0)             -- dont accelerate in the air

        end
		
    end,
    
    OnEnterWater = function(self)
		
        local army = self:GetArmy()

        for i in self.FxEnterWaterEmitter do --splash
            CreateEmitterAtEntity(self,army,self.FxEnterWaterEmitter[i]):ScaleEmitter(self.FxSplashScale)
        end	
	
        SHeavyCavitationTorpedo.OnEnterWater(self)
		
        self:ForkThread(self.ProjectileSplit)
		
    end,

    ProjectileSplit = function(self)
		
		local LOUDSIN = math.sin
		local LOUDCOS = math.cos
		local CreateEmitterAtEntity = CreateEmitterAtEntity
		
        WaitTicks(1)
        
        self:TrackTarget(true)
		
		-- this is the projectile it will split into --
        local ChildProjectileBP = '/projectiles/SANHeavyCavitationTorpedo03/SANHeavyCavitationTorpedo03_proj.bp'  
        local numProjectiles = 3		

        local vx, vy, vz = self:GetVelocity()
        local velocity = 5

        -- Create projectiles in a dispersal pattern
        local angle             = 6.28 / numProjectiles
        local angleInitial      = RandomFloat( 0, angle )
        local angleVariation    = angle * 0.32  -- Adjusts angle variance spread
        local spreadMul         = .38           -- Adjusts the width of the dispersal        

        local xVec = 0 
        local yVec = vy * .2
        local zVec = 0
        
		-- disabled the split effects for now
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
        for i = 1, numProjectiles do
		
            xVec = vx + (LOUDSIN(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul
            zVec = vz + (LOUDCOS(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul 
			
            proj = self:CreateChildProjectile(ChildProjectileBP)

            proj:SetVelocity(xVec, vy/5, zVec)
			
            proj:PassDamageData(DividedDamageData)
			
            proj:PassData(self:GetTrackingTarget())
			
            proj:SetVelocity(velocity)
			
        end 
        
        self:Destroy()
		
    end,
	
}

TypeClass = SANHeavyCavitationTorpedo02