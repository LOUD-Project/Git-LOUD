local SAirUnit = import('/lua/defaultunits.lua').AirUnit

local explosion = import('/lua/defaultexplosions.lua')
local util = import('/lua/utilities.lua')

local SeraphimWeapons = import('/lua/seraphimweapons.lua')

local SAAShleoCannonWeapon          = SeraphimWeapons.SAAShleoCannonWeapon
local SDFHeavyPhasicAutoGunWeapon   = SeraphimWeapons.SDFHeavyPhasicAutoGunWeapon

SeraphimWeapons = nil

local SeraLambdaFieldRedirector = import('/lua/defaultantiprojectile.lua').SeraLambdaFieldRedirector
local SeraLambdaFieldDestroyer = import('/lua/defaultantiprojectile.lua').SeraLambdaFieldDestroyer

local ForkThead = ForkThread

BSA0309 = Class(SAirUnit) {

    AirDestructionEffectBones = { 'XSA0309','Left_Attachpoint08','Right_Attachpoint02'},

    Weapons = {
	
        AutoGun = Class(SDFHeavyPhasicAutoGunWeapon) {},
        AAGun = Class(SAAShleoCannonWeapon) {},
		
    },
	
	OnStopBeingBuilt = function(self, builder, layer)
	
        local bp = __blueprints[self.BlueprintID].Defense.LambdaRedirect01
        local bp3 = __blueprints[self.BlueprintID].Defense.LambdaDestroy01
		
        self.Lambda1 = SeraLambdaFieldRedirector {
            Owner = self,
            Radius = bp.Radius,
            AttachBone = bp.AttachBone,
            RedirectRateOfFire = bp.RedirectRateOfFire
        }

        self.Lambda2 = SeraLambdaFieldDestroyer {
            Owner = self,
            Radius = bp3.Radius,
            AttachBone = bp3.AttachBone,
            RedirectRateOfFire = bp3.RedirectRateOfFire
        }
		
        self.Trash:Add( self.Lambda1 )
        self.Trash:Add( self.Lambda2 )
		
        self.UnitComplete = true
		
        SAirUnit.OnStopBeingBuilt(self,builder,layer)

		-- turn on Lambda emitters --
        self:SetScriptBit('RULEUTC_SpecialToggle', true)
    end,
    
    OnScriptBitSet = function(self, bit)
	
        SAirUnit.OnScriptBitSet(self, bit)
		
        if bit == 7 then 
            self.Lambda1:Enable()
            self.Lambda2:Enable()

			self:SetMaintenanceConsumptionActive()
            
            if not self.ConsumptionThread then
                self.ConsumptionThread = self:ForkThread( self.WatchConsumption )
            end

    	end
    end,
    
    OnScriptBitClear = function(self, bit)
	
        SAirUnit.OnScriptBitClear(self, bit)
		
        if bit == 7 then 
            self.Lambda1:Disable()
            self.Lambda2:Disable()

			self:SetMaintenanceConsumptionInactive()
    	end
        
        KillThread(self.ConsumptionThread)
        self.ConsumptionThread = nil

    end,

    -- this thread is launched when the lambda is turned on
    -- and will disable it, and remove the toggle, if the power drops out
    -- and will restore it once the power returns
    WatchConsumption = function(self)
	
        local GetEconomyStored = moho.aibrain_methods.GetEconomyStored
		local GetResourceConsumed = moho.unit_methods.GetResourceConsumed
        local WaitTicks = coroutine.yield

        local MaintenanceConsumption = __blueprints[self.BlueprintID].MaintenanceConsumptionPerSecondEnergy
    
        local on = true
        local count

        local aiBrain = self:GetAIBrain()
        local army =  self.Army

        while true do

            count = 0
            
            WaitTicks(11)
            
            if GetResourceConsumed(self) != 1 and GetEconomyStored(aiBrain,'Energy') < 1 then
            
                self.Lambda1:Disable()

                self:SetMaintenanceConsumptionInactive()

                self:RemoveToggleCap('RULEUTC_SpecialToggle')

                on = false
            end

            while not on do

                WaitTicks(11)

                if GetEconomyStored(aiBrain,'Energy') > MaintenanceConsumption then

                    self.Lambda1:Enable()

                    self:SetMaintenanceConsumptionActive()

                    self:AddToggleCap('RULEUTC_SpecialToggle')

                    on = true
                end
            end
           
        end
        
    end,	
    -- Override air destruction effects so we can do something custom here
    CreateUnitAirDestructionEffects = function( self, scale )
	
        self:ForkThread(self.AirDestructionEffectsThread, self )
		
    end,

    AirDestructionEffectsThread = function( self )
	
        local numExplosions = math.floor( table.getn( self.AirDestructionEffectBones ) * 0.5 )
		
        for i = 0, numExplosions do
		
            explosion.CreateDefaultHitExplosionAtBone( self, self.AirDestructionEffectBones[util.GetRandomInt( 1, numExplosions )], 0.5 )
            WaitSeconds( util.GetRandomFloat( 0.2, 0.9 ))
			
        end
		
    end,
}

TypeClass = BSA0309