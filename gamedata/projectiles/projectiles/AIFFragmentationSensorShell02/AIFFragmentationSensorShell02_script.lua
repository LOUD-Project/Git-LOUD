local EffectTemplate = import('/lua/EffectTemplates.lua')

local AArtilleryFragmentationSensorShellProjectile = import('/lua/aeonprojectiles.lua').AArtilleryFragmentationSensorShellProjectile02

local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

local CreateEmitterAtBone = CreateEmitterAtBone

AIFFragmentationSensorShell02 = Class(AArtilleryFragmentationSensorShellProjectile) {

    OnImpact = function(self, TargetType, TargetEntity) 
	
		-- if we're hitting anything but a shield (or we're just detonating at height)
		-- do the projectile split
        if TargetType != 'Shield' then
		
	        local FxFragEffect = EffectTemplate.Aeon_QuanticClusterFrag02 
	        local ChildProjectileBP = '/projectiles/AIFFragmentationSensorShell03/AIFFragmentationSensorShell03_proj.bp' 

			local LOUDPI = math.pi
			local LOUDCOS = math.cos
			local LOUDSIN = math.sin
			local CreateEmitterAtBone = CreateEmitterAtBone
			
	        
	        -- Split effects
	        for k, v in FxFragEffect do
	            CreateEmitterAtBone( self, -1, self.Sync.army, v )
	        end
	        
	        local vx, vy, vz = self:GetVelocity()
	        local velocity = 12
	    
			-- One initial projectile following same directional path as the original
	        self:CreateChildProjectile(ChildProjectileBP):SetVelocity(vx, 0.8*vy, vz):SetVelocity(velocity):PassDamageData(self.DamageData)
	   		
			-- and 5 other projectiles in a dispersal pattern
	        local numProjectiles = 5
	        local angle = (2*LOUDPI) / numProjectiles
	        local angleInitial = RandomFloat( 0, angle )

	        -- Randomization of the spread
	        local angleVariation = angle * 13 	--# Adjusts angle variance spread
	        local spreadMul = 0.4 				--# Adjusts the width of the dispersal        

	        local xVec = 0 
	        local yVec = vy*0.8
	        local zVec = 0
	
	        -- Launch projectiles at semi-random angles away from split location
	        for i = 0, (numProjectiles -1) do
			
	            xVec = vx + (LOUDSIN(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul
	            zVec = vz + (LOUDCOS(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul 
				
	            local proj = self:CreateChildProjectile(ChildProjectileBP)
				
	            proj:SetVelocity(xVec,yVec,zVec)
	            proj:SetVelocity(velocity)
	            proj:PassDamageData(self.DamageData)                        
	        end
			
	        local pos = self:GetPosition()
			
	        local spec = {
	            X = pos[1],
	            Z = pos[3],
	            Radius = self.Data.Radius,
	            LifeTime = self.Data.Lifetime,
	            Army = self.Data.Army,
	            Omni = false,
	            WaterVision = false,
	        }
			-- destroy the original projectile
	        self:Destroy()
			
		else
	        self:DoDamage( self, self.DamageData, TargetEntity)
	        self:OnImpactDestroy(TargetType, TargetEntity)
        end
    end,
}
TypeClass = AIFFragmentationSensorShell02