local SeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local AeonWeapons = import('/lua/aeonweapons.lua')

local ADFCannonQuantumWeapon        = AeonWeapons.ADFCannonQuantumWeapon
local AIFQuasarAntiTorpedoWeapon    = AeonWeapons.AIFQuasarAntiTorpedoWeapon
local ADepthCharge                  = AeonWeapons.AANDepthChargeBombWeapon

AeonWeapons = nil

local AQuantumCannonMuzzle02 = import('/lua/EffectTemplates.lua').AQuantumCannonMuzzle02

UAS0103 = Class(SeaUnit) {

    Weapons = {
        DeckGuns        = Class(ADFCannonQuantumWeapon) { FxMuzzleFlash = AQuantumCannonMuzzle02 },
        AntiTorpedo     = Class(AIFQuasarAntiTorpedoWeapon) {},
        DepthCharge     = Class(ADepthCharge) {
        
            OnLostTarget = function(self)
                
                self.unit:SetAccMult(1)
                
                self:ChangeMaxRadius(12)
                
                ADepthCharge.OnLostTarget(self)
            
            end,
        
            RackSalvoFireReadyState = State( ADepthCharge.RackSalvoFireReadyState) {
            
                Main = function(self)
                
                    self:ChangeMaxRadius(6)
                
                    ADepthCharge.RackSalvoFireReadyState.Main(self)
                    
                end,
            },
        
            RackSalvoReloadState = State( ADepthCharge.RackSalvoReloadState) {
            
                Main = function(self)
                
                    self.unit:SetAccMult(1.3)
                
                    self:ForkThread( function() self:ChangeMaxRadius(15) self:ChangeMinRadius(15) WaitTicks(44) self:ChangeMinRadius(0) self:ChangeMaxRadius(12) end)
                    
                    ADepthCharge.RackSalvoReloadState.Main(self)

                end,
            },
        },
    },
	
}

TypeClass = UAS0103
