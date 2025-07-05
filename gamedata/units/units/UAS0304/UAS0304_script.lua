local ASubUnit =  import('/lua/defaultunits.lua').SubUnit

local WeaponFile = import('/lua/aeonweapons.lua')

local Torpedo   = WeaponFile.AANChronoTorpedoWeapon
local Missile   = WeaponFile.AIFMissileTacticalSerpentineWeapon
local Nuke      = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

WeaponFile = nil

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add

UAS0304 = Class(ASubUnit) {
	
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

        Missiles = Class(Missile) { FxMuzzleFlash = false },

        SubNukeMissiles = Class(Nuke) {},
    },
	
	OnStopBeingBuilt = function(self,builder,layer)

		ASubUnit.OnStopBeingBuilt(self,builder,layer)

        -- create Torp Defense emitter
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy
        
        for _,v in bp.AttachBone do

            local antiMissile1 = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = v, RedirectRateOfFire = bp.RedirectRateOfFire }

            TrashAdd( self.Trash, antiMissile1)
            
        end

        self.DeathWeaponEnabled = true
	end,

}

TypeClass = UAS0304

