local SHeavyQuarnonCannon = import('/lua/seraphimprojectiles.lua').SHeavyQuarnonCannon

local EffectTemplate = import('/lua/EffectTemplates.lua')

SDFHeavyQuarnonCannon01 = Class(SHeavyQuarnonCannon) {

	OnImpact = function(self, TargetType, TargetEntity)

		local instigator = self:GetLauncher()
		
		if instigator == nil then
			instigator = self
		end
		
		local damagedata = self.DamageData
		
		self:DoDamage( instigator, damagedata, TargetEntity )
        
        local FxFragEffect = EffectTemplate.SThunderStormCannonProjectileSplitFx 

		nukeProjectile = self:CreateProjectile('/mods/BlackOpsUnleashed/projectiles/SeraHeavyLightningCannonChild01/SeraHeavyLightningCannonChild01_proj.bp', 0, 0, 0, nil, nil, nil)--:SetCollision(false)

		local pos = self:GetPosition()

        pos[2] = pos[2] + 4
        Warp( nukeProjectile, pos)
		nukeProjectile:PassDamageData(self.DamageData) 
        
        for k, v in FxFragEffect do
            CreateEmitterAtEntity( self, self:GetArmy(), v )
        end

        self:Destroy()
    end,
}
TypeClass = SDFHeavyQuarnonCannon01