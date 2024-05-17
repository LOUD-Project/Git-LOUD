local CStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local Shield = import('/lua/shield.lua').Shield

local ForkThread = ForkThread

BRB4309 = Class(CStructureUnit) {

    OnCreate = function(self)

        CStructureUnit.OnCreate(self)

        self.ExtractionAnimManip = CreateAnimator(self)
    end,

    OnStopBeingBuilt = function(self,builder,layer)

        CStructureUnit.OnStopBeingBuilt(self,builder,layer)

        self:SetScriptBit('RULEUTC_ShieldToggle', true)
        self:DisableUnitIntel('CloakField')

        self.antiteleportEmitterTable = {}
        self:ForkThread(self.ResourceThread)
    end,

    OnScriptBitSet = function(self, bit)

       	CStructureUnit.OnScriptBitSet(self, bit)

       	if bit == 0 then 

       		self:ForkThread(self.antiteleportEmitter)
        	self:SetMaintenanceConsumptionActive()

       		if(not self.Rotator1) then
            	self.Rotator1 = CreateRotator(self, 'Shaft', 'y')
            	self.Trash:Add(self.Rotator1)
        	end

        	self.Rotator1:SetTargetSpeed(30)
        	self.Rotator1:SetAccel(30)
        end
    end,

    OnScriptBitClear = function(self, bit)

        CStructureUnit.OnScriptBitClear(self, bit)

        if bit == 0 then 

        	self:ForkThread(self.KillantiteleportEmitter)
        	self:SetMaintenanceConsumptionInactive()

        	if(not self.Rotator1) then
            	self.Rotator1 = CreateRotator(self, 'Shaft', 'y')
            	self.Trash:Add(self.Rotator1)
        	end

        	self.Rotator1:SetTargetSpeed(0)
        	self.Rotator1:SetAccel(30)
        end
    end,
    
    antiteleportEmitter = function(self)

    	if not self.Dead then

        	WaitSeconds(0.5)

        	if not self.Dead then

            	local platOrient = self:GetOrientation()
            
            	local location = self:GetPosition('Shaft')

            	local antiteleportEmitter = CreateUnit('beb0003', self:GetArmy(), location[1], location[2], location[3], platOrient[1], platOrient[2], platOrient[3], platOrient[4], 'Land') 

            	table.insert (self.antiteleportEmitterTable, antiteleportEmitter)
            
            	antiteleportEmitter:AttachTo(self, 'Shaft') 

            	antiteleportEmitter:SetParent(self, 'brb4309')
            	antiteleportEmitter:SetCreator(self)  

            	self.Trash:Add(antiteleportEmitter)
        	end
    	end 
	end,


	KillantiteleportEmitter = function(self, instigator, type, overkillRatio)
 
    	if table.getn({self.antiteleportEmitterTable}) > 0 then
        
        	for k, v in self.antiteleportEmitterTable do 
            	IssueClearCommands({self.antiteleportEmitterTable[k]}) 
            	IssueKillSelf({self.antiteleportEmitterTable[k]})
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

        	if not self.Dead then
            	self:ForkThread(self.ResourceThread)
        	end
    	end
	end,
	
	ResourceThread2 = function(self) 

    	if not self.Dead then

        	local energy = self:GetAIBrain():GetEconomyStored('Energy')

        	if  energy >= 3000 then 

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

TypeClass = BRB4309