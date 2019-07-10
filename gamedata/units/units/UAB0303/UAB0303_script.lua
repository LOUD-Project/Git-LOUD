
local ASeaFactoryUnit = import('/lua/aeonunits.lua').ASeaFactoryUnit

local AIFQuasarAntiTorpedoWeapon = import('/lua/aeonweapons.lua').AIFQuasarAntiTorpedoWeapon

UAB0303 = Class(ASeaFactoryUnit) {

    Weapons = {
        AntiTorpedo = Class(AIFQuasarAntiTorpedoWeapon) {},
    },
    
    OnCreate = function(self)
        ASeaFactoryUnit.OnCreate(self)
        self.BuildPointSlider = CreateSlider(self, self:GetBlueprint().Display.BuildAttachBone or 0, -15, 0, 0, -1)
        self.Trash:Add(self.BuildPointSlider)
    end,
}

TypeClass = UAB0303

