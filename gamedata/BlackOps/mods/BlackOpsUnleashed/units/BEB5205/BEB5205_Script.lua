local TAirStagingPlatformUnit = import('/lua/terranunits.lua').TAirStagingPlatformUnit

local TANTorpedoLandWeapon = import('/lua/terranweapons.lua').TANTorpedoLandWeapon
local TAAFlakArtilleryCannon = import('/lua/terranweapons.lua').TAAFlakArtilleryCannon

local CreateRotator = CreateRotator
local CreateAttachedEmitter = CreateAttachedEmitter

BEB5205 = Class(TAirStagingPlatformUnit) {    
    Weapons = {
        FlakGun01 = Class(TAAFlakArtilleryCannon) {},
        FlakGun02 = Class(TAAFlakArtilleryCannon) {},
        FlakGun03 = Class(TAAFlakArtilleryCannon) {},
        FlakGun04 = Class(TAAFlakArtilleryCannon) {},
        TorpedoTurret01 = Class(TANTorpedoLandWeapon) {},
        TorpedoTurret02 = Class(TANTorpedoLandWeapon) {},
        TorpedoTurret03 = Class(TANTorpedoLandWeapon) {},
        TorpedoTurret04 = Class(TANTorpedoLandWeapon) {},
    },

    ShieldEffects = {
        '/effects/emitters/terran_shield_generator_t2_01_emit.bp',
        '/effects/emitters/terran_shield_generator_t2_02_emit.bp',
    },
    
    OnStopBeingBuilt = function(self,builder,layer)
	
        TAirStagingPlatformUnit.OnStopBeingBuilt(self,builder,layer)
		
		-- Drone Globals
        self.Side = 0
        self.DroneTable = {}
		self:ForkThread(self.InitialDroneSpawn)
        if not self.OpenAnim then
            self.OpenAnim = CreateAnimator(self)
            self.Trash:Add(self.OpenAnim)
            self.Rotator1 = CreateRotator(self, 'Spinner', 'y', nil, 10, 5, 10)
            self.Rotator2 = CreateRotator(self, 'B01', 'z', nil, -10, 5, -10)
            self.Trash:Add(self.Rotator1)
            self.Trash:Add(self.Rotator2)
		    self.ShieldEffectsBag = {}
			local layer = self:GetCurrentLayer()
			# If created with F2 on land
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
        end
        self.OpenAnim:PlayAnim(self:GetBlueprint().Display.AnimationOpen, false):SetRate(0.4)
    end,
	
	InitialDroneSpawn = function(self)
		-- spawning a number of drones times equal to the number preset by numcreate
		local numcreate = 4

		-- Randomly determines which launch bay will be the first to spawn a drone
		self.Side = Random(1,4)

		-- Short delay after the carrier has been built
		WaitSeconds(2)

		for i = 0, (numcreate -1) do
			self:ForkThread(self.SpawnDrone)
            ### Short delay between spawns to spread them out
			WaitSeconds(2)
		end
	end,
	
	SpawnDrone = function(self)

		WaitSeconds(5)
		
        -- Sets up local Variables used and spawns a drone at the parents location
        local myOrientation = self:GetOrientation()
		
        if self.Side == 1 then
            -- Gets the current position of the carrier launch bay in the game world
            local position = self:GetPosition('Station_01')

            ### Creates our drone in the left launch bay and directs the unit to face the same direction as its parent unit
            local drone = CreateUnitHPR('beb0005', self:GetArmy(), position.x, position.y, position.z, 0, 0, 0)
			drone:AttachTo(self, 'Station_01')
			### Adds the newly created drone to the parent carriers drone table
            table.insert (self.DroneTable, drone)

            ### Sets the Carrier unit as the drones parent
            drone:SetParent(self, 'beb5205')
            drone:SetCreator(self)

            ### Flips to the next spawn point
            self.Side = 2
			self:HideBone('Station_01', true)

            ###Drone clean up scripts
            self.Trash:Add(drone)

        elseif self.Side == 2 then
            ### Gets the current position of the carrier launch bay in the game world
            local position = self:GetPosition('Station_02')

            ### Creates our drone in the right launch bay and directs the unit to face the same direction as its parent unit
            local drone = CreateUnitHPR('beb0005', self:GetArmy(), position.x, position.y, position.z, 0, 0, 0)
			drone:AttachTo(self, 'Station_02')
			
            ### Adds the newly created drone to the parent carriers drone table
            table.insert (self.DroneTable, drone)
		
            ### Sets the Carrier unit as the drones parent
            drone:SetParent(self, 'beb5205')
            drone:SetCreator(self)

            ### Flips from the right to the left self.Side after a drone has been spawned
            self.Side = 3
			self:HideBone('Station_02', true)
			
            ###Drone clean up scripts
            self.Trash:Add(drone)

        elseif self.Side == 3 then
            ### Gets the current position of the carrier launch bay in the game world
            local position = self:GetPosition('Station_03')
		
            ### Creates our drone in the right launch bay and directs the unit to face the same direction as its parent unit
            local drone = CreateUnitHPR('beb0005', self:GetArmy(), position.x, position.y, position.z, 0, 0, 0)
			drone:AttachTo(self, 'Station_03')
			
            ### Adds the newly created drone to the parent carriers drone table
            table.insert (self.DroneTable, drone)

            ### Sets the Carrier unit as the drones parent
            drone:SetParent(self, 'beb5205')
            drone:SetCreator(self)

            ### Flips to the next spawn point
            self.Side = 4
			self:HideBone('Station_03', true)
			
            ###Drone clean up scripts
            self.Trash:Add(drone)

        elseif self.Side == 4 then
            ### Gets the current position of the carrier launch bay in the game world
            local position = self:GetPosition('Station_04')
	
            ### Creates our drone in the right launch bay and directs the unit to face the same direction as its parent unit
            local drone = CreateUnitHPR('beb0005', self:GetArmy(), position.x, position.y, position.z, 0, 0, 0)
			drone:AttachTo(self, 'Station_04')
			
            ### Adds the newly created drone to the parent carriers drone table
            table.insert (self.DroneTable, drone)

            ### Sets the Carrier unit as the drones parent
            drone:SetParent(self, 'beb5205')
            drone:SetCreator(self)

            ### Flips back to the first spawn point
            self.Side = 1
			self:HideBone('Station_04', true)

            ###Drone clean up scripts
            self.Trash:Add(drone)
        end
	end,
    
     OnShieldEnabled = function(self)
        TAirStagingPlatformUnit.OnShieldEnabled(self)
        if self.Rotator1 then
            self.Rotator1:SetTargetSpeed(10)
        end
        if self.Rotator2 then
            self.Rotator2:SetTargetSpeed(-10)
        end
        
        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
		
		local CreateAttachedEmitter = CreateAttachedEmitter
		
        for k, v in self.ShieldEffects do
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 'Shield_Base', self:GetArmy(), v ) )
        end
    end,

    OnShieldDisabled = function(self)
        TAirStagingPlatformUnit.OnShieldDisabled(self)
        self.Rotator1:SetTargetSpeed(0)
        self.Rotator2:SetTargetSpeed(0)
        
        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
    end,
	
	OnKilled = function(self)
		self:HideBone('Station_01', false)
		self:HideBone('Station_02', false)
		self:HideBone('Station_03', false)
		self:HideBone('Station_04', false)
        if table.getn({self.DroneTable}) > 0 then
            for k, v in self.DroneTable do
                IssueClearCommands({self.DroneTable[k]})
                IssueKillSelf({self.DroneTable[k]})
            end
        end
        TAirStagingPlatformUnit.OnKilled(self)
    end,
    
}


TypeClass = BEB5205