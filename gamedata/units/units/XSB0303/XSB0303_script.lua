local SSeaFactoryUnit = import('/lua/seraphimunits.lua').SSeaFactoryUnit

local SDFAjelluAntiTorpedoDefense = import('/lua/seraphimweapons.lua').SDFAjelluAntiTorpedoDefense

XSB0303 = Class(SSeaFactoryUnit) {

    Weapons = {
        AntiTorpedo = Class(SDFAjelluAntiTorpedoDefense) {},
    },
  
    OnCreate = function(self)
        SSeaFactoryUnit.OnCreate(self)
        local bp = self:GetBlueprint()
        self.Rotator1 = CreateRotator(self, 'Pod01', 'y', nil, 3, 0, 0)
        self.Trash:Add(self.Rotator1)

        self.Rotator2 = CreateRotator(self, 'Pod02', 'y', nil, 6, 0, 0)
        self.Trash:Add(self.Rotator2)

        self.Rotator3 = CreateRotator(self, 'Pod03', 'y', nil, -3, 0, 0)
        self.Trash:Add(self.Rotator3)

        self.BuildPointSlider = CreateSlider(self, self:GetBlueprint().Display.BuildAttachBone or 0, -15, 0, 0, -1)
        self.Trash:Add(self.BuildPointSlider)
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        self.Rotator1:SetSpeed(0)
        self.Rotator2:SetSpeed(0)
        self.Rotator3:SetSpeed(0)
        SSeaFactoryUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
}

TypeClass = XSB0303

