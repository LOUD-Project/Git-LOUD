local ASeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local AeonWeapons = import('/lua/aeonweapons.lua')

local Cannon        = AeonWeapons.ADFCannonOblivionWeapon
local Torpedo       = AeonWeapons.AANChronoTorpedoWeapon
local AntiTorpedo   = AeonWeapons.AIFQuasarAntiTorpedoWeapon
local DepthCharge   = AeonWeapons.AANDepthChargeBombWeapon
AeonWeapons = nil

UAS0201 = Class(ASeaUnit) {

    Weapons = {
        FrontTurret     = Class(Cannon) {},
        DepthCharge     = Class(DepthCharge) {
        
            OnLostTarget = function(self)
                
                self.unit:SetAccMult(1)
                
                self:ChangeMaxRadius(12)
                
                DepthCharge.OnLostTarget(self)
            
            end,
        
            RackSalvoFireReadyState = State( DepthCharge.RackSalvoFireReadyState) {
            
                Main = function(self)
                
                    self:ChangeMaxRadius(8)
                
                    DepthCharge.RackSalvoFireReadyState.Main(self)
                    
                end,
            },
        
            RackSalvoReloadState = State( DepthCharge.RackSalvoReloadState) {
            
                Main = function(self)
                
                    self.unit:SetAccMult(1.3)
                
                    self:ForkThread( function() self:ChangeMaxRadius(18) self:ChangeMinRadius(18) WaitTicks(49) self:ChangeMaxRadius(8) self:ChangeMinRadius(0) end)
                    
                    DepthCharge.RackSalvoReloadState.Main(self)

                end,
            },
        },
        Torpedo         = Class(Torpedo) { FxMuzzleFlash = false },
        AntiTorpedo1    = Class(AntiTorpedo) {},
        AntiTorpedo2    = Class(AntiTorpedo) {},
        AntiTorpedo3    = Class(AntiTorpedo) {},
    },
}

TypeClass = UAS0201