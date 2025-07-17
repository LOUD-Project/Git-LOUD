local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CreateAttachedEmitter = CreateAttachedEmitter
local CreateRotator = CreateRotator

local LOUDINSERT = table.insert

BEB4309 = Class(TStructureUnit) {

    AmbientEffects = {'/effects/emitters/aeon_shield_generator_t3_04_emit.bp'},

	ShieldEffects = {'/effects/emitters/terran_shield_generator_t2_01_emit.bp','/effects/emitters/seraphim_shield_generator_t2_03_emit.bp'},
  
    OnStopBeingBuilt = function(self,builder,layer)
	
        TStructureUnit.OnStopBeingBuilt(self,builder,layer)
        
        self.Slider1 = CreateSlider( self, 'Spinner_middle', 0, 0, 0, 0.1, true )
        self.Trash:Add(self.Slider1)
        
        self.Slider2 = CreateSlider( self, 'Spinner_lower', 0, 0, 0, 0.1, true )
        self.Trash:Add(self.Slider2)

        self.Rotator1 = CreateRotator(self, 'Spinner_Upper', 'y', nil, 0, 0, 0)
        self.Trash:Add(self.Rotator1)        
       	self.Rotator1:SetAccel(15)

        self.Rotator2 = CreateRotator(self, 'Spinner_middle', 'y', nil, 0, 0, 0)
        self.Trash:Add(self.Rotator2)
       	self.Rotator2:SetAccel(60)

        self.Rotator3 = CreateRotator(self, 'Spinner_lower', 'y', nil, 0, 0, 0)
        self.Trash:Add(self.Rotator3)
       	self.Rotator3:SetAccel(25)

        self:SetScriptBit('RULEUTC_ShieldToggle', true)

        self.AmbientEffectsBag = {}
		
        self:ForkThread(self.ResourceThread)
    end,
	
    AntiteleportEffects = function(self)

        for k, v in self.AmbientEffectsBag do
            v:Destroy()
            self.AmbientEffectsBag[k] = nil
        end

		local army = self.Army

        for k, v in self.AmbientEffects do
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter(self,'XEB4309',army,v):ScaleEmitter(0.30):OffsetEmitter(0,-0.5, 0) )
        end

        for k, v in self.ShieldEffects do
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Effect01', army, v ):ScaleEmitter(0.15):OffsetEmitter(0, 0, -0.46) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Effect02', army, v ):ScaleEmitter(0.15):OffsetEmitter(0, 0, -0.46) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Effect03', army, v ):ScaleEmitter(0.15):OffsetEmitter(0, 0.27, -0.46) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Effect04', army, v ):ScaleEmitter(0.15):OffsetEmitter(0,-0.27, -0.46) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Effect05', army, v ):ScaleEmitter(0.15):OffsetEmitter(0, 0.27, -0.46) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Effect06', army, v ):ScaleEmitter(0.15):OffsetEmitter(0,-0.27, -0.46) )
        end		
    end,
    
    OnScriptBitSet = function(self, bit)

        TStructureUnit.OnScriptBitSet(self, bit)

        if bit == 0 then 

			self:ForkThread(self.AntiteleportEffects)

            self.Slider1:SetGoal(0,0,0)
            self.Slider2:SetGoal(0,0,0)

        	self.Rotator1:SetTargetSpeed(-30)
        	self.Rotator2:SetTargetSpeed(120)
        	self.Rotator3:SetTargetSpeed(-50)

			self:SetMaintenanceConsumptionActive()
        end
    end,
    
    OnScriptBitClear = function(self, bit)
	
        TStructureUnit.OnScriptBitClear(self, bit)
		
        if bit == 0 then 
			
            self.Slider1:SetGoal(0,-0.4,0)
            self.Slider2:SetGoal(0,-0.4,0)

        	self.Rotator1:SetTargetSpeed(0)
        	self.Rotator2:SetTargetSpeed(0)
        	self.Rotator3:SetTargetSpeed(0)

			self:SetMaintenanceConsumptionInactive()

           	for k, v in self.AmbientEffectsBag do
               	v:Destroy()
                self.AmbientEffectsBag[k] = nil
           	end
		end
    end,
    
    ResourceThread = function(self) 

    	if not self.Dead then
		
        	local energy = self:GetAIBrain():GetEconomyStored('Energy')

        	if  energy <= 1000 then 

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