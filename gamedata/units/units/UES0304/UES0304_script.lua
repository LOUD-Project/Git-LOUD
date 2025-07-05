local TSubUnit =  import('/lua/defaultunits.lua').SubUnit

local Missile       = import('/lua/terranweapons.lua').TIFCruiseMissileLauncherSub
local Strategic     = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local Torpedo       = import('/lua/terranweapons.lua').TANTorpedoAngler

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add

UES0304 = Class(TSubUnit) {
	
    Weapons = {

        Torpedo  = Class(Torpedo) {
  
            FxMuzzleFlash = false,
        
            OnLostTarget = function(self)
                
                self.unit:SetAccMult(1)
                
                self:ChangeMaxRadius(48)
                
                Torpedo.OnLostTarget(self)
            
            end,
        
            RackSalvoFireReadyState = State( Torpedo.RackSalvoFireReadyState) {
            
                Main = function(self)
                
                    self:ChangeMaxRadius(44)
                
                    Torpedo.RackSalvoFireReadyState.Main(self)
                    
                end,
            },
        
            RackSalvoReloadState = State( Torpedo.RackSalvoReloadState) {
            
                Main = function(self)
                
                    self.unit:SetAccMult(1.3)
                
                    self:ForkThread( function() self:ChangeMaxRadius(56) self:ChangeMinRadius(48) WaitTicks(70) self:ChangeMaxRadius(44) self:ChangeMinRadius(8) end)
                    
                    Torpedo.RackSalvoReloadState.Main(self)

                end,
            },    
        },
        
        CruiseMissiles = Class(Missile) {
		
            CurrentRack = 1,
            
            FxMuzzleFlash = false,
           
            PlayFxMuzzleSequence = function(self, muzzle)
			
                local bp = self:GetBlueprint()
				
                self.Rotator = CreateRotator(self.unit, bp.RackBones[self.CurrentRack].RackBone, 'z', nil, 360, 360, 90)
				
                self.Rotator:SetGoal(90)
				
                muzzle = bp.RackBones[self.CurrentRack].MuzzleBones[1]
				
                Missile.PlayFxMuzzleSequence(self, muzzle)
				
                WaitFor(self.Rotator)
				
            end,
            
            CreateProjectileAtMuzzle = function(self, muzzle)
			
                muzzle = self:GetBlueprint().RackBones[self.CurrentRack].MuzzleBones[1]
				
                if self.CurrentRack >= 6 then
				
                    self.CurrentRack = 1
					
                else
				
                    self.CurrentRack = self.CurrentRack + 1
					
                end
				
                Missile.CreateProjectileAtMuzzle(self, muzzle)
				
            end,
            
            PlayFxRackReloadSequence = function(self)

                self.Rotator:SetGoal(0)
				
                WaitFor(self.Rotator)
				
                self.Rotator:Destroy()
				
                self.Rotator = nil
				
            end,
        },
		
        SubNukeMissiles = Class(Strategic) {
		
            CurrentRack = 1,
           
            PlayFxMuzzleSequence = function(self, muzzle)
			
                local bp = self:GetBlueprint()
				
                self.Rotator = CreateRotator(self.unit, bp.RackBones[self.CurrentRack].RackBone, 'z', nil, 360, 360, 90)
				
                muzzle = bp.RackBones[self.CurrentRack].MuzzleBones[1]
				
                self.Rotator:SetGoal(90)
				
                Missile.PlayFxMuzzleSequence(self, muzzle)
				
                WaitFor(self.Rotator)
				
            end,
            
            CreateProjectileAtMuzzle = function(self, muzzle)
			
                muzzle = self:GetBlueprint().RackBones[self.CurrentRack].MuzzleBones[1]
				
                if self.CurrentRack >= 2 then
				
                    self.CurrentRack = 1
					
                else
				
                    self.CurrentRack = self.CurrentRack + 1
					
                end
				
                Missile.CreateProjectileAtMuzzle(self, muzzle)
				
            end,
            
            PlayFxRackReloadSequence = function(self)
				
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
	
	OnStopBeingBuilt = function(self,builder,layer)
		
		TSubUnit.OnStopBeingBuilt(self,builder,layer)

        -- create Torp Defense emitter
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy
        
        for _,v in bp.AttachBone do

            local antiMissile1 = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = v, RedirectRateOfFire = bp.RedirectRateOfFire }

            TrashAdd( self.Trash, antiMissile1)
            
        end
        
        self.DeathWeaponEnabled = true

	end,	
    
}

TypeClass = UES0304

