local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local CybranWeaponsFile = import('/lua/cybranweapons.lua')
local CybranWeaponsFile2 = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua')
local CDFLaserHeavyWeapon = CybranWeaponsFile.CDFLaserHeavyWeapon
local ScorpDisintegratorWeapon = CybranWeaponsFile2.ScorpDisintegratorWeapon

local CreateCybranBuildBeams = import('/lua/EffectUtilities.lua').CreateCybranBuildBeams

local ScaleEmitter = moho.IEffect.ScaleEmitter
local TrashDestroy = TrashBag.Destroy

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
		
        Disintigrator01 = Class(ScorpDisintegratorWeapon) {},
    },
    
    OnCreate = function(self)
    
        CWalkingLandUnit.OnCreate(self)
        
        self:SetMaintenanceConsumptionActive()
		
		if __blueprints[self.BlueprintID].General.BuildBones then
            self:SetupBuildBones()
        end
    end,
	
    CreateBuildEffects = function( self, unitBeingBuilt, order )

       CreateCybranBuildBeams( self, unitBeingBuilt, __blueprints[self.BlueprintID].General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
       
    end,
    
    OnStopBuild = function( self, unitBeingBuilt )

        if self.BuildProjectile then
        
            for _, v in self.BuildProjectile do
            
                TrashDestroy( v.BuildEffectsBag )
                
                ScaleEmitter( v.Emitter, .1)
                ScaleEmitter( v.Sparker, .1)

                if v.Detached then
                    v:AttachTo( self, v.Name )
                end
                
                v.Detached = false
                
            end
        end
        
        CWalkingLandUnit.OnStopBuild( self, unitBeingBuilt )

    end,

    OnStopBeingBuilt = function(self, builder, layer)
    
        CWalkingLandUnit.OnStopBeingBuilt(self, builder, layer)
        
        self:EnableUnitIntel('RadarStealth')        

		self:DisableUnitIntel('Cloak')
        
		self.Cloaked = false
        
        ChangeState( self, self.InvisState )
        

    end,
    
    InvisState = State() {
    
        Main = function(self)
            
            local bp = __blueprints[self.BlueprintID]

            self:SetEnergyMaintenanceConsumptionOverride(bp.Economy.MaintenanceConsumptionPerSecondEnergyCloak)
            
            self:SetMaintenanceConsumptionActive()
        
            self.Cloaked = false

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
            
            CWalkingLandUnit.OnMotionHorzEventChange(self, new, old)
        end,
    },
    
    VisibleState = State() {
    
        Main = function(self)
            
            local bp = __blueprints[self.BlueprintID]

            self:SetEnergyMaintenanceConsumptionOverride(bp.Economy.MaintenanceConsumptionPerSecondEnergy)
            
            self:SetMaintenanceConsumptionActive()        
            
            if self.Cloaked then
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