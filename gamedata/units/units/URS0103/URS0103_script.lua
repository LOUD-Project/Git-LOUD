local CSeaUnit = import('/lua/cybranunits.lua').CSeaUnit
local CybranWeaponsFile = import('/lua/cybranweapons.lua')
local CAAAutocannon = CybranWeaponsFile.CAAAutocannon
local CDFProtonCannonWeapon = CybranWeaponsFile.CDFProtonCannonWeapon

URS0103 = Class(CSeaUnit) {

    DestructionTicks = 200,

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
