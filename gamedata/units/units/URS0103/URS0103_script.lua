local CSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local CybranWeaponsFile     = import('/lua/cybranweapons.lua')
local CAAAutocannon         = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local CDepthCharge          = import('/lua/aeonweapons.lua').AANDepthChargeBombWeapon

local CDFProtonCannonWeapon = CybranWeaponsFile.CDFProtonCannonWeapon

CybranWeaponsFile = nil

URS0103 = Class(CSeaUnit) {

    DestructionTicks = 120,

    Weapons = {
        ProtonCannon    = Class(CDFProtonCannonWeapon) {},
        AAGun           = Class(CAAAutocannon) {},
        DepthCharge     = Class(CDepthCharge) {
        
            OnLostTarget = function(self)
                
                self.unit:SetAccMult(1)
                
                self:ChangeMaxRadius(12)
                
                CDepthCharge.OnLostTarget(self)
            
            end,
        
            RackSalvoFireReadyState = State( CDepthCharge.RackSalvoFireReadyState) {
            
                Main = function(self)
                
                    self:ChangeMaxRadius(6)
                
                    CDepthCharge.RackSalvoFireReadyState.Main(self)
                    
                end,
            },
        
            RackSalvoReloadState = State( CDepthCharge.RackSalvoReloadState) {
            
                Main = function(self)
                
                    self.unit:SetAccMult(1.3)
                
                    self:ForkThread( function() self:ChangeMaxRadius(15) self:ChangeMinRadius(15) WaitTicks(44) self:ChangeMinRadius(0) self:ChangeMaxRadius(12) end)
                    
                    CDepthCharge.RackSalvoReloadState.Main(self)

                end,
            },
        },
    },

    OnStopBeingBuilt = function(self,builder,layer)
	
        CSeaUnit.OnStopBeingBuilt(self,builder,layer)
		
        self.Trash:Add(CreateRotator(self, 'Cybran_Radar', 'y', nil, 90, 0, 0))
        self.Trash:Add(CreateRotator(self, 'Back_Radar', 'y', nil, -360, 0, 0))
        self.Trash:Add(CreateRotator(self, 'Front_Radar', 'y', nil, -180, 0, 0))
		
    end,
}

TypeClass = URS0103
