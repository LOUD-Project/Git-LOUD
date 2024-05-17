local CSubUnit = import('/lua/defaultunits.lua').SubUnit

local WeaponsFile = import('/lua/cybranweapons.lua')

local CANNaniteTorpedoWeapon        = WeaponsFile.CANNaniteTorpedoWeapon
local CDFElectronBolterWeapon       = WeaponsFile.CDFElectronBolterWeapon
local CKrilTorpedoLauncherWeapon    = WeaponsFile.CKrilTorpedoLauncherWeapon

WeaponsFile = nil

local TorpRedirectField = import('/mods/BlackOpsUnleashed/lua/BlackOpsdefaultantiprojectile.lua').TorpRedirectField

BRS0305 = Class(CSubUnit) {
    
    Weapons = {
        DeckGun = Class(CDFElectronBolterWeapon) {},
        Torpedo01 = Class(CANNaniteTorpedoWeapon) {},
        Torpedo02 = Class(CKrilTorpedoLauncherWeapon) {},
    },
	
    OnStopBeingBuilt = function(self, builder, layer)
	
        CSubUnit.OnStopBeingBuilt(self,builder,layer)
		
        if layer == 'Water' then
		
            ChangeState( self, self.OpenState )
			
        else
		
            ChangeState( self, self.ClosedState )
			
        end

        local bp = self:GetBlueprint().Defense.TorpRedirectField01
        
        local TorpRedirectField01 = TorpRedirectField { Owner = self, Radius = bp.Radius, AttachBone = bp.AttachBone, RedirectRateOfFire = bp.RedirectRateOfFire }
		
        self.Trash:Add(TorpRedirectField01)

    end,
    
	OnLayerChange = function( self, new, old )
	
        CSubUnit.OnLayerChange(self, new, old)
		
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
			
            local bp2 = self:GetBlueprint()
			
            self.CannonAnim:PlayAnim(bp2.Display.CannonOpenAnimation)
            self.CannonAnim:SetRate(bp2.Display.CannonOpenRate or 1)
			
            WaitFor(self.CannonAnim)
			
        end,
		
    },
    
    ClosedState = State() {
	
        Main = function(self)
			
            if self.CannonAnim then
			
                local bp2 = self:GetBlueprint()
				
                self.CannonAnim:SetRate( -1 * ( bp2.Display.CannonOpenRate or 1 ) )
				
                WaitFor(self.CannonAnim)
				
            end
			
        end,
		
    },
	
}

TypeClass = BRS0305