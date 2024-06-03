local SRadarUnit = import('/lua/seraphimunits.lua').SRadarUnit

local SHoverLandUnit = import('/lua/defaultunits.lua').MobileUnit

SSL0324 = Class(SHoverLandUnit) {

    OnCreate = function(self)
        self.FxBlinkingLightsBag = {}
        SHoverLandUnit.OnCreate(self)
    end,

    OnIntelEnabled = function(self)

        SRadarUnit.OnIntelEnabled(self)

        if not self.Rotator then
            self.Rotator = CreateRotator(self, 'Array', 'y')
            self.Trash:Add(self.Rotator1)
        end

        self.Rotator:SetTargetSpeed(30)
        self.Rotator:SetAccel(20)
    end,

    PlayActiveAnimation = function(self)
        if SRadarUnit.PlayActiveAnimation then
            SRadarUnit.PlayActiveAnimation(self)
        end
    end,

    CreateBlinkingLights = function(self, color)
        if SRadarUnit.CreateBlinkingLights then
            SRadarUnit.CreateBlinkingLights(self, color)
        end
    end,

    DestroyBlinkingLights = function(self)
        if SRadarUnit.DestroyBlinkingLights then
            SRadarUnit.DestroyBlinkingLights(self)
        end
    end,
}

TypeClass = SSL0324
