local SOhwalliStrategicBombProjectile = import('/lua/seraphimprojectiles.lua').SOhwalliStrategicBombProjectile

SBOOhwalliStategicBomb01 = Class(SOhwalliStrategicBombProjectile){
    OnImpact = function(self, TargetType, TargetEntity)
        self:CreateProjectile('/effects/entities/SBOOhwalliBombEffectController01/SBOOhwalliBombEffectController01_proj.bp', 0, 0, 0, 0, 0, 0):SetCollision(false)
        SOhwalliStrategicBombProjectile.OnImpact(self, TargetType, TargetEntity) 
    end,
}
TypeClass = SBOOhwalliStategicBomb01
