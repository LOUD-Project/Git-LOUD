local SSubUnit =  import('/lua/defaultunits.lua').SubUnit

local SWeapons = import('/lua/seraphimweapons.lua')

local SANUallCavitationTorpedo = SWeapons.SANUallCavitationTorpedo
local SDFOhCannon = SWeapons.SDFOhCannon02
local SDFAjelluAntiTorpedoDefense = SWeapons.SDFAjelluAntiTorpedoDefense

XSS0203 = Class(SSubUnit) {

    Weapons = {
	
        Torpedo = Class(SANUallCavitationTorpedo) {},
        Cannon = Class(SDFOhCannon) {},
        AntiTorpedo = Class(SDFAjelluAntiTorpedoDefense) {},
		
    },

    OnStopBeingBuilt = function(self,builder,layer)
	
        SSubUnit.OnStopBeingBuilt(self,builder,layer)
		
        self.CannonAnim = CreateAnimator(self)
        self.Trash:Add(self.CannonAnim)
		
        local bp = self:GetBlueprint()
		
        self.CannonAnim:PlayAnim(bp.Display.CannonOpenAnimation)
        self.CannonAnim:SetRate(bp.Display.CannonOpenRate or 1)

    end,
	
}

TypeClass = XSS0203