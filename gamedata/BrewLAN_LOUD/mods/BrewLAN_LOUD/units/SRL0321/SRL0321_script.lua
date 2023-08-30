--------------------------------------------------------------------------------
--  Summary  :  Cybran Mobile Missile Launcher Script
--------------------------------------------------------------------------------
local CLandUnit = import('/lua/defaultunits.lua').MobileUnit

local CAMEMPMissileWeapon = import('/lua/cybranweapons.lua').CAMEMPMissileWeapon

SRL0321 = Class(CLandUnit) {

    Weapons = {
	
        AntiMissile = Class(CAMEMPMissileWeapon) {

            OnWeaponFired = function(self)
			
                CAMEMPMissileWeapon.OnWeaponFired()
				
                self.unit:HideBone('Missile', true)
				
                if not self.unit.MissileSlider then
				
                    self.unit.MissileSlider = CreateSlider(self.unit, 'Missile', 0, 0, -35, 100)
                else
                    self.unit.MissileSlider:SetGoal(0, 0, -35)
                end
				
            end,
			
        },
    },
	
    OnSiloBuildStart = function(self, weapon)
	
        self:ShowBone('Missile', true)
		
		if not self.MissileSlider then
		
			self.MissileSlider = CreateSlider(self, 'Missile', 0, 0, -35, 100)
			
		end
		
        CLandUnit.OnSiloBuildStart(self, weapon)
		
    end,
	
    OnSiloBuildEnd = function(self, weapon)
	
        self.MissileSlider:SetGoal(0, 0, 0)
		
        CLandUnit.OnSiloBuildEnd(self,weapon)
		
    end,
}

TypeClass = SRL0321
