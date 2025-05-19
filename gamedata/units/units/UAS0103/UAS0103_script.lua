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
            
                self:ChangeMaxRadius(12)
                
                ADepthCharge.OnLostTarget(self)
            
            end,
        
            RackSalvoFireReadyState = State( ADepthCharge.RackSalvoFireReadyState) {
            
                Main = function(self)
                
                    self.unit:SetAccMult(0.6)
                
                    self:ChangeMaxRadius(8)
                
                    ADepthCharge.RackSalvoFireReadyState.Main(self)
                    
                end,
            },
        
            RackSalvoReloadState = State( ADepthCharge.RackSalvoReloadState) {
            
                Main = function(self)
                
                    self.unit:SetAccMult(1.0)
                
                    ForkThread( function() self:ChangeMaxRadius(18) self:ChangeMinRadius(18) WaitTicks(41) self:ChangeMinRadius(0) self:ChangeMaxRadius(12) end)
                    
                    ADepthCharge.RackSalvoReloadState.Main(self)

                end,
            },
        },
    },
	
}

TypeClass = UAS0103
