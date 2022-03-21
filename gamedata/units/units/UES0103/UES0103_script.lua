local TSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local TAALinkedRailgun = import('/lua/terranweapons.lua').TAALinkedRailgun
local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFGaussCannonWeapon
local Entity = import('/lua/sim/Entity.lua').Entity

UES0103 = Class(TSeaUnit) {

    Weapons = {
	
        MainGun = Class(TDFGaussCannonWeapon) {},
        AAGun = Class(TAALinkedRailgun) {},
		
    },

    OnStopBeingBuilt = function(self,builder,layer)
	
        TSeaUnit.OnStopBeingBuilt(self,builder,layer)
		
        self.Trash:Add(CreateRotator(self, 'Spinner01', 'y', nil, 360, 0, 180))
        self.Trash:Add(CreateRotator(self, 'Spinner02', 'y', nil, 90, 0, 180))
        self.Trash:Add(CreateRotator(self, 'Spinner03', 'y', nil, -180, 0, -180))
		
        --self.RadarEnt = Entity {}
		
        --self.Trash:Add(self.RadarEnt)
		
        --self.RadarEnt:InitIntel(self:GetArmy(), 'Radar', self:GetBlueprint().Intel.RadarRadius or 75)
        --self.RadarEnt:EnableIntel('Radar')
		
        --self.RadarEnt:InitIntel(self:GetArmy(), 'Sonar', self:GetBlueprint().Intel.SonarRadius or 75)
        --self.RadarEnt:EnableIntel('Sonar')
		
        --self.RadarEnt:AttachBoneTo(-1, self, 0)
    end,
}

TypeClass = UES0103