local CSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local CybranWeaponsFile = import('/lua/cybranweapons.lua')
local CAAAutocannon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local CDFProtonCannonWeapon = CybranWeaponsFile.CDFProtonCannonWeapon

CybranWeaponsFile = nil

URS0103 = Class(CSeaUnit) {

    DestructionTicks = 120,

    Weapons = {
        ProtonCannon = Class(CDFProtonCannonWeapon) {},
        AAGun = Class(CAAAutocannon) {},
    },

    OnStopBeingBuilt = function(self,builder,layer)
	
        CSeaUnit.OnStopBeingBuilt(self,builder,layer)
		
        self.Trash:Add(CreateRotator(self, 'Cybran_Radar', 'y', nil, 90, 0, 0))
        self.Trash:Add(CreateRotator(self, 'Back_Radar', 'y', nil, -360, 0, 0))
        self.Trash:Add(CreateRotator(self, 'Front_Radar', 'y', nil, -180, 0, 0))
		
    end,
}

TypeClass = URS0103
