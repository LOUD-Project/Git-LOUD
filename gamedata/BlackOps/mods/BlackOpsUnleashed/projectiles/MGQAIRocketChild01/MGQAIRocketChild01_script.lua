
local MGQAIRocketChildProjectile = import('/mods/BlackOpsUnleashed/lua/BlackOpsprojectiles.lua').MGQAIRocketChildProjectile

MGQAIRocket01 = Class(MGQAIRocketChildProjectile) {
    OnCreate = function(self)
        MGQAIRocketChildProjectile.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 2)
        self:ForkThread(self.UpdateThread)
    end,

	UpdateThread = function(self)
        WaitSeconds(0.1)
        self:SetTurnRate(360)

        WaitSeconds(0.5)
        self:SetTurnRate(15)

    end,
    
    PassDamageData = function(self, damageData)
        MGQAIRocketChildProjectile.PassDamageData(self,damageData)
        local launcherbp = self:GetLauncher():GetBlueprint()  
        self.ChildDamageData = table.copy(self.DamageData)
        self.ChildDamageData.DamageAmount = launcherbp.SplitDamage.DamageAmount or 0
        self.ChildDamageData.DamageRadius = launcherbp.SplitDamage.DamageRadius or 1   
    end,
}

TypeClass = MGQAIRocket01