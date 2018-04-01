local CAirStagingPlatformUnit = import('/lua/cybranunits.lua').CAirStagingPlatformUnit
local CAABurstCloudFlakArtilleryWeapon = import('/lua/cybranweapons.lua').CAABurstCloudFlakArtilleryWeapon
local CANNaniteTorpedoWeapon = import('/lua/cybranweapons.lua').CANNaniteTorpedoWeapon


BRB5205 = Class(CAirStagingPlatformUnit) {
	Weapons = {
        TorpedoTurret01 = Class(CANNaniteTorpedoWeapon) {},
        TorpedoTurret02 = Class(CANNaniteTorpedoWeapon) {},
        TorpedoTurret03 = Class(CANNaniteTorpedoWeapon) {},
        TorpedoTurret04 = Class(CANNaniteTorpedoWeapon) {},
        FlakGun01 = Class(CAABurstCloudFlakArtilleryWeapon) {},
        FlakGun02 = Class(CAABurstCloudFlakArtilleryWeapon) {},
        FlakGun03 = Class(CAABurstCloudFlakArtilleryWeapon) {},
        FlakGun04 = Class(CAABurstCloudFlakArtilleryWeapon) {},
    },
	
	OnStopBeingBuilt = function(self)
	
		CAirStagingPlatformUnit.OnStopBeingBuilt(self)

        self:SetMaintenanceConsumptionInactive()
		self:SetScriptBit('RULEUTC_CloakToggle', true)		#-- turn OFF cloak field
        self:RequestRefreshUI()
		
		local layer = self:GetCurrentLayer()
		
		### Drone Globals
        self.Side = 0
        self.DroneTable = {}
		self:ForkThread(self.InitialDroneSpawn)
		
        if(layer == 'Land') then
			# Disable Naval weapons
	        self:SetWeaponEnabledByLabel('TorpedoTurret01', false)
	        self:SetWeaponEnabledByLabel('TorpedoTurret02', false)
	        self:SetWeaponEnabledByLabel('TorpedoTurret03', false)
	        self:SetWeaponEnabledByLabel('TorpedoTurret04', false)
        elseif (layer == 'Water') then
			# Enable Naval Weapons
	        self:SetWeaponEnabledByLabel('TorpedoTurret01', true)
	        self:SetWeaponEnabledByLabel('TorpedoTurret02', true)
	        self:SetWeaponEnabledByLabel('TorpedoTurret03', true)
	        self:SetWeaponEnabledByLabel('TorpedoTurret04', true)
        end
		
	end,
	
	InitialDroneSpawn = function(self)
		### spawning a number of drones times equal to the number preset by numcreate
#    	LOG('*SPAWNING FIRST SET OF DRONES')
		local numcreate = 4

		### Randomly determines which launch bay will be the first to spawn a drone
		self.Side = Random(1,4)

		### Short delay after the carrier has been built
		WaitSeconds(2)

		for i = 0, (numcreate -1) do
			self:ForkThread(self.SpawnDrone)
            ### Short delay between spawns to spread them out
			WaitSeconds(2)
		end
	end,
	
	SpawnDrone = function(self)
    ### Small respawn delay so the drones are not instantly respawned after death
#    LOG('*RESPAWNING LOST DRONES')
    --Mithy: This needs to be longer than one second
    WaitSeconds(5)
		
        ### Sets up local Variables used and spawns a drone at the parents location
        local myOrientation = self:GetOrientation()
		--local position = self:GetPosition()
        if self.Side == 1 then
            ### Gets the current position of the carrier launch bay in the game world
            local position = self:GetPosition('xrb01')

            ### Creates our drone in the left launch bay and directs the unit to face the same direction as its parent unit
            local drone = CreateUnitHPR('brb0004', self:GetArmy(), position.x, position.y, position.z, 0, 0, 0)
			drone:AttachTo(self, 'xrb01')
			### Adds the newly created drone to the parent carriers drone table
            table.insert (self.DroneTable, drone)

            ### Sets the Carrier unit as the drones parent
            drone:SetParent(self, 'brb5205')
            drone:SetCreator(self)

            ### Flips to the next spawn point
            self.Side = 2
			self:HideBone('xrb01', true)

            ###Drone clean up scripts
            self.Trash:Add(drone)

        elseif self.Side == 2 then
            ### Gets the current position of the carrier launch bay in the game world
            local position = self:GetPosition('xrb02')

            ### Creates our drone in the right launch bay and directs the unit to face the same direction as its parent unit
            local drone = CreateUnitHPR('brb0004', self:GetArmy(), position.x, position.y, position.z, 0, 0, 0)
			drone:AttachTo(self, 'xrb02')
			
            ### Adds the newly created drone to the parent carriers drone table
            table.insert (self.DroneTable, drone)
		
            ### Sets the Carrier unit as the drones parent
            drone:SetParent(self, 'brb5205')
            drone:SetCreator(self)

            ### Flips from the right to the left self.Side after a drone has been spawned
            self.Side = 3
			self:HideBone('xrb02', true)
			
            ###Drone clean up scripts
            self.Trash:Add(drone)

        elseif self.Side == 3 then
            ### Gets the current position of the carrier launch bay in the game world
            local position = self:GetPosition('xrb03')
		
            ### Creates our drone in the right launch bay and directs the unit to face the same direction as its parent unit
            local drone = CreateUnitHPR('brb0004', self:GetArmy(), position.x, position.y, position.z, 0, 0, 0)
			drone:AttachTo(self, 'xrb03')
			
            ### Adds the newly created drone to the parent carriers drone table
            table.insert (self.DroneTable, drone)

            ### Sets the Carrier unit as the drones parent
            drone:SetParent(self, 'brb5205')
            drone:SetCreator(self)

            ### Flips to the next spawn point
            self.Side = 4
			self:HideBone('xrb03', true)
			
            ###Drone clean up scripts
            self.Trash:Add(drone)

        elseif self.Side == 4 then
            ### Gets the current position of the carrier launch bay in the game world
            local position = self:GetPosition('xrb04')
	
            ### Creates our drone in the right launch bay and directs the unit to face the same direction as its parent unit
            local drone = CreateUnitHPR('brb0004', self:GetArmy(), position.x, position.y, position.z, 0, 0, 0)
			drone:AttachTo(self, 'xrb04')
			
            ### Adds the newly created drone to the parent carriers drone table
            table.insert (self.DroneTable, drone)

            ### Sets the Carrier unit as the drones parent
            drone:SetParent(self, 'brb5205')
            drone:SetCreator(self)

            ### Flips back to the first spawn point
            self.Side = 1
			self:HideBone('xrb04', true)

            ###Drone clean up scripts
            self.Trash:Add(drone)
        end
	end,

	OnKilled = function(self)
		self:HideBone('xrb01', false)
		self:HideBone('xrb02', false)
		self:HideBone('xrb03', false)
		self:HideBone('xrb04', false)
        if table.getn({self.DroneTable}) > 0 then
            for k, v in self.DroneTable do
                IssueClearCommands({self.DroneTable[k]})
                IssueKillSelf({self.DroneTable[k]})
            end
        end
        CAirStagingPlatformUnit.OnKilled(self)
    end,

}

TypeClass = BRB5205