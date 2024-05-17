local CLOATacticalMissileProjectile = import('/lua/cybranprojectiles.lua').CLOATacticalMissileProjectile

local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

MGQAIRocket01 = Class(CLOATacticalMissileProjectile) {

    OnCreate = function(self)

        CLOATacticalMissileProjectile.OnCreate(self)

        self:ForkThread(self.UpdateThread)
    end,

	UpdateThread = function(self)

        self:TrackTarget(false)

        WaitSeconds(0.5)

        local Velx, Vely, Velz = self:GetVelocity()
        
        local NumberOfChildProjectiles = 3
        
        local ChildProjectileBP = '/mods/BlackOpsUnleashed/projectiles/MGQAIRocketChild01/MGQAIRocketChild01_proj.bp'  
        
        local angleRange = math.pi * 0.7
        local angleInitial = -angleRange / 2
        local angleIncrement = angleRange / NumberOfChildProjectiles
        local angleVariation = angleIncrement * 0.85

        local angle, ca, sa, x, z, proj

        for i = 1, NumberOfChildProjectiles  do
        
            angle = angleInitial + (i*angleIncrement) + RandomFloat(-angleVariation, angleVariation)

            ca = math.cos(angle)
            sa = math.sin(angle)

            x = Velx * ca - Velz * sa
            z = Velx * sa + Velz * ca

            proj = self:CreateChildProjectile(ChildProjectileBP)

            proj:PassDamageData(self.DamageData)

            -- split damage across projectiles --
            proj.DamageData.DamageAmount = self.DamageData.DamageAmount/NumberOfChildProjectiles

            mul = RandomFloat(1,3)
            proj:SetVelocity( x * mul, Vely * mul, z * mul )
        end   

        self:Destroy()
    end,
	
}

TypeClass = MGQAIRocket01