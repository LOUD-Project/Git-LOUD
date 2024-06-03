local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CreateAttachedEmitter = CreateAttachedEmitter
local CreateRotator = CreateRotator

local LOUDINSERT = table.insert

BEB4309 = Class(TStructureUnit) {

	AntiTeleport = {'/effects/emitters/seraphim_shield_generator_t3_03_emit.bp','/effects/emitters/seraphim_shield_generator_t2_03_emit.bp'},

    OnStopBeingBuilt = function(self,builder,layer)
	
        TStructureUnit.OnStopBeingBuilt(self,builder,layer)

        self:SetScriptBit('RULEUTC_ShieldToggle', true)
        self:DisableUnitIntel('CloakField')
		
        self.antiteleportEmitterTable = {}
        self.AntiTeleportBag = {}
		
        self:ForkThread(self.ResourceThread)
    end,
    
    OnScriptBitSet = function(self, bit)
	
        TStructureUnit.OnScriptBitSet(self, bit)

        if bit == 0 then 
		
			self:ForkThread(self.antiteleportEmitter)
			self:ForkThread(self.AntiteleportEffects)
			self:SetMaintenanceConsumptionActive()
        	
        	if (not self.Rotator1) then
            	self.Rotator1 = CreateRotator(self, 'Spinner_Upper', 'y')
            	self.Trash:Add(self.Rotator1)
        	end
			
        	self.Rotator1:SetTargetSpeed(-70)
        	self.Rotator1:SetAccel(7)

            if (not self.Rotator2) then
            	self.Rotator2 = CreateRotator(self, 'Spinner_middle', 'y')
            	self.Trash:Add(self.Rotator2)
        	end
			
        	self.Rotator2:SetTargetSpeed(300)
        	self.Rotator2:SetAccel(30)
        
        	if (not self.Rotator3) then
            	self.Rotator3 = CreateRotator(self, 'Spinner_lower', 'y')
            	self.Trash:Add(self.Rotator3)
        	end
			
        	self.Rotator3:SetTargetSpeed(-70)
        	self.Rotator3:SetAccel(10)
        end
		
    end,
	
    AntiteleportEffects = function(self)
	
    	if self.AntiTeleportBag then
            for k, v in self.AntiTeleportBag do
                v:Destroy()
            end
		    self.AntiTeleportBag = {}
		end
		
		local army = self.Army
		local CreateAttachedEmitter = CreateAttachedEmitter
		
        for k, v in self.AntiTeleport do
            LOUDINSERT( self.AntiTeleportBag, CreateAttachedEmitter( self, 'Effect01', army, v ):ScaleEmitter(0.1) )
            LOUDINSERT( self.AntiTeleportBag, CreateAttachedEmitter( self, 'Effect01', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, -0.5, 0) )
            LOUDINSERT( self.AntiTeleportBag, CreateAttachedEmitter( self, 'Effect01', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.5, 0) )
            LOUDINSERT( self.AntiTeleportBag, CreateAttachedEmitter( self, 'Effect02', army, v ):ScaleEmitter(0.1) )
            LOUDINSERT( self.AntiTeleportBag, CreateAttachedEmitter( self, 'Effect02', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, -0.5, 0) )
            LOUDINSERT( self.AntiTeleportBag, CreateAttachedEmitter( self, 'Effect02', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.5, 0) )
            LOUDINSERT( self.AntiTeleportBag, CreateAttachedEmitter( self, 'Effect03', army, v ):ScaleEmitter(0.1) )
            LOUDINSERT( self.AntiTeleportBag, CreateAttachedEmitter( self, 'Effect03', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.5, 0) )
            LOUDINSERT( self.AntiTeleportBag, CreateAttachedEmitter( self, 'Effect04', army, v ):ScaleEmitter(0.1) )
            LOUDINSERT( self.AntiTeleportBag, CreateAttachedEmitter( self, 'Effect04', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, -0.5, 0) )
            LOUDINSERT( self.AntiTeleportBag, CreateAttachedEmitter( self, 'Effect05', army, v ):ScaleEmitter(0.1) )
            LOUDINSERT( self.AntiTeleportBag, CreateAttachedEmitter( self, 'Effect05', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.5, 0) )
            LOUDINSERT( self.AntiTeleportBag, CreateAttachedEmitter( self, 'Effect06', army, v ):ScaleEmitter(0.1) )
            LOUDINSERT( self.AntiTeleportBag, CreateAttachedEmitter( self, 'Effect06', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, -0.5, 0) )
        end
    end,
    
    OnScriptBitClear = function(self, bit)
	
        TStructureUnit.OnScriptBitClear(self, bit)
		
        if bit == 0 then 
		
			self:ForkThread(self.KillantiteleportEmitter)
			self:SetMaintenanceConsumptionInactive()
        	
        	if (not self.Rotator1) then
            	self.Rotator1 = CreateRotator(self, 'Spinner_Upper', 'y')
            	self.Trash:Add(self.Rotator1)
        	end
			
        	self.Rotator1:SetTargetSpeed(0)
        	self.Rotator1:SetAccel(30)

        	if (not self.Rotator2) then
            	self.Rotator2 = CreateRotator(self, 'Spinner_middle', 'y')
            	self.Trash:Add(self.Rotator2)
        	end
			
        	self.Rotator2:SetTargetSpeed(0)
        	self.Rotator2:SetAccel(50)
        
        	if (not self.Rotator3) then
            	self.Rotator3 = CreateRotator(self, 'Spinner_lower', 'y')
            	self.Trash:Add(self.Rotator3)
        	end
			
        	self.Rotator3:SetTargetSpeed(0)
        	self.Rotator3:SetAccel(30)

        	if self.AntiTeleportBag then
            	for k, v in self.AntiTeleportBag do
                	v:Destroy()
            	end
		    	self.AntiTeleportBag = {}
			end
		end
    end,

    antiteleportEmitter = function(self)

    	if not self.Dead then
		
        	WaitSeconds(0.5)

        	if not self.Dead then

            	local platOrient = self:GetOrientation()
            
				local location = self:GetPosition('XEB4309')

            	local antiteleportEmitter = CreateUnit('beb0003', self:GetArmy(), location[1], location[2], location[3], platOrient[1], platOrient[2], platOrient[3], platOrient[4], 'Land') 

            	LOUDINSERT (self.antiteleportEmitterTable, antiteleportEmitter)

            	antiteleportEmitter:SetParent(self, 'beb4309')
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

TypeClass = BEB4309