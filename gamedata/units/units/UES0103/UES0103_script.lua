local TSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local TAALinkedRailgun = import('/lua/terranweapons.lua').TAALinkedRailgun
local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFGaussCannonWeapon

UES0103 = Class(TSeaUnit) {

    Weapons = {
	
        MainGun = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.5 },
        AAGun = Class(TAALinkedRailgun) {},
    },

    OnStopBeingBuilt = function(self,builder,layer)
	
        TSeaUnit.OnStopBeingBuilt(self,builder,layer)
		
        self.Trash:Add(CreateRotator(self, 'Spinner01', 'y', nil, 360, 0, 180))
        self.Trash:Add(CreateRotator(self, 'Spinner02', 'y', nil, 90, 0, 180))
        self.Trash:Add(CreateRotator(self, 'Spinner03', 'y', nil, -180, 0, -180))
    end,
}

TypeClass = UES0103