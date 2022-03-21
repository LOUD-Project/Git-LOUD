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
		
        --WaitFor(self.CannonAnim)		

--[[		
        if layer == 'Water' then
            ChangeState( self, self.CannonEnabled )
        else
            ChangeState( self, self.CannonDisabled )
        end
--]]		
    end,
   
--[[   
    OnLayerChange = function(self, new, old)
	
		SSubUnit.OnLayerChange(self, new, old)
		
   		if new == 'Sub' then
            ChangeState( self, self.CannonDisabled )
   		elseif new == 'Water' then
            ChangeState( self, self.CannonEnabled )
   		end
		
    end,
    
    CannonEnabled = State() {
        Main = function(self)
            if not self.CannonAnim then
                self.CannonAnim = CreateAnimator(self)
                self.Trash:Add(self.CannonAnim)
            end
            local bp = self:GetBlueprint()
            self.CannonAnim:PlayAnim(bp.Display.CannonOpenAnimation)
            self.CannonAnim:SetRate(bp.Display.CannonOpenRate or 1)
            WaitFor(self.CannonAnim)
            self:SetWeaponEnabledByLabel('Cannon', true)
        end,
    },
    
    CannonDisabled = State() {
        Main = function(self)
            self:SetWeaponEnabledByLabel('Cannon', false)
            if self.CannonAnim then
                local bp = self:GetBlueprint()
                self.CannonAnim:SetRate( -1 * ( bp.Display.CannonOpenRate or 1 ) )
                WaitFor(self.CannonAnim)
            end
        end,
    },
--]]	
	
}

TypeClass = XSS0203