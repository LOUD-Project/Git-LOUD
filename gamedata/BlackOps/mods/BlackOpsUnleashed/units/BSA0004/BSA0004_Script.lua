local SAirUnit = import('/lua/defaultunits.lua').AirUnit

local WeaponsFile2 = import ('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua')

local YenzothaExperimentalLaser02 = WeaponsFile2.YenzothaExperimentalLaser02


BSA0004 = Class(SAirUnit) {

	Weapons = {
        BeamWeapon = Class(YenzothaExperimentalLaser02) {},
    },

	Carrier = nil,

	OnKilled = function(self, instigator, damagetype, overkillRatio)

		self.Carrier:NotifyOfDroneDeath(self.Name)
		self.Carrier = nil

		KillThread(self.HeartBeatThread)

		SAirUnit.OnKilled(self, instigator, damagetype, overkillRatio)
	end,

	OnDamage = function(self, instigator, amount, vector, damagetype)
    
		SAirUnit.OnDamage(self, instigator, amount, vector, damagetype)
        
		if self.Carrier.DroneData[self.Name] and (not self.Carrier.DroneData[self.Name].Damaged) and amount > 0 and amount < self:GetHealth() then
			self.Carrier.DroneData[self.Name].Damaged = true
		end
	end,
	
	OnStopBeingBuilt = function(self, builder, layer)

		SAirUnit.OnStopBeingBuilt(self, builder, layer)

		self.CapTable = {
			'RULEUCC_Attack',
			'RULEUCC_Guard',
			'RULEUCC_Move',
			'RULEUCC_Patrol',
			'RULEUCC_RetaliateToggle',
			'RULEUCC_Stop',
		}

		self.AwayFromCarrier = false

	end,

	SetParent = function(self, parent, droneName)
		self.Name = droneName
		self.Carrier = parent

		self.MaxRange           = self.Carrier.ControlRange	        --Distance from carrier at which drone is recalled
		self.ReturnRange        = self.Carrier.ReturnRange	        --Distance from carrier at which the returning drone is released
		self.HeartBeatInterval  = self.Carrier.HeartBeatInterval	--Time in seconds between monitor heartbeats
		
		self.HeartBeatThread = self:ForkThread(self.DroneLinkHeartbeat)
	end,

	DroneLinkHeartbeat = function(self)

		while ( self and not self.Dead ) and ( self.Carrier and not self.Carrier:IsDead() ) do

			local distance = self:GetDistanceFromAttachpoint()

			if distance > self.MaxRange and self.AwayFromCarrier == false then
				self:DroneRecall()

			elseif distance <= self.ReturnRange and self.AwayFromCarrier == true then
				self:DroneRelease()

			end

			WaitSeconds(self.HeartBeatInterval)
		end
	end,

	GetDistanceFromAttachpoint = function(self)

		local myPosition = self:GetPosition()
		local parentPosition = self.Carrier:GetPosition(self.Carrier.DroneData[self.Name].Attachpoint)
		local dist = VDist2(myPosition[1], myPosition[3], parentPosition[1], parentPosition[3])

		return dist
	end,

	DroneRecall = function(self, disableweapons)

		self.AwayFromCarrier = true

		self:SetSpeedMult(1.5)
		self:SetAccMult(1.5)
		self:SetTurnMult(2.0)

		if disableweapons and not self.WeaponsDisabled then

			for i = 1, self:GetWeaponCount() do 
				local wep = self:GetWeapon(i)
				wep:SetWeaponEnabled(false) 
				wep:AimManipulatorSetEnabled(false)
			end

			self.WeaponsDisabled = true

		end

		IssueStop({self})
		IssueClearCommands({self})

		for k, cap in self.CapTable do
			self:RemoveCommandCap(cap)
		end
	end,

	DroneRelease = function(self)

		self.AwayFromCarrier = false

		self:SetSpeedMult(1.0)
		self:SetAccMult(1.0)
		self:SetTurnMult(1.0)

		if self.WeaponsDisabled then

			for i = 1, self:GetWeaponCount() do 
				local wep = self:GetWeapon(i) 
				wep:SetWeaponEnabled(true) 
				wep:AimManipulatorSetEnabled(true)
			end

			self.WeaponsDisabled = false
		end

		self:RestoreCommandCaps()
	end,
	
}

TypeClass = BSA0004