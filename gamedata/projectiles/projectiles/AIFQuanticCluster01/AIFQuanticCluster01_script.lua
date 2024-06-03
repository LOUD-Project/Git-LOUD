local EffectTemplate = import('/lua/EffectTemplates.lua')

local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

local CreateEmitterAtEntity = CreateEmitterAtEntity

AIFQuanticCluster01 = Class(import('/lua/aeonprojectiles.lua').AQuantumCluster) {

    OnImpact = function(self, TargetType, TargetEntity)

        local FxFragEffect = EffectTemplate.TFragmentationSensorShellFrag
        local ChildProjectileBP = '/projectiles/AIFQuanticCluster02/AIFQuanticCluster02_proj.bp'
		
		local LOUDCOS = math.cos
		local LOUDSIN = math.sin
		local CreateEmitterAtEntity = CreateEmitterAtEntity

        for k, v in FxFragEffect do
            CreateEmitterAtEntity( self, self:GetArmy(), v )
        end

        local vx, vy, vz = self:GetVelocity()
        local velocity = 6

        self:CreateChildProjectile(ChildProjectileBP):SetVelocity(vx, vy, vz):SetVelocity(velocity):PassDamageData(self.DamageData)

        local numProjectiles = 8
        local angle = 6.28 / numProjectiles
        local angleInitial = RandomFloat( 0, angle )

        local angleVariation = angle * 0.35     -- Adjusts angle variance spread
        local spreadMul = 10                    -- Adjusts width of dispersal

        local xVec = 0
        local yVec = vy
        local zVec = 0


        for i = 0, (numProjectiles -1) do

            xVec = vx + (LOUDSIN(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul
            zVec = vz + (LOUDCOS(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul

            local proj = self:CreateChildProjectile(ChildProjectileBP)

            proj:SetVelocity(xVec,yVec,zVec)
            proj:SetVelocity(velocity)
            proj:PassDamageData(self.DamageData)
        end

        local pos = self:GetPosition()

        self:Destroy()
    end,
}

TypeClass = AIFQuanticCluster01