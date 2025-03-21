local AAirUnit = import('/lua/defaultunits.lua').AirUnit

local WeaponsFile = import('/lua/aeonweapons.lua')

local ADFCannonOblivionWeapon = WeaponsFile.ADFCannonOblivionWeapon02
local AANDepthChargeBombWeapon = WeaponsFile.AANDepthChargeBombWeapon
local ADFQuantumAutogunWeapon = WeaponsFile.ADFQuantumAutogunWeapon

WeaponsFile = nil

BAA0001 = Class(AAirUnit) {

    Weapons = {
	
        MainGun = Class(import('/lua/aeonweapons.lua').ADFCannonOblivionWeapon) {
			FxMuzzleFlash = {
				'/effects/emitters/oblivion_cannon_flash_04_emit.bp',
				'/effects/emitters/oblivion_cannon_flash_05_emit.bp',				
				'/effects/emitters/oblivion_cannon_flash_06_emit.bp',
			},        
        },
		
        BlazeGun = Class(ADFQuantumAutogunWeapon) {},
        Depthcharge = Class(AANDepthChargeBombWeapon) {},
		
    },

    OnStopBeingBuilt = function(self, builder, layer)
	
		AAirUnit.OnStopBeingBuilt(self, builder, layer)
		
		self.AnimManip = CreateAnimator(self)
        self.Trash:Add(self.AnimManip)
        self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationTakeOff, false):SetRate(1)
		
        if not self.OpenAnim then
            self.OpenAnim = CreateAnimator(self)
            self.Trash:Add(self.OpenAnim)
        end
		
		--Table of all command caps the drone may have available, for recall lockdown
		self.CapTable = {
			'RULEUCC_Attack',
			'RULEUCC_Guard',
			'RULEUCC_Move',
			'RULEUCC_Patrol',
			'RULEUCC_RetaliateToggle',
			'RULEUCC_Stop',
		}
		
		--Flags drone as being recalled
		self.AwayFromCarrier = false
		
	end,
	
	OnMotionVertEventChange = function(self, new, old)
	
        #LOG( 'OnMotionVertEventChange, new = ', new, ', old = ', old )
		
        AAirUnit.OnMotionVertEventChange(self, new, old)
		
        --Aborting a landing
        if ((new == 'Top' or new == 'Up') and old == 'Down') then
            self.AnimManip:SetRate(-1)
        elseif (new == 'Down') then
            self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationLand, false):SetRate(1)
        elseif (new == 'Up') then
            self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationTakeOff, false):SetRate(1)
        end
		
    end,
	
	Carrier = nil,

	OnKilled = function(self, instigator, damagetype, overkillRatio)
	
		--Notify the carrier of our death
		self.Carrier:NotifyOfDroneDeath(self.Name)
		self.Carrier = nil
		
		--Kill our heartbeat thread
		KillThread(self.HeartBeatThread)
		AAirUnit.OnKilled(self, instigator, damagetype, overkillRatio)
		
	end,
	
	--Flags drone as damaged when hit
	OnDamage = function(self, instigator, amount, vector, damagetype)
	
		AAirUnit.OnDamage(self, instigator, amount, vector, damagetype)
		
		if not self.Carrier.DroneData[self.Name].Damaged and amount > 0 and amount < self:GetHealth() then
		
			self.Carrier.DroneData[self.Name].Damaged = true
			
		end
		
	end,
	
	--Called on us by the carrier after creation, sets our name, parent ref and control variables
	SetParent = function(self, parent, droneName)
		self.Name = droneName
		self.Carrier = parent
		
		--Heartbeat globals
		self.MaxRange = self.Carrier.ControlRange	--Distance from the carrier at which the drone is recalled
		self.ReturnRange = self.Carrier.ReturnRange	--Distance from the carrier at which the returning drone is released
		self.HeartBeatInterval = self.Carrier.HeartBeatInterval	--Time in seconds between monitor heartbeats
		
		--Start our monitor heartbeat thread
		self.HeartBeatThread = self:ForkThread(self.DroneLinkHeartbeat)
	end,

	--Monitors drone distance from the carrier, issuing recalls and releases as necessary
	DroneLinkHeartbeat = function(self)
		while ( self and not self:IsDead() ) and ( self.Carrier and not self.Carrier:IsDead() ) do
			local distance = self:GetDistanceFromAttachpoint()
			if distance > self.MaxRange and self.AwayFromCarrier == false then
				self:DroneRecall()
				--LOG("Mithy: Drone - Out of range, being recalled: " .. self.Name)
			elseif distance <= self.ReturnRange and self.AwayFromCarrier == true then
				self:DroneRelease()
				--LOG("Mithy: Drone - Back in range, being released: " .. self.Name)
			end
			WaitSeconds(self.HeartBeatInterval)
		end
	end,

	--Returns the drone's horizontal distance from its original attach point, used for all distance checks
	GetDistanceFromAttachpoint = function(self)
		local myPosition = self:GetPosition()
		local parentPosition = self.Carrier:GetPosition(self.Carrier.DroneData[self.Name].Attachpoint)
		local dist = VDist2(myPosition[1], myPosition[3], parentPosition[1], parentPosition[3])
		return dist
	end,

	--Locks drone down and returns it to the carrier - also called in the carrier script by the recall button
	DroneRecall = function(self, disableweapons)
		self.AwayFromCarrier = true
		--Accelerate the drone for return
		self:SetSpeedMult(2.0)
		self:SetAccMult(2.0)
		self:SetTurnMult(2.0)
		--Temporarily disable weapons, if requested
		if disableweapons and not self.WeaponsDisabled then
			for i = 1, self:GetWeaponCount() do 
				local wep = self:GetWeapon(i)
				wep:SetWeaponEnabled(false) 
				wep:AimManipulatorSetEnabled(false)
			end
			self.WeaponsDisabled = true
		end
		--Halt the drone and clear its orders - the drone will immediately attempt to return
		IssueStop({self})
		IssueClearCommands({self})
		--Lock the drone's command input until it's back in the specified control range
		for k, cap in self.CapTable do
			self:RemoveCommandCap(cap)
		end
	end,
	
	--Cancels drone lockdown and returns it to normal speed
	DroneRelease = function(self)
		self.AwayFromCarrier = false
		--Restore standard mobility
		self:SetSpeedMult(1.0)
		self:SetAccMult(1.0)
		self:SetTurnMult(1.0)
		--Re-enable weapons, if disabled
		if self.WeaponsDisabled then
			for i = 1, self:GetWeaponCount() do 
				local wep = self:GetWeapon(i) 
				wep:SetWeaponEnabled(true) 
				wep:AimManipulatorSetEnabled(true)
			end
			self.WeaponsDisabled = false
		end
		--Cancel drone lockdown, re-enable command caps
		self:RestoreCommandCaps()
	end,
}

TypeClass = BAA0001