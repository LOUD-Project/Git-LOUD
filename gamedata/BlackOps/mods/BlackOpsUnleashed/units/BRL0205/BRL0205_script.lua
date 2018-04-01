local CWalkingLandUnit = import('/lua/cybranunits.lua').CWalkingLandUnit

local CybranWeaponsFile = import('/lua/cybranweapons.lua')
local CybranWeaponsFile2 = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua')
local CDFLaserHeavyWeapon = CybranWeaponsFile.CDFLaserHeavyWeapon
local ScorpDisintegratorWeapon = CybranWeaponsFile2.ScorpDisintegratorWeapon
local EffectUtil = import('/lua/EffectUtilities.lua')

BRL0205 = Class(CWalkingLandUnit) {

    Weapons = {
        LaserArms = Class(CDFLaserHeavyWeapon) {
			OnWeaponFired = function(self, target)
				CDFLaserHeavyWeapon.OnWeaponFired(self, target)
				ChangeState( self.unit, self.unit.VisibleState )
			end,
			
			OnLostTarget = function(self)
				CDFLaserHeavyWeapon.OnLostTarget(self)
				if self.unit:IsIdleState() then
				    ChangeState( self.unit, self.unit.InvisState )
				end
			end,
        },
		
        Disintigrator01 = Class(ScorpDisintegratorWeapon) {
        },
    },
    
    OnCreate = function(self)
        CWalkingLandUnit.OnCreate(self)
        self:SetMaintenanceConsumptionActive()
		
		if self:GetBlueprint().General.BuildBones then
            self:SetupBuildBones()
        end
    end,
	
    CreateBuildEffects = function( self, unitBeingBuilt, order )
       EffectUtil.SpawnBuildBots( self, unitBeingBuilt, 1, self.BuildEffectsBag )
       EffectUtil.CreateCybranBuildBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,
    
    OnStopBeingBuilt = function(self, builder, layer)
        CWalkingLandUnit.OnStopBeingBuilt(self, builder, layer)
        
        --These start enabled, so before going to InvisState, disabled them.. they'll be reenabled shortly
        self:DisableUnitIntel('RadarStealth')
		self:DisableUnitIntel('Cloak')
		self.Cloaked = false
        ChangeState( self, self.InvisState ) # If spawned in we want the unit to be invis, normally the unit will immediately start moving
        self:EnableUnitIntel('RadarStealth')
    end,
    
    InvisState = State() {
        Main = function(self)
            self.Cloaked = false
            local bp = self:GetBlueprint()
            if bp.Intel.StealthWaitTime then
                WaitSeconds( bp.Intel.StealthWaitTime )
            end
			#self:EnableUnitIntel('RadarStealth')
			self:EnableUnitIntel('Cloak')
			self.Cloaked = true
        end,
        
        OnMotionHorzEventChange = function(self, new, old)
            if new != 'Stopped' then
                ChangeState( self, self.VisibleState )
            end
            CWalkingLandUnit.OnMotionHorzEventChange(self, new, old)
        end,
    },
    
    VisibleState = State() {
        Main = function(self)
            if self.Cloaked then
                #self:DisableUnitIntel('RadarStealth')
			    self:DisableUnitIntel('Cloak')
			end
        end,
        
        OnMotionHorzEventChange = function(self, new, old)
            if new == 'Stopped' then
                ChangeState( self, self.InvisState )
            end
            CWalkingLandUnit.OnMotionHorzEventChange(self, new, old)
        end,
    },
}
TypeClass = BRL0205