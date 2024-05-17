local SWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local SDFThauCannon             = import('/lua/seraphimweapons.lua').SDFThauCannon
local SAMElectrumMissileDefense = import('/lua/seraphimweapons.lua').SAMElectrumMissileDefense

local SeraLambdaFieldDestroyer  = import('/lua/defaultantiprojectile.lua').SeraLambdaFieldDestroyer

BSL0310 = Class(SWalkingLandUnit) {

    LambdaEffects = {'/effects/emitters/seraphim_rift_in_small_01_emit.bp','/effects/emitters/seraphim_rift_in_small_02_emit.bp'},

    Weapons = {
        MainGun     = Class(SDFThauCannon) {},
        AntiMissile = Class(SAMElectrumMissileDefense) {},
    },

    OnStopBeingBuilt = function(self,builder,layer)

        SWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)

        local bp = self:GetBlueprint().Defense.LambdaDestroy01

        self.Lambda1 = SeraLambdaFieldDestroyer {
            Owner = self,
            Radius = bp.Radius,
            AttachBone = bp.AttachBone,
            RedirectRateOfFire = bp.RedirectRateOfFire
        }

        self.Trash:Add(self.Lambda1)   

		self:SetScriptBit('RULEUTC_SpecialToggle', true)

    end,
    
    OnScriptBitSet = function(self, bit)
	
        SWalkingLandUnit.OnScriptBitSet(self, bit)
		
        if bit == 7 then 
            self.Lambda1:Enable()
			self:SetMaintenanceConsumptionActive()
            
            if not self.ConsumptionThread then
                self.ConsumptionThread = self:ForkThread( self.WatchConsumption )
            end

    	end
    end,
    
    OnScriptBitClear = function(self, bit)
	
        SWalkingLandUnit.OnScriptBitClear(self, bit)
		
        if bit == 7 then 
            self.Lambda1:Disable()
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

        self.Effects = {}    

        while true do

            count = 0

            for _,v in self.LambdaEffects do
                count = count + 1
                self.Effects[count] = CreateEmitterOnEntity( self, army, v ):ScaleEmitter(0.9)
            end
            
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

            for _,v in self.Effects do
                v:Destroy()
            end
            
        end
        
    end,
}
TypeClass = BSL0310