local CStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CreateAttachedEmitter = CreateAttachedEmitter

local LOUDINSERT = table.insert

BRB4309 = Class(CStructureUnit) {

    AmbientEffects = {'/effects/emitters/aeon_shield_generator_t3_04_emit.bp'},

    ShieldEffects = {
       '/effects/emitters/terran_shield_generator_t2_01_emit.bp',
        '/effects/emitters/terran_shield_generator_t2_02_emit.bp',
    },

    OnStopBeingBuilt = function(self,builder,layer)

        CStructureUnit.OnStopBeingBuilt(self,builder,layer)
        
        self.Slider1 = CreateSlider( self, 'Shaft', 0, 0, 0, 0.3, true )
        self.Trash:Add(self.Slider1)

        self.Rotator1 = CreateRotator(self, 'Shaft', 'y', nil, 0, 15, 20 + Random(0, 20))
        self.Trash:Add(self.Rotator1)
        self.Rotator1:SetAccel(10)

        self.AmbientEffectsBag = {}

        self:SetScriptBit('RULEUTC_ShieldToggle', true)

        self:ForkThread(self.ResourceThread)
    end,
	
	AntiteleportEffects = function(self)
	
        for k, v in self.AmbientEffectsBag do
            v:Destroy()
            self.AmbientEffectsBag[k] = nil
		end
		
        local army = self.Army
        
        for k, v in self.AmbientEffects do
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter(self,'XRB4309',army,v):ScaleEmitter(0.25) )
        end
		
        for k, v in self.ShieldEffects do
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Spike', army, v ):ScaleEmitter(0.38):OffsetEmitter(0,1.1,-1.2) )
        end        
    end,
  
    OnScriptBitSet = function(self, bit)

       	CStructureUnit.OnScriptBitSet(self, bit)

       	if bit == 0 then 

        	self:ForkThread(self.AntiteleportEffects)

            self.Slider1:SetGoal(0,0,0)            

        	self.Rotator1:SetTargetSpeed(30)

        	self:SetMaintenanceConsumptionActive()
        end
    end,

    OnScriptBitClear = function(self, bit)

        CStructureUnit.OnScriptBitClear(self, bit)

        if bit == 0 then 

        	self:SetMaintenanceConsumptionInactive()

            self.Slider1:SetGoal(0,-0.8,0)
  
        	self.Rotator1:SetTargetSpeed(0)

           	for k, v in self.AmbientEffectsBag do
               	v:Destroy()
                self.AmbientEffectsBag[k] = nil                    
			end
        end
    end,
	
    OnKilled = function(self, instigator, type, overkillRatio)

      	for k, v in self.AmbientEffectsBag do
           	v:Destroy()
		end
        
        self.AmbientEffectsBag = nil

        CStructureUnit.OnKilled(self, instigator, type, overkillRatio)

    end,
    
   	ResourceThread = function(self) 

    	if not self.Dead then

        	local energy = self:GetAIBrain():GetEconomyStored('Energy')

        	if  energy <= 600 then 

            	self:SetScriptBit('RULEUTC_ShieldToggle', false)
                
                self:RemoveToggleCap('RULEUTC_ShieldToggle')

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

                self:AddToggleCap('RULEUTC_ShieldToggle')
   
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