local SOhwalliStrategicBombProjectile = import('/lua/seraphimprojectiles.lua').SOhwalliStrategicBombProjectile

SBOOhwalliStategicBomb01 = Class(SOhwalliStrategicBombProjectile){
    OnImpact = function(self, TargetType, TargetEntity)
        SOhwalliStrategicBombProjectile.OnImpact(self, TargetType, TargetEntity)
        if TargetType == 'Shield' then
            return
        end
        self:CreateProjectile('/effects/entities/SBOOhwalliBombEffectController01/SBOOhwalliBombEffectController01_proj.bp', 0, 0, 0, 0, 0, 0):SetCollision(false)
    end,
}
TypeClass = SBOOhwalliStategicBomb01
