local TSubUnit = import('/lua/terranunits.lua').TSubUnit

local WeaponFile = import('/lua/terranweapons.lua')

local TIFCruiseMissileLauncherSub = WeaponFile.TIFCruiseMissileLauncherSub
local TIFStrategicMissileWeapon = WeaponFile.TIFStrategicMissileWeapon

UES0304 = Class(TSubUnit) {
	
    Weapons = {
	
        CruiseMissiles = Class(TIFCruiseMissileLauncherSub) {
		
            CurrentRack = 1,
           
            PlayFxMuzzleSequence = function(self, muzzle)
			
                local bp = self:GetBlueprint()
				
                self.Rotator = CreateRotator(self.unit, bp.RackBones[self.CurrentRack].RackBone, 'z', nil, 90, 90, 90)
				
                muzzle = bp.RackBones[self.CurrentRack].MuzzleBones[1]
				
                self.Rotator:SetGoal(90)
				
                TIFCruiseMissileLauncherSub.PlayFxMuzzleSequence(self, muzzle)
				
                WaitFor(self.Rotator)
				
                WaitSeconds(1)
				
            end,
            
            CreateProjectileAtMuzzle = function(self, muzzle)
			
                muzzle = self:GetBlueprint().RackBones[self.CurrentRack].MuzzleBones[1]
				
                if self.CurrentRack >= 6 then
				
                    self.CurrentRack = 1
					
                else
				
                    self.CurrentRack = self.CurrentRack + 1
					
                end
				
                TIFCruiseMissileLauncherSub.CreateProjectileAtMuzzle(self, muzzle)
				
            end,
            
            PlayFxRackReloadSequence = function(self)
			
                WaitSeconds(1)
				
                self.Rotator:SetGoal(0)
				
                WaitFor(self.Rotator)
				
                self.Rotator:Destroy()
				
                self.Rotator = nil
				
            end,
        },
		
        NukeMissiles = Class(TIFStrategicMissileWeapon) {
		
            CurrentRack = 1,
           
            PlayFxMuzzleSequence = function(self, muzzle)
			
                local bp = self:GetBlueprint()
				
                self.Rotator = CreateRotator(self.unit, bp.RackBones[self.CurrentRack].RackBone, 'z', nil, 90, 90, 90)
				
                muzzle = bp.RackBones[self.CurrentRack].MuzzleBones[1]
				
                self.Rotator:SetGoal(90)
				
                TIFCruiseMissileLauncherSub.PlayFxMuzzleSequence(self, muzzle)
				
                WaitFor(self.Rotator)
				
                WaitSeconds(1)
				
            end,
            
            CreateProjectileAtMuzzle = function(self, muzzle)
			
                muzzle = self:GetBlueprint().RackBones[self.CurrentRack].MuzzleBones[1]
				
                if self.CurrentRack >= 2 then
				
                    self.CurrentRack = 1
					
                else
				
                    self.CurrentRack = self.CurrentRack + 1
					
                end
				
                TIFCruiseMissileLauncherSub.CreateProjectileAtMuzzle(self, muzzle)
				
            end,
            
            PlayFxRackReloadSequence = function(self)
			
                WaitSeconds(1)
				
                self.Rotator:SetGoal(0)
				
                WaitFor(self.Rotator)
				
                self.Rotator:Destroy()
				
                self.Rotator = nil
				
            end,
        },
    },
}

TypeClass = UES0304

