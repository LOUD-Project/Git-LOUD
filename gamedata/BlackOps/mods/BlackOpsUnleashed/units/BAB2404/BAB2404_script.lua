local ALandFactoryUnit = import('/lua/aeonunits.lua').ALandFactoryUnit

BAB2404 = Class(ALandFactoryUnit) {

	DeathThreadDestructionWaitTime = 8,
	
	BuildingEffect01 = {
        '/effects/emitters/light_blue_blinking_01_emit.bp',
    },
	
	BuildingEffect02 = {
        '/effects/emitters/light_red_03_emit.bp',
    },
	
	OnStopBeingBuilt = function(self,builder,layer)
        ALandFactoryUnit.OnStopBeingBuilt(self,builder,layer)
		self.BuildingEffect01Bag = {}
		self.BuildingEffect02Bag = {}
		--self.DroneTable = {}
		--LOG(repr(self.DroneTable))
        local mul = 1
        local sx = 1 or 1
    	local sz = 1 or 1
    	local sy = 1 or sx + sz
		
		local LOUDATTACHEMITTER = CreateAttachedEmitter
		
		local army = self:GetArmy()

        for i = 1, 16 do
            local fxname
            if i < 10 then
                fxname = 'Light0' .. i
            else
                fxname = 'Light' .. i
            end
            local fx = LOUDATTACHEMITTER(self, fxname, army, '/effects/emitters/light_yellow_02_emit.bp'):OffsetEmitter(0, 0, 0.01):ScaleEmitter(3)
            self.Trash:Add(fx)
        end
    end,
	
	OnStartBuild = function(self, unitBeingBuilt, order )
		ALandFactoryUnit.OnStartBuild(self, unitBeingBuilt, order )
			--supposed to define drone variable as the unit currently being built and then add it to the DroneTable
			local drone = unitBeingBuilt
			self.PetDrone = drone
			--LOG(repr(self.DroneTable))
            drone:SetParent(self)
			
			###Drone clean up scripts
            --self.Trash:Add(drone)
			if self.BuildingEffect01Bag then
				for k, v in self.BuildingEffect01Bag do
					v:Destroy()
				end
				self.BuildingEffect01Bag = {}
			end
            
            local army = self:GetArmy()
			local LOUDINSERT = table.insert
			local LOUDATTACHEMITTER = CreateAttachedEmitter
			
			for k, v in self.BuildingEffect01 do
				LOUDINSERT( self.BuildingEffect01Bag, LOUDATTACHEMITTER( self, 'BlinkyLight01', army, v ):OffsetEmitter(0, 0, 0.01):ScaleEmitter( 1.00 ) )
				LOUDINSERT( self.BuildingEffect01Bag, LOUDATTACHEMITTER( self, 'BlinkyLight02', army, v ):OffsetEmitter(0, 0, 0.01):ScaleEmitter( 1.00 ) )
				LOUDINSERT( self.BuildingEffect01Bag, LOUDATTACHEMITTER( self, 'BlinkyLight03', army, v ):OffsetEmitter(0, 0, 0.01):ScaleEmitter( 1.00 ) )
				LOUDINSERT( self.BuildingEffect01Bag, LOUDATTACHEMITTER( self, 'BlinkyLight04', army, v ):OffsetEmitter(0, 0, 0.01):ScaleEmitter( 1.00 ) )
				LOUDINSERT( self.BuildingEffect01Bag, LOUDATTACHEMITTER( self, 'BlinkyLight05', army, v ):OffsetEmitter(0, 0, 0.01):ScaleEmitter( 1.00 ) )
				LOUDINSERT( self.BuildingEffect01Bag, LOUDATTACHEMITTER( self, 'BlinkyLight06', army, v ):OffsetEmitter(0, 0, 0.01):ScaleEmitter( 1.00 ) )
				LOUDINSERT( self.BuildingEffect01Bag, LOUDATTACHEMITTER( self, 'BlinkyLight07', army, v ):OffsetEmitter(0, 0, 0.01):ScaleEmitter( 1.00 ) )
				LOUDINSERT( self.BuildingEffect01Bag, LOUDATTACHEMITTER( self, 'BlinkyLight08', army, v ):OffsetEmitter(0, 0, 0.01):ScaleEmitter( 1.00 ) )
			end
			if self.BuildingEffect02Bag then
				for k, v in self.BuildingEffect02Bag do
					v:Destroy()
				end
				self.BuildingEffect02Bag = {}
			end
			for k, v in self.BuildingEffect02 do
				LOUDINSERT( self.BuildingEffect02Bag, LOUDATTACHEMITTER( self, 'BlinkyLight09', army, v ):OffsetEmitter(0, 0, 0.01):ScaleEmitter( 1.00 ) )
				LOUDINSERT( self.BuildingEffect02Bag, LOUDATTACHEMITTER( self, 'BlinkyLight10', army, v ):OffsetEmitter(0, 0, 0.01):ScaleEmitter( 1.00 ) )
				LOUDINSERT( self.BuildingEffect02Bag, LOUDATTACHEMITTER( self, 'BlinkyLight11', army, v ):OffsetEmitter(0, 0, 0.01):ScaleEmitter( 1.00 ) )
				LOUDINSERT( self.BuildingEffect02Bag, LOUDATTACHEMITTER( self, 'BlinkyLight12', army, v ):OffsetEmitter(0, 0, 0.01):ScaleEmitter( 1.00 ) )
				LOUDINSERT( self.BuildingEffect02Bag, LOUDATTACHEMITTER( self, 'BlinkyLight13', army, v ):OffsetEmitter(0, 0, 0.01):ScaleEmitter( 1.00 ) )
				LOUDINSERT( self.BuildingEffect02Bag, LOUDATTACHEMITTER( self, 'BlinkyLight14', army, v ):OffsetEmitter(0, 0, 0.01):ScaleEmitter( 1.00 ) )
				LOUDINSERT( self.BuildingEffect02Bag, LOUDATTACHEMITTER( self, 'BlinkyLight15', army, v ):OffsetEmitter(0, 0, 0.01):ScaleEmitter( 1.00 ) )
				LOUDINSERT( self.BuildingEffect02Bag, LOUDATTACHEMITTER( self, 'BlinkyLight16', army, v ):OffsetEmitter(0, 0, 0.01):ScaleEmitter( 1.00 ) )
			end
	end,
	
	OnStopBuild = function(self, unitBeingBuilt, order )
		ALandFactoryUnit.OnStopBuild(self, unitBeingBuilt, order )
		self.PetDrone = nil
		if self.BuildingEffect01Bag then
            for k, v in self.BuildingEffect01Bag do
                v:Destroy()
            end
            self.BuildingEffect01Bag = {}
        end
		if self.BuildingEffect02Bag then
            for k, v in self.BuildingEffect02Bag do
                v:Destroy()
            end
            self.BuildingEffect02Bag = {}
        end
	end,
	
	FinishBuildThread = function(self, unitBeingBuilt, order )
		ALandFactoryUnit.FinishBuildThread(self, unitBeingBuilt, order )
		LOG('*SAT FINISHED BUILDING RESTRICT BUILD QUEUE')
		--LOG(repr(self.DroneTable))
			self:PlayUnitSound('LaunchSat')
			self:AddBuildRestriction( categories.BUILTBYSTATION )
	end,
	
	
	NotifyOfDroneDeath = function(self)
		### remove build restriction if sat has been lost
			LOG('*sat HAS BEEN LOST LETS MAKE ANOTHER')
			self.PetDrone = nil
			self:RemoveBuildRestriction( categories.BUILTBYSTATION )
	end,
    
	OnKilled = function(self, instigator, type, overkillRatio)
        ALandFactoryUnit.OnKilled(self, instigator, type, overkillRatio)
		LOG('*STATION IS DEAD DESTROY ANY ACTIVE SATS')
		--LOG(repr(self.DroneTable))
        #
		if self.PetDrone then
    --      kill self, using normal damage, and no overkill.
            self.PetDrone:Kill(self, 'Normal', 0)
            self.PetDrone = nil
        end
    end,

}

TypeClass = BAB2404