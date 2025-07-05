local CSubUnit =  import('/lua/defaultunits.lua').SubUnit

local CybranWeapons = import('/lua/cybranweapons.lua')

local Missile   = CybranWeapons.CIFMissileLoaWeapon
local Strategic = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local Torpedo   = CybranWeapons.CANNaniteTorpedoWeapon

CybranWeapons = nil

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add

URS0304 = Class(CSubUnit) {

    Weapons = {
        Torpedo             = Class(Torpedo){
        
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
        CruiseMissile       = Class(Missile){},
        SubNukeMissiles     = Class(Strategic){},
    },
    
    OnStopBeingBuilt = function(self,builder,layer)
	
        CSubUnit.OnStopBeingBuilt(self,builder,layer)

        -- create Torp Defense emitters
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy
        
        for _,v in bp.AttachBone do

            local antiMissile1 = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = v, RedirectRateOfFire = bp.RedirectRateOfFire }

            TrashAdd( self.Trash, antiMissile1)
            
        end

        self.DeathWeaponEnabled = true
    end,

}

TypeClass = URS0304

