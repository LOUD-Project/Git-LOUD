local AGuidedMissileProjectile = import('/lua/aeonprojectiles.lua').AGuidedMissileProjectile

local RandF = import('/lua/utilities.lua').GetRandomFloat
local EffectTemplate = import('/lua/EffectTemplates.lua')

local ForkThread = ForkThread
local CreateEmitterOnEntity = CreateEmitterOnEntity

AIFGuidedMissile = Class(AGuidedMissileProjectile) {

    OnCreate = function(self)
	
		AGuidedMissileProjectile.OnCreate(self)
		
        local launcher = self:GetLauncher()
		
        if launcher and not launcher:IsDead() then
            launcher:ProjectileFired()
        end		
		
		self:ForkThread( self.SplitThread )
    end,

    SplitThread = function(self)
	
		local LOUDCOS = math.cos
		local LOUDSIN = math.sin
		local CreateEmitterOnEntity = CreateEmitterOnEntity
		
		for k,v in EffectTemplate.AMercyGuidedMissileSplit do
            CreateEmitterOnEntity(self,self:GetArmy(),v)
        end
        
        
		WaitSeconds( 0.1 )

		-- Create several other projectiles in a dispersal pattern
        local vx, vy, vz = self:GetVelocity()
        local velocity = 16		
        local numProjectiles = 8
        local angle = 6.28 / numProjectiles
        local angleInitial = RandF( 0, angle )
        local ChildProjectileBP = '/projectiles/AIFGuidedMissile02/AIFGuidedMissile02_proj.bp'          
        local spreadMul = 0.4 # Adjusts the width of the dispersal        
       
        local xVec = 0 
        local yVec = vy*0.8
        local zVec = 0
        
        -- Adjust damage by number of split projectiles
        self.DamageData.DamageAmount = self.DamageData.DamageAmount / numProjectiles

        -- Launch projectiles at semi-random angles away from split location
        for i = 0, (numProjectiles -1) do
            xVec = vx + LOUDSIN(angleInitial + (i*angle) ) * spreadMul * RandF( 0.6, 1.3 )
            zVec = vz + LOUDCOS(angleInitial + (i*angle) ) * spreadMul * RandF( 0.6, 1.3 )

            local proj = self:CreateChildProjectile(ChildProjectileBP)

            proj:SetVelocity( xVec, yVec, zVec )
            proj:SetVelocity( velocity * RandF( 0.8, 1.2 ) )
            proj:PassDamageData(self.DamageData)                        
        end        

        self:Destroy()    
    end,  
}
TypeClass = AIFGuidedMissile

