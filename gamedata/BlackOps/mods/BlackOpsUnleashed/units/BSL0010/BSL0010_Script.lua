local SWalkingLandUnit = import('/lua/seraphimunits.lua').SWalkingLandUnit

local SDFThauCannon = import('/lua/seraphimweapons.lua').SDFThauCannon
local SAMElectrumMissileDefense = import('/lua/seraphimweapons.lua').SAMElectrumMissileDefense

local ForkThread = ForkThread

BSL0010 = Class(SWalkingLandUnit) {
    Weapons = {
        MainGun = Class(SDFThauCannon) {},
        AntiMissile = Class(SAMElectrumMissileDefense) {},
    },
    
    
    OnStopBeingBuilt = function(self,builder,layer)
	
        SWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
		
		self.lambdaEmitterTable = {}
		self:SetScriptBit('RULEUTC_ShieldToggle', true)
		
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
		
        SWalkingLandUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
    
    OnScriptBitSet = function(self, bit)
	
        SWalkingLandUnit.OnScriptBitSet(self, bit)
		
        local army =  self:GetArmy()
		
        if bit == 0 then 
			self:ForkThread(self.LambdaEmitter)
    	end
    end,
    
    OnScriptBitClear = function(self, bit)
	
        SWalkingLandUnit.OnScriptBitClear(self, bit)
		
        if bit == 0 then 
			self:ForkThread(self.KillLambdaEmitter)
			self:SetMaintenanceConsumptionInactive()
    	end
    end,
    
	LambdaEmitter = function(self)

		if not self.Dead then
	
			WaitSeconds(0.5)
        
			if not self.Dead then

				local platOrient = self:GetOrientation()

				local location = self:GetPosition('Torso')

				local lambdaEmitter = CreateUnit('bsb0005', self:GetArmy(), location[1], location[2], location[3], platOrient[1], platOrient[2], platOrient[3], platOrient[4], 'Land') 

				table.insert (self.lambdaEmitterTable, lambdaEmitter)
            
				lambdaEmitter:AttachTo(self, 'Torso') 

				lambdaEmitter:SetParent(self, 'bsl0010')
				lambdaEmitter:SetCreator(self)  

				self.Trash:Add(lambdaEmitter)
			end
		end 
	end,

	KillLambdaEmitter = function(self, instigator, type, overkillRatio)

		if table.getn({self.lambdaEmitterTable}) > 0 then
		
			for k, v in self.lambdaEmitterTable do 
				IssueClearCommands({self.lambdaEmitterTable[k]}) 
				IssueKillSelf({self.lambdaEmitterTable[k]})
			end
			
		end
	end,
	
	ResourceThread = function(self) 

    	if not self.Dead then
		
        	local energy = self:GetAIBrain():GetEconomyStored('Energy')

        	if  energy <= 10 then 

            	self:ForkThread(self.KillFactory)
            	self:SetScriptBit('RULEUTC_ShieldToggle', false)
            	self:ForkThread(self.ResourceThread2)

        	else
            	self:ForkThread(self.EconomyWaitUnit)
        	end
    	end    
	end,

	EconomyWaitUnit = function(self)
	
    	if not self.Dead then
		
			WaitSeconds(2)

        	if not self.Dead then
            	self:ForkThread(self.ResourceThread)
        	end
    	end
	end,

	KillFactory = function(self)
    	self:Kill()
	end,
	
	ResourceThread2 = function(self) 

    	if not self.Dead then
		
        	local energy = self:GetAIBrain():GetEconomyStored('Energy')

        	if  energy > 300 then 

            	self:SetScriptBit('RULEUTC_ShieldToggle', true)
            	self:ForkThread(self.ResourceThread)

        	else
            	self:ForkThread(self.EconomyWaitUnit2)
        	end
    	end    
	end,

	EconomyWaitUnit2 = function(self)
	
    	if not self.Dead then
		
			WaitSeconds(2)

        	if not self:IsDead() then
            	self:ForkThread(self.ResourceThread2)
        	end
    	end
	end,

}
TypeClass = BSL0010