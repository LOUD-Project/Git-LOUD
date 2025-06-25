local SSubUnit =  import('/lua/defaultunits.lua').SubUnit

local SWeapons = import('/lua/seraphimweapons.lua')

local Torpedo                       = SWeapons.SANAnaitTorpedo
local SDFAjelluAntiTorpedoDefense   = SWeapons.SDFAjelluAntiTorpedoDefense
local SDFOhCannon                   = SWeapons.SDFOhCannon02

SWeapons = nil

XSS0203 = Class(SSubUnit) {

    Weapons = {
        Torpedo     = Class(Torpedo) {
        
            RackSalvoReloadState = State( Torpedo.RackSalvoReloadState) {
            
                Main = function(self)

                    self:ForkThread( function() self:ChangeMaxRadius(36) self:ChangeMinRadius(36) WaitTicks(32) self:ChangeMinRadius(8) self:ChangeMaxRadius(34) end)
                    
                    Torpedo.RackSalvoReloadState.Main(self)

                end,
            },
        },

        AntiTorpedo = Class(SDFAjelluAntiTorpedoDefense) {},
        DeckGun     = Class(SDFOhCannon) {},		
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