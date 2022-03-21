local SStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local SSeraphimSubCommanderGateway02 = import('/lua/EffectTemplates.lua').SeraphimSubCommanderGateway02


BSB4309 = Class(SStructureUnit) {

	AntiTeleport = {
       '/effects/emitters/op_seraphim_quantum_jammer_tower_emit.bp',
    },
    AntiTeleportOrbs = {
       '/effects/emitters/seraphim_gate_04_emit.bp',
       '/effects/emitters/seraphim_gate_05_emit.bp',
    },
    

    OnStopBeingBuilt = function(self,builder,layer)
    	SStructureUnit.OnStopBeingBuilt(self,builder,layer)
        self:SetScriptBit('RULEUTC_ShieldToggle', true)
        self:DisableUnitIntel('CloakField')
        self.antiteleportEmitterTable = {}
        self.AntiTeleportBag = {}
        self.AntiTeleportOrbsBag = {}
        self:ForkThread(self.ResourceThread)
    end,
    
     OnScriptBitSet = function(self, bit)
        SStructureUnit.OnScriptBitSet(self, bit)
        if bit == 0 then
        self:ForkThread(self.antiteleportEmitter)
        self:ForkThread(self.AntiteleportEffects)
        self:SetMaintenanceConsumptionActive()
        
        	if(not self.Rotator1) then
            	self.Rotator1 = CreateRotator(self, 'Spinner01', 'y')
            	self.Trash:Add(self.Rotator21)
        	end
        	self.Rotator1:SetTargetSpeed(-400)
        	self.Rotator1:SetAccel(100)
            if(not self.Rotator2) then
            	self.Rotator2 = CreateRotator(self, 'Spinner02', 'y')
            	self.Trash:Add(self.Rotator2)
        	end
        	self.Rotator2:SetTargetSpeed(400)
        	self.Rotator2:SetAccel(100)
        
        	if(not self.Rotator3) then
            	self.Rotator3 = CreateRotator(self, 'Array01', 'y')
            	self.Trash:Add(self.Rotator3)
        	end
        	self.Rotator3:SetTargetSpeed(-70)
        	self.Rotator3:SetAccel(30)
        end
    end,
    
    
    AntiteleportEffects = function(self)
        if self.AntiTeleportBag then
            for k, v in self.AntiTeleportBag do
                v:Destroy()
            end
		    self.AntiTeleportBag = {}
		end
        for k, v in self.AntiTeleport do
            table.insert( self.AntiTeleportBag, CreateAttachedEmitter( self, 'Light02', self:GetArmy(), v ):ScaleEmitter(0.5):OffsetEmitter(0, -0.5, 0) )
        end
        if self.AntiTeleportOrbsBag then
            for k, v in self.AntiTeleportOrbsBag do
                v:Destroy()
            end
		    self.AntiTeleportOrbsBag = {}
		end
        for k, v in self.AntiTeleportOrbs do
             table.insert( self.AntiTeleportOrbsBag, CreateAttachedEmitter( self, 'Orb01', self:GetArmy(), v ):ScaleEmitter(0.2):OffsetEmitter(0, -0.2, 0) )
            table.insert( self.AntiTeleportOrbsBag, CreateAttachedEmitter( self, 'Orb01', self:GetArmy(), v ):ScaleEmitter(0.2):OffsetEmitter(0, 0.2, 0) )
            table.insert( self.AntiTeleportOrbsBag, CreateAttachedEmitter( self, 'Orb01', self:GetArmy(), v ):ScaleEmitter(0.2):OffsetEmitter(0, 0, 0.3) )
            table.insert( self.AntiTeleportOrbsBag, CreateAttachedEmitter( self, 'Orb04', self:GetArmy(), v ):ScaleEmitter(0.2):OffsetEmitter(0, 0, 0.3) )
             table.insert( self.AntiTeleportOrbsBag, CreateAttachedEmitter( self, 'Orb04', self:GetArmy(), v ):ScaleEmitter(0.2):OffsetEmitter(0, -0.2, 0) )
            table.insert( self.AntiTeleportOrbsBag, CreateAttachedEmitter( self, 'Orb04', self:GetArmy(), v ):ScaleEmitter(0.2):OffsetEmitter(0, 0.2, 0) )
            table.insert( self.AntiTeleportOrbsBag, CreateAttachedEmitter( self, 'Orb06', self:GetArmy(), v ):ScaleEmitter(0.2):OffsetEmitter(0, 0, 0.3) )
             table.insert( self.AntiTeleportOrbsBag, CreateAttachedEmitter( self, 'Orb06', self:GetArmy(), v ):ScaleEmitter(0.2):OffsetEmitter(0, -0.2, 0) )
            table.insert( self.AntiTeleportOrbsBag, CreateAttachedEmitter( self, 'Orb06', self:GetArmy(), v ):ScaleEmitter(0.2):OffsetEmitter(0, 0.2, 0) )
            table.insert( self.AntiTeleportOrbsBag, CreateAttachedEmitter( self, 'Orb03', self:GetArmy(), v ):ScaleEmitter(0.2):OffsetEmitter(0, 0, 0.3) )
             table.insert( self.AntiTeleportOrbsBag, CreateAttachedEmitter( self, 'Orb03', self:GetArmy(), v ):ScaleEmitter(0.2):OffsetEmitter(0, -0.2, 0) )
            table.insert( self.AntiTeleportOrbsBag, CreateAttachedEmitter( self, 'Orb03', self:GetArmy(), v ):ScaleEmitter(0.2):OffsetEmitter(0, 0.2, 0) )
            table.insert( self.AntiTeleportOrbsBag, CreateAttachedEmitter( self, 'Orb07', self:GetArmy(), v ):ScaleEmitter(0.2):OffsetEmitter(0, 0, 0.3) )
             table.insert( self.AntiTeleportOrbsBag, CreateAttachedEmitter( self, 'Orb07', self:GetArmy(), v ):ScaleEmitter(0.2):OffsetEmitter(0, -0.2, 0) )
            table.insert( self.AntiTeleportOrbsBag, CreateAttachedEmitter( self, 'Orb07', self:GetArmy(), v ):ScaleEmitter(0.2):OffsetEmitter(0, 0.2, 0) )
            table.insert( self.AntiTeleportOrbsBag, CreateAttachedEmitter( self, 'Orb05', self:GetArmy(), v ):ScaleEmitter(0.2):OffsetEmitter(0, 0, 0.3) )
             table.insert( self.AntiTeleportOrbsBag, CreateAttachedEmitter( self, 'Orb05', self:GetArmy(), v ):ScaleEmitter(0.2):OffsetEmitter(0, -0.2, 0) )
            table.insert( self.AntiTeleportOrbsBag, CreateAttachedEmitter( self, 'Orb05', self:GetArmy(), v ):ScaleEmitter(0.2):OffsetEmitter(0, 0.2, 0) )
        end
    end,
    
     OnScriptBitClear = function(self, bit)
        SStructureUnit.OnScriptBitClear(self, bit)
        if bit == 0 then 
        self.FieldActive = false
        self:ForkThread(self.KillantiteleportEmitter)
        self:SetMaintenanceConsumptionInactive()
        	 if(not self.Rotator1) then
            	self.Rotator1 = CreateRotator(self, 'Spinner01', 'y')
            	self.Trash:Add(self.Rotator1)
        	end
        	self.Rotator1:SetTargetSpeed(0)
        	self.Rotator1:SetAccel(100)
        	
            if(not self.Rotator2) then
            	self.Rotator2 = CreateRotator(self, 'Spinner02', 'y')
            	self.Trash:Add(self.Rotator2)
        	end
        	self.Rotator2:SetTargetSpeed(0)
        	self.Rotator2:SetAccel(100)
        
        	if(not self.Rotator3) then
            	self.Rotator3 = CreateRotator(self, 'Array01', 'y')
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
			if self.AntiTeleportOrbsBag then
            	for k, v in self.AntiTeleportOrbsBag do
                	v:Destroy()
            	end
		    	self.AntiTeleportOrbsBag = {}
			end
		end
	end,
    

    antiteleportEmitter = function(self)
    	### Are we dead yet, if not then wait 0.5 second
    	if not self:IsDead() then
        	WaitSeconds(0.5)
        	### Are we dead yet, if not spawn antiteleportEmitter
        	if not self:IsDead() then

            	### Gets the platforms current orientation
            	local platOrient = self:GetOrientation()
            
            	### Gets the current position of the platform in the game world
            	local location = self:GetPosition('XSB4309')

            	### Creates our antiteleportEmitter over the platform with a ranomly generated Orientation
            	local antiteleportEmitter = CreateUnit('bsb0003', self:GetArmy(), location[1], location[2], location[3], platOrient[1], platOrient[2], platOrient[3], platOrient[4], 'Land') 

            	### Adds the newly created antiteleportEmitter to the parent platforms antiteleportEmitter table
            	table.insert (self.antiteleportEmitterTable, antiteleportEmitter)

            	### Sets the platform unit as the antiteleportEmitter parent
            	antiteleportEmitter:SetParent(self, 'bsb4309')
            	antiteleportEmitter:SetCreator(self)  
            	###antiteleportEmitter clean up scripts
            	self.Trash:Add(antiteleportEmitter)
        	end
    	end 
	end,


	KillantiteleportEmitter = function(self, instigator, type, overkillRatio)
    	### Small bit of table manipulation to sort thru all of the avalible rebulder bots and remove them after the platform is dead
    	if table.getn({self.antiteleportEmitterTable}) > 0 then
        	for k, v in self.antiteleportEmitterTable do 
            	IssueClearCommands({self.antiteleportEmitterTable[k]}) 
            	IssueKillSelf({self.antiteleportEmitterTable[k]})
        	end
    	end
	end,
    
    ResourceThread = function(self) 
    	### Only respawns the drones if the parent unit is not dead 
    	#LOG('*CHECK TO SEE IF WE HAVE TO TURN OFF THE FIELD!!!')
    	if not self:IsDead() then
        	local energy = self:GetAIBrain():GetEconomyStored('Energy')

        	### Check to see if the player has enough mass / energy
        	if  energy <= 10 then 

            	###Loops to check again
            	#LOG('*TURNING OFF FIELD!!')
            	self:SetScriptBit('RULEUTC_ShieldToggle', false)
            	self:ForkThread(self.ResourceThread2)

        	else
            	### If the above conditions are not met we check again
            	self:ForkThread(self.EconomyWaitUnit)
            	
        	end
    	end    
	end,

	EconomyWaitUnit = function(self)
    	if not self:IsDead() then
    	WaitSeconds(2)
	    #LOG('*we have enough so keep on checking Resthread1')
        	if not self:IsDead() then
            	self:ForkThread(self.ResourceThread)
        	end
    	end
	end,
	
	ResourceThread2 = function(self) 
    	### Only respawns the drones if the parent unit is not dead 
    	#LOG('*CAN WE TURN IT BACK ON YET?')
    	if not self:IsDead() then
        	local energy = self:GetAIBrain():GetEconomyStored('Energy')

        	### Check to see if the player has enough mass / energy
        	if  energy >= 3000 then 

            	###Loops to check again
            	#LOG('*TURNING ON FIELD!!!')
            	self:SetScriptBit('RULEUTC_ShieldToggle', true)
            	self:ForkThread(self.ResourceThread)

        	else
            	### If the above conditions are not met we kill this unit
            	self:ForkThread(self.EconomyWaitUnit2)
        	end
    	end    
	end,

	EconomyWaitUnit2 = function(self)
    	if not self:IsDead() then
    	WaitSeconds(2)
	    #LOG('*we dont have enough so keep on checking Resthread2!!')
        	if not self:IsDead() then
            	self:ForkThread(self.ResourceThread2)
        	end
    	end
	end,

    
}

TypeClass = BSB4309