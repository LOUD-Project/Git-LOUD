local CLandUnit = import('/lua/cybranunits.lua').CLandUnit
local CAAMissileNaniteWeapon = import('/lua/cybranweapons.lua').CAAMissileNaniteWeapon
local EffectUtil = import('/lua/EffectUtilities.lua')

SRL0320 = Class(CLandUnit) {

    IntelEffects = {
	
		{ Bones = { 0 }, Offset = { 0, 1, 0 }, Scale = 0.2, Type = 'Jammer01' },
		
    },
	
    Weapons = {
	
        MainGun = Class(CAAMissileNaniteWeapon) {
		
            CreateProjectileAtMuzzle = function(self, muzzle)
			
                if self.unit:IsIntelEnabled('Cloak') then
                    self.unit:SetMaintenanceConsumptionInactive()
                    self.unit:SetScriptBit('RULEUTC_CloakToggle', true)
                    self.unit:DisableUnitIntel('Cloak')
                    self.unit:RequestRefreshUI()			
                    self.unit.IntelWasOn = true
                end
                CAAMissileNaniteWeapon.CreateProjectileAtMuzzle(self, muzzle)   
            end,

            OnWeaponFired = function(self)
			
                if self.unit.IntelWasOn then
				
                    self.unit:SetMaintenanceConsumptionActive()
                    self.unit:SetScriptBit('RULEUTC_CloakToggle', false)
                    self.unit:EnableUnitIntel('Cloak')
                    self.unit:RequestRefreshUI()			
                    self.unit.IntelWasOn = false
					
                end
				
                CAAMissileNaniteWeapon.OnWeaponFired(self)
				
            end,
			
        },
    },
	
    OnStopBeingBuilt = function(self,builder,layer)
	
        CLandUnit.OnStopBeingBuilt(self,builder,layer)
		
        self:SetMaintenanceConsumptionActive()

        --These start enabled, so before going to InvisState, disable them.. they'll be reenabled shortly
        self:DisableUnitIntel('RadarStealth')
		self:DisableUnitIntel('SonarStealth')
		self:DisableUnitIntel('Cloak')
		
		self.Cloaked = false
		
        ChangeState( self, self.InvisState ) -- If spawned in we want the unit to be invis, normally the unit will immediately start moving
		
        self:EnableUnitIntel('RadarStealth')
		self:EnableUnitIntel('SonarStealth')
		
    end,
    
    
    OnIntelEnabled = function(self) 
	
        self:PlaySound(self:GetBlueprint().Audio.Cloak)
		
        CLandUnit.OnIntelEnabled(self)
		
        if self.IntelEffects and not self.IntelFxOn then
		
            self.IntelEffectsBag = {}
            self.CreateTerrainTypeEffects( self, self.IntelEffects, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag )
            self.IntelFxOn = true
        end
		
    end,

    OnIntelDisabled = function(self)
	
        self:PlaySound(self:GetBlueprint().Audio.Decloak)
        CLandUnit.OnIntelDisabled(self)
        EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
        self.IntelFxOn = false
    end,
	
    
    InvisState = State() {
	
        Main = function(self)
		
            self.Cloaked = false
			
            local bp = self:GetBlueprint()
			
            if bp.Intel.StealthWaitTime then
                WaitSeconds( bp.Intel.StealthWaitTime )
            end

			self:EnableUnitIntel('Cloak')
			self.Cloaked = true
        end,
        
        OnMotionHorzEventChange = function(self, new, old)
            if new != 'Stopped' then
                ChangeState( self, self.VisibleState )
            end
            CLandUnit.OnMotionHorzEventChange(self, new, old)
        end,
    },
    
    VisibleState = State() {
	
        Main = function(self)
		
            if self.Cloaked then
			    self:DisableUnitIntel('Cloak')
			end
			
        end,
        
        OnMotionHorzEventChange = function(self, new, old)
		
            if new == 'Stopped' then
                ChangeState( self, self.InvisState )
            end
			
            CLandUnit.OnMotionHorzEventChange(self, new, old)
        end,
    },		
}

TypeClass = SRL0320
