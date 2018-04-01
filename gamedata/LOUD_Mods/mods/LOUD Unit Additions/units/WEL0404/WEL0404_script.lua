local ExperimentalMobileUnit = import('/lua/terranunits.lua').TLandUnit

local DefaultProjectileWeapon = import('/lua/terranweapons.lua').TDFLandGaussCannonWeapon

local Utilities = import('/lua/utilities.lua')

WEL0404 = Class(ExperimentalMobileUnit) {

	Weapons = {
	
		MainTurret01 = Class(DefaultProjectileWeapon) {},
		RightTurret01 = Class(DefaultProjectileWeapon) {},
		RightTurret02 = Class(DefaultProjectileWeapon) {},
		LeftTurret01 = Class(DefaultProjectileWeapon) {},
		LeftTurret02 = Class(DefaultProjectileWeapon) {},
    },


	OnStopBeingBuilt = function(self,builder,layer)
	
		ExperimentalMobileUnit.OnStopBeingBuilt(self,builder,layer)
		
		self.TreadManipulators = {}
		self.AmbientEffectsBag = {}

		self.TreadBlock01 = CreateRotator(self, 'Tread01', 'y', nil)
		self.TreadBlock02 = CreateRotator(self, 'Tread02', 'y', nil)
		self.TreadBlock03 = CreateRotator(self, 'Tread03', 'y', nil)
		self.TreadBlock04 = CreateRotator(self, 'Tread04', 'y', nil)

		self.Trash:Add(self.TreadBlock01)  
		self.Trash:Add(self.TreadBlock02) 
		self.Trash:Add(self.TreadBlock03) 
		self.Trash:Add(self.TreadBlock04) 

		self.TreadBlock01:SetCurrentAngle(0)
		self.TreadBlock02:SetCurrentAngle(0)
		self.TreadBlock03:SetCurrentAngle(0)
		self.TreadBlock04:SetCurrentAngle(0)

		self:ForkThread(self.TreadManipulationThread)
		-- Exhaust smoke effects
		--table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'UUX0101', self:GetArmy(), '/effects/emitters/units/uef/uux0101/ambient/uux0101_01_smoke_emit.bp' ) )
	end,
	
	TreadManipulationThread = function(self)
	
		local GoalAngle = 0
		local nav=self:GetNavigator()
		
		while not self:IsDead() do
		
			local target=nav:GetCurrentTargetPos()
			local MyPos=self:GetPosition()
			
			target.y=0
			target.x=target.x-MyPos.x
			target.z=target.z-MyPos.z
			target=Utilities.NormalizeVector(target)
			
			GoalAngle=(math.atan2(target.x,target.z)-self:GetHeading())*180/math.pi

			self.TreadBlock01:SetSpeed(100)
			self.TreadBlock02:SetSpeed(100)
			self.TreadBlock03:SetSpeed(100)
			self.TreadBlock04:SetSpeed(100)
			
			self.TreadBlock01:SetGoal(GoalAngle)
			self.TreadBlock02:SetGoal(GoalAngle)
			self.TreadBlock03:SetGoal(-GoalAngle)
			self.TreadBlock04:SetGoal(-GoalAngle)
			
			WaitSeconds(0.25)
		end
		
	end,
}

TypeClass = WEL0404