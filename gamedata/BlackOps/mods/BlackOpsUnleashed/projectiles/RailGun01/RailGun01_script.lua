local RailGun01Projectile = import('/mods/BlackOpsUnleashed/lua/BlackOpsprojectiles.lua').RailGun01Projectile

RailGun01 = Class(RailGun01Projectile) {

	OnImpact = function(self, TargetType, TargetEntity) 
		self:ShakeCamera( 15, 0.25, 0, 0.2 )
		RailGun01Projectile.OnImpact (self, TargetType, TargetEntity)
	end,
	
	OnImpactDestroy = function( self, targetType, targetEntity )
		if targetEntity and not IsUnit(targetEntity) then
			RailGun01Projectile.OnImpactDestroy(self, targetType, targetEntity)
		return
	end
   
	if self.counter then
		if self.counter >= 1 then
			RailGun01Projectile.OnImpactDestroy(self, targetType, targetEntity)
			return
		else
			self.counter = self.counter + 1
		end

		else
			self.counter = 1
		end

		if targetEntity then
			self.lastimpact = targetEntity:GetEntityId() #remember what was hit last
		end
	end,
}
TypeClass = RailGun01