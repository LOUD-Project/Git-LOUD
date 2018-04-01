#
# Cybran Anti Air Projectile
#

local CAANanoDartProjectile = import('/lua/cybranprojectiles.lua').CAANanoDartProjectile03
local CreateEmitterOnEntity = CreateEmitterOnEntity

CAANanoDart02 = Class(CAANanoDartProjectile) {

   OnCreate = function(self)
        CAANanoDartProjectile.OnCreate(self)
		
		local CreateEmitterOnEntity = CreateEmitterOnEntity
		
        for k, v in self.FxTrails do
            CreateEmitterOnEntity(self,self:GetArmy(),v )
        end
   end,
}

TypeClass = CAANanoDart02
