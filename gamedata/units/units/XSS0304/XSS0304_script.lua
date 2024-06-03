local SSubUnit =  import('/lua/defaultunits.lua').SubUnit

local SANUallCavitationTorpedo = import('/lua/seraphimweapons.lua').SANUallCavitationTorpedo
local SAALosaareAutoCannonWeapon = import('/lua/seraphimweapons.lua').SAALosaareAutoCannonWeaponSeaUnit

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add

XSS0304 = Class(SSubUnit) {

    Weapons = {
	
        Torpedo = Class(SANUallCavitationTorpedo) {},

        AAAutoCannon = Class(SAALosaareAutoCannonWeapon) {},
    },
    
    OnStopBeingBuilt = function(self,builder,layer)
	
        SSubUnit.OnStopBeingBuilt(self,builder,layer)

        -- create Torp Defense emitters
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy
        
        for _,v in bp.AttachBone do

            local antiMissile1 = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = v, RedirectRateOfFire = bp.RedirectRateOfFire }

            TrashAdd( self.Trash, antiMissile1)
            
        end

		
        if layer == 'Water' then
            ChangeState( self, self.OpenState )
        else
            ChangeState( self, self.ClosedState )
        end
		
    end,

    OnLayerChange = function( self, new, old )
	
        SSubUnit.OnLayerChange(self, new, old)
		
        if new == 'Water' then
		
            ChangeState( self, self.OpenState )
			
        elseif new == 'Sub' then
		
            ChangeState( self, self.ClosedState )
			
        end
		
    end,
    
    OpenState = State() {
	
        Main = function(self)
		
            if not self.CannonAnim then
                self.CannonAnim = CreateAnimator(self)
                self.Trash:Add(self.CannonAnim)
            end
			
            local bp = self:GetBlueprint()
			
            self.CannonAnim:PlayAnim(bp.Display.CannonOpenAnimation)
            self.CannonAnim:SetRate(bp.Display.CannonOpenRate or 1)
			
            WaitFor(self.CannonAnim)
			
        end,
    },
    
    ClosedState = State() {
	
        Main = function(self)
			
            if self.CannonAnim then
			
                local bp = self:GetBlueprint()
				
                self.CannonAnim:SetRate( -1 * ( bp.Display.CannonOpenRate or 1 ) )
				
                WaitFor(self.CannonAnim)
				
            end
			
        end,
		
    },
	
}
TypeClass = XSS0304