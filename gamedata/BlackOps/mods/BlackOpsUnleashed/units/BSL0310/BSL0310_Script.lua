local SWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local SDFThauCannon = import('/lua/seraphimweapons.lua').SDFThauCannon
local SAMElectrumMissileDefense = import('/lua/seraphimweapons.lua').SAMElectrumMissileDefense

local ForkThread = ForkThread

BSL0310 = Class(SWalkingLandUnit) {
    Weapons = {
        MainGun = Class(SDFThauCannon) {},
        AntiMissile = Class(SAMElectrumMissileDefense) {},
    },
    
    
    OnStopBeingBuilt = function(self,builder,layer)
        SWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
		self.lambdaEmitterTable = {}
		self:SetScriptBit('RULEUTC_ShieldToggle', true)
        self:ForkThread(self.ResourceThread)
    end,
    
    OnScriptBitSet = function(self, bit)
	
        SWalkingLandUnit.OnScriptBitSet(self, bit)
		
        local army =  self.Army
		
        if bit == 0 then 
			self:SetMaintenanceConsumptionActive()
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

				-- Creates lambdaEmitter over the platform with a ranomly generated Orientation
				local lambdaEmitter = CreateUnit('bsb0005', self:GetArmy(), location[1], location[2], location[3], platOrient[1], platOrient[2], platOrient[3], platOrient[4], 'Land') 

				table.insert (self.lambdaEmitterTable, lambdaEmitter)
            
				lambdaEmitter:AttachTo(self, 'Torso') 

				lambdaEmitter:SetParent(self, 'bsl0310')
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

        	if not self:IsDead() then
            	self:ForkThread(self.ResourceThread)
        	end
    	end
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

        	if not self.Dead then
            	self:ForkThread(self.ResourceThread2)
        	end
    	end
	end,


}
TypeClass = BSL0310