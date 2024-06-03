local CAANanoDartProjectile = import('/lua/cybranprojectiles.lua').CAANanoDartProjectile
local CreateEmitterOnEntity = CreateEmitterOnEntity

CAANanoDart02 = Class(CAANanoDartProjectile) {

   OnCreate = function(self)
   
        CAANanoDartProjectile.OnCreate(self)
	
        if self.FxTrails then
        
            local CreateEmitterOnEntity = CreateEmitterOnEntity
		
            for k, v in self.FxTrails do
                CreateEmitterOnEntity(self,self:GetArmy(),v )
            end
            
        end
   end,
}

TypeClass = CAANanoDart02
