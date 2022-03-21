local AAirUnit = import('/lua/defaultunits.lua').AirUnit

local ADFLaserLightWeapon = import('/lua/aeonweapons.lua').ADFLaserLightWeapon

UAA0203 = Class(AAirUnit) {

    Weapons = {
	
        Turret = Class(ADFLaserLightWeapon) {
		
			FxChassisMuzzleFlash = {'/effects/emitters/aeon_gunship_body_illumination_01_emit.bp',},
			
			PlayFxMuzzleSequence = function(self, muzzle)
            
				local bp = self:GetBlueprint()
				local army = self.unit:GetArmy()
				local CreateAttachedEmitter = CreateAttachedEmitter
                
				for _, v in self.FxMuzzleFlash do
				
					CreateAttachedEmitter(self.unit, muzzle, army, v)
					
				end
				
				for _, v in self.FxChassisMuzzleFlash do
				
					CreateAttachedEmitter(self.unit, -1, army, v)
					
				end
				
				if self.unit:GetCurrentLayer() == 'Water' and bp.Audio.FireUnderWater then
				
					self:PlaySound(bp.Audio.FireUnderWater)
					
				elseif bp.Audio.Fire then
				
					self:PlaySound(bp.Audio.Fire)
					
				end
				
			end,
			
        },
    },
}

TypeClass = UAA0203