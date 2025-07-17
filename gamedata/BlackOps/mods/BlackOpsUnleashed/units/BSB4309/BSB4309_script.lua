local SStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local LOUDINSERT = table.insert

local CreateAttachedEmitter = CreateAttachedEmitter

BSB4309 = Class(SStructureUnit) {

	AntiTeleport = {'/effects/emitters/op_seraphim_quantum_jammer_tower_emit.bp'},

    AntiTeleportOrbs = {'/effects/emitters/seraphim_gate_04_emit.bp','/effects/emitters/seraphim_gate_05_emit.bp'},

    OnStopBeingBuilt = function(self,builder,layer)

    	SStructureUnit.OnStopBeingBuilt(self,builder,layer)
        
        self.Slider1 = CreateSlider( self, 'Big_Orb', 0, 0, 0, 0.26, true )
        self.Trash:Add(self.Slider1)
        
        self.Slider2 = CreateSlider( self, 'Spinner01', 0, 0, 0, 0.28, true )
        self.Trash:Add(self.Slider2)
        
        self.Slider3 = CreateSlider( self, 'Spinner02', 0, 0, 0, 0.28, true )
        self.Trash:Add(self.Slider3)
        
        self.Slider4 = CreateSlider( self, 'Array01', 0, 0, 0, 0.24, true )
        self.Trash:Add(self.Slider4)
    
       	self.Rotator1 = CreateRotator( self, 'Array01', 'y', nil, 0, 15, 80 )
        self.Trash:Add(self.Rotator1)
        self.Rotator1:SetAccel(40)

       	self.Rotator2 = CreateRotator(self, 'Spinner02', 'y', nil, 0, 15, 120 )
       	self.Trash:Add(self.Rotator2)
        self.Rotator2:SetAccel(50)

       	self.Rotator3 = CreateRotator(self, 'Spinner01', 'y', nil, 0, 15, 120 )
       	self.Trash:Add(self.Rotator3)
        self.Rotator3:SetAccel(40)

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

        for k, v in self.AntiTeleport do
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Light02', army, v ):ScaleEmitter(0.25):OffsetEmitter(0, -0.5, 0) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Big_Orb', army, v ):ScaleEmitter(0.18):OffsetEmitter(0, 0, 0) )
        end

        for k, v in self.AntiTeleportOrbs do
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Orb01', army, v ):ScaleEmitter(0.1):OffsetEmitter(0,-0.2, 0) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Orb01', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.2, 0) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Orb01', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0, 0.2) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Orb04', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0, 0.2) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Orb04', army, v ):ScaleEmitter(0.1):OffsetEmitter(0,-0.2, 0) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Orb04', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.2, 0) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Orb06', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0, 0.2) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Orb06', army, v ):ScaleEmitter(0.1):OffsetEmitter(0,-0.2, 0) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Orb06', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.2, 0) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Orb03', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0, 0.2) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Orb03', army, v ):ScaleEmitter(0.1):OffsetEmitter(0,-0.2, 0) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Orb03', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.2, 0) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Orb07', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0, 0.2) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Orb07', army, v ):ScaleEmitter(0.1):OffsetEmitter(0,-0.2, 0) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Orb07', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.2, 0) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Orb05', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0, 0.2) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Orb05', army, v ):ScaleEmitter(0.1):OffsetEmitter(0,-0.2, 0) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Orb05', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.2, 0) )
        end

    end,

    OnScriptBitSet = function(self, bit)

        SStructureUnit.OnScriptBitSet(self, bit)

        if bit == 0 then

            self:ForkThread(self.AntiteleportEffects)

            self:SetMaintenanceConsumptionActive()

            self.Slider1:SetGoal(0,0,0)            
            self.Slider2:SetGoal(0,0,0)
            self.Slider3:SetGoal(0,0,0)
            self.Slider4:SetGoal(0,0,0)

        	self.Rotator1:SetTargetSpeed(-160)
        	self.Rotator2:SetTargetSpeed(200)
        	self.Rotator3:SetTargetSpeed(-80)
        end
    end,

    OnScriptBitClear = function(self, bit)

        SStructureUnit.OnScriptBitClear(self, bit)

        if bit == 0 then 

        	self.Rotator1:SetTargetSpeed(0)
        	self.Rotator2:SetTargetSpeed(0)
        	self.Rotator3:SetTargetSpeed(0)

            self.Slider1:SetGoal(0,-1.6,0)            
            self.Slider2:SetGoal(0,-1.6,0)
            self.Slider3:SetGoal(0,-1.6,0)
            self.Slider4:SetGoal(0,-0.66,0)

           	for k, v in self.AmbientEffectsBag do
               	v:Destroy()
                self.AmbientEffectsBag[k] = nil                    
			end

            self:SetMaintenanceConsumptionInactive()
		end
	end,

    ResourceThread = function(self) 

    	if not self.Dead then

        	local energy = self:GetAIBrain():GetEconomyStored('Energy')

        	if  energy <= 650 then 

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

TypeClass = BSB4309