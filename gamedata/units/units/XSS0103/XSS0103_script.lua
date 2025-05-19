local SSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local SWeapon               = import('/lua/seraphimweapons.lua')
local SDepthCharge          = import('/lua/aeonweapons.lua').AANDepthChargeBombWeapon

XSS0103 = Class(SSeaUnit) {

    Weapons = {
        MainGun         = Class(SWeapon.SDFShriekerCannon){},
        AntiAir         = Class(SWeapon.SAAShleoCannonWeapon){},
        DepthCharge     = Class(SDepthCharge) {
        
            OnLostTarget = function(self)
                
                self.unit:SetAccMult(1)
                
                self:ChangeMaxRadius(12)
                
                SDepthCharge.OnLostTarget(self)
            
            end,
        
            RackSalvoFireReadyState = State( SDepthCharge.RackSalvoFireReadyState) {
            
                Main = function(self)
                
                    self:ChangeMaxRadius(6)
                
                    SDepthCharge.RackSalvoFireReadyState.Main(self)
                    
                end,
            },
        
            RackSalvoReloadState = State( SDepthCharge.RackSalvoReloadState) {
            
                Main = function(self)
                
                    self.unit:SetAccMult(1.3)
                
                    self:ForkThread( function() self:ChangeMaxRadius(15) self:ChangeMinRadius(15) WaitTicks(44) self:ChangeMinRadius(0) self:ChangeMaxRadius(12) end)
                    
                    SDepthCharge.RackSalvoReloadState.Main(self)

                end,
            },
        },
    },
}

TypeClass = XSS0103
