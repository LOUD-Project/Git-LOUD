local SLandUnit = import('/lua/defaultunits.lua').MobileUnit

local SDFUnstablePhasonBeam = import('/lua/kirvesweapons.lua').SDFUnstablePhasonBeam

local Dummy = import('/lua/kirvesweapons.lua').Dummy
local EffectTemplate = import('/lua/kirveseffects.lua')

local CreateAttachedEmitter = CreateAttachedEmitter
local ForkThread = ForkThread

BSL0009 = Class(SLandUnit) {

    Weapons = {
        PhasonBeam = Class(SDFUnstablePhasonBeam) {
			FxMuzzleFlash = {'/Effects/Emitters/seraphim_experimental_phasonproj_muzzle_flash_01_emit.bp','/Effects/Emitters/seraphim_experimental_phasonproj_muzzle_flash_02_emit.bp','/Effects/Emitters/seraphim_experimental_phasonproj_muzzle_flash_03_emit.bp','/Effects/Emitters/seraphim_experimental_phasonproj_muzzle_flash_04_emit.bp','/Effects/Emitters/seraphim_experimental_phasonproj_muzzle_flash_05_emit.bp','/Effects/Emitters/seraphim_experimental_phasonproj_muzzle_flash_06_emit.bp','/mods/BlackOpsUnleashed/Effects/Emitters/seraphim_electricity_emit.bp'},
		},
		
		Dummy = Class(Dummy) {},
    },
	
	AmbientEffects = 'OrbGlowEffect',
	
    OnStopBeingBuilt = function(self, builder, layer)
	
		SLandUnit.OnStopBeingBuilt(self,builder,layer)
		
        local army =  self.Army
		
        if self.AmbientEffects then
            for k, v in EffectTemplate[self.AmbientEffects] do
				CreateAttachedEmitter(self, 'Orb', army, v)
            end
        end
		
        if not self.Dead then

            self:SetMaintenanceConsumptionActive()
            self:ForkThread(self.ResourceThread)
            self:SetVeterancy(5)
			self.Brain = self:GetAIBrain()
        end
    end,

    
    OnKilled = function(self, instigator, type, overkillRatio)

        self:SetWeaponEnabledByLabel('MainTurret', false)
        self:SetWeaponEnabledByLabel('Torpedo01', false)
        self:SetWeaponEnabledByLabel('LeftTurret', false)
        self:SetWeaponEnabledByLabel('RightTurret', false)

        IssueClearCommands(self)

        SLandUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
    
    ResourceThread = function(self) 

    	if not self.Dead then
        	local energy = self.Brain:GetEconomyStored('Energy')

        	if  energy <= 10 then 
            	self:ForkThread(self.KillFactory)
        	else
            	self:ForkThread(self.EconomyWaitUnit)
        	end
    	end    
	end,

	EconomyWaitUnit = function(self)
	
    	if not self.Dead then
		
			WaitTicks(50)
			
        	if not self:IsDead() then
            	self:ForkThread(self.ResourceThread)
        	end
    	end
	end,
	
	KillFactory = function(self)
    	self:Kill()
	end,
}
TypeClass = BSL0009