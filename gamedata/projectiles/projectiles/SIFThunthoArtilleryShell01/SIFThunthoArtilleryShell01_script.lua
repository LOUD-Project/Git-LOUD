local SThunthoArtilleryShell = import('/lua/seraphimprojectiles.lua').SThunthoArtilleryShell

local FxFragEffect = import('/lua/EffectTemplates.lua').SThunderStormCannonProjectileSplitFx

local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local CreateEmitterAtEntity = CreateEmitterAtEntity

SIFThunthoArtilleryShell01 = Class(SThunthoArtilleryShell) {

    OnImpact = function(self, TargetType, TargetEntity) 

        local ChildProjectileBP = '/projectiles/SIFThunthoArtilleryShell02/SIFThunthoArtilleryShell02_proj.bp' 

		local LOUDSIN = math.sin
		local LOUDCOS = math.cos
		local CreateEmitterAtEntity = CreateEmitterAtEntity
		
        for k, v in FxFragEffect do
            CreateEmitterAtEntity( self, self:GetArmy(), v )
        end
        
        local vx, vy, vz = self:GetVelocity()
        local velocity = 18

        local numProjectiles = 5
		
		self.DamageData.DamageAmount = self.DamageData.DamageAmount / numProjectiles

        self:CreateChildProjectile(ChildProjectileBP):SetVelocity(vx, vy, vz):SetVelocity(velocity):PassDamageData(self.DamageData)

        local angle = 6.28 / numProjectiles
        local angleInitial = RandomFloat( 0, angle )

        local angleVariation = angle * 0.8 	-- Adjusts angle variance spread
        local spreadMul = 0.15 				-- Adjusts the width of the dispersal        
        
        local xVec = 0
        local yVec = vy
        local zVec = 0

        for i = 1, (numProjectiles -1) do
		
            xVec = vx + (LOUDSIN(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul
            zVec = vz + (LOUDCOS(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul 
			
            local proj = self:CreateChildProjectile(ChildProjectileBP)
			
            proj:SetVelocity(xVec,yVec,zVec)
            proj:SetVelocity(velocity)
            proj:PassDamageData(self.DamageData)
        end
        
		-- destroy the original projectile
        self:Destroy()
    end,
    
    

}

TypeClass = SIFThunthoArtilleryShell01