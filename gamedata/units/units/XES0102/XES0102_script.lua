local TSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local Torpedo       = import('/lua/terranweapons.lua').TANTorpedoAngler
local Decoy         = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local DepthCharge   = import('/lua/aeonweapons.lua').AANDepthChargeBombWeapon

XES0102 = Class(TSeaUnit) {

    Weapons = {

        Torpedo     = Class(Torpedo) {

            FxMuzzleFlashScale = 0.4,
        
            OnLostTarget = function(self)
                
                self.unit:SetAccMult(1)
                
                self:ChangeMaxRadius(44)
                
                Torpedo.OnLostTarget(self)
            
            end,
        
            RackSalvoFireReadyState = State( Torpedo.RackSalvoFireReadyState) {
            
                Main = function(self)
                
                    self:ChangeMaxRadius(38)
                
                    Torpedo.RackSalvoFireReadyState.Main(self)
                    
                end,
            },
        
            RackSalvoReloadState = State( Torpedo.RackSalvoReloadState) {
            
                Main = function(self)
                
                    self.unit:SetAccMult(1.3)
                
                    self:ForkThread( function() self:ChangeMaxRadius(52) self:ChangeMinRadius(52) WaitTicks(64) self:ChangeMaxRadius(38) self:ChangeMinRadius(6) end)
                    
                    Torpedo.RackSalvoReloadState.Main(self)

                end,
            },
        },

        AntiTorpL    = Class(Decoy) { FxMuzzleFlash = false },
        AntiTorpR    = Class(Decoy) { FxMuzzleFlash = false },
        DepthCharge  = Class(DepthCharge) {},
    },    
}

TypeClass = XES0102