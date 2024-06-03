local TSubUnit =  import('/lua/defaultunits.lua').SubUnit

local TIFCruiseMissileLauncherSub   = import('/lua/terranweapons.lua').TIFCruiseMissileLauncherSub
local TIFStrategicMissileWeapon     = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

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
	
	OnCreate = function(self)
        TSubUnit.OnCreate(self)
        if type(ScenarioInfo.Options.RestrictedCategories) == 'table' and table.find(ScenarioInfo.Options.RestrictedCategories, 'NUKE') then
            self:SetWeaponEnabledByLabel('NukeMissiles', false)
        end
    end,
}

TypeClass = UES0304

