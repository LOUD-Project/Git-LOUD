local MGQAIRocketChildProjectile = import('/mods/BlackOpsUnleashed/lua/BlackOpsprojectiles.lua').MGQAIRocketChildProjectile

MGQAIRocket01 = Class(MGQAIRocketChildProjectile) {

    OnCreate = function(self)

        MGQAIRocketChildProjectile.OnCreate(self)

        self:SetCollisionShape('Sphere', 0, 0, 0, 2)

        self:ForkThread(self.UpdateThread)
    end,

	UpdateThread = function(self)
    
        WaitSeconds(0.3)
        
        self:TrackTarget(true)

        WaitSeconds(0.5)
        
        self:SetTurnRate(90)

    end,

}

TypeClass = MGQAIRocket01