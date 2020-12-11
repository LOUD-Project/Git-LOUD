--****************************************************************************
--**
--**  File     :  /data/projectiles/ExWifeMaincannon0105/ExWifeMaincannon0105_script.lua
--**  Author(s):  Gordon Duclos, Matt Vainio
--**
--**  Summary  :  Cybran Proton Artillery projectile script, XRL0403
--**
--**  Copyright � 2007 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

local ExWifeMaincannonProjectile = import('/mods/BattlePack/lua/BattlePackprojectiles.lua').ExWifeMainProjectile
ExWifeMaincannon01 = Class(ExWifeMaincannonProjectile) {
	OnImpact = function(self, TargetType, TargetEntity) 
		###self:ShakeCamera( radius, maxShakeEpicenter, minShakeAtRadius, interval )
		self:ShakeCamera( 15, 0.25, 0, 0.2 )
		ExWifeMaincannonProjectile.OnImpact (self, TargetType, TargetEntity)
	end,
OnImpactDestroy = function( self, targetType, targetEntity )

   if targetEntity and not IsUnit(targetEntity) then
      ExWifeMaincannonProjectile.OnImpactDestroy(self, targetType, targetEntity)
      return
   end
   
   if self.counter then
      if self.counter >= 5 then
         ExWifeMaincannonProjectile.OnImpactDestroy(self, targetType, targetEntity)
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
TypeClass = ExWifeMaincannon01